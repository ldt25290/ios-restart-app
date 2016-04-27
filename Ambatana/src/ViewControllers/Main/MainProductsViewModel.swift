//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result

protocol MainProductsViewModelDelegate: BaseViewModelDelegate {
    func vmDidSearch(searchViewModel: MainProductsViewModel)
    func vmShowFilters(filtersVM: FiltersViewModel)
    func vmShowTags(tags: [FilterTag])
    func vmDidFailRetrievingProducts(hasProducts hasProducts: Bool, error: String?)
    func vmDidSuceedRetrievingProducts(hasProducts hasProducts: Bool, isFirstPage: Bool)
    func vmShowProduct(productVC: UIViewController)
}

protocol InfoBubbleDelegate: class {
    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, updatedBubbleInfoString: String)
    func mainProductsViewModel(mainProductsViewModel: MainProductsViewModel, shouldHideBubble hidden: Bool)
}

protocol PermissionsDelegate: class {
    func mainProductsViewModelShowPushPermissionsAlert(mainProductsViewModel: MainProductsViewModel)
}


class MainProductsViewModel: BaseViewModel {
    
    // > Input
    var searchString: String?
    var filters: ProductFilters
    
    var infoBubblePresent: Bool {
        guard let selectedOrdering = filters.selectedOrdering else { return true }
        switch (selectedOrdering) {
        case .Distance, .Creation:
            return true
        case .PriceAsc, .PriceDesc:
            return false
        }
    }

    let infoBubbleDefaultText =  LGLocalizedString.productPopularNearYou
    
    var tags: [FilterTag] {
        
        var resultTags : [FilterTag] = []
        for prodCat in filters.selectedCategories {
            resultTags.append(.Category(prodCat))
        }
        if let place = filters.place {
            resultTags.append(.Location(place))
        }
        if filters.selectedWithin != ProductTimeCriteria.defaultOption {
            resultTags.append(.Within(filters.selectedWithin))
        }
        if let selectedOrdering = filters.selectedOrdering where selectedOrdering != ProductSortCriteria.defaultOption {
            resultTags.append(.OrderBy(selectedOrdering))
        }
        return resultTags
    }
    
    // Manager & repositories
    private let myUserRepository: MyUserRepository
    private let locationManager: LocationManager
    private let tracker: Tracker
    
    // > Delegate
    weak var delegate: MainProductsViewModelDelegate?
    weak var bubbleDelegate: InfoBubbleDelegate?
    weak var permissionsDelegate: PermissionsDelegate?

    // List VM
    let listViewModel: ProductListViewModel
    private var productListRequester: FilteredProductListRequester
    private var shouldRetryLoad = false
    private var lastReceivedLocation: LGLocation?
    private var bubbleDistance: Float = 1

    // Search tracking state
    private var shouldTrackSearch = false
    
    // MARK: - Lifecycle
    
    init(myUserRepository: MyUserRepository, locationManager: LocationManager, tracker: Tracker,
                searchString: String? = nil, filters: ProductFilters) {
        self.myUserRepository = myUserRepository
        self.locationManager = locationManager
        self.tracker = tracker
        self.searchString = searchString
        self.filters = filters
        self.productListRequester = FilteredProductListRequester()
        self.listViewModel = ProductListViewModel(requester: self.productListRequester)
        if let search = searchString where !search.isEmpty {
            self.shouldTrackSearch = true
        }
        super.init()

        setup()
    }
    
    convenience init(searchString: String? = nil, filters: ProductFilters) {
        let myUserRepository = Core.myUserRepository
        let locationManager = Core.locationManager
        let tracker = TrackerProxy.sharedInstance
        self.init(myUserRepository: myUserRepository, locationManager: locationManager, tracker: tracker,
                  searchString: searchString, filters: filters)
    }
    
    convenience init(searchString: String? = nil) {
        let filters = ProductFilters()
        self.init(searchString: searchString, filters: filters)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didBecomeActive() {
        guard let currentLocation = locationManager.currentLocation else { return }
        retrieveProductsIfNeededWithNewLocation(currentLocation)
    }

    
    // MARK: - Public methods
    
    /**
        Search action.
    */
    func search() {
        if let actualSearchString = searchString {
            if actualSearchString.characters.count > 0 {
                delegate?.vmDidSearch(viewModelForSearch())
            }
        }
    }

    func productListViewDidSucceedRetrievingProductsForPage(page: UInt, hasProducts: Bool) {
        // Should track search-complete only for the first page and only the first time
        guard let actualSearchString = searchString where shouldTrackSearch && page == 0 && filters.isDefault()
            else { return }
        shouldTrackSearch = false
        tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: actualSearchString,
            success: hasProducts ? .Success : .Failed))
    }

    func showFilters() {

        let filtersVM = FiltersViewModel(currentFilters: filters ?? ProductFilters())
        filtersVM.dataDelegate = self
        
        delegate?.vmShowFilters(filtersVM)
        
        // Tracking
        tracker.trackEvent(TrackerEvent.filterStart())
    }

    func shareDelegateForProduct(product: Product) -> MainProductsViewModelShareDelegate? {
        return MainProductsViewModelShareDelegate(product: product, myUser: myUserRepository.myUser)
    }

    func chatViewModelForProduct(product: Product) -> OldChatViewModel? {
        guard let chatVM = OldChatViewModel(product: product) else { return nil }
        chatVM.askQuestion = .ProductList
        return chatVM
    }
    
    /**
        Called when search button is pressed.
    */
    func searchBegan() {
        // Tracking
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
    }
    
    /**
        Called when a filter gets removed
    */
    func updateFiltersFromTags(tags: [FilterTag]) {

        var place: Place? = nil
        var categories: [ProductCategory] = []
        var orderBy = ProductSortCriteria.defaultOption
        var within = ProductTimeCriteria.defaultOption
        
        for filterTag in tags {
            switch filterTag {
            case .Location(let thePlace):
                place = thePlace
            case .Category(let prodCategory):
                categories.append(prodCategory)
            case .OrderBy(let prodSortOption):
                orderBy = prodSortOption
            case .Within(let prodTimeOption):
                within = prodTimeOption
            }
        }

        filters.place = place
        filters.selectedCategories = categories
        filters.selectedOrdering = orderBy
        filters.selectedWithin = within
        
        updateListView()
    }


    // MARK: - Private methods

    private func setup() {
        listViewModel.dataDelegate = self
        applyProductFilters()

        setupSessionAndLocation()
    }

    private func applyProductFilters() {
        productListRequester.filters = filters
        productListRequester.queryString = searchString
    }
    
    /**
        Returns a view model for search.
    
        - returns: A view model for search.
    */
    private func viewModelForSearch() -> MainProductsViewModel {
        return MainProductsViewModel(searchString: searchString, filters: filters)
    }
    
    private func updateListView() {
        if filters.selectedOrdering == ProductSortCriteria.defaultOption {
            bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: LGLocalizedString.productPopularNearYou)
        }

        applyProductFilters()
        listViewModel.refresh()
    }
    
    private func bubbleInfoTextForDistance(distance: Int, type: DistanceType) -> String {
        let distanceString = String(format: "%d %@", arguments: [min(Constants.productListMaxDistanceLabel, distance),
            type.string])
        if distance <= Constants.productListMaxDistanceLabel {
            return LGLocalizedString.productDistanceXFromYou(distanceString)
        } else {
            return LGLocalizedString.productDistanceMoreThanFromYou(distanceString)
        }
    }
}


// MARK: - FiltersViewModelDataDelegate

extension MainProductsViewModel: FiltersViewModelDataDelegate {

    func viewModelDidUpdateFilters(viewModel: FiltersViewModel, filters: ProductFilters) {
        self.filters = filters
        delegate?.vmShowTags(tags)
        updateListView()
    }
}


// MARK: - ProductListViewCellsDelegate 

extension MainProductsViewModel: ProductListViewCellsDelegate {
    func visibleTopCellWithIndex(index: Int, whileScrollingDown scrollingDown: Bool) {
        guard let sortCriteria = filters.selectedOrdering else { return }

        switch (sortCriteria) {
        case .Distance:
            guard let topProduct = listViewModel.productAtIndex(index) else { return }
            let distance = Float(productListRequester.distanceFromProductCoordinates(topProduct.location))

            // instance var max distance or MIN distance to avoid updating the label everytime
            if (scrollingDown && distance > bubbleDistance) || (!scrollingDown && distance < bubbleDistance) ||
                listViewModel.refreshing {
                bubbleDistance = distance
            }
            let distanceString = bubbleInfoTextForDistance(max(1,Int(round(bubbleDistance))),
                                                           type: DistanceType.systemDistanceType())
            bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: distanceString)
        case .Creation:
            bubbleDelegate?.mainProductsViewModel(self, updatedBubbleInfoString: LGLocalizedString.productPopularNearYou)
        case .PriceAsc, .PriceDesc:
            break
        }
    }

    func visibleBottomCell(index: Int) {
        guard index == Constants.itemIndexPushPermissionsTrigger else { return }
        permissionsDelegate?.mainProductsViewModelShowPushPermissionsAlert(self)
    }

    func pullingToRefresh(refreshing: Bool) {
        bubbleDelegate?.mainProductsViewModel(self, shouldHideBubble: refreshing)
    }
}


// MARK: - ProductListViewModelDataDelegate

extension MainProductsViewModel: ProductListViewModelDataDelegate {
    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt,
                              hasProducts: Bool) {
        if page == 0 && !hasProducts {
            let errImage: UIImage?
            let errTitle: String?
            let errBody: String?

            // Search
            if productListRequester.queryString != nil || productListRequester.hasFilters() {
                errImage = UIImage(named: "err_search_no_products")
                errTitle = LGLocalizedString.productSearchNoProductsTitle
                errBody = LGLocalizedString.productSearchNoProductsBody
            } else {
                // Listing
                errImage = UIImage(named: "err_list_no_products")
                errTitle = LGLocalizedString.productListNoProductsTitle
                errBody = LGLocalizedString.productListNoProductsBody
            }

            listViewModel.state = .Error(errImage: errImage, errTitle: errTitle, errBody: errBody, errButTitle: nil,
                                         errButAction: nil)
        }

        if page == 0 {
            let trackerEvent = TrackerEvent.productList(myUserRepository.myUser,
                                                        categories: productListRequester.filters?.selectedCategories,
                                                        searchQuery: productListRequester.queryString)
            tracker.trackEvent(trackerEvent)
        }

        if shouldRetryLoad {
            // in case the user allows sensors while loading the product list with the iplookup parameters
            shouldRetryLoad = false
            listViewModel.retrieveProducts()
        }
        delegate?.vmDidSuceedRetrievingProducts(hasProducts: hasProducts, isFirstPage: page == 0)
        if(page == 0) {
            bubbleDistance = 1
        }
    }

    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt,
                              hasProducts: Bool, error: RepositoryError) {
        if page == 0 && !hasProducts {
            let errImage: UIImage?
            let errTitle: String
            let errBody: String
            let errButTitle: String
            switch error {
            case .Network:
                errImage = UIImage(named: "err_network")
                errTitle = LGLocalizedString.commonErrorTitle
                errBody = LGLocalizedString.commonErrorNetworkBody
                errButTitle = LGLocalizedString.commonErrorRetryButton
            case .Internal, .Unauthorized, .NotFound:
                errImage = UIImage(named: "err_generic")
                errTitle = LGLocalizedString.commonErrorTitle
                errBody = LGLocalizedString.commonErrorGenericBody
                errButTitle = LGLocalizedString.commonErrorRetryButton
            }

            let errButAction: () -> Void = { [weak viewModel] in
                viewModel?.refresh()
            }

            listViewModel.state = .Error(errImage: errImage, errTitle: errTitle, errBody: errBody,
                                         errButTitle: errButTitle, errButAction: errButAction)
        }

        var errorString: String? = nil
        if hasProducts && page > 0 {
            switch error {
            case .Network:
                errorString = LGLocalizedString.toastNoNetwork
            case .Internal, .NotFound:
                errorString = LGLocalizedString.toastErrorInternal
            case .Unauthorized:
                errorString = nil
            }
        }
        delegate?.vmDidFailRetrievingProducts(hasProducts: hasProducts, error: errorString)
    }

    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?, originFrame: CGRect?) {
        guard let product = viewModel.productAtIndex(index) else { return }
        guard let productVC = ProductDetailFactory.productDetailFromProduct(product, thumbnailImage: thumbnailImage,
                                                                            originFrame: originFrame) else { return }
        delegate?.vmShowProduct(productVC)
    }
}


// MARK: - Session & Location handling

extension MainProductsViewModel {
    private func setupSessionAndLocation() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionDidChange),
                                                         name: SessionManager.Notification.Logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationDidChange),
                                                         name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)
    }

    dynamic private func sessionDidChange() {
        guard listViewModel.canRetrieveProducts else {
            shouldRetryLoad = true
            return
        }
        listViewModel.retrieveProducts()
    }

    dynamic private func locationDidChange() {
        guard let newLocation = locationManager.currentLocation else { return }

        // Tracking: when a new location is received and has different type than previous one
        if lastReceivedLocation?.type != newLocation.type {
            let locationServiceStatus = locationManager.locationServiceStatus
            let trackerEvent = TrackerEvent.location(newLocation, locationServiceStatus: locationServiceStatus)
            tracker.trackEvent(trackerEvent)
        }

        // Retrieve products (should be place after tracking, as it updates lastReceivedLocation)
        retrieveProductsIfNeededWithNewLocation(newLocation)
    }

    private func retrieveProductsIfNeededWithNewLocation(newLocation: LGLocation) {

        var shouldUpdate = false
        if listViewModel.canRetrieveProducts {
            // If there are no products, then refresh
            if listViewModel.numberOfProducts == 0 {
                shouldUpdate = true
            }
            // If new location is manual OR last location was manual, and location has changed then refresh
            else if newLocation.type == .Manual || lastReceivedLocation?.type == .Manual {
                if let lastReceivedLocation = lastReceivedLocation where newLocation != lastReceivedLocation {
                    shouldUpdate = true
                }
            }
            // If new location is not manual and we improved the location type to sensors
            else if lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
                shouldUpdate = true
            }
        } else if listViewModel.numberOfProducts == 0 && lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
            // in case the user allows sensors while loading the product list with the iplookup parameters
            shouldRetryLoad = true
        }

        if shouldUpdate{
            listViewModel.retrieveProducts()
        }

        // Track the received location
        lastReceivedLocation = newLocation
    }
}


//MARK: - NativeShareDelegate

public class MainProductsViewModelShareDelegate: NativeShareDelegate {

    let sharingProduct: Product
    var shareText: String {
        return SocialHelper.socialMessageWithTitle(LGLocalizedString.productShareBody,
            product: sharingProduct).nativeShareText
    }

    init(product: Product, myUser: MyUser?) {
        self.sharingProduct = product
    }

    func nativeShareInFacebook() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Facebook,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func nativeShareInTwitter() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Twitter,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func nativeShareInEmail() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Email,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    func nativeShareInWhatsApp() {
        let trackerEvent = TrackerEvent.productShare(sharingProduct, network: .Whatsapp,
            buttonPosition: .None, typePage: .ProductList)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
}
