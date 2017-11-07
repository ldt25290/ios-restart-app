//
//  RealEstatePropertyType.swift
//  LetGo
//
//  Created by Juan Iglesias on 11/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

extension RealEstatePropertyType {
    var localizedString: String {
        switch self {
        case .apartment:
            return LGLocalizedString.realEstateTypePropertyApartment
        case .room:
            return LGLocalizedString.realEstateTypePropertyRoom
        case .house:
            return LGLocalizedString.realEstateTypePropertyHouse
        case .other:
            return LGLocalizedString.realEstateTypePropertyOthers
        case .commercial:
            return LGLocalizedString.realEstateTypePropertyCommercial
        }
    }
    
    static var allValues: [RealEstatePropertyType] {
        return [.apartment, .room, .house, .commercial, .other]
    }
    
    var position: Int {
        switch self {
        case .apartment:
            return 0
        case .room:
            return 1
        case .house:
            return 2
        case .commercial:
            return 3
        case .other:
            return 4
        }
    }
}