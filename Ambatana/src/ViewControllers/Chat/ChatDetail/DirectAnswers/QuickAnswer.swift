//
//  QuickAnswer.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum QuickAnswer: Equatable {

    case interested
    case notInterested
    case meetUp
    case stillAvailable
    case isNegotiable
    case likeToBuy
    case listingCondition
    case listingStillForSale
    case listingSold
    case whatsOffer
    case negotiableYes
    case negotiableNo
    case freeStillHave
    case freeYours
    case freeAvailable
    case freeNotAvailable

    case meetingAssistant(chatNorrisABtestVersion: ChatNorris)
    case dynamic(chatAnswer: ChatAnswer)
    

    static public func ==(lhs: QuickAnswer, rhs: QuickAnswer) -> Bool {
        switch lhs {
        case .interested:
            if case .interested = rhs { return true }
        case .notInterested:
            if case .notInterested = rhs { return true }
        case .meetUp:
            if case .meetUp = rhs { return true }
        case .stillAvailable:
            if case .stillAvailable = rhs { return true }
        case .isNegotiable:
            if case .isNegotiable = rhs { return true }
        case .likeToBuy:
            if case .likeToBuy = rhs { return true }
        case .listingCondition:
            if case .listingCondition = rhs { return true }
        case .listingStillForSale:
            if case .listingStillForSale = rhs { return true }
        case .listingSold:
            if case .listingSold = rhs { return true }
        case .whatsOffer:
            if case .whatsOffer = rhs { return true }
        case .negotiableYes:
            if case .negotiableYes = rhs { return true }
        case .negotiableNo:
            if case .negotiableNo = rhs { return true }
        case .freeStillHave:
            if case .freeStillHave = rhs { return true }
        case .freeYours:
            if case .freeYours = rhs { return true }
        case .freeAvailable:
            if case .freeAvailable = rhs { return true }
        case .freeNotAvailable:
            if case .freeNotAvailable = rhs { return true }
        case .meetingAssistant(let lhsABTest):
            if case .meetingAssistant(let rhsABTest) = rhs {
                return lhsABTest == rhsABTest
            }
        case .dynamic(let lhsAnswer):
            if case .dynamic(let rhsAnswer) = rhs {
                guard lhsAnswer.id == rhsAnswer.id else { return false }
                switch lhsAnswer.type {
                case .replyText(let rhsTextToShow, let rhsTextToReply):
                    if case ChatAnswerType.replyText(let lhsTextToShow, let lhsTextToReply) = rhsAnswer {
                        return rhsTextToShow == lhsTextToShow && rhsTextToReply == lhsTextToReply
                    }
                case .callToAction(let rhsTextToShow, let rhsTextToReply, let rhsDeeplink):
                    if case ChatAnswerType.callToAction(let lhsTextToShow, let lhsTextToReply, let lhsDeeplink) = rhsAnswer {
                        return rhsTextToShow == lhsTextToShow && rhsTextToReply == lhsTextToReply
                            && rhsDeeplink == lhsDeeplink
                    }
                }
            }
        }
        return false
    }

    var text: String {
        switch self {
        case .interested:
            return LGLocalizedString.directAnswerInterested
        case .notInterested:
            return LGLocalizedString.directAnswerNotInterested
        case .meetUp:
            return LGLocalizedString.directAnswerMeetUp
        case .stillAvailable:
            return LGLocalizedString.directAnswerStillAvailable
        case .isNegotiable:
            return LGLocalizedString.directAnswerIsNegotiable
        case .likeToBuy:
            return LGLocalizedString.directAnswerLikeToBuy
        case .listingCondition:
            return LGLocalizedString.directAnswerCondition
        case .listingStillForSale:
            return LGLocalizedString.directAnswerStillForSale
        case .listingSold:
            return LGLocalizedString.directAnswerProductSold
        case .whatsOffer:
            return LGLocalizedString.directAnswerWhatsOffer
        case .negotiableYes:
            return LGLocalizedString.directAnswerNegotiableYes
        case .negotiableNo:
            return LGLocalizedString.directAnswerNegotiableNo
        case .freeStillHave:
            return LGLocalizedString.directAnswerFreeStillHave
        case .freeYours:
            return LGLocalizedString.directAnswerFreeYours
        case .freeAvailable:
            return LGLocalizedString.directAnswerFreeAvailable
        case .freeNotAvailable:
            return LGLocalizedString.directAnswerFreeNoAvailable
        case .meetingAssistant:
            return LGLocalizedString.directAnswerLetsMeet
        case .dynamic(let chatAnswer):
            switch chatAnswer.type {
            case .replyText(let textToShow, _):
                return textToShow
            case .callToAction(let textToShow, _, _):
                return textToShow
            }
        }
    }
    
    var id: String? {
        switch self {
        case .interested, .notInterested, .meetUp, .stillAvailable, .isNegotiable, .likeToBuy, .listingCondition,
            .listingStillForSale, .listingSold, .whatsOffer, .negotiableYes, .negotiableNo, .freeStillHave,
            .freeYours, .freeAvailable, .freeNotAvailable, .meetingAssistant:
            return nil
        case .dynamic(let chatAnswer):
            return chatAnswer.id
        }
    }
    
    var key: String? {
        switch self {
        case .interested, .notInterested, .meetUp, .stillAvailable, .isNegotiable, .likeToBuy, .listingCondition,
             .listingStillForSale, .listingSold, .whatsOffer, .negotiableYes, .negotiableNo, .freeStillHave,
             .freeYours, .freeAvailable, .freeNotAvailable, .meetingAssistant:
            return nil
        case .dynamic(let chatAnswer):
            return chatAnswer.key
        }
    }

    var quickAnswerTypeParameter: String? {
        switch self {
        case .interested:
            return EventParameterQuickAnswerType.interested.rawValue
        case .notInterested:
            return EventParameterQuickAnswerType.notInterested.rawValue
        case .meetUp:
            return EventParameterQuickAnswerType.meetUp.rawValue
        case .stillAvailable:
            return EventParameterQuickAnswerType.stillAvailable.rawValue
        case .isNegotiable:
            return EventParameterQuickAnswerType.isNegotiable.rawValue
        case .likeToBuy:
            return EventParameterQuickAnswerType.likeToBuy.rawValue
        case .listingCondition:
            return EventParameterQuickAnswerType.listingCondition.rawValue
        case .listingStillForSale:
            return EventParameterQuickAnswerType.listingStillForSale.rawValue
        case .listingSold:
            return EventParameterQuickAnswerType.listingSold.rawValue
        case .whatsOffer:
            return EventParameterQuickAnswerType.whatsOffer.rawValue
        case .negotiableYes:
            return EventParameterQuickAnswerType.negotiableYes.rawValue
        case .negotiableNo:
            return EventParameterQuickAnswerType.negotiableNo.rawValue
        case .freeStillHave:
            return EventParameterQuickAnswerType.freeStillHave.rawValue
        case .freeYours:
            return EventParameterQuickAnswerType.freeYours.rawValue
        case .freeAvailable:
            return EventParameterQuickAnswerType.freeAvailable.rawValue
        case .freeNotAvailable:
            return EventParameterQuickAnswerType.freeNotAvailable.rawValue
        case .meetingAssistant:
            return nil
        case .dynamic(let chatAnswer):
            return chatAnswer.key
        }
    }

    var isMeetingAssistant: Bool {
        switch self {
        case .meetingAssistant:
            return true
        default:
            return false
        }
    }

    var icon: UIImage? {
        switch self {
        case .meetingAssistant:
            return #imageLiteral(resourceName: "ic_calendar").withRenderingMode(.alwaysTemplate)
        default:
            return nil
        }
    }

    var textColor: UIColor {
        switch self {
        case .meetingAssistant(let chatNorrisABtestVersion):
            switch chatNorrisABtestVersion {
            case .baseline, .control, .greenButton, .redButton:
                return UIColor.white
            case .whiteButton:
                return UIColor.primaryColor
            }
        default:
            return UIColor.white
        }
    }

    var iconTintColor: UIColor {
        switch self {
        case .meetingAssistant(let chatNorrisABtestVersion):
            switch chatNorrisABtestVersion {
            case .baseline, .control, .greenButton, .redButton:
                return UIColor.white
            case .whiteButton:
                return UIColor.primaryColor
            }
        default:
            return UIColor.white
        }
    }

    var bgColor: UIColor {
        switch self {
        case .meetingAssistant(let chatNorrisABtestVersion):
            switch chatNorrisABtestVersion {
            case .baseline, .control, .redButton:
                return UIColor.primaryColor
            case  .greenButton:
                return UIColor.terciaryColor
            case .whiteButton:
                return UIColor.white
            }
        default:
            return UIColor.primaryColor
        }
    }

    static func quickAnswersForChatMessage(chatViewMessage: ChatViewMessage) -> [QuickAnswer]? {
        if case .multiAnswer(_, let answers) = chatViewMessage.type {
            return answers.map { QuickAnswer.dynamic(chatAnswer: $0) }
        }
        return nil
    }

    static func quickAnswersForChatWith(buyer: Bool, isFree: Bool, chatNorrisABtestVersion: ChatNorris) -> [QuickAnswer] {
        var result = [QuickAnswer]()
        if chatNorrisABtestVersion.isActive {
            result.append(.meetingAssistant(chatNorrisABtestVersion: chatNorrisABtestVersion))
        }
        if isFree {
            if buyer {
                result.append(.interested)
                result.append(.freeStillHave)
                result.append(.meetUp)
                result.append(.notInterested)
            } else {
                result.append(.freeYours)
                result.append(.freeAvailable)
                result.append(.meetUp)
                result.append(.freeNotAvailable)
            }
        } else {
            if buyer {
                result.append(.interested)
                result.append(.isNegotiable)
                result.append(.likeToBuy)
                result.append(.meetUp)
                result.append(.notInterested)
            } else {
                result.append(.listingStillForSale)
                result.append(.whatsOffer)
                result.append(.negotiableYes)
                result.append(.negotiableNo)
                result.append(.notInterested)
                result.append(.listingSold)
            }
        }
        return result
    }

    static func quickAnswersForPeriscope(isFree: Bool) -> [QuickAnswer] {
        var result = [QuickAnswer]()
        if isFree {
            result.append(.interested)
            result.append(.meetUp)
            result.append(.listingCondition)
        } else {
            result.append(.stillAvailable)
            result.append(.isNegotiable)
            result.append(.listingCondition)
        }
        return result
    }
}
