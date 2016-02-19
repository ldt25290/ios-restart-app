//
//  EditProfileViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import LGCoreKit
import Result
import UIKit
import SDWebImage

private let kLetGoDisabledButtonBackgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0)
private let kLetGoDisabledButtonForegroundColor = UIColor.lightGrayColor()
private let kLetGoEnabledButtonBackgroundColor = UIColor.whiteColor()
private let kLetGoEnabledButtonForegroundColor = UIColor(red: 0.949, green: 0.361, blue: 0.376, alpha: 1.0)
private let kLetGoEditProfileCellFactor: CGFloat = 210.0 / 160.0


enum EditProfileSource {
    case TabBar
    case ProductDetail
    case Chat
}

class EditProfileViewController: UIViewController, ProductListViewDataDelegate, UICollectionViewDelegate,
UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout, ScrollableToTop {
    
    enum ProfileTab {
        case ProductImSelling
        case ProductISold
        case ProductFavourite
    }
    
    // Header
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    // "tab" buttons
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    // Selling
    @IBOutlet weak var sellingProductListView: ProfileProductListView!
    
    // Sold
    @IBOutlet weak var soldProductListView: ProfileProductListView!
    
    // Favourites
    @IBOutlet weak var favouriteCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var noFavouritesLabel: UILabel!
    
    // No products
    @IBOutlet weak var youDontHaveTitleLabel: UILabel!
    @IBOutlet weak var youDontHaveSubtitleLabel: UILabel!
    @IBOutlet weak var startSellingNowButton: UIButton!
    @IBOutlet weak var startSearchingNowButton: UIButton!
    
    // data
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    
    var user: User
    var selectedTab: ProfileTab = .ProductImSelling
    var source: EditProfileSource
    
    private var isSellProductsEmpty: Bool = true
    private var isSoldProductsEmpty: Bool = true
    private var favProducts: [Product] = []
    
    private var loadingSellProducts: Bool = false
    private var loadingSoldProducts: Bool = false
    private var loadingFavProducts: Bool = false

    private var isMyUser: Bool {
        if let myUserId = Core.myUserRepository.myUser?.objectId, userId = user.objectId {
            return userId == myUserId
        }
        return false
    }

    private var tabEventParameter: EventParameterTab {
        switch selectedTab {
        case .ProductImSelling:
            return .Selling
        case .ProductISold:
            return .Sold
        case .ProductFavourite:
            return .Favorites
        }
    }
    private var typePageEventParameter: EventParameterTypePage? {
        switch source {
        case .TabBar:
            return nil
        case .Chat:
            return .Chat
        case .ProductDetail:
            return .ProductDetail
        }
    }
    
    var cellSize = CGSizeMake(160.0, 210.0)
    
    init(user: User?, source: EditProfileSource) {
        self.user = user ?? Core.myUserRepository.myUser ?? LGUser()
        self.source = source
        self.productRepository = Core.productRepository
        self.userRepository = Core.userRepository
        super.init(nibName: "EditProfileViewController", bundle: nil)
        
        self.hidesBottomBarWhenPushed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        // > Main product list view
        sellingProductListView.delegate = self
        sellingProductListView.user = user
        sellingProductListView.type = .Selling
        soldProductListView.delegate = self
        soldProductListView.user = user
        soldProductListView.type = .Sold
        
        // User image
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        userImageView.clipsToBounds = true
        userImageView.layer.borderColor = UIColor(rgb: 0xD8D8D8).CGColor
        userImageView.layer.borderWidth = 1
        
        // internationalization
        sellButton.setTitle(LGLocalizedString.profileSellingProductsTab, forState: .Normal)
        soldButton.setTitle(LGLocalizedString.profileSoldProductsTab, forState: .Normal)
        favoriteButton.setTitle(LGLocalizedString.profileFavouritesProductsTab, forState: .Normal)
        
        noFavouritesLabel.text = LGLocalizedString.profileNoProducts
        
        // center activity indicator (if there's a tabbar)
        let bottomMargin: CGFloat
        if let tabBarCtl = tabBarController {
            bottomMargin = tabBarCtl.tabBar.hidden ? 0 : -tabBarCtl.tabBar.frame.size.height/2
        }
        else {
            bottomMargin = 0
        }
        activityIndicatorCenterYConstraint.constant = bottomMargin
        
        // collection view.
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        favouriteCollectionView.autoresizingMask = .FlexibleHeight
        favouriteCollectionView.alwaysBounceVertical = true
        favouriteCollectionView.collectionViewLayout = layout
        
        // Add bottom inset (tabbar) if tabbar visible
        let bottomInset: CGFloat
        let sellButtonHeight: CGFloat
        if let tabBarCtl = tabBarController {
            bottomInset = tabBarCtl.tabBar.hidden ? 0 : tabBarCtl.tabBar.frame.height
            sellButtonHeight = tabBarCtl.tabBar.hidden ? 0 : Constants.tabBarSellFloatingButtonHeight
        }
        else {
            bottomInset = 0
            sellButtonHeight = 0
        }
        favouriteCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        sellingProductListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        sellingProductListView.collectionViewContentInset = UIEdgeInsets(top: 0, left: 0,
            bottom: sellButtonHeight, right: 0)
        soldProductListView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        soldProductListView.collectionViewContentInset = UIEdgeInsets(top: 0, left: 0,
            bottom: sellButtonHeight, right: 0)
        
        // register ProductCell
        ProductCellDrawerFactory.registerCells(favouriteCollectionView)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground:",
            name: UIApplicationWillEnterForegroundNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearProductLists:",
            name: SessionManager.Notification.Logout.rawValue, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // cell size
        let cellWidth = UIScreen.mainScreen().bounds.size.width * 0.50
        let cellHeight = cellWidth * kLetGoEditProfileCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
    }
    
    // MARK: - Actions
    
    func goToSettings() {
        let vc = SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showSellProducts(sender: AnyObject) {
        selectedTab = .ProductImSelling
        updateUIForCurrentTab()
    }
    
    @IBAction func showSoldProducts(sender: AnyObject) {
        selectedTab = .ProductISold
        updateUIForCurrentTab()
    }
    
    @IBAction func showFavoritedProducts(sender: AnyObject) {
        selectedTab = .ProductFavourite
        updateUIForCurrentTab()
    }

    func refreshSellingProductsList() {
        retrieveProductsForTab(.ProductImSelling)
    }

    dynamic private func showOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        alert.addAction(UIAlertAction(title: LGLocalizedString.reportUserTitle, style: .Default,
            handler: { [weak self] _ in self?.showReportUser() } ))
        
        let block = UIAlertAction(title: LGLocalizedString.chatBlockUser, style: .Default) { [weak self] action in
            self?.showBlockConfirmation()
        }
        let unblock = UIAlertAction(title: LGLocalizedString.chatUnblockUser, style: .Default) { [weak self] action in
            guard let user = self?.user else { return }
            self?.userRepository.unblockUser(user) { result in
                if let _ = result.value {
                    self?.showAutoFadingOutMessageAlert(LGLocalizedString.unblockUserSuccessMessage)
                } else {
                    self?.showAutoFadingOutMessageAlert(LGLocalizedString.unblockUserErrorGeneric)
                }
            }
        }
        
        // TODO: Decide what action should be shown in the ActionSheet. Uncomment when backend is ready
        // alert.addAction(block)
        
        alert.addAction(UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showBlockConfirmation() {
        let alert = UIAlertController(title: LGLocalizedString.chatBlockUserAlertTitle,
            message: LGLocalizedString.chatBlockUserAlertText, preferredStyle: .Alert)
        let action = UIAlertAction(title: LGLocalizedString.chatBlockUserAlertBlockButton, style: .Destructive) {
            [weak self] action in
            guard let user = self?.user else { return }
            self?.userRepository.blockUser(user) { result in
                if let _ = result.value {
                    self?.showAutoFadingOutMessageAlert(LGLocalizedString.blockUserSuccessMessage)
                } else {
                    self?.showAutoFadingOutMessageAlert(LGLocalizedString.blockUserErrorGeneric)
                }
            }
        }
        let cancel = UIAlertAction(title: LGLocalizedString.commonCancel, style: .Cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - You don't have any products action buttons.
    
    @IBAction func startSellingNow(sender: AnyObject) {
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        tabBarController.sellButtonPressed()
    }

    @IBAction func startSearchingNow(sender: AnyObject) {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.Home)
    }


    // MARK: - ScrollableToTop

    func scrollToTop() {
        switch selectedTab {
        case .ProductImSelling:
            guard let sellingProductListView = sellingProductListView else { return }
            sellingProductListView.scrollToTop()
        case .ProductISold:
            guard let soldProductListView = soldProductListView else { return }
            soldProductListView.scrollToTop()
        case .ProductFavourite:
            guard let favouriteCollectionView = favouriteCollectionView else { return }
            favouriteCollectionView.setContentOffset(CGPointZero, animated: true)
        }
    }

    // MARK: - ProductListViewDataDelegate
    
    func productListView(productListView: ProductListView, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
        error: RepositoryError) {
            
            if productListView == sellingProductListView {
                isSellProductsEmpty = !hasProducts
                loadingSellProducts = false
                
                retrievalFinishedForProductsAtTab(.ProductImSelling)
            }
            else if productListView == soldProductListView {
                isSoldProductsEmpty = !hasProducts
                loadingSoldProducts = false
                
                retrievalFinishedForProductsAtTab(.ProductISold)
            }
    }
    
    func productListView(productListView: ProductListView, didSucceedRetrievingProductsPage page: UInt,
        hasProducts: Bool) {
            
            if productListView == sellingProductListView {
                isSellProductsEmpty = !hasProducts
                loadingSellProducts = false
                
                retrievalFinishedForProductsAtTab(.ProductImSelling)
            }
            else if productListView == soldProductListView {
                isSoldProductsEmpty = !hasProducts
                loadingSoldProducts = false
                
                retrievalFinishedForProductsAtTab(.ProductISold)
            }
    }
    
    func productListView(productListView: ProductListView, didSelectItemAtIndexPath indexPath: NSIndexPath,
        thumbnailImage: UIImage?) {
            guard productListView == sellingProductListView || productListView == soldProductListView else { return }
            
            let productVM = productListView.productViewModelForProductAtIndex(indexPath.row,
                thumbnailImage: thumbnailImage)
            let vc = ProductViewController(viewModel: productVM)
            navigationController?.pushViewController(vc, animated: true)
    }

    
    // MARK: - UICollectionViewDataSource and Delegate methods
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        heightForFooterInSection section: Int) -> CGFloat {
            if let tabBarCtl = tabBarController {
                return tabBarCtl.tabBar.hidden ? 0 : Constants.tabBarSellFloatingButtonHeight
            }
            return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            // TODO: Calculate size in the future when using thumbnail sizes from REST API.
            return cellSize
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        columnCountForSection section: Int) -> Int {
            return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favProducts.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let drawer = ProductCellDrawerFactory.drawerForProduct(true)
            let cell = drawer.cell(collectionView, atIndexPath: indexPath)
            cell.tag = indexPath.hash
            drawer.draw(cell, data: productCellDataAtIndex(indexPath), delegate: nil)

            return cell
    }
    
    func collectionView(cv: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let product = productAtIndexPath(indexPath)
        let cell = collectionView(cv, cellForItemAtIndexPath: indexPath) as? ProductCell
        let thumbnailImage = cell?.thumbnailImageView.image
        let productVM = ProductViewModel(product: product, thumbnailImage: thumbnailImage)
        let vc = ProductViewController(viewModel: productVM)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UI

    /**
        Clears the collection view
    */

    func clearProductLists(notification: NSNotification) {
        sellingProductListView.clearList()
        soldProductListView.clearList()
        favProducts = []
        favouriteCollectionView.reloadData()
    }

    func selectButton(button: UIButton) {
        button.backgroundColor = kLetGoEnabledButtonBackgroundColor
        button.setTitleColor(kLetGoEnabledButtonForegroundColor, forState: .Normal)
        if button != sellButton {
            sellButton.backgroundColor = kLetGoDisabledButtonBackgroundColor
            sellButton.setTitleColor(kLetGoDisabledButtonForegroundColor, forState: .Normal)
        }
        if button != soldButton {
            soldButton.backgroundColor = kLetGoDisabledButtonBackgroundColor
            soldButton.setTitleColor(kLetGoDisabledButtonForegroundColor, forState: .Normal)
        }
        if button != favoriteButton {
            favoriteButton.backgroundColor = kLetGoDisabledButtonBackgroundColor
            favoriteButton.setTitleColor(kLetGoDisabledButtonForegroundColor, forState: .Normal)
        }
    }
    
    func updateUIForCurrentTab() {
        
        // Check if view is initialized
        guard let youDontHaveTitleLabel = youDontHaveTitleLabel else { return }
        
        youDontHaveTitleLabel.hidden = true
        
        switch selectedTab {
        case .ProductImSelling:
            sellingProductListView.hidden = false
            soldProductListView.hidden = true
            noFavouritesLabel.hidden = true
            favouriteCollectionView.hidden = true
            break
        case .ProductISold:
            sellingProductListView.hidden = true
            soldProductListView.hidden = false
            noFavouritesLabel.hidden = true
            favouriteCollectionView.hidden = true
            break
        case .ProductFavourite:
            sellingProductListView.hidden = true
            soldProductListView.hidden = true
            
            if favProducts.isEmpty {
                noFavouritesLabel.hidden = false
                favouriteCollectionView.hidden = true
            }
            else {
                noFavouritesLabel.hidden = true
                favouriteCollectionView.hidden = false
            }
        }
        
        switch selectedTab {
        case .ProductImSelling:
            selectButton(sellButton)
        case .ProductISold:
            selectButton(soldButton)
        case .ProductFavourite:
            selectButton(favoriteButton)
        }
    }
    
    // MARK: - Requests
    
    func retrieveProductsForTab(tab: ProfileTab) {
        
        if let userId = user.objectId {
            switch tab {
            case .ProductImSelling:
                loadingSellProducts = true
                sellingProductListView.refresh()
                
            case .ProductISold:
                loadingSoldProducts = true
                soldProductListView.refresh()
            case .ProductFavourite:
                
                // Retrieve the products
                loadingFavProducts = true
                
                productRepository.indexFavorites(userId) { [weak self] result in
                    if let value = result.value {
                        self?.favProducts = value
                    }
                    self?.loadingFavProducts = false
                    self?.favouriteCollectionView.reloadData()
                    self?.retrievalFinishedForProductsAtTab(tab)
                }
            }
        }
        else {
            retrievalFinishedForProductsAtTab(tab)
        }
    }
    
    func retrievalFinishedForProductsAtTab(tab: ProfileTab) {
        // If any tab is loading, then quit this function
        if loadingSellProducts || loadingSoldProducts || loadingFavProducts {
            return
        }
        
        activityIndicator.stopAnimating()
        
        // If the 3 tabs are empty then display update UI with "no products available"
        if isSellProductsEmpty && isSoldProductsEmpty && favProducts.isEmpty {
            
            youDontHaveTitleLabel.hidden = false
            
            sellButton.hidden = true
            soldButton.hidden = true
            favoriteButton.hidden = true
            
            favouriteCollectionView.hidden = true
            noFavouritesLabel.hidden = true
            
            // set text depending on if we are the user being shown or not
            if isMyUser {
                youDontHaveTitleLabel.text = LGLocalizedString.profileFavouritesMyUserNoProductsLabel
                youDontHaveSubtitleLabel.text = LGLocalizedString.profileFavouritesMyUserNoProductsSubtitleLabel
                youDontHaveSubtitleLabel.hidden = false
                
                startSearchingNowButton.hidden = false
                startSellingNowButton.hidden = false
            } else {
                youDontHaveTitleLabel.text = LGLocalizedString.profileFavouritesOtherUserNoProductsLabel
                youDontHaveSubtitleLabel.hidden = true
                
                startSearchingNowButton.hidden = true
                startSellingNowButton.hidden = true
            }
        } else {
            // Else, update the UI
            favouriteCollectionView.hidden = false
            
            youDontHaveTitleLabel.hidden = true
            youDontHaveSubtitleLabel.hidden = true
            
            sellButton.hidden = false
            soldButton.hidden = false
            favoriteButton.hidden = false
            
            startSearchingNowButton.hidden = true
            startSellingNowButton.hidden = true
            
            updateUIForCurrentTab()
        }
    }
    
    // MARK: Helper
    
    func productAtIndexPath(indexPath: NSIndexPath) -> Product {
        let row = indexPath.row
        return favProducts[row]
    }
    
    func productCellDataAtIndex(indexPath: NSIndexPath) -> ProductCellData {
        let product = productAtIndexPath(indexPath)
        var isMine = false
        if let productUserId = product.user.objectId, myUserId = Core.myUserRepository.myUser?.objectId
            where productUserId == myUserId {
                isMine = true
        }
        return ProductCellData(title: product.name, price: product.priceString(),
            thumbUrl: product.thumbnail?.fileURL, status: product.status, date: product.createdAt,
            isFavorite: false, isMine: isMine, cellWidth: sellingProductListView.defaultCellSize.width,
            indexPath: indexPath)
    }


    // MARK: - NSNotification selector

    func willEnterForeground(notification: NSNotification) {
        refreshView()
    }

    // MARK: - private methods

    private func refreshView() {

        if let myUser = Core.myUserRepository.myUser where user.objectId == myUser.objectId {
            user = myUser
        }

        // UX/UI and Appearance.
        setLetGoNavigationBarStyle("")

        sellingProductListView.hidden = true
        soldProductListView.hidden = true
        favouriteCollectionView.hidden = true
        activityIndicator.startAnimating()

        // load
        isSellProductsEmpty = true
        isSoldProductsEmpty = true
        favProducts = []

        // reset UI
        sellingProductListView.delegate = self
        sellingProductListView.user = user
        sellingProductListView.type = .Selling
        soldProductListView.delegate = self
        soldProductListView.user = user
        soldProductListView.type = .Sold

        favouriteCollectionView.reloadData()

        retrieveProductsForTab(ProfileTab.ProductImSelling)
        retrieveProductsForTab(ProfileTab.ProductISold)
        retrieveProductsForTab(ProfileTab.ProductFavourite)

        // UI
        if let avatarURL = user.avatar?.fileURL, id = user.objectId, name = user.name {
            userImageView.sd_setImageWithURL(avatarURL, placeholderImage: LetgoAvatar.avatarWithID(id, name: name))
        } else {
            userImageView.image = UIImage(named: "no_photo")
        }

        userNameLabel.text = user.name ?? ""
        userLocationLabel.text = user.postalAddress.city ?? user.postalAddress.countryCode

        if isMyUser {
            //Allow go to settings
            setLetGoRightButtonWith(imageName: "navbar_settings", selector: "goToSettings")
        } else  {
            if let typePage = typePageEventParameter {
                //Track profile visit
                let trackerEvent = TrackerEvent.profileVisit(user, typePage: typePage, tab: tabEventParameter)
                TrackerProxy.sharedInstance.trackEvent(trackerEvent)
            }
            if Core.sessionManager.loggedIn {
                setLetGoRightButtonWith(imageName: "ic_more_options", selector: "showOptions")
            }
        }
    }

    private func showReportUser() {
        let vc = ReportUsersViewController(viewModel: ReportUsersViewModel(origin: .Profile, userReported: user))
        pushViewController(vc, animated: true, completion: nil)
    }
}
