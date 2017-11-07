//
//  SuggestiveSearch+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 10/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension SuggestiveSearch {
    var title: String {
        switch self {
        case let .term(name):
            return name.lowercased()
        case let .category(category):
            return category.name
        case let .termWithCategory(name, _):
            return name.lowercased()
        }
    }
    
    var subtitle: String? {
        switch self {
        case .term:
            return nil
        case .category:
            return LGLocalizedString.suggestionsCategory
        case let .termWithCategory(_, category):
            return category.name
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .term, .termWithCategory:
            return #imageLiteral(resourceName: "ic_search")
        case .category:
            return #imageLiteral(resourceName: "ic_filters_gray")
        }
    }
}