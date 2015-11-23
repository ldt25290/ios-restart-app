//
//  ProductViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import FBSDKShareKit
import LGCoreKit
import Result

public protocol ProductViewModelDelegate: class {
    
    func viewModelDidUpdate(viewModel: ProductViewModel)
    
    func viewModelDidStartSwitchingFavouriting(viewModel: ProductViewModel)
    func viewModelDidUpdateIsFavourite(viewModel: ProductViewModel)
    func viewModelForbiddenAccessToFavourite(viewModel: ProductViewModel)

    func viewModelDidStartRetrievingUserProductRelation(viewModel: ProductViewModel)

    func viewModelDidStartReporting(viewModel: ProductViewModel)
    func viewModelDidUpdateIsReported(viewModel: ProductViewModel)
    func viewModelDidCompleteReporting(viewModel: ProductViewModel)
    func viewModelDidFailReporting(viewModel: ProductViewModel, error: ProductReportSaveServiceError)
    
    func viewModelDidStartDeleting(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishDeleting result: ProductDeleteServiceResult)
    
    func viewModelDidStartMarkingAsSold(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishMarkingAsSold result: ProductMarkSoldServiceResult)

    func viewModelDidStartMarkingAsUnsold(viewModel: ProductViewModel)
    func viewModel(viewModel: ProductViewModel, didFinishMarkingAsUnsold result: ProductMarkUnsoldServiceResult)

    func viewModelDidStartAsking(viewModel: ProductViewModel)
    // TODO: Refactor to return a ViewModel
    func viewModel(viewModel: ProductViewModel, didFinishAsking result: Result<UIViewController, ChatRetrieveServiceError>)
}

public class ProductViewModel: BaseViewModel, UpdateDetailInfoDelegate {

    // Output
    // > Product
    public var name: String {
        return product.name?.lg_capitalizedWords() ?? ""
    }
    public var price: String {
        return product.formattedPrice()
    }
    public var descr: String {
        return product.descr ?? ""
    }
    public var addressIconVisible: Bool {
        return !address.isEmpty
    }
    public var address: String {
        var address = ""
        if let city = product.postalAddress.city {
            if !city.isEmpty {
                address += city.lg_capitalizedWord()
            }
        }
        if let zipCode = product.postalAddress.zipCode {
            if !zipCode.isEmpty {
                if !address.isEmpty {
                    address += ", "
                }
                address += zipCode
            }
        }
        return address.lg_capitalizedWord()
    }
    public var location: LGLocationCoordinates2D? {
        return product.location
    }
    public var thumbnailURL : NSURL? {
        return product.thumbnail?.fileURL
    }
    
    // > User
    public var userName: String {
        return product.user.publicUsername ?? ""
    }
    public var userAvatar: NSURL? {
        return product.user.avatar?.fileURL
    }
    
    // > My User
    public private(set) var isFavourite: Bool
    public private(set) var isReported: Bool
    public private(set) var isMine: Bool
    
    // Delegate
    public weak var delegate: ProductViewModelDelegate?
    
    // Data
    private var product: Product
    
    // Manager
    private var productManager: ProductManager
    private var tracker: Tracker
    
    // MARK: - Computed iVars
    
    private var isOnSale: Bool {
        let onSale: Bool
        switch product.status {
        case .Pending, .Approved, .Discarded:
            onSale = true
            
        case .Deleted, .Sold, .SoldOld:
            onSale = false
        }
        return onSale
    }
    
    public var isEditable: Bool {
        // It's editable when the product is mine and is on sale
        return isMine && isOnSale
    }
    
    // TODO: Refactor to return a view model
    public var editViewModelWithDelegate: UIViewController {
        return EditSellProductViewController(product: product, updateDelegate: self)
    }
    
    public var isFavouritable: Bool {
        return !isMine && isOnSale
    }
    
    public var isShareable: Bool {
        return !isMine && isOnSale
    }
    
    public var isReportable: Bool {
        return !isMine
    }
    
    public var numberOfImages: Int {
        return product.images.count
    }
    
    // TODO: Refactor to return a view model as soon as UserProfile is refactored to MVVM
    public var productUserProfileViewModel: UIViewController? {
        let productUser = product.user
        if let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId, let productUserId = productUser.objectId {
            if myUserId != productUserId {
                return EditProfileViewController(user: productUser)
            }
        }
        return nil
    }
    
    // TODO: Refactor to return a view model as soon as ProductLocationViewController is refactored to MVVM
    public var productLocationViewModel: UIViewController? {
        var vc: ProductLocationViewController?
        let location = product.location
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewControllerWithIdentifier("ProductLocationViewController") as? ProductLocationViewController
        
        if let actualVC = vc {
            let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            actualVC.location = coordinate
            actualVC.annotationTitle = product.name
            
            var subtitle = ""
            if let city = product.postalAddress.city {
                subtitle += city
            }
            if let countryCode = product.postalAddress.countryCode {
                if !subtitle.isEmpty {
                    subtitle += ", "
                }
                subtitle += countryCode
            }
            actualVC.annotationSubtitle = subtitle
        }
        
        return vc
    }
    
    public var shareText: String {
        return shareSocialMessage.shareText
    }
    
    public var shareEmailSubject: String {
        return shareSocialMessage.title
    }
    
    public var shareEmailBody: String {
        return shareSocialMessage.emailShareText
    }
    
    public var shareFacebookContent: FBSDKShareLinkContent {
        return shareSocialMessage.fbShareContent
    }
    
    private var shareSocialMessage: SocialMessage {
        let title = LGLocalizedString.productShareBody
        return SocialHelper.socialMessageWithTitle(title, product: product)
    }
    
    public var shouldSuggestMarkSoldWhenDeleting: Bool {
        let suggestMarkSold: Bool
        switch product.status {
        case .Pending, .Discarded, .Sold, .SoldOld, .Deleted:
            suggestMarkSold = false

        case .Approved:
            suggestMarkSold = true
        }
        return suggestMarkSold
    }
    
    public var isDeletable: Bool {
        return isMine
    }
    
    public var isFooterVisible: Bool {
        let footerViewVisible: Bool
        switch product.status {
        case .Pending, .Discarded, .Deleted:
            footerViewVisible = false
        case .Approved:
            footerViewVisible = true
        case .Sold, .SoldOld:
            footerViewVisible = isMine
        }
        return footerViewVisible
    }
    
    public var productIsSold: Bool {
        let productSold: Bool
        switch product.status {
        case .Pending, .Discarded, .Approved, .Deleted:
            productSold = false
        case .Sold, .SoldOld:
            productSold = true
        }
        return productSold
    }
    
    // TODO: Refactor to return a view model as soon as MakeAnOfferViewController is refactored to MVVM
    public var offerViewModel: UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("MakeAnOfferViewController") as! MakeAnOfferViewController
        vc.product = product
        return vc
    }
    
    public var isProductStatusLabelVisible: Bool {
        let statusLabelVisible: Bool
        switch product.status {
        case .Pending:
            statusLabelVisible = false
        case .Approved:
            statusLabelVisible = false
        case .Discarded:
            statusLabelVisible = false
        case .Sold:
            statusLabelVisible = true
        case .SoldOld:
            statusLabelVisible = true
        case .Deleted:
            statusLabelVisible = true
        }
        return statusLabelVisible
    }
    
    public var productStatusLabelBackgroundColor: UIColor {
        let color: UIColor
        switch product.status {
        case .Pending, .Approved, .Discarded, .Deleted:
            color = UIColor.whiteColor()
        case .Sold, .SoldOld:
            color = StyleHelper.soldColor
        }
        return color
    }
    
    public var productStatusLabelFontColor: UIColor {
        let color: UIColor
        switch product.status {
        case .Pending, .Approved, .Discarded, .Deleted:
            color = UIColor.blackColor()
        case .Sold, .SoldOld:
            color = UIColor.whiteColor()
        }
        return color
    }
    
    public var productStatusLabelText: String {
        let text: String
        switch product.status {
        case .Pending:
            text = LGLocalizedString.productStatusLabelPending
        case .Approved:
            text = LGLocalizedString.productStatusLabelApproved
        case .Discarded:
            text = LGLocalizedString.productStatusLabelDiscarded
        case .Sold, .SoldOld:
            text = LGLocalizedString.productListItemSoldStatusLabel
        case .Deleted:
            text = LGLocalizedString.productStatusLabelDeleted
        }
        return text
    }
    
    // MARK: - Lifecycle
    
    public init(product: Product, tracker: Tracker) {
        // My user
        self.isFavourite = false
        self.isReported = false
        let productUser = product.user
        if let productUserId = productUser.objectId, let myUser = MyUserManager.sharedInstance.myUser(), let myUserId = myUser.objectId {
            self.isMine = ( productUserId == myUserId )
        }
        else {
            self.isMine = false
        }
        
        // Data
        self.product = product
        
        // Manager
        self.productManager = ProductManager()
        self.tracker = TrackerProxy.sharedInstance
        
        super.init()
        
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDetailVisit(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    internal override func didSetActive(active: Bool) {
        
        if active {
            delegate?.viewModelDidStartRetrievingUserProductRelation(self)
            
            productManager.retrieveUserProductRelation(product) { [weak self] (result: UserProductRelationServiceResult) -> Void in
                
                if let strongSelf = self {
                    if let favorited = result.value?.isFavorited, let reported = result.value?.isReported {
                        strongSelf.isFavourite = favorited
                        strongSelf.isReported = reported
                    }
                    strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                    strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
                }
            }
        }
    }
    
    // MARK: - Public methods
    
    // MARK: > Favourite
    
    public func switchFavourite() {
        delegate?.viewModelDidStartSwitchingFavouriting(self)
        
        // If favourite, then remove from favourites / delete
        if isFavourite {
            productManager.deleteFavourite(product) { [weak self] (result: ProductFavouriteDeleteServiceResult) -> Void in
                if let strongSelf = self {
                    // Success
                    if let _ = result.value {
                        // Update the flag
                        strongSelf.isFavourite = false
                        
                        // Run completed
                        strongSelf.deleteFavouriteCompleted()
                    }
                    
                    // Notify the delegate
                    strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                }
            }
        }
        // Otherwise, add it / save
        else {
            productManager.saveFavourite(product) { [weak self] (result: ProductFavouriteSaveServiceResult) -> Void in
                if let strongSelf = self {
                    // Success
                    if let _ = result.value {
                        // Update the flag
                        strongSelf.isFavourite = true
                        
                        // Run completed
                        strongSelf.saveFavouriteCompleted()
                    }
                    else {
                        if let actualError = result.error {
                            if actualError == .Forbidden {
                                strongSelf.delegate?.viewModelForbiddenAccessToFavourite(strongSelf)
                            }
                        }
                    }
                    
                    // Notify the delegate
                    strongSelf.delegate?.viewModelDidUpdateIsFavourite(strongSelf)
                }
            }
        }
    }
    
    // MARK: > Gallery
    
    public func imageURLAtIndex(index: Int) -> NSURL? {
        return product.images[index].fileURL
    }
    
    public func imageTokenAtIndex(index: Int) -> String? {
        return product.images[index].objectId
    }
    
    
    // MARK: > Share

    public func shareInEmail(buttonPosition: String) {
        let trackerEvent = TrackerEvent.productShare(self.product, user: MyUserManager.sharedInstance.myUser(), network: .Email, buttonPosition: buttonPosition)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    public func shareInFacebook(buttonPosition: String) {
        let trackerEvent = TrackerEvent.productShare(self.product, user: MyUserManager.sharedInstance.myUser(), network: .Facebook, buttonPosition: buttonPosition)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(self.product, user: MyUserManager.sharedInstance.myUser(), network: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(self.product, user: MyUserManager.sharedInstance.myUser(), network: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBMessenger() {
        let trackerEvent = TrackerEvent.productShare(self.product, user: MyUserManager.sharedInstance.myUser(), network: .FBMessenger, buttonPosition: "bottom")
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBMessengerCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(self.product, user: MyUserManager.sharedInstance.myUser(), network: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInFBMessengerCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(self.product, user: MyUserManager.sharedInstance.myUser(), network: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func shareInWhatsApp() -> Bool {
        guard canShareInWhatsapp() else { return false }
        guard let url = generateWhatsappURL() else { return false }
        let success = UIApplication.sharedApplication().openURL(url)
        let trackerEvent = TrackerEvent.productShare(self.product, user: MyUserManager.sharedInstance.myUser(), network: .Whatsapp, buttonPosition: "bottom")
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        return success
    }
    
    public func shareInWhatsappActivity() {
        let trackerEvent = TrackerEvent.productShare(self.product, user: MyUserManager.sharedInstance.myUser(), network: .Whatsapp, buttonPosition: "top")
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }

    public func shareInTwitterActivity() {
        let trackerEvent = TrackerEvent.productShare(self.product, user: MyUserManager.sharedInstance.myUser(), network: .Twitter, buttonPosition: "top")
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func generateWhatsappURL() -> NSURL? {
        let queryCharSet = NSCharacterSet.URLQueryAllowedCharacterSet()
        guard let urlEncodedShareText = shareText.stringByAddingPercentEncodingWithAllowedCharacters(queryCharSet) else { return nil }
        return NSURL(string: String(format: Constants.whatsAppShareURL, arguments: [urlEncodedShareText]))
    }
    
    public func canShareInWhatsapp() -> Bool {
        guard let url = generateWhatsappURL() else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }
    
    /**
    Detect if the user has the FB Messenger App installed.
    Done manually because Facebook does not provide a way to do it with the SDK
    
    - returns: Wether the content can be shared in facebook-messenger or not
    */
    public func canShareInFBMessenger() -> Bool {
        guard let url = NSURL(string: "fb-messenger-api://") else { return false }
        let application = UIApplication.sharedApplication()
        return application.canOpenURL(url)
    }
    

    // MARK: >  Report
    
    public func reportStarted() {
        let trackerEvent = TrackerEvent.productReport(self.product, user: MyUserManager.sharedInstance.myUser())
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    public func reportAbandon() {
    }
    
    public func report() {
        // If it's already reported, then do nothing
        if isReported {
            return
        }
        
        // Otherwise, start
        delegate?.viewModelDidStartReporting(self)
        productManager.saveReport(product) { [weak self] (result: ProductReportSaveServiceResult) -> Void in
            if let strongSelf = self {
                // Success
                if let _ = result.value {
                    // Update the flag
                    strongSelf.isReported = true
                    
                    // Run completed
                    strongSelf.reportCompleted()
                    // Notify the delegate
                    strongSelf.delegate?.viewModelDidUpdateIsReported(strongSelf)
                } else {
                    let failure = result.error ?? .Internal
                    strongSelf.delegate?.viewModelDidFailReporting(strongSelf, error: failure)
                }
                
            }
        }
    }
    
    // MARK: > Delete
    
    public func deleteStarted() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteStart(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    public func deleteAbandon() {
    }
    
    public func delete() {
        delegate?.viewModelDidStartDeleting(self)
        productManager.deleteProduct(product) { [weak self] (result: ProductDeleteServiceResult) -> Void in
            if let strongSelf = self {
                if let product = result.value {
                    // Update the status
                    strongSelf.product = product
                    
                    // Run completed
                    strongSelf.deleteCompleted()
                }
                
                // Notify the delegate
                strongSelf.delegate?.viewModel(strongSelf, didFinishDeleting: result)
            }
        }
    }

    // MARK: >  Ask
    
    public func askStarted() {
    }
    
    // TODO: Refactor when Chat is following MVVM
    public func ask() {
        if let myUser = MyUserManager.sharedInstance.myUser() {

            // Notify the delegate
            delegate?.viewModelDidStartAsking(self)
            
            // Retrieve the chat
            ChatManager.sharedInstance.retrieveChatWithProduct(product, buyer: myUser) { [weak self] (retrieveResult: Result<Chat, ChatRetrieveServiceError>) -> Void in
                if let strongSelf = self, let actualDelegate = strongSelf.delegate {
                    
                    var result = Result<UIViewController, ChatRetrieveServiceError>(error: .Internal)
                    
                    // Success
                    if let chat = retrieveResult.value, let vc = ChatViewController(chat: chat) {
                        vc.askQuestion = true
                        result = Result<UIViewController, ChatRetrieveServiceError>(value: vc)
                    }
                    // Error
                    if let error = retrieveResult.error {
                        switch error {
                        // If not found, then no conversation has been created yet, it's a success
                        case .NotFound:
                            if let vc = ChatViewController(product: strongSelf.product) {
                                vc.askQuestion = true
                                result = Result<UIViewController, ChatRetrieveServiceError>(value: vc)
                            }
                        case .Network, .Unauthorized, .Internal, .Forbidden:
                            result = Result<UIViewController, ChatRetrieveServiceError>(error: error)
                        }
                    }
                    
                    // Notify the delegate
                    actualDelegate.viewModel(strongSelf, didFinishAsking: result)
                }
            }
        }
    }
    
    // MARK: > Mark as Sold
    
    public func markSoldStarted(source: EventParameterSellSourceValue) {
    }
    
    public func markSold(source: EventParameterSellSourceValue) {
        delegate?.viewModelDidStartMarkingAsSold(self)
        productManager.markProductAsSold(product) { [weak self] ( result: ProductMarkSoldServiceResult) -> Void in
            if let strongSelf = self {
                // Success
                if let soldProduct = result.value {
                    // Update the status
                    strongSelf.product = soldProduct
                    
                    // Run completed
                    strongSelf.markSoldCompleted(soldProduct, source: source)
                }
                
                // Notify the delegate
                strongSelf.delegate?.viewModel(strongSelf, didFinishMarkingAsSold: result)
            }
        }
    }
    
    public func markSoldAbandon(source: EventParameterSellSourceValue) {
    }
    
    
    public func markUnsoldStarted() {
    }
    
    public func markUnsold() {
        delegate?.viewModelDidStartMarkingAsUnsold(self)
        productManager.markProductAsUnsold(product) { [weak self] ( result: ProductMarkUnsoldServiceResult) -> Void in
            if let strongSelf = self {
                // Success
                if let unsoldProduct = result.value {
                    // Run completed. 'unsoldProduct' already has its status updated
                    strongSelf.markUnsoldCompleted(unsoldProduct)
                }
                
                // Notify the delegate
                strongSelf.delegate?.viewModel(strongSelf, didFinishMarkingAsUnsold: result)
            }
        }
    }
    
    public func markUnsoldAbandon() {
    }
    
    // MARK: - UpdateDetailInfoDelegate
    
    public func updateDetailInfo(viewModel: EditSellProductViewModel,  withSavedProduct savedProduct: Product) {
        product = savedProduct
        delegate?.viewModelDidUpdate(self)
    }
    
    // MARK: - Private methods
    
    private func reportCompleted() {
        delegate?.viewModelDidCompleteReporting(self)
    }
    
    private func markSoldCompleted(soldProduct: Product, source: EventParameterSellSourceValue) {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: soldProduct, user: myUser)
        tracker.trackEvent(trackerEvent)
        
    }
    
    private func markUnsoldCompleted(unsoldProduct: Product) {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productMarkAsUnsold(unsoldProduct, user: myUser)
        tracker.trackEvent(trackerEvent)
        
    }
    private func deleteCompleted() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productDeleteComplete(product, user: myUser)
        tracker.trackEvent(trackerEvent)
    }
    
    private func saveFavouriteCompleted() {
        let trackerEvent = TrackerEvent.productFavorite(self.product, user: MyUserManager.sharedInstance.myUser())
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    private func deleteFavouriteCompleted() {
    }
    
}
