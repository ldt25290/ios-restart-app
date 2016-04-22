//
//  UserViewController.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CHTCollectionViewWaterfallLayout
import LGCoreKit
import RxCocoa
import RxSwift

class UserViewController: BaseViewController {
    private static let navBarUserViewHeight: CGFloat = 36
    private static let userBgViewDefaultHeight: CGFloat = headerExpandedHeight

    private static let productListViewTopMargin: CGFloat = 64

    private static let headerExpandedBottom: CGFloat = -(headerExpandedHeight+userBgViewDefaultHeight)
    private static let headerExpandedHeight: CGFloat = 150

    private static let headerCollapsedBottom: CGFloat = -108 // 20 status bar + 44 fake nav bar + 44 header buttons
    private static let headerCollapsedHeight: CGFloat = 44

    private static let expandedPercentageUserInfoSwitch: CGFloat = 0.75
    private static let expandedPercentageUserInfoDisappear: CGFloat = 1.2

    private static let userBgTintViewHeaderExpandedAlpha: CGFloat = 0.54
    private static let userBgTintViewHeaderCollapsedAlpha: CGFloat = 1.0

    private static let userEffectViewHeaderExpandedAlpha: CGFloat = 0.85
    private static let userEffectViewHeaderCollapsedAlpha: CGFloat = 1.0

    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    private var navBarUserView: UserView?
    private var navBarUserViewAlphaOnDisappear: CGFloat = 0.0

    @IBOutlet weak var patternView: UIView!
    @IBOutlet weak var userBgView: UIView!
    @IBOutlet weak var userBgEffectView: UIVisualEffectView!

    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var headerContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var headerContainerViewHeight: NSLayoutConstraint!

    var header: UserViewHeader?
    let headerGestureRecognizer: UIPanGestureRecognizer
    @IBOutlet weak var productListViewBackgroundView: UIView!
    @IBOutlet weak var productListView: ProductListView!

    @IBOutlet weak var userLabelsContainer: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userBgImageView: UIImageView!
    @IBOutlet weak var userBgTintView: UIView!

    private var bottomInset: CGFloat = 0
    private let cellDrawer: ProductCellDrawer
    private var viewModel: UserViewModel

    private let headerExpandedPercentage = Variable<CGFloat>(1)
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    init(viewModel: UserViewModel) {
        let size = CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight)
        self.navBarUserView = UserView.userView(.CompactBorder(size: size))
        self.header = UserViewHeader.userViewHeader()
        self.headerGestureRecognizer = UIPanGestureRecognizer()
        self.viewModel = viewModel
        self.cellDrawer = ProductCellDrawerFactory.drawerForProduct(true)
        self.disposeBag = DisposeBag()
        super.init(viewModel: viewModel, nibName: "UserViewController", statusBarStyle: .LightContent)
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage

        if let tabBarCtl = tabBarController {
            bottomInset = tabBarCtl.tabBar.hidden ? 0 : tabBarCtl.tabBar.frame.height
        }
        else {
            bottomInset = 0
        }

        setupUI()
        setupRxBindings()
    }

    override func viewWillAppearFromBackground(fromBackground: Bool) {
        super.viewWillAppearFromBackground(fromBackground)

        setNavigationBarStyle()

        // UINavigationBar's title alpha gets resetted on view appear, does not allow initial 0.0 value
        if let navBarUserView = navBarUserView {
            let currentAlpha: CGFloat = navBarUserViewAlphaOnDisappear
            navBarUserView.hidden = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.01 * Double(NSEC_PER_SEC))),
                dispatch_get_main_queue()) {
                    navBarUserView.alpha = currentAlpha
                    navBarUserView.hidden = false
            }
        }
    }

    override func viewWillDisappearToBackground(toBackground: Bool) {
        super.viewWillDisappearToBackground(toBackground)
        revertNavigationBarStyle()
        if let navBarUserView = navBarUserView {
            navBarUserViewAlphaOnDisappear = navBarUserView.alpha
        }
    }
}


// MARK: - ProductsRefreshable

extension UserViewController: ProductsRefreshable {
    func productsRefresh() {
        viewModel.refreshSelling()
    }
}


// MARK: - ProductListViewScrollDelegate

extension UserViewController: ProductListViewScrollDelegate {
    func productListView(productListView: ProductListView, didScrollDown scrollDown: Bool) {
    }

    func productListView(productListView: ProductListView, didScrollWithContentOffsetY contentOffsetY: CGFloat) {
        updateContentInset(contentOffsetY)
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController: UserViewModelDelegate {
    func vmOpenSettings(settingsVC: SettingsViewController) {
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    func vmOpenReportUser(reportUserVM: ReportUsersViewModel) {
        let vc = ReportUsersViewController(viewModel: reportUserVM)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmOpenProduct(productVC: UIViewController) {
        navigationController?.pushViewController(productVC, animated: true)
    }

    func vmOpenHome() {
        guard let tabBarCtl = tabBarController as? TabBarController else { return }
        tabBarCtl.switchToTab(.Home)
    }
}


// MARK: - UserViewModelDelegate

extension UserViewController : UserViewHeaderDelegate {
    func headerAvatarAction() {
        viewModel.avatarButtonPressed()
    }
}


// MARK: - Private methods
// MARK: - UI

extension UserViewController {
    private func setupUI() {
        hidesBottomBarWhenPushed = false
        automaticallyAdjustsScrollViewInsets = false

        setupUserBgView()
        setupMainView()
        setupHeader()
        setupNavigationBar()
        setupProductListView()
    }

    private func setupMainView() {
        guard let patternImage = UIImage(named: "pattern_transparent") else { return }
        patternView.backgroundColor = UIColor(patternImage: patternImage)
    }

    private func setupHeader() {
        guard let header = header else { return }
        header.delegate = self
        header.translatesAutoresizingMaskIntoConstraints = false
        headerContainerView.addSubview(header)

        headerGestureRecognizer.addTarget(self, action: #selector(UserViewController.handleHeaderPan))
        view.addGestureRecognizer(headerGestureRecognizer)

        let views = ["header": header]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[header]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(hConstraints)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[header]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        view.addConstraints(vConstraints)

        headerContainerBottom.constant = UserViewController.headerExpandedBottom
        headerContainerViewHeight.constant = UserViewController.headerExpandedHeight
    }

    private func setupNavigationBar() {
        if let navBarUserView = navBarUserView {
            navBarUserView.alpha = 0
            navBarUserView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat.max, height: UserViewController.navBarUserViewHeight))
        }

        let backIcon = UIImage(named: "navbar_back_white_shadow")
        setLetGoNavigationBarStyle(navBarUserView, backIcon: backIcon)
    }

    private func setupUserBgView() {
    }

    private func setupProductListView() {
        productListViewBackgroundView.backgroundColor = StyleHelper.userProductListBgColor



        // Remove pull to refresh
        productListView.refreshControl?.removeFromSuperview()
        productListView.setErrorViewStyle(bgColor: nil, borderColor: nil, containerColor: nil)
        productListView.shouldScrollToTopOnFirstPageReload = false
        productListView.padding = UIEdgeInsets(top: UserViewController.productListViewTopMargin, left: 0, bottom: 0, right: 0)

        let top = abs(UserViewController.headerExpandedBottom + UserViewController.productListViewTopMargin)
        let contentInset = UIEdgeInsets(top: top, left: 0, bottom: bottomInset, right: 0)
        productListView.collectionViewContentInset = contentInset
        productListView.collectionView.scrollIndicatorInsets.top = contentInset.top
        productListView.scrollDelegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        productListView.minimumContentHeight = productListView.collectionView.frame.height - UserViewController.headerCollapsedHeight - bottomInset
    }

    private func setNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func revertNavigationBarStyle() {
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
    }

    private func updateContentInset(contentOffsetInsetY: CGFloat) {
        let minBottom = UserViewController.headerExpandedBottom
        let maxBottom = UserViewController.headerCollapsedBottom

        let bottom = min(maxBottom, contentOffsetInsetY - UserViewController.productListViewTopMargin)
        headerContainerBottom.constant = bottom

        let percentage = min(1, abs(bottom - maxBottom) / abs(maxBottom - minBottom))

        let height = UserViewController.headerCollapsedHeight + percentage * (UserViewController.headerExpandedHeight - UserViewController.headerCollapsedHeight)
        headerContainerViewHeight.constant = height

        // header expands more than 100% to hide the avatar when pulling
        let headerPercentage = abs(bottom - maxBottom) / abs(maxBottom - minBottom)
        headerExpandedPercentage.value = headerPercentage
//        print("🌻🌻🌻 \(contentOffsetInsetY) \(bottom) \(percentage) \(headerPercentage) \(height)")
    }

    dynamic private func handleHeaderPan(gestureRecognizer: UIPanGestureRecognizer) {
        guard viewModel.shouldScrollOnPan() else { return }

//        let minTop = UserViewController.headerCollapsedHeaderTop
//        let maxTop = UserViewController.headerExpandedHeaderTop
//
//        let translation = gestureRecognizer.translationInView(view)
//        gestureRecognizer.setTranslation(CGPoint.zero, inView: view)
//
//        let currentInset = productListView.contentInset.top
//        let top = currentInset + translation.y
//
//        headerContainerViewTop.constant = top + minTop
//
//        let contentInset = UIEdgeInsets(top: min(maxTop, top), left: 0, bottom: bottomInset, right: 0)
//        productListView.contentInset = contentInset
//        productListView.collectionViewContentInset = contentInset
//        productListView.collectionView.scrollIndicatorInsets.top = contentInset.top
//
//        let percentage = 1 - (top / (maxTop - minTop))
//        headerCollapsePercentage.value = percentage
    }
}


// MARK: - Rx

extension UserViewController {
    private func setupRxBindings() {
        setupBackgroundRxBindings()
        setupUserBgViewRxBindings()
        setupNavBarRxBindings()
        setupHeaderRxBindings()
        setupProductListViewRxBindings()
    }

    private func setupBackgroundRxBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.view.backgroundColor = bgColor
        }.addDisposableTo(disposeBag)
    }

    private func setupUserBgViewRxBindings() {
        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.userBgTintView.backgroundColor = bgColor
        }.addDisposableTo(disposeBag)

        // Pattern overlay is hidden if there's no avatarand user background view is shown if so
        let userAvatar = viewModel.userAvatarURL.asObservable()
        userAvatar.map { url in
            guard let url = url else { return false }
            return !url.absoluteString.isEmpty
        }.bindTo(patternView.rx_hidden).addDisposableTo(disposeBag)

        userAvatar.map { url in
            guard let url = url else { return true }
            return url.absoluteString.isEmpty
        }.bindTo(userBgView.rx_hidden).addDisposableTo(disposeBag)

        // Load avatar image
        viewModel.userAvatarURL.asObservable().subscribeNext { [weak self] url in
            self?.userBgImageView.sd_setImageWithURL(url)
        }.addDisposableTo(disposeBag)
    }

    private func setupNavBarRxBindings() {
        Observable.combineLatest(
            viewModel.userName.asObservable(),
            viewModel.userLocation.asObservable(),
            viewModel.userAvatarURL.asObservable(),
            viewModel.userAvatarPlaceholder.asObservable()) { $0 }
        .subscribeNext { [weak self] (userName, userLocation, avatar, placeholder) in
            guard let navBarUserView = self?.navBarUserView else { return }
            navBarUserView.setupWith(userAvatar: avatar, placeholder: placeholder, userName: userName,
                subtitle: userLocation)
        }.addDisposableTo(disposeBag)

        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }

            var buttons = [UIButton]()
            navBarButtons.forEach { navBarButton in
                let button = UIButton(type: .System)
                button.setImage(navBarButton.image, forState: .Normal)
                button.rx_tap.bindNext { _ in
                    navBarButton.action()
                }.addDisposableTo(strongSelf.disposeBag)
                buttons.append(button)
            }
            strongSelf.setNavigationBarRightButtons(buttons)
        }.addDisposableTo(disposeBag)
    }

    private func setupHeaderRxBindings() {
        // Name, location, avatar & bg
        viewModel.userName.asObservable().bindTo(userNameLabel.rx_optionalText).addDisposableTo(disposeBag)
        viewModel.userLocation.asObservable().bindTo(userLocationLabel.rx_optionalText).addDisposableTo(disposeBag)

        Observable.combineLatest(viewModel.userAvatarURL.asObservable(),
            viewModel.userAvatarPlaceholder.asObservable()) { ($0, $1) }
            .subscribeNext { [weak self] (avatar, placeholder) in
                self?.header?.setAvatar(avatar, placeholderImage: placeholder)
        }.addDisposableTo(disposeBag)

        viewModel.backgroundColor.asObservable().subscribeNext { [weak self] bgColor in
            self?.header?.selectedColor = bgColor
        }.addDisposableTo(disposeBag)

        // User relation
        viewModel.userRelationText.asObservable().subscribeNext { [weak self] userRelationText in
            self?.header?.setUserRelationText(userRelationText)
        }.addDisposableTo(disposeBag)

        // Accounts
        viewModel.userAccounts.asObservable().subscribeNext { [weak self] accounts in
            self?.header?.accounts = accounts
        }.addDisposableTo(disposeBag)

        // Header mode
        viewModel.headerMode.asObservable().subscribeNext { [weak self] mode in
            self?.header?.mode = mode
        }.addDisposableTo(disposeBag)

        // Header collapse notify percentage
        headerExpandedPercentage.asObservable().map { percentage -> CGFloat in
            let max = UserViewController.userBgTintViewHeaderCollapsedAlpha
            let min = UserViewController.userBgTintViewHeaderExpandedAlpha
            return min + 1 - (percentage * max)
        }.bindTo(userBgTintView.rx_alpha).addDisposableTo(disposeBag)

        headerExpandedPercentage.asObservable().map { percentage -> CGFloat in
            let max = UserViewController.userEffectViewHeaderCollapsedAlpha
            let min = UserViewController.userEffectViewHeaderExpandedAlpha
            return min + 1 - (percentage * max)
        }.bindTo(userBgEffectView.rx_alpha).addDisposableTo(disposeBag)

        // Header collapse switch
        headerExpandedPercentage.asObservable().map { $0 <= UserViewController.expandedPercentageUserInfoSwitch }
            .distinctUntilChanged().subscribeNext { [weak self] collapsed in
                self?.header?.collapsed = collapsed

                UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: {
                    let topAlpha: CGFloat = collapsed ? 1 : 0
                    let bottomAlpha: CGFloat = collapsed ? 0 : 1
                    self?.navBarUserView?.alpha = topAlpha
                    self?.userLabelsContainer.alpha = bottomAlpha
                    }, completion: nil)
        }.addDisposableTo(disposeBag)

        // Header disappear
        headerExpandedPercentage.asObservable().map { $0 >= UserViewController.expandedPercentageUserInfoDisappear }
            .distinctUntilChanged().subscribeNext { [weak self] hidden in
                self?.header?.collapsed = hidden

                UIView.animateWithDuration(0.2, delay: 0, options: [.CurveEaseIn, .BeginFromCurrentState], animations: {
                    self?.userLabelsContainer.alpha = hidden ? 0 : 1
                }, completion: nil)
        }.addDisposableTo(disposeBag)

        // Tab switch
        header?.tab.asObservable().bindTo(viewModel.tab).addDisposableTo(disposeBag)
    }

    private func setupProductListViewRxBindings() {
        viewModel.productListViewModel.asObservable().subscribeNext { [weak self] viewModel in
            self?.productListView.switchViewModel(viewModel)
            self?.productListView.refreshDataView()
//            self?.productListView.scrollToTop(false)
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ScrollableToTop

extension UserViewController: ScrollableToTop {
    func scrollToTop() {
        productListView.scrollToTop(true)
    }
}
