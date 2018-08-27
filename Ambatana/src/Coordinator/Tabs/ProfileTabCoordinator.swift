import LGCoreKit
import SafariServices
import LGComponents

protocol ProfileCoordinatorSearchAlertsDelegate: class {
    func profileCoordinatorSearchAlertsOpenSearch()
}

final class ProfileTabCoordinator: TabCoordinator {

    weak var profileCoordinatorSearchAlertsDelegate: ProfileCoordinatorSearchAlertsDelegate?

    private lazy var changePasswordAssembly = ChangePasswordBuilder.standard(root: navigationController)
    private lazy var editAssemby = EditListingBuilder.modal(navigationController)

    convenience init(source: UserSource = .tabBar) {
        let sessionManager = Core.sessionManager
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let chatRepository = Core.chatRepository
        let myUserRepository = Core.myUserRepository
        let installationRepository = Core.installationRepository
        let bubbleNotificationManager =  LGBubbleNotificationManager.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let tracker = TrackerProxy.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let viewModel = UserProfileViewModel.makePrivateProfile(source: source)
        let rootViewController = UserProfileViewController(viewModel: viewModel)
        self.init(listingRepository: listingRepository,
                  userRepository: userRepository,
                  chatRepository: chatRepository,
                  myUserRepository: myUserRepository,
                  installationRepository: installationRepository,
                  bubbleNotificationManager: bubbleNotificationManager,
                  keyValueStorage: keyValueStorage,
                  tracker: tracker,
                  rootViewController: rootViewController,
                  featureFlags: featureFlags,
                  sessionManager: sessionManager,
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)

        viewModel.profileNavigator = self
    }

    override func presentViewController(parent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard viewController.parent == nil else { return }
        parent.present(viewController, animated: animated, completion: completion)
    }

    override func dismissViewController(animated: Bool, completion: (() -> Void)?) {
        viewController.dismissWithPresented(animated: animated, completion: completion)
    }
}

extension ProfileTabCoordinator: ProfileTabNavigator {
    func openAskPhoneFor(listing: Listing, interlocutor: User?) {
        // Ignore. This case only needs to be handled by the public user coordinator
        return
    }
    
    func openLoginIfNeeded(infoMessage: String, then loggedInAction: @escaping (() -> Void)) {
        // Ignore. This case only needs to be handled by the public user coordinator
        return
    }
    
    func openSettings() {
        let vm = SettingsViewModel()
        vm.navigator = self
        let vc = SettingsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func editListing(_ listing: Listing, pageType: EventParameterTypePage?) {
        let vc = editAssemby.buildEditView(listing: listing,
                                           pageType: pageType,
                                           bumpUpProductData: nil,
                                           listingCanBeBoosted: false,
                                           timeSinceLastBump: nil,
                                           maxCountdown: 0,
                                           onEditAction: nil)
        navigationController.present(vc, animated: true)
    }

    func closeProfile() {
        dismissViewController(animated: true, completion: nil)
    }
}

extension ProfileTabCoordinator: SettingsNavigator {
    func openEditUserName() {
        let vm = ChangeUsernameViewModel()
        vm.navigator = self
        let vc = ChangeUsernameViewController(vm: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditEmail() {
        let vm = ChangeEmailViewModel()
        vm.navigator = self
        let vc = ChangeEmailViewController(with: vm)
        navigationController.pushViewController(vc, animated: true)
    }

    func openEditLocation(withDistanceRadius distanceRadius: Int?) {
        let assembly = QuickLocationFiltersBuilder.standard(navigationController)
        let vc = assembly.buildQuickLocationFilters(mode: .editUserLocation,
                                                    initialPlace: nil,
                                                    distanceRadius: distanceRadius,
                                                    locationDelegate: nil)
        navigationController.pushViewController(vc, animated: true)
    }

    func openChangePassword() {
        let vc = changePasswordAssembly.buildChangePassword()
        navigationController.pushViewController(vc, animated: true)
    }

    func openHelp() {
        let vc = LGHelpBuilder.standard(navigationController).buildHelp()
        navigationController.pushViewController(vc, animated: true)
    }

    func openNotificationSettings() {
        let vm = NotificationSettingsViewModel()
        vm.navigator = self
        let vc = NotificationSettingsViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func closeSettings() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: ChangeUsernameNavigator {

    func closeChangeUsername() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: ChangeEmailNavigator {
    func closeChangeEmail() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: HelpNavigator {
    func open(url: URL) {
        navigationController.openInAppWebViewWith(url: url)
    }

    func closeHelp() {
        navigationController.popViewController(animated: true)
    }
}

extension ProfileTabCoordinator: NotificationSettingsNavigator {
    func closeNotificationSettings() {
        navigationController.popViewController(animated: true)
    }

    func openSearchAlertsList() {
        let vm = SearchAlertsListViewModel()
        vm.navigator = self
        let vc = SearchAlertsListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openNotificationSettingsList(notificationSettingsType: NotificationSettingsType) {
        if featureFlags.notificationSettings == .differentLists {
            openNotificationSettingsAccessorList(notificationSettingsType: notificationSettingsType)
        } else if featureFlags.notificationSettings == .sameList {
            openNotificationSettingsCompleteList(notificationSettingType: notificationSettingsType)
        }
    }
    
    private func openNotificationSettingsAccessorList(notificationSettingsType: NotificationSettingsType) {
        let vm: NotificationSettingsAccessorListViewModel
        switch notificationSettingsType {
        case .push:
            vm = NotificationSettingsAccessorListViewModel.makePusherNotificationSettingsListViewModel()
        case .mail:
            vm = NotificationSettingsAccessorListViewModel.makeMailerNotificationSettingsListViewModel()
        case .marketing, .searchAlerts:
            return
        }
        vm.navigator = self
        let vc = NotificationSettingsAccessorListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func openNotificationSettingsCompleteList(notificationSettingType: NotificationSettingsType) {
        let vm: NotificationSettingsCompleteListViewModel
        switch notificationSettingType {
        case .push:
            vm = NotificationSettingsCompleteListViewModel.makePusherNotificationSettingsListViewModel()
        case .mail:
            vm = NotificationSettingsCompleteListViewModel.makeMailerNotificationSettingsListViewModel()
        case .marketing, .searchAlerts:
            return
        }
        vm.navigator = self
        let vc = NotificationSettingsCompleteListViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openNotificationSettingsListDetail(notificationSetting: NotificationSetting, notificationSettingsRepository: NotificationSettingsRepository) {
        let vm = NotificationSettingsListDetailViewModel(notificationSetting: notificationSetting,
                                                         notificationSettingsRepository: notificationSettingsRepository)
        vm.navigator = self
        let vc = NotificationSettingsListDetailViewController(viewModel: vm)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension ProfileTabCoordinator: SearchAlertsListNavigator {
    func closeSearchAlertsList() {
        navigationController.popViewController(animated: true)
    }

    func openSearch() {
        navigationController.popToRootViewController(animated: false)
        profileCoordinatorSearchAlertsDelegate?.profileCoordinatorSearchAlertsOpenSearch()
    }
}
