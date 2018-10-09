import Foundation
import LGCoreKit
import LGComponents

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
    func openMakeAnOffer(chatConversation: ChatConversation)
    func openOfferStatus(offerId: String)
    func openOfferPayCode(offerId: String)
    func openEnterPayCode(offerId: String, buyerName: String, buyerAvatar: File?)
    func openPayout(offerId: String)
    func openUserReport(user: ChatInterlocutor, source: EventParameterTypePage)
}


final class ChatDetailWireframe: ChatDetailNavigator {
    private let nc: UINavigationController
    private let deeplinkMailBox: DeepLinkMailBox

    private let sessionManager: SessionManager
    private let userNavigator: UserWireframe
    private let listingNavigator: ListingWireframe
    private let rateBuyerAssembly: RateBuyerAssembly
    private let chatAssembly: ChatAssembly
    private let expressChatAssembly: ExpressChatAssembly
    private let verificationAssembly: UserVerificationAssembly
    private let verifyAccountsAssembly: VerifyAccountsAssembly
    private let loginAssembly: LoginAssembly
    private let assistantMeetingAssembly: AssistantMeetingAssembly
    private let p2pPaymentsMakeAnOfferAssembly: P2PPaymentsMakeAnOfferAssembly

    convenience init(nc: UINavigationController) {
        self.init(nc: nc,
                  sessionManager: Core.sessionManager,
                  userNavigator: UserWireframe(nc: nc),
                  listingNavigator: ListingWireframe(nc: nc),
                  chatAssembly: LGChatBuilder.standard(nav: nc),
                  expressChatAssembly: ExpressChatBuilder.modal(nc),
                  rateBuyerAssembly: RateBuyerBuilder.modal(nc),
                  verificationAssembly: LGUserVerificationBuilder.standard(nav: nc),
                  verifyAccountsAssembly: VerifyAccountsBuilder.modal,
                  loginAssembly: LoginBuilder.modal,
                  assistantMeetingAssembly: AssistantMeetingBuilder.modal(nc),
                  p2pPaymentsMakeAnOfferAssembly: P2PPaymentsMakeAnOfferBuilder.modal,
                  deeplinkMailBox: LGDeepLinkMailBox.sharedInstance)
    }

    init(nc: UINavigationController,
         sessionManager: SessionManager,
         userNavigator: UserWireframe,
         listingNavigator: ListingWireframe,
         chatAssembly: ChatAssembly,
         expressChatAssembly: ExpressChatAssembly,
         rateBuyerAssembly: RateBuyerAssembly,
         verificationAssembly: UserVerificationAssembly,
         verifyAccountsAssembly: VerifyAccountsAssembly,
         loginAssembly: LoginAssembly,
         assistantMeetingAssembly: AssistantMeetingAssembly,
         p2pPaymentsMakeAnOfferAssembly: P2PPaymentsMakeAnOfferAssembly,
         deeplinkMailBox: DeepLinkMailBox) {
        self.nc = nc
        self.sessionManager = sessionManager
        self.userNavigator = userNavigator
        self.listingNavigator = listingNavigator
        self.chatAssembly = chatAssembly
        self.expressChatAssembly = expressChatAssembly
        self.rateBuyerAssembly = rateBuyerAssembly
        self.verificationAssembly = verificationAssembly
        self.verifyAccountsAssembly = verifyAccountsAssembly
        self.loginAssembly = loginAssembly
        self.assistantMeetingAssembly = assistantMeetingAssembly
        self.p2pPaymentsMakeAnOfferAssembly = p2pPaymentsMakeAnOfferAssembly
        self.deeplinkMailBox = deeplinkMailBox
    }

    func navigate(with convertible: DeepLinkConvertible) {
        deeplinkMailBox.push(convertible: convertible)
    }

    func closeChatDetail() {
        nc.popViewController(animated: true)
    }

    func openAppRating(_ source: EventParameterRatingSource) {
        guard let url = URL.makeAppRatingDeeplink(with: source) else { return }
        deeplinkMailBox.push(convertible: url)
    }

    func openExpressChat(_ listings: [Listing], sourceListingId: String, manualOpen: Bool) {
        let vc = expressChatAssembly.buildExpressChat(listings: listings,
                                                      sourceProductId: sourceListingId,
                                                      manualOpen: manualOpen)
        nc.present(vc, animated: true)
    }

    func openUserVerificationView() {
        let vc = verificationAssembly.buildUserVerification()
        nc.pushViewController(vc, animated: true)
    }

    func openListing(_ data: ListingDetailData,
                     source: EventParameterListingVisitSource,
                     actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {
        listingNavigator.openListing(data, source: source, actionOnFirstAppear: actionOnFirstAppear)
    }

    func openUser(_ data: UserDetailData) {
        userNavigator.openUser(data)
    }

    func openVerifyAccounts(_ types: [VerificationType],
                            source: VerifyAccountsSource,
                            completionBlock: (() -> Void)?) {
        let vc = verifyAccountsAssembly.buildVerifyAccounts(types, source: source, completionBlock: completionBlock)
        vc.setupForModalWithNonOpaqueBackground()
        vc.modalTransitionStyle = .crossDissolve
        nc.present(vc, animated: true, completion: nil)
    }

    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {
        let vc = rateBuyerAssembly.buildRateBuyers(source: source,
                                                   buyers: buyers,
                                                   listingId: listingId,
                                                   sourceRateBuyers: sourceRateBuyers,
                                                   trackingInfo: trackingInfo,
                                                   onRateUserFinishAction: nil)
        nc.present(vc, animated: true, completion: nil)
    }

    func openLoginIfNeededFromChatDetail(from: EventParameterLoginSourceValue,
                                         loggedInAction: @escaping (() -> Void)) {
        guard !sessionManager.loggedIn else {
            loggedInAction()
            return
        }

        let vc = loginAssembly.buildPopupSignUp(
            withMessage: R.Strings.chatLoginPopupText,
            andSource: from,
            appearance: .light,
            loginAction: loggedInAction,
            cancelAction: nil
        )
        vc.modalTransitionStyle = .crossDissolve
        nc.present(vc, animated: true)
    }

    func openAssistantFor(listingId: String,
                          dataDelegate: MeetingAssistantDataDelegate) {
        let vc = assistantMeetingAssembly.buildAssistantFor(listingId: listingId, dataDelegate: dataDelegate)
        nc.present(vc, animated: true, completion: nil)
    }

    func openMakeAnOffer(chatConversation: ChatConversation) {
        let vc = p2pPaymentsMakeAnOfferAssembly.buildOnboarding(chatConversation: chatConversation)
        nc.present(vc, animated: true)
    }

    func openOfferStatus(offerId: String) {
        let vc = P2PPaymentsOfferStatusBuilder.modal.buildOfferStatus(offerId: offerId)
        nc.present(vc, animated: true)
    }

    func openOfferPayCode(offerId: String) {
        let vc = P2PPaymentsOfferStatusBuilder.modal.buildGetPayCode(offerId: offerId)
        nc.present(vc, animated: true)
    }

    func openEnterPayCode(offerId: String, buyerName: String, buyerAvatar: File?) {
        let vc = P2PPaymentsOfferStatusBuilder.modal.buildEnterPayCode(offerId: offerId,
                                                                       buyerName: buyerName,
                                                                       buyerAvatar: buyerAvatar)
        nc.present(vc, animated: true)
    }

    func openPayout(offerId: String) {
        let vc = P2PPaymentsOfferStatusBuilder.modal.buildPayout(offerId: offerId)
        nc.present(vc, animated: true)
    }

    func openUserReport(user: ChatInterlocutor, source: EventParameterTypePage) {
        guard let userId = user.objectId else { return }
        guard let data = RateUserData(user: user, listingId: nil, ratingType: UserRatingType.report) else { return }
        let vc = ReportBuilder.modal(nc).buildReport(type: .user(rateData: data), reportedId: userId, source: .chat)
        nc.present(vc, animated: true)
    }
}
