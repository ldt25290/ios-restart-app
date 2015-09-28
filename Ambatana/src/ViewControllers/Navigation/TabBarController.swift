//
//  TabBarController.swift
//  LetGo
//
//  Created by AHL on 17/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Parse
import Result
import UIKit

public final class TabBarController: UITabBarController, NewSellProductViewControllerDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate {

    // Constants & enums
    private static let tooltipVerticalSpacingAnimBottom: CGFloat = 5
    private static let tooltipVerticalSpacingAnimTop: CGFloat = 25
    
    /**
     Defines the tabs contained in the TabBarController
    */
    enum Tab: Int {
        case Home = 0, Categories = 1, Sell = 2, Chats = 3, Profile = 4
        
        var tabIconImageName: String {
            switch self {
            case Home:
                return "tabbar_home"
            case Categories:
                return "tabbar_categories"
            case Sell:
                return "tabbar_sell"
            case Chats:
                return "tabbar_chats"
            case Profile:
                return "tabbar_profile"
            }
        }
        
        var viewController: UIViewController? {
            switch self {
            case Home:
                return MainProductsViewController()
            case Categories:
                return CategoriesViewController()
            case Sell:
                return nil
            case Chats:
                return ChatListViewController()
            case Profile:
                if let user = MyUserManager.sharedInstance.myUser() {
                    return EditProfileViewController(user: user)
                }
            }
            return nil
        }
        
        static var all:[Tab]{
            return Array(SequenceOf { () -> GeneratorOf<Tab> in
                    var i = 0
                    return GeneratorOf<Tab>{
                        return Tab(rawValue: i++)
                    }
                }
            )
        }
    }
    
    // Managers
    var productManager: ProductManager
    var userManager: UserManager
    
    // UI
    var floatingSellButton: FloatingButton!
    var sellButton: UIButton!
    var chatsTabBarItem: UITabBarItem?
    
    // MARK: - Lifecycle
    
    public convenience init() {
        let productManager = ProductManager()
        let userManager = UserManager()
        self.init(productManager: productManager, userManager: userManager)
    }
    
    public required init(productManager: ProductManager, userManager: UserManager) {
        // Managers
        self.productManager = productManager
        self.userManager = userManager
        
       super.init(nibName: nil, bundle: nil)
        
        // Generate the view controllers
        var vcs: [UIViewController] = []
        let iconInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
        for tab in Tab.all {
            vcs.append(controllerForTab(tab))
        }
        
        // Get the chats tab bar items
        if vcs.count > Tab.Chats.rawValue {
            chatsTabBarItem = vcs[Tab.Chats.rawValue].tabBarItem
        }
        
        // UITabBarController setup
        viewControllers = vcs
        delegate = self
        
        // Add the sell button as a custom one
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton = UIButton(frame: CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth, height: tabBar.frame.height))
        sellButton.addTarget(self, action: Selector("sellButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        sellButton.setImage(UIImage(named: Tab.Sell.tabIconImageName), forState: UIControlState.Normal)
//        sellButton.backgroundColor = StyleHelper.tabBarSellIconBgColor
        tabBar.addSubview(sellButton)
        
        // Add the floating sell button
        floatingSellButton = FloatingButton.floatingButtonWithTitle(NSLocalizedString("tab_bar_tool_tip", comment: ""), icon: UIImage(named: "ic_sell_white"))
        floatingSellButton.addTarget(self, action: Selector("sellButtonPressed"), forControlEvents: UIControlEvents.TouchUpInside)
        floatingSellButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(floatingSellButton)
        
        let sellCenterXConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
//        let sellBottomMarginConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .Bottom, relatedBy: .Equal, toItem: tabBar, attribute: .Top, multiplier: 1, constant: -15)
        let sellBottomMarginConstraint = NSLayoutConstraint(item: floatingSellButton, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: -65) // 44 (tabbar size= + 15
        view.addConstraints([sellCenterXConstraint,sellBottomMarginConstraint])
        
        // Initially set the chats tab badge to the app icon badge number
        if let chatsTab = chatsTabBarItem {
            let applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
            chatsTab.badgeValue = applicationIconBadgeNumber > 0 ? "\(applicationIconBadgeNumber)" : nil
        }
        
        // Update chats badge
        updateChatsBadge()
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "askUserToUpdateLocation", name: LocationManager.didMoveFromManualLocationNotification, object: nil)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unreadMessagesDidChange:", name: PushManager.Notification.unreadMessagesDidChange.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout:", name: MyUserManager.Notification.logout.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public override func viewWillLayoutSubviews() {
        // Move the sell button
        let itemWidth = self.tabBar.frame.width / CGFloat(self.tabBar.items!.count)
        sellButton.frame = CGRect(x: itemWidth * CGFloat(Tab.Sell.rawValue), y: 0, width: itemWidth, height: tabBar.frame.height)
    }
    
    // MARK: - Public / Internal methods
    
    /**
        Pops the current navigation controller to root and switches to the given tab.
        
        :param: The tab to go to.
    */
    func switchToTab(tab: Tab) {
        if let navBarCtl = selectedViewController as? UINavigationController {
            
            let vcIdx = tab.rawValue
            if vcIdx < viewControllers?.count {
                if let selectedVC = (viewControllers! as NSArray).objectAtIndex(tab.rawValue) as? UIViewController, let actualDelegate = delegate {

                    // If it should be selected
                    let shouldSelectVC = actualDelegate.tabBarController?(self, shouldSelectViewController: selectedVC) ?? true
                    if shouldSelectVC {
                        
                        // Change the tab
                        selectedIndex = vcIdx
                        
                        // Pop the navigation back to root
                        navBarCtl.popToRootViewControllerAnimated(false)
                        
                        // Notify the delegate, as programmatically change doesn't do it
                        actualDelegate.tabBarController?(self, didSelectViewController: selectedVC)
                    }
                }
            }
        }
    }
    
    /**
        Opens a deep link.
    
        :param: deepLink The deep link.
        :returns: If succesfully handled opening the deep link.
    */
    func openDeepLink(deepLink: DeepLink) -> Bool {
        if deepLink.isValid {
            switch deepLink.type {
            case .Home:
                switchToTab(.Home)
                break
            case .Sell:
                openSell()
            case .Product:
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    let productId = deepLink.components[0]
                    self?.openProductWithId(productId)
                }
            case .User:
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                    let userId = deepLink.components[0]
                    self?.openUserWithId(userId)
                }
           }
        }
        return true
    }
    
    /**
        Shows the app rating if needed.
    */
    func showAppRatingViewIfNeeded() {
        // If never shown before, show app rating view
        if !UserDefaultsManager.sharedInstance.loadAlreadyRated() {
            if let nav = selectedViewController as? UINavigationController, let ratingView = AppRatingView.ratingView() {
                let screenFrame = nav.view.frame
                UserDefaultsManager.sharedInstance.saveAlreadyRated(true)
                ratingView.setupWithFrame(screenFrame, contactBlock: { (vc) -> Void in
                    nav.pushViewController(vc, animated: true)
                })
                self.view.addSubview(ratingView)
            }
        }
    }
    
    // MARK: - SellProductViewControllerDelegate
    func sellProductViewController(sellVC: NewSellProductViewController?, didCompleteSell successfully: Bool) {
        if successfully {
            switchToTab(.Profile)
            
            showAppRatingViewIfNeeded()
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        let hidden = viewController.hidesBottomBarWhenPushed || tabBar.hidden
        setSellFloatingButtonHidden(hidden, animated: true)
    }
    
    // MARK: - UITabBarControllerDelegate
    
    public func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        let vcIdx = (viewControllers! as NSArray).indexOfObject(viewController)
        if let tab = Tab(rawValue: vcIdx) {
            
            var isLogInRequired = false
            var loginSource: EventParameterLoginSourceValue?
            
            // Do not allow selecting Sell
            if tab == .Sell {
                return false
            }
            // Chats require login
            else if tab == .Chats {
                loginSource = .Chats
                isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
            }
            // Profile require login
            else if tab == .Profile {
                loginSource = .Profile
                isLogInRequired = MyUserManager.sharedInstance.isMyUserAnonymous()
            }
            
            // Profile needs a user update
            if let user = MyUserManager.sharedInstance.myUser() {
                if let navVC = viewController as? UINavigationController, let profileVC = navVC.topViewController as? EditProfileViewController {
                    profileVC.user = user
                }
                else if let profileVC = viewController as? EditProfileViewController {
                    profileVC.user = user
                }
            }
            
            // If login is required
            if isLogInRequired {
                
                // If logged present the selected VC, otherwise present the login VC (and if successful the selected  VC)
                if let actualLoginSource = loginSource {
                    ifLoggedInThen(actualLoginSource, loggedInAction: { [weak self] in
                        self?.switchToTab(tab)
                    },
                    elsePresentSignUpWithSuccessAction: { [weak self] in
                        self?.switchToTab(tab)
                    })
                }
            }
            
            return !isLogInRequired
        }
        
        return true
    }
    
    public func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {

        // If we have a user
        if let user = MyUserManager.sharedInstance.myUser() {
            
            // And if it's my profile, then update the user
            if let navVC = viewController as? UINavigationController, let profileVC = navVC.topViewController as? EditProfileViewController {
                profileVC.user = user
            }
            else if let profileVC = viewController as? EditProfileViewController {
                profileVC.user = user
            }
        }
    }
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    private func controllerForTab(tab: Tab) -> UIViewController {
        let vc = tab.viewController
        let navCtl = UINavigationController(rootViewController: vc ?? UIViewController())
        navCtl.delegate = self
       
        
        let tabBarItem = UITabBarItem(title: nil, image: UIImage(named: tab.tabIconImageName), selectedImage: nil)

        // Customize the selected appereance
        tabBarItem.image = tabBarItem.selectedImage.imageWithColor(StyleHelper.tabBarIconUnselectedColor).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        tabBarItem.imageInsets = UIEdgeInsetsMake(5.5, 0, -5.5, 0)
        
        navCtl.tabBarItem = tabBarItem
        return navCtl
    }
    
    // MARK: > Action
    
    dynamic private func sellButtonPressed() {
        openSell()
    }
    
    // MARK: > UI
    
    private func updateChatsBadge() {
        if let chatsTab = chatsTabBarItem {
            let badgeNumber = PushManager.sharedInstance.unreadMessagesCount
            chatsTab.badgeValue = badgeNumber > 0 ? "\(badgeNumber)" : nil
        }
    }
   
    private func openSell() {
        // If logged present the sell, otherwise present the login VC (and if successful the sell)
        ifLoggedInThen(.Sell, loggedInAction: {
            self.presentSellVC()
        }, elsePresentSignUpWithSuccessAction: {
            self.presentSellVC()
        })
    }
    
    private func presentSellVC() {
        let vc = NewSellProductViewController()
        vc.completedSellDelegate = self
        let navCtl = UINavigationController(rootViewController: vc)
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    private func openProductWithId(productId: String) {
        // Show loading
        showLoadingMessageAlert()
        
        // Retrieve the product
        productManager.retrieveProductWithId(productId) { [weak self] (result: Result<Product, ProductRetrieveServiceError>) in
            
            var loadingDismissCompletion: (() -> Void)? = nil
            
            // Success
            if let product = result.value {
                
                // Dismiss the loading and push the product vc on dismissal
                loadingDismissCompletion = { () -> Void in
                    if let navBarCtl = self?.selectedViewController as? UINavigationController {
                        
                        // TODO: Refactor TabBarController with MVVM
                        let vm = ProductViewModel(product: product, tracker: TrackerProxy.sharedInstance)
                        let vc = ProductViewController(viewModel: vm)
                        navBarCtl.pushViewController(vc, animated: true)
                    }
                }
            }
            
            // Dismiss loading
            self?.dismissLoadingMessageAlert(completion: loadingDismissCompletion)
        }
    }

    private func openUserWithId(userId: String) {
        // Show loading
        showLoadingMessageAlert()
        
        // Retrieve the product
        userManager.retrieveUserWithId(userId) { [weak self] (result: Result<User, UserRetrieveServiceError>) in
            
            var loadingDismissCompletion: (() -> Void)? = nil
            
            // Success
            if let user = result.value {
                
                // Dismiss the loading and push the product vc on dismissal
                loadingDismissCompletion = { () -> Void in
                    if let navBarCtl = self?.selectedViewController as? UINavigationController {
                        
                        // TODO: Refactor TabBarController with MVVM
                        let vc = EditProfileViewController(user: user)
                        navBarCtl.pushViewController(vc, animated: true)
                    }
                }
            }
            
            // Dismiss loading
            self?.dismissLoadingMessageAlert(completion: loadingDismissCompletion)
        }
    }
    
    /**
        Shows/hides the sell floating button
    
        :param: hidden If should be hidden
        :param: animated If transition should be animated
    */
    private func setSellFloatingButtonHidden(hidden: Bool, animated: Bool) {
        let alpha: CGFloat = hidden ? 0 : 1
        if animated {
            floatingSellButton.hidden = hidden
           
            UIView.animateWithDuration(0.35) { [weak self] in
                self?.floatingSellButton.alpha = alpha
            }
        }
        else {
            floatingSellButton.hidden = hidden
        }
    }
    
    // MARK: > NSNotification
    
    @objc private func unreadMessagesDidChange(notification: NSNotification) {
        updateChatsBadge()
    }
    
    @objc private func logout(notification: NSNotification) {
        
        // Leave navCtl in its initial state, pop to root
        selectedViewController?.navigationController?.popToRootViewControllerAnimated(false)

        // Switch to home tab
        var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.switchToTab(.Home)
        })
    }
    
    @objc private func applicationWillEnterForeground(notification: NSNotification) {

    }
    
    dynamic private func askUserToUpdateLocation() {
        
        let firstAlert = UIAlertController(title: nil, message: NSLocalizedString("change_location_ask_update_location_message", comment: ""), preferredStyle: .Alert)
        let yesAction = UIAlertAction(title: NSLocalizedString("common_ok", comment: ""), style: .Default) { (updateToGPSLocation) -> Void in
            LocationManager.sharedInstance.userDidSetAutomaticLocation(nil)
        }
        let noAction = UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: .Cancel) { (showSecondAlert) -> Void in
            let secondAlert = UIAlertController(title: nil, message: NSLocalizedString("change_location_recommend_update_location_message", comment: ""), preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel", comment: ""), style: .Cancel, handler: nil)
            let updateAction = UIAlertAction(title: NSLocalizedString("change_location_confirm_update_button", comment: ""), style: .Default) { (updateToGPSLocation) -> Void in
                LocationManager.sharedInstance.userDidSetAutomaticLocation(nil)
            }
            secondAlert.addAction(cancelAction)
            secondAlert.addAction(updateAction)

            self.presentViewController(secondAlert, animated: true, completion: nil)
        }
        firstAlert.addAction(yesAction)
        firstAlert.addAction(noAction)
        
        self.presentViewController(firstAlert, animated: true, completion: nil)
        
        // We should ask only one time
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LocationManager.didMoveFromManualLocationNotification, object: nil)
        
    }
 }
