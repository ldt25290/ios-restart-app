import Foundation
import LGCoreKit

protocol ChatDetailNavigator: DeepLinkNavigator {
    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear)
    func openUserVerificationView()
    func openUser(_ data: UserDetailData)
    func closeChatDetail()
    func openAppRating(_ source: EventParameterRatingSource)
    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool)
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo)
    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void))
    func openAssistantFor(listingId: String, dataDelegate: MeetingAssistantDataDelegate)
    func openUserReport(user: ChatInterlocutor, source: EventParameterTypePage)
}

final class ChatDetailRouter: ChatDetailNavigator {
    private weak var navigationController: UINavigationController?
    private let deeplinkMailBox: DeepLinkMailBox
    private let chatAssembly: ChatAssembly
    private let verificationAssembly: UserVerificationAssembly

    convenience init(navigationController: UINavigationController) {
        self.init(navigationController: navigationController,
                  chatAssembly: LGChatBuilder.standard(nav: navigationController),
                  verificationAssembly: LGUserVerificationBuilder.standard(nav: navigationController),
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)
    }

    init(navigationController: UINavigationController,
         chatAssembly: ChatAssembly,
         verificationAssembly: UserVerificationAssembly,
         deeplinkMailBox: DeepLinkMailBox) {
        self.navigationController = navigationController
        self.chatAssembly = chatAssembly
        self.verificationAssembly = verificationAssembly
        self.deeplinkMailBox = deeplinkMailBox
    }

    func navigate(with convertible: DeepLinkConvertible) {
        deeplinkMailBox.push(convertible: convertible)
    }

    func closeChatDetail() {
        navigationController?.popViewController(animated: true)
    }

    func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deeplinkMailBox.push(convertible: url)
    }

    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool) {
        let vc = chatAssembly.buildExpressChat(listings: listings,
                                               sourceProductId: sourceListingId,
                                               manualOpen: manualOpen)
        navigationController?.present(vc, animated: true)
    }

    func openUserVerificationView() {
        let vc = verificationAssembly.buildUserVerification()
        navigationController?.pushViewController(vc, animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        guard let nav = navigationController else { return }
        let userCoordinator = UserCoordinator(navigationController: nav)
        let listingCoordinator = ListingCoordinator(navigationController: nav, userCoordinator: userCoordinator)
        userCoordinator.listingCoordinator = listingCoordinator

        listingCoordinator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }

    func openUser(_ data: UserDetailData) {
        guard let nav = navigationController else { return }
        let userCoordinator = UserCoordinator(navigationController: nav)
        userCoordinator.openUser(data)
    }

    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {
        guard let nav = navigationController else { return }
        let assembly = LGRateBuilder.modal(root: nav)
        let toPresentNav = UINavigationController()
        _ = assembly.buildRateBuyers(into: toPresentNav,
                                     source: source,
                                     buyers: buyers,
                                     listingId: listingId,
                                     sourceRateBuyers: sourceRateBuyers,
                                     trackingInfo: trackingInfo)
        nav.pushViewController(toPresentNav, animated: true)
    }

    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue,
                                         loggedInAction: @escaping (() -> Void)) {

    }
    func openAssistantFor(listingId: String,
                          dataDelegate: MeetingAssistantDataDelegate) {

    }

    func openUserReport(user: ChatInterlocutor, source: EventParameterTypePage) {
        guard let parent = navigationController else { return }
        guard let userId = user.objectId else { return }
        guard let data = RateUserData(user: user, listingId: nil, ratingType: .report) else { return }
        let coord = ReportCoordinator(type: .user(rateData: data), reportedId: userId, source: source)
        coord.presentViewController(parent: parent, animated: true, completion: nil)
    }
}
