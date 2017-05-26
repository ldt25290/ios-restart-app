//
//  CountryCode.swift
//  LetGo
//
//  Created by Juan Iglesias on 22/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum CountryCode: String {
    case turkey = "tr"
    case usa = "us"

    init?(string: String) {
        let lowerCasedCode = string.lowercased()
        guard let countryCode = CountryCode(rawValue: lowerCasedCode) else { return nil }
        self = countryCode
    }

    var zipCodeLenght: Int {
        switch self {
        case .usa:
            return 5
        case .turkey:
            return 5
        }
    }
}
