//
//  EditProfileViewController.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Parse
import UIKit
import SDWebImage

private let kLetGoDisabledButtonBackgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0)
private let kLetGoDisabledButtonForegroundColor = UIColor.lightGrayColor()
private let kLetGoEnabledButtonBackgroundColor = UIColor.whiteColor()
private let kLetGoEnabledButtonForegroundColor = UIColor(red: 0.949, green: 0.361, blue: 0.376, alpha: 1.0)
private let kLetGoEditProfileCellFactor: CGFloat = 210.0 / 160.0


class EditProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    enum ProfileTab {
        case ProductImSelling
        case ProductISold
        case ProductFavourite
    }
    
    // outlets && buttons
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var youDontHaveTitleLabel: UILabel!
    @IBOutlet weak var youDontHaveSubtitleLabel: UILabel!
    @IBOutlet weak var startSellingNowButton: UIButton!
    @IBOutlet weak var startSearchingNowButton: UIButton!
    
    // data
    var userObject: PFUser?
    var selectedTab: ProfileTab = .ProductImSelling
    
    private var sellProducts: [PFObject] = []
    private var soldProducts: [PFObject] = []
    private var favProducts: [PFObject] = []
    
    private var loadingSellProducts: Bool = false
    private var loadingSoldProducts: Bool = false
    private var loadingFavProducts: Bool = false
    
    var cellSize = CGSizeMake(160.0, 210.0)
    
    init() {
        super.init(nibName: "EditProfileViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0
        self.userImageView.clipsToBounds = true
        
        // UX/UI and Appearance.
        userLocationLabel.text = ""
        userNameLabel.text = ""
        setLetGoNavigationBarStyle(title: "")
        
        // internationalization
        sellButton.setTitle(translate("selling_button"), forState: .Normal)
        soldButton.setTitle(translate("sold"), forState: .Normal)
        favoriteButton.setTitle(translate("favorited"), forState: .Normal)
        
        // ui
        collectionView.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        // center activity indicator (if there's a tabbar)
        let bottomMargin: CGFloat
        if let tabBarCtl = self.tabBarController {
            bottomMargin = tabBarCtl.tabBar.hidden ? 0 : -tabBarCtl.tabBar.frame.size.height/2
        }
        else {
            bottomMargin = 0
        }
        activityIndicatorCenterYConstraint.constant = bottomMargin
        
        // collection view.
        var layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        self.collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight // | UIViewAutoresizing.FlexibleWidth
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.collectionViewLayout = layout
        
        // Add bottom inset (tabbar) if tabbar visible
        let bottomInset: CGFloat
        if let tabBarCtl = self.tabBarController {
            bottomInset = tabBarCtl.tabBar.hidden ? 0 : tabBarCtl.tabBar.frame.height
        }
        else {
            bottomInset = 0
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        // register ProductCell
        let cellNib = UINib(nibName: "ProductCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "ProductCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // load
        retrieveProductsForTab(ProfileTab.ProductImSelling)
        retrieveProductsForTab(ProfileTab.ProductISold)
        retrieveProductsForTab(ProfileTab.ProductFavourite)
        
        // load user data (image, name, location...)
        if userObject != nil {
            userObject!.fetchIfNeededInBackgroundWithBlock({ [weak self] (retrievedObject, error) -> Void in
                if error == nil && retrievedObject != nil {
                    if let strongSelf = self {
                        if let avatarFile = retrievedObject?["avatar"] as? PFFile, let avatarFileURLStr = avatarFile.url, let avatarFileURL = NSURL(string: avatarFileURLStr) {
                            strongSelf.userImageView.sd_setImageWithURL(avatarFileURL)
                        }
                        if let userName = retrievedObject?["username_public"] as? String {
                            strongSelf.userNameLabel.text = userName
                            strongSelf.setLetGoNavigationBarStyle(title: userName)
                        }
                        if let userLocation = retrievedObject?["city"] as? String {
                            strongSelf.userLocationLabel.text = userLocation
                            strongSelf.userLocationLabel.hidden = false
                        }
                        else {
                            strongSelf.userLocationLabel.hidden = true
                        }
                    }
                }
            })
            
            // Current user has the option of editing his/her settings
            if userObject!.objectId == PFUser.currentUser()!.objectId { setLetGoRightButtonsWithImageNames(["navbar_settings"], andSelectors: ["goToSettings"]) }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // cell size
        let cellWidth = kLetGoFullScreenWidth * 0.50
        let cellHeight = cellWidth * kLetGoEditProfileCellFactor
        cellSize = CGSizeMake(cellWidth, cellHeight)
    }
    
    // MARK: - Actions
    
    func goToSettings() {
        let vc = SettingsViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    // MARK: - You don't have any products action buttons.
    
    @IBAction func startSellingNow(sender: AnyObject) {
        let vc = SellProductViewController()
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    @IBAction func startSearchingNow(sender: AnyObject) {
        if let tabBarCtl = tabBarController as? TabBarController {
            tabBarCtl.switchToTab(.Home)
        }
    }
    
    // MARK: - UICollectionViewDataSource and Delegate methods
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // TODO: Calculate size in the future when using thumbnail sizes from REST API.
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedTab {
        case .ProductImSelling:
            return sellProducts.count
        case .ProductISold:
            return soldProducts.count
        case .ProductFavourite:
            return favProducts.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProductCell", forIndexPath: indexPath) as! ProductCell
        cell.tag = indexPath.hash
        
        if let product = self.productAtIndexPath(indexPath) {
            //cell.setupCellWithProduct(product, indexPath: indexPath)
            cell.setupCellWithParseProductObject(product, indexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let selectedProduct = self.productAtIndexPath(indexPath) {
            let vc = ShowProductViewController()
            vc.productObject = selectedProduct
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // Hide tip when dragging
        if let tabBarCtl = tabBarController as? TabBarController {
            tabBarCtl.dismissTooltip(animated: true)
        }
    }
    
    // MARK: - UI
    
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
        var products: [AnyObject] = []
        switch selectedTab {
        case .ProductImSelling:
            products = sellProducts
        case .ProductISold:
            products = soldProducts
        case .ProductFavourite:
            products = favProducts
        }
        
        if products.isEmpty {
            youDontHaveTitleLabel.hidden = false
            youDontHaveTitleLabel.text = translate("no_items_in_this_section")
            collectionView.hidden = true
        }
        else {
            youDontHaveTitleLabel.hidden = true
            collectionView.hidden = false
            collectionView.reloadSections(NSIndexSet(index: 0))
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
        if let userId = userObject?.objectId {
            switch tab {
            case .ProductImSelling:
                loadingSellProducts = true
                var statuses: [LetGoProductStatus] = [.Approved]
                
                if userId == PFUser.currentUser()?.objectId { statuses.append(.Pending) }
                self.retrieveProductsForUserId(userId, statuses: statuses, completion: { [weak self] (products, error) -> (Void) in
                    if let strongSelf = self {
                        if error == nil && products.count > 0 {
                            strongSelf.sellProducts = products
                        }
                        strongSelf.loadingSellProducts = false
                        strongSelf.retrievalFinishedForProductsAtTab(tab)
                    }
                })
            case .ProductISold:
                loadingSoldProducts = true
                
                self.retrieveProductsForUserId(userId, statuses: [.Sold], completion: { [weak self] (products, error) -> Void in
                    if let strongSelf = self {
                        if error == nil && products.count > 0 {
                            strongSelf.soldProducts = products
                        }
                        strongSelf.loadingSoldProducts = false
                        strongSelf.retrievalFinishedForProductsAtTab(tab)
                    }
                    })
                
            case .ProductFavourite:
                loadingFavProducts = true
                
                self.retrieveFavouriteProductsForUserId(userId, completion: { [weak self] (products, error) -> Void in
                    if let strongSelf = self {
                        if error == nil && products.count > 0 {
                            strongSelf.favProducts = products
                        }
                        strongSelf.loadingFavProducts = false
                        strongSelf.retrievalFinishedForProductsAtTab(tab)
                    }
                })
            }
        }
    }
    
    func retrieveProductsForUserId(userId: String, statuses: [LetGoProductStatus], completion: (products: [PFObject]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        let query = PFQuery(className: "Products")
        query.whereKey("user", equalTo: user)
        // statuses
        var statusesIncluded: [Int] = []
        for status in statuses { statusesIncluded.append(status.rawValue) }
        
        //query.whereKey("status", equalTo: status.rawValue)
        query.whereKey("status", containedIn: statusesIncluded)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            let products = objects as! [PFObject]!
            completion(products: products, error: error)
        })
    }
    
    func retrieveFavouriteProductsForUserId(userId: String?, completion: (favProducts: [PFObject]!, error: NSError!) -> (Void)) {
        let user = PFObject(withoutDataWithClassName: "_User", objectId: userId)
        let query = PFQuery(className: "UserFavoriteProducts")
        query.whereKey("user", equalTo: user)
        query.orderByDescending("createdAt")
        query.includeKey("product")
        query.findObjectsInBackgroundWithBlock( { (objects, error) -> Void in
            
            var productList: [PFObject] = []
            if let favorites = objects as? [PFObject] {
                for favorite in favorites {
                    if let product = favorite["product"] as? PFObject {
                        productList.append(product)
                    }
                }
            }
            completion(favProducts: productList, error: error)
        })
    }
    
    
    func retrievalFinishedForProductsAtTab(tab: ProfileTab) {
        // If any tab is loading, then quit this function
        if loadingSellProducts || loadingSoldProducts || loadingFavProducts {
            return
        }
        
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        
        // If the 3 tabs are empty then display update UI with "no products available"
        if sellProducts.isEmpty && soldProducts.isEmpty && favProducts.isEmpty {
            
            collectionView.hidden = true
            youDontHaveTitleLabel.hidden = false
            sellButton.hidden = true
            soldButton.hidden = true
            favoriteButton.hidden = true
            
            // set text depending on if we are the user being shown or not
            if userObject?.objectId == PFUser.currentUser()?.objectId { // user is me!
                youDontHaveTitleLabel.text = translate("no_published_favorited_products")
                youDontHaveSubtitleLabel.hidden = false
                
                startSearchingNowButton.hidden = false
                startSellingNowButton.hidden = false
            }
            else {
                youDontHaveTitleLabel.text = translate("this_user_no_published_favorited_products")
                youDontHaveSubtitleLabel.hidden = true
                
                startSearchingNowButton.hidden = true
                startSellingNowButton.hidden = true
            }
        }
        // Else, update the UI and refresh the collection view
        else {
            collectionView.hidden = false
            
            youDontHaveTitleLabel.hidden = true
            youDontHaveSubtitleLabel.hidden = true
            
            startSearchingNowButton.hidden = true
            startSellingNowButton.hidden = true
            
            updateUIForCurrentTab()
        }
    }
    
    // MARK: Helper
    
    func productAtIndexPath(indexPath: NSIndexPath) -> PFObject? {
        let row = indexPath.row
        var product: PFObject?
        switch selectedTab {
        case .ProductImSelling:
            product = sellProducts[row]
        case .ProductISold:
            product = soldProducts[row]
        case .ProductFavourite:
            product = favProducts[row]
        }
        return product
    }
}
