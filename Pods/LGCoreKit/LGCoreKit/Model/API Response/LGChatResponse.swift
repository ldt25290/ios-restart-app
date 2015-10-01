//
//  LGChatResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc public class LGChatResponse : ChatResponse, ResponseObjectSerializable {
    
    public var chat: Chat
    
    // MARK: - Lifecycle
    
    public init() {
        chat = LGChat()
    }
    
    // MARK: - ResponseObjectSerializable
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let countryInfoDao = RLMCountryInfoDAO()
        let currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDao)
        
        // since the response gives distance in the units passed per parameters,
        // we retrieve distance type the same way we do in productlistviewmodel
        var distanceType = DistanceType.Km
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        
        let json = JSON(representation)
        chat = LGChatParser.chatWithJSON(json, currencyHelper: currencyHelper, distanceType: distanceType)
    }    
}
