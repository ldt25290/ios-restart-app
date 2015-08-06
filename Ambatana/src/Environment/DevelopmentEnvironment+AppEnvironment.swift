//
//  DevelopmentEnvironment+AppEnvironment.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension DevelopmentEnvironment: AppEnvironment {
    // General
    var appleAppId: String { get { return "986339882" } }
    
    // Tracking
    var appsFlyerAPIKey: String { get { return "5EKnCjmwmNKjE2e7gYBo6T" } }
    var amplitudeAPIKey: String { get { return "1c32ba5ed444237608436bad4f310307" } }
    var googleConversionTrackingId: String { get { return "949799886" } }
    
    var urbanAirshipAPIKey: String { get { return "psjAmPh7RD-qPQXMykcPXQ"} }
    var urbanAirshipAPISecret: String { get { return "GfoA9hGdSOC0_JyFWqmGdQ"} }
}
