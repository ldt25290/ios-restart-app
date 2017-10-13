//
//  DeepLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct DeepLink {
    let action: DeepLinkAction
    let origin: DeepLinkOrigin
    let campaign: String?
    let medium: String?
    let source: DeepLinkSource
    let cardActionParameter: String?

    static func push(_ action: DeepLinkAction, origin: DeepLinkOrigin, campaign: String?, medium: String?,
                     source: DeepLinkSource, cardActionParameter: String?) -> DeepLink {
        return DeepLink(action: action, origin: origin, campaign: campaign, medium: medium,
                        source: source, cardActionParameter: cardActionParameter)
    }

    static func link(_ action: DeepLinkAction, campaign: String?, medium: String?,
                     source: DeepLinkSource, cardActionParameter: String?) -> DeepLink {
        return DeepLink(action: action, origin: .link, campaign: campaign, medium: medium,
                        source: source, cardActionParameter: cardActionParameter)
    }

    static func shortCut(_ action: DeepLinkAction) -> DeepLink {
        return DeepLink(action: action, origin: .shortCut, campaign: nil, medium: nil,
                        source: .none, cardActionParameter: nil)
    }

    static func appInstall(_ action: DeepLinkAction, source: DeepLinkSource) -> DeepLink {
        return DeepLink(action: action, origin: .appInstall, campaign: nil, medium: nil,
                        source: source, cardActionParameter: nil)
    }

}

enum DeepLinkAction: Equatable {
    case home
    case sell
    case listing(listingId: String)
    case listingShare(listingId: String)
    case listingBumpUp(listingId: String)
    case listingMarkAsSold(listingId: String)
    case user(userId: String)
    case conversations
    case conversation(data: ConversationData)
    case conversationWithMessage(data: ConversationData, message: String)
    case message(messageType: DeepLinkMessageType, data: ConversationData)
    case search(query: String, categories: String?)
    case resetPassword(token: String)
    case userRatings
    case userRating(ratingId: String)
    case passiveBuyers(listingId: String)
    case notificationCenter
    case appStore
    
    static public func ==(lhs: DeepLinkAction, rhs: DeepLinkAction) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.sell, .sell):
            return true
        case (.listing(let lhsDetail), .listing(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.listingShare(let lhsDetail), .listingShare(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.listingBumpUp(let lhsDetail), .listingBumpUp(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.listingMarkAsSold(let lhsDetail), .listingMarkAsSold(let rhsDetail)):
            return lhsDetail == rhsDetail
        case (.user(let lhsUser), .user(let rhsUser)):
            return lhsUser == rhsUser
        case (.conversations, .conversations):
            return true
        case (.conversation(let lhsData), .conversation(let rhsData)):
            return lhsData == rhsData
        case (.conversationWithMessage(let lhsData, let lhsMessage), .conversationWithMessage(let rhsData, let rhsMessage)):
            return lhsData == rhsData && lhsMessage == rhsMessage
        case (.message(let lhsMessageType, let lhsData), .message(let rhsMessageType, let rhsData)):
            return lhsMessageType == rhsMessageType && lhsData == rhsData
        case (.search(let lhsQuery, let lhsCategories), .search(let rhsQuery, let rhsCategories)):
            return lhsQuery == rhsQuery && lhsCategories == rhsCategories
        case (.resetPassword(let lhsToken), .resetPassword(let rhsToken)):
            return lhsToken == rhsToken
        case (.userRatings, .userRatings):
            return true
        case (.userRating(let lhsRatingId), .userRating(let rhsRatingId)):
            return lhsRatingId == rhsRatingId
        case (.passiveBuyers(let lhsListingId), .passiveBuyers(let rhsListingId)):
            return lhsListingId == rhsListingId
        case (.notificationCenter, .notificationCenter):
            return true
        case (.appStore, .appStore):
            return true
        default:
            return false
        }
    }
}

enum DeepLinkOrigin {
    case push(appActive: Bool, alert: String)
    case link
    case shortCut
    case appInstall

    var appActive: Bool {
        switch self {
        case .link, .shortCut:
            return false
        case let .push(appActive, _):
            return appActive
        case .appInstall:
            return true
        }
    }

    var message: String {
        switch self {
        case .link, .shortCut, .appInstall:
            return ""
        case let .push(_, message):
            return message
        }
    }
}

enum DeepLinkSource {
    case external(source: String)
    case push
    case none

    init(string: String?) {
        guard let string = string else {
            self = .none
            return
        }
        self = .external(source: string)
    }
}

/**
 Enum to distinguish between the two methods to obtain a conversation

 - Conversation: By conversation id
 - ProductBuyer: By productId and buyerId 
 */
enum ConversationData: Equatable {
    case conversation(conversationId: String)
    case listingBuyer(listingId: String, buyerId: String)
    
    static public func ==(lhs: ConversationData, rhs: ConversationData) -> Bool {
        switch (lhs, rhs) {
        case (.conversation(let lhsConversationId), .conversation(let rhsConversationId)):
            return lhsConversationId == rhsConversationId
        case (.listingBuyer(let lhsListingId, let lhsBuyerId), .listingBuyer(let rhsListingId, let rhsBuyerId)):
            return lhsListingId == rhsListingId && lhsBuyerId == rhsBuyerId
        default:
            return false
        }
    }
}

protocol ConversationDataDisplayer {
    func isDisplayingConversationData(_ data: ConversationData) -> Bool
}

/**
 Message type enum

 - Message: Typical message
 - Offer:   Message from an offer
 */
enum DeepLinkMessageType: Int {
    case message = 0
    case offer = 1
    case sticker = 2
}
