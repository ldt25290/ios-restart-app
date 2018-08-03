import Foundation
import LGCoreKit

protocol ChatAssembly {
    func buildChatInactiveConversationDetails(conversation: ChatInactiveConversation) -> ChatInactiveConversationDetailsViewController
    func buildChatInactiveConversationsList() -> ChatInactiveConversationsListViewController
    func buildExpressChat(listings: [Listing],
                          sourceProductId: String,
                          manualOpen: Bool) -> ExpressChatViewController
    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool) -> RateUserViewController
    func buildRateBuyers(source: RateUserSource,
                         buyers: [UserListing],
                         listingId: String,
                         sourceRateBuyers: SourceRateBuyers?,
                         trackingInfo: MarkAsSoldTrackingInfo) -> RateBuyersViewController
    func buildChatFrom(listing: Listing,
                       source: EventParameterTypePage,
                       openChatAutomaticMessage: ChatWrapperMessageType?,
                       interlocutor: User?) -> ChatViewController?
    func buildChatFrom(_ conversation: ChatConversation,
                       source: EventParameterTypePage,
                       predefinedMessage: String?) -> ChatViewController
}

enum LGChatBuilder {
    case standard(nav: UINavigationController)
}

extension LGChatBuilder: ChatAssembly {
    func buildChatInactiveConversationDetails(conversation: ChatInactiveConversation) -> ChatInactiveConversationDetailsViewController {
        switch self {
        case .standard(let nav):
            let vm = ChatInactiveConversationDetailsViewModel(conversation: conversation)
            let vc = ChatInactiveConversationDetailsViewController(viewModel: vm)
            vm.delegate = vc
            vm.navigator = ChatInactiveDetailRouter(navigationController: nav)
            return vc
        }
    }

    func buildChatInactiveConversationsList() -> ChatInactiveConversationsListViewController {
        switch self {
        case .standard(let nav):
            let vm = ChatInactiveConversationsListViewModel(navigator: ChatRouter(navigationController: nav))
            return ChatInactiveConversationsListViewController(viewModel: vm)
        }
    }

    func buildExpressChat(listings: [Listing],
                          sourceProductId: String,
                          manualOpen: Bool) -> ExpressChatViewController {
        switch self {
        case .standard(let nav):
            let vm = ExpressChatViewModel(listings: listings, sourceProductId: sourceProductId, manualOpen: manualOpen)
            let vc = ExpressChatViewController(viewModel: vm)
            vm.navigator = ExpressChatRouter(root: nav)
            return vc
        }
    }

    func buildRateUser(source: RateUserSource, data: RateUserData, showSkipButton: Bool) -> RateUserViewController {
        switch self {
        case .standard(let nav):
            let vm = RateUserViewModel(source: source, data: data)
            let vc = RateUserViewController(viewModel: vm, showSkipButton: showSkipButton)
            vm.navigator = RateUserRouter(navigationController: nav)
            return vc
        }
    }
    func buildRateBuyers(source: RateUserSource,
                         buyers: [UserListing],
                         listingId: String,
                         sourceRateBuyers: SourceRateBuyers?,
                         trackingInfo: MarkAsSoldTrackingInfo) -> RateBuyersViewController {
        switch self {
        case .standard(let nav):
            let vm = RateBuyersViewModel(buyers: buyers,
                                         listingId: listingId,
                                         source: sourceRateBuyers,
                                         trackingInfo: trackingInfo)
            let vc = RateBuyersViewController(with: vm)
            vm.navigator = RateBuyersRouter(navigationController: nav, source: source)
            return vc
        }
    }

    func buildChatFrom(listing: Listing,
                      source: EventParameterTypePage,
                      openChatAutomaticMessage: ChatWrapperMessageType?,
                      interlocutor: User?) -> ChatViewController? {
        switch self {
        case .standard(let nav):
            guard let vm = ChatViewModel(listing: listing,
                                             navigator: ChatDetailRouter.init(navigationController: nav),
                                             source: source,
                                             openChatAutomaticMessage: openChatAutomaticMessage,
                                             interlocutor: interlocutor) else { return nil }
            let vc = ChatViewController(viewModel: vm, hidesBottomBar: source == .listingListFeatured)
            return vc
        }

    }

    func buildChatFrom(_ conversation: ChatConversation,
                          source: EventParameterTypePage,
                          predefinedMessage: String?)  -> ChatViewController {
        switch self {
        case .standard(let nav):
            let vm = ChatViewModel(conversation: conversation,
                                   navigator: ChatDetailRouter.init(navigationController: nav),
                                   source: source,
                                   predefinedMessage: predefinedMessage)
            let vc = ChatViewController(viewModel: vm)
            return vc
        }
    }
}
