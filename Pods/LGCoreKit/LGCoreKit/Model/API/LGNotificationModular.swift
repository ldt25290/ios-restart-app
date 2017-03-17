//
//  LGNotificationModular.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 27/02/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGNotificationModular: NotificationModular {
    
    public let  text: NotificationTextModule
    public let  callToActions: [NotificationCTAModule]
    public let  basicImage: NotificationImageModule?
    public let  iconImage: NotificationImageModule?
    public let  heroImage: NotificationImageModule?
    public let  thumbnails: [NotificationImageModule]?
    
    init(text: LGNotificationTextModule, callToAction: [LGNotificationCTAModule], basicImage: LGNotificationImageModule?,
         iconImage: LGNotificationImageModule?, heroImage: LGNotificationImageModule?, thumbnails: [LGNotificationImageModule]?) {
        self.text = text
        self.callToActions = callToAction
        self.basicImage = basicImage
        self.iconImage = iconImage
        self.heroImage = heroImage
        self.thumbnails = thumbnails
    }
}

extension LGNotificationModular: Decodable {
    private struct JSONKeys {
        static let text = "text"
        static let callToAction = "cta"
        static let basicImage = "basic_image"
        static let iconImage = "icon_image"
        static let userImage = "hero_image"
        static let thumbnails = "thumbnails"
    }
    
    public static func decode(_ j: JSON) -> Decoded<LGNotificationModular> {
        
        let init1 = curry(LGNotificationModular.init)
            <^> j <| JSONKeys.text
            <*> j <|| JSONKeys.callToAction
            <*> j <|? JSONKeys.basicImage
        let init2 = init1
            <*> j <|? JSONKeys.iconImage
            <*> j <|? JSONKeys.userImage
        let result = init2
            <*> j <||? JSONKeys.thumbnails
        return result
    }
}