//
//  UserViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

enum UserSource {
    case TabBar
    case ProductDetail
    case Chat
}

protocol UserViewModelDelegate: BaseViewModelDelegate {
    func vmOpenSettings(settingsVC: SettingsViewController)
    func vmOpenReportUser(reportUserVM: ReportUsersViewModel)
    func vmOpenProduct(productVC: UIViewController)
    func vmOpenHome()
}

class UserViewModel: BaseViewModel {
    // Constants
    private static let userBgEffectAlphaMax: CGFloat = 0.9
    private static let userBgTintAlphaMax: CGFloat = 0.54

    // Repositories / Managers
    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository
    private let userRepository: UserRepository
    private let tracker: Tracker

    // Data & VMs
    private let user: Variable<User?>
    private(set) var isMyProfile: Bool
    private let userRelationIsBlocked = Variable<Bool>(false)
    private let userRelationIsBlockedBy = Variable<Bool>(false)
    private let source: UserSource

    private let sellingProductListViewModel: ProductListViewModel
    private let sellingProductListRequester: UserProductListRequester
    private let soldProductListViewModel: ProductListViewModel
    private let soldProductListRequester: UserProductListRequester
    private let favoritesProductListViewModel: ProductListViewModel
    private let favoritesProductListRequester: UserProductListRequester

    // Input
    let tab = Variable<UserViewHeaderTab>(.Selling)

    // Output
    let navBarButtons = Variable<[UIAction]>([])
    let backgroundColor = Variable<UIColor>(UIColor.clearColor())
    let headerMode = Variable<UserViewHeaderMode>(.MyUser)
    let userAvatarPlaceholder = Variable<UIImage?>(nil)
    let userAvatarURL = Variable<NSURL?>(nil)
    let userRelationText = Variable<String?>(nil)
    let userName = Variable<String?>(nil)
    let userLocation = Variable<String?>(nil)
    let userAccounts = Variable<UserViewHeaderAccounts?>(nil)

    let productListViewModel: Variable<ProductListViewModel>

    weak var delegate: UserViewModelDelegate?

    // Rx
    let disposeBag: DisposeBag


    // MARK: - Lifecycle

    static func myUserUserViewModel(source: UserSource) -> UserViewModel {
        return UserViewModel(source: source)
    }

    private convenience init(source: UserSource) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, myUserRepository: myUserRepository, userRepository: userRepository,
            tracker: tracker, isMyProfile: true, user: nil, source: source)
    }

    convenience init(user: User, source: UserSource) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(sessionManager: sessionManager, myUserRepository: myUserRepository, userRepository: userRepository,
            tracker: tracker, isMyProfile: false, user: user, source: source)
    }

    init(sessionManager: SessionManager, myUserRepository: MyUserRepository, userRepository: UserRepository,
        tracker: Tracker, isMyProfile: Bool, user: User?, source: UserSource) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.userRepository = userRepository
        self.tracker = tracker
        self.isMyProfile = isMyProfile
        self.user = Variable<User?>(user)
        self.source = source

        self.sellingProductListRequester = UserStatusesProductListRequester(statuses: [.Pending, .Approved])
        self.sellingProductListViewModel = ProductListViewModel(requester: self.sellingProductListRequester)
        self.soldProductListRequester = UserStatusesProductListRequester(statuses: [.Sold, .SoldOld])
        self.soldProductListViewModel = ProductListViewModel(requester: self.soldProductListRequester)
        self.favoritesProductListRequester = UserFavoritesProductListRequester()
        self.favoritesProductListViewModel = ProductListViewModel(requester: self.favoritesProductListRequester)

        self.productListViewModel = Variable<ProductListViewModel>(sellingProductListViewModel)
        self.disposeBag = DisposeBag()
        super.init()

        self.sellingProductListViewModel.dataDelegate = self
        self.soldProductListViewModel.dataDelegate = self
        self.favoritesProductListViewModel.dataDelegate = self

        setupNotificationCenterObservers()
        setupRxBindings()
    }

    deinit {
        tearDownNotificationCenterObservers()
    }


    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if itsMe {
            updateWithMyUser()
        }
        retrieveUserAccounts()

        refreshIfLoading()
        trackVisit()
    }
}


// MARK: - Public methods

extension UserViewModel {
    func refreshSelling() {
        sellingProductListViewModel.retrieveProducts()
    }

    func avatarButtonPressed() {
        guard isMyProfile else { return }
        openSettings()
    }
}

// MARK: - Private methods
// MARK: > Helpers

extension UserViewModel {
    private var isMyUser: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId else { return false }
        guard let userId = user.value?.objectId else { return false }
        return myUserId == userId
    }

    private var itsMe: Bool {
        return isMyProfile || isMyUser
    }

    private func updateWithMyUser() {
        guard let myUser = myUserRepository.myUser else { return }
        user.value = myUser
    }

    private func buildNavBarButtons() -> [UIAction] {
        var navBarButtons = [UIAction]()

        if isMyProfile {
            navBarButtons.append(buildSettingsNavBarAction())
        } else if sessionManager.loggedIn && !isMyUser {
            navBarButtons.append(buildMoreNavBarAction())
        }
        return navBarButtons
    }

    private func buildSettingsNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_settings")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            self?.openSettings()
        })
    }

    private func buildMoreNavBarAction() -> UIAction {
        let icon = UIImage(named: "navbar_more")?.imageWithRenderingMode(.AlwaysOriginal)
        return UIAction(interface: .Image(icon), action: { [weak self] in
            guard let strongSelf = self else { return }

            var actions = [UIAction]()
            actions.append(strongSelf.buildReportButton())

            if strongSelf.userRelationIsBlocked.value {
                actions.append(strongSelf.buildUnblockButton())
            } else {
                actions.append(strongSelf.buildBlockButton())
            }

            strongSelf.delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: actions)
        })
    }

    private func buildReportButton() -> UIAction {
        let title = LGLocalizedString.reportUserTitle
        return UIAction(interface: .Text(title), action: { [weak self] in
            guard let strongSelf = self, userReported = strongSelf.user.value else { return }
            let reportVM = ReportUsersViewModel(origin: .Profile, userReported: userReported)
            strongSelf.delegate?.vmOpenReportUser(reportVM)
        })
    }

    private func buildBlockButton() -> UIAction {
        let title = LGLocalizedString.chatBlockUser
        return UIAction(interface: .Text(title), action: { [weak self] in
            let title = LGLocalizedString.chatBlockUserAlertTitle
            let message = LGLocalizedString.chatBlockUserAlertText
            let cancelLabel = LGLocalizedString.commonCancel
            let actionTitle = LGLocalizedString.chatBlockUserAlertBlockButton
            let action = UIAction(interface: .StyledText(actionTitle, .Destructive), action: { [weak self] in
                self?.block()
            })
            self?.delegate?.vmShowAlert(title, message: message, cancelLabel: cancelLabel, actions: [action])
        })
    }

    private func buildUnblockButton() -> UIAction {
        let title = LGLocalizedString.chatUnblockUser
        return UIAction(interface: .Text(title), action: { [weak self] in
            self?.unblock()
        })
    }

    private func refreshIfLoading() {
        let listVM = productListViewModel.value
        switch listVM.state {
        case .FirstLoad:
            listVM.retrieveProducts()
        case .Data, .Error:
            break
        }
    }

    private func openSettings() {
        // TODO: Refactor settings to MVVM
        let vc = SettingsViewController()
        delegate?.vmOpenSettings(vc)
    }
}


// MARK: > NSNotificationCenter

extension UserViewModel {
    private func setupNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UserViewModel.login(_:)),
            name: SessionManager.Notification.Login.rawValue, object: nil)
    }

    private func tearDownNotificationCenterObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    dynamic private func login(notification: NSNotification) {
        if isMyProfile {
            updateWithMyUser()
        }
    }
}



// MARK: > Requests

extension UserViewModel {
    private func retrieveUserAccounts() {
        guard userAccounts.value == nil else { return }
        guard let userId = user.value?.objectId else { return }

        userRepository.show(userId, includeAccounts: true) { [weak self] result in
            guard let user = result.value else { return }
            self?.updateAccounts(user)
        }
    }

    private func retrieveUsersRelation() {
        guard let userId = user.value?.objectId else { return }
        guard !itsMe else { return }

        userRepository.retrieveUserToUserRelation(userId) { [weak self] result in
            guard let userRelation = result.value else { return }
            self?.userRelationIsBlocked.value = userRelation.isBlocked
            self?.userRelationIsBlockedBy.value = userRelation.isBlockedBy
        }
    }

    private func block() {
        guard let userId = user.value?.objectId else { return }

        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        userRepository.blockUserWithId(userId) { [weak self] result in
            self?.trackBlock(userId)

            var afterMessageCompletion: (() -> ())? = nil
            if let _ = result.value {
                self?.userRelationIsBlocked.value = true
            } else {
                afterMessageCompletion = {
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
                }
            }
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: afterMessageCompletion)
        }
    }

    private func unblock() {
        guard let userId = user.value?.objectId else { return }

        delegate?.vmShowLoading(LGLocalizedString.commonLoading)
        userRepository.unblockUserWithId(userId) { [weak self] result in
            self?.trackUnblock(userId)

            var afterMessageCompletion: (() -> ())? = nil
            if let _ = result.value {
                self?.userRelationIsBlocked.value = false
            } else {
                afterMessageCompletion = {
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.unblockUserErrorGeneric, completion: nil)
                }
            }
            self?.delegate?.vmHideLoading(nil, afterMessageCompletion: afterMessageCompletion)
        }
    }
}


// MARK: > Rx

extension UserViewModel {
    private func setupRxBindings() {
        setupUserInfoRxBindings()
        setupUserRelationRxBindings()
        setupTabRxBindings()
        setupProductListViewRxBindings()
    }

    private func setupUserInfoRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            guard let strongSelf = self else { return }

            if strongSelf.isMyProfile {
                strongSelf.backgroundColor.value = StyleHelper.defaultBackgroundColor
                strongSelf.userAvatarPlaceholder.value = LetgoAvatar.avatarWithColor(StyleHelper.defaultAvatarColor,
                    name: user?.name)
            } else {
                strongSelf.backgroundColor.value = StyleHelper.backgroundColorForString(user?.objectId)
                strongSelf.userAvatarPlaceholder.value = LetgoAvatar.avatarWithID(user?.objectId, name: user?.name)
            }
            strongSelf.userAvatarURL.value = user?.avatar?.fileURL
            strongSelf.userName.value = user?.name
            strongSelf.userLocation.value = user?.postalAddress.cityCountryString

            strongSelf.headerMode.value = strongSelf.isMyProfile ? .MyUser : .OtherUser

            // If the user has accounts the set them up
            if let user = user, _ = user.accounts {
                strongSelf.updateAccounts(user)
            }

        }.addDisposableTo(disposeBag)
    }

    private func updateAccounts(user: User) {
        let facebookAccount = user.facebookAccount
        let googleAccount = user.googleAccount
        let emailAccount = user.emailAccount

        let facebookLinked = facebookAccount != nil
        let facebookVerified = facebookAccount?.verified ?? false
        let googleLinked = googleAccount != nil
        let googleVerified = googleAccount?.verified ?? false
        let emailLinked = emailAccount != nil
        let emailVerified = emailAccount?.verified ?? false
        userAccounts.value = UserViewHeaderAccounts(facebookLinked: facebookLinked,
                                                    facebookVerified: facebookVerified,
                                                    googleLinked: googleLinked,
                                                    googleVerified: googleVerified,
                                                    emailLinked: emailLinked,
                                                    emailVerified: emailVerified)
    }

    private func setupUserRelationRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            self?.userRelationIsBlocked.value = false
            self?.userRelationIsBlockedBy.value = false
            self?.retrieveUsersRelation()
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(userRelationIsBlocked.asObservable(), userRelationIsBlockedBy.asObservable(),
            userName.asObservable()) { (isBlocked, isBlockedBy, userName) -> String? in
            if isBlocked {
                if let userName = userName {
                    return LGLocalizedString.profileBlockedByMeLabelWName(userName)
                } else {
                    return LGLocalizedString.profileBlockedByMeLabel
                }
            } else if isBlockedBy {
                return LGLocalizedString.profileBlockedByOtherLabel
            }
            return nil
        }.bindTo(userRelationText).addDisposableTo(disposeBag)

        userRelationText.asObservable().subscribeNext { [weak self] relation in
            guard let strongSelf = self else { return }
            strongSelf.navBarButtons.value = strongSelf.buildNavBarButtons()
        }.addDisposableTo(disposeBag)
    }

    private func setupTabRxBindings() {
        tab.asObservable().skip(1).map { [weak self] tab -> ProductListViewModel? in
            switch tab {
            case .Selling:
                return self?.sellingProductListViewModel
            case .Sold:
                return self?.soldProductListViewModel
            case .Favorites:
                return self?.favoritesProductListViewModel
            }
        }.subscribeNext { [weak self] viewModel in
            guard let viewModel = viewModel else { return }
            self?.productListViewModel.value = viewModel
            self?.refreshIfLoading()
        }.addDisposableTo(disposeBag)
    }

    private func setupProductListViewRxBindings() {
        user.asObservable().subscribeNext { [weak self] user in
            self?.sellingProductListRequester.userObjectId = user?.objectId
            self?.sellingProductListViewModel.resetUI()
            self?.soldProductListRequester.userObjectId = user?.objectId
            self?.soldProductListViewModel.resetUI()
            self?.favoritesProductListRequester.userObjectId = user?.objectId
            self?.favoritesProductListViewModel.resetUI()
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ProductListViewModelDataDelegate

extension UserViewModel: ProductListViewModelDataDelegate {
    func productListMV(viewModel: ProductListViewModel, didFailRetrievingProductsPage page: UInt, hasProducts: Bool,
                       error: RepositoryError) {
        guard page == 0 && !hasProducts else { return }

        var errorData = ViewErrorData(repositoryError: error, retryAction: { [weak viewModel] in viewModel?.refresh() })
        errorData.image = nil
        viewModel.state = .Error(data: errorData)
    }

    func productListVM(viewModel: ProductListViewModel, didSucceedRetrievingProductsPage page: UInt, hasProducts: Bool) {
        guard page == 0 && !hasProducts else { return }

        let errTitle: String?
        let errButTitle: String?
        var errButAction: (()->Void)? = nil
        if viewModel === sellingProductListViewModel {
            errTitle = LGLocalizedString.profileSellingNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSellingOtherUserNoProductsButton
        } else if viewModel === soldProductListViewModel {
            errTitle = LGLocalizedString.profileSoldNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileSoldOtherNoProductsButton
        } else if viewModel === favoritesProductListViewModel {
            errTitle = LGLocalizedString.profileFavouritesMyUserNoProductsLabel
            errButTitle = itsMe ? nil : LGLocalizedString.profileFavouritesMyUserNoProductsButton
            errButAction = { [weak self] in self?.delegate?.vmOpenHome() }
        } else { return }

        let errorData = ViewErrorData(title: errTitle, buttonTitle: errButTitle, buttonAction: errButAction)
        viewModel.state = .Error(data: errorData)
    }

    func productListVM(viewModel: ProductListViewModel, didSelectItemAtIndex index: Int, thumbnailImage: UIImage?,
                       originFrame: CGRect?) {
        guard viewModel === productListViewModel.value else { return } //guarding view model is the selected one
        guard let productVC = ProductDetailFactory.productDetailFromProductList(viewModel, index: index,
                                                                    thumbnailImage: thumbnailImage, originFrame: originFrame) else { return }
        delegate?.vmOpenProduct(productVC)
    }
}


// MARK: - Tracking

extension UserViewModel {
    private func trackVisit() {
        guard let user = user.value else { return }

        let typePage: EventParameterTypePage?
        switch source {
        case .TabBar:
            typePage = nil
        case .Chat:
            typePage = .Chat
        case .ProductDetail:
            typePage = .ProductDetail
        }
        guard let actualTypePage = typePage else { return }

        let eventTab: EventParameterTab
        switch tab.value {
        case .Selling:
            eventTab = .Selling
        case .Sold:
            eventTab = .Sold
        case .Favorites:
            eventTab = .Favorites
        }

        let event = TrackerEvent.profileVisit(user, typePage: actualTypePage, tab: eventTab)
        tracker.trackEvent(event)
    }

    private func trackBlock(userId: String) {
        let event = TrackerEvent.profileBlock(.Profile, blockedUsersIds: [userId])
        tracker.trackEvent(event)
    }

    private func trackUnblock(userId: String) {
        let event = TrackerEvent.profileUnblock(.Profile, unblockedUsersIds: [userId])
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}
