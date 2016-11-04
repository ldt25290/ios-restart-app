//
//  ShareType.swift
//  LetGo
//
//  Created by AHL on 16/8/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import TwitterKit
import LGCoreKit
import MessageUI
import Branch


enum ShareType {
    case Email, Facebook, FBMessenger, Whatsapp, Twitter, Telegram, CopyLink, SMS, Native

    private static var otherCountriesTypes: [ShareType] { return [.SMS, .Email, .Facebook, .FBMessenger, .Twitter, .Whatsapp, .Telegram] }
    private static var turkeyTypes: [ShareType] { return [.Whatsapp, .Facebook, .Email ,.FBMessenger, .Twitter, .SMS, .Telegram] }

    var moreInfoTypes: [ShareType] {
        return ShareType.shareTypesForCountry("", maxButtons: nil, includeNative: false)
    }

    static func shareTypesForCountry(countryCode: String, maxButtons: Int?, includeNative: Bool) -> [ShareType] {
        let turkey = "tr"

        let countryTypes: [ShareType]
        switch countryCode.lowercaseString {
        case turkey:
            countryTypes = turkeyTypes
        default:
            countryTypes = otherCountriesTypes
        }

        var resultShareTypes = countryTypes.filter { SocialSharer.canShareIn($0) }

        if var maxButtons = maxButtons where maxButtons > 0 {
            maxButtons = includeNative ? maxButtons-1 : maxButtons
            if resultShareTypes.count > maxButtons {
                resultShareTypes = Array(resultShareTypes[0..<maxButtons])
            }
        }

        if includeNative {
            resultShareTypes.append(.Native)
        }

        return resultShareTypes
    }

    var trackingShareNetwork: EventParameterShareNetwork {
        switch self {
        case .Email:
            return .Email
        case .FBMessenger:
            return .FBMessenger
        case .Whatsapp:
            return .Whatsapp
        case .Facebook:
            return .Facebook
        case .Twitter:
            return .Twitter
        case .Telegram:
            return .Telegram
        case .CopyLink:
            return .CopyLink
        case .SMS:
            return .SMS
        case .Native:
            return .Native
        }
    }

    var smallImage: UIImage? {
        switch self {
        case .Email:
            return UIImage(named: "item_share_email")
        case .Facebook:
            return UIImage(named: "item_share_fb")
        case .Twitter:
            return UIImage(named: "item_share_twitter")
        case .Native:
            return UIImage(named: "item_share_more")
        case .CopyLink:
            return UIImage(named: "item_share_link")
        case .FBMessenger:
            return UIImage(named: "item_share_fb_messenger")
        case .Whatsapp:
            return UIImage(named: "item_share_whatsapp")
        case .Telegram:
            return UIImage(named: "item_share_telegram")
        case .SMS:
            return UIImage(named: "item_share_sms")
        }
    }

    var bigImage: UIImage? {
        switch self {
        case .Email:
            return UIImage(named: "item_share_email_big")
        case .Facebook:
            return UIImage(named: "item_share_fb_big")
        case .Twitter:
            return UIImage(named: "item_share_twitter_big")
        case .Native:
            return UIImage(named: "item_share_more_big")
        case .CopyLink:
            return UIImage(named: "item_share_link_big")
        case .FBMessenger:
            return UIImage(named: "item_share_fb_messenger_big")
        case .Whatsapp:
            return UIImage(named: "item_share_whatsapp_big")
        case .Telegram:
            return UIImage(named: "item_share_telegram_big")
        case .SMS:
            return UIImage(named: "item_share_sms_big")
        }
    }

    var accesibilityId: AccessibilityId {
        switch self {
        case .Email:
            return .SocialShareEmail
        case .Facebook:
            return .SocialShareFacebook
        case .Twitter:
            return .SocialShareTwitter
        case .Native:
            return .SocialShareMore
        case .CopyLink:
            return .SocialShareCopyLink
        case .FBMessenger:
            return .SocialShareFBMessenger
        case .Whatsapp:
            return .SocialShareWhatsapp
        case .Telegram:
            return .SocialShareTelegram
        case .SMS:
            return .SocialShareSMS
        }
    }
}
