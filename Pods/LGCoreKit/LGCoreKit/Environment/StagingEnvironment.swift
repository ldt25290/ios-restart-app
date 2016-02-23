//
//  DevelopmentEnvironment.swift
//  LetGo
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

struct StagingEnvironment: Environment {
    // API
    let apiBaseURL = "http://api.stg.letgo.com"
    let bouncerBaseURL = "http://bouncer.stg.letgo.com/api"

    // Config
    let configURL = "http://letgo-images-devel.s3.amazonaws.com/config/ios.json"
}
