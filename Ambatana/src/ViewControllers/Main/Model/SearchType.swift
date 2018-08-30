//
//  SearchType.swift
//  LetGo
//
//  Created by Eli Kohen on 16/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum SearchType {
    case user(query: String)
    case trending(query: String)
    case suggestive(search: SuggestiveSearch, indexSelected: Int)
    case lastSearch(search: SuggestiveSearch)
    case collection(type: CollectionCellType, query: String)
    case feed(page: URL, title: String)

    var text: String? {
        switch self {
        case let .user(query):
            return query
        case let .trending(query):
            return query
        case let .suggestive(search, _):
            return search.name
        case let .lastSearch(search):
            return search.name
        case let .collection(type, _):
            return type.title
        case let .feed(_, title):
            return title
        }
    }

    var query: String? {
        switch self {
        case let .user(query):
            return query
        case let .trending(query):
            return query
        case let .suggestive(search, _):
            return search.name
        case let .lastSearch(search):
            return search.name
        case let .collection(_ , query):
            return query
        case .feed:
            return nil
        }
    }
    
    var category: ListingCategory? {
        switch self {
        case .user, .trending, .collection, .feed:
            return nil
        case let .suggestive(search, _):
            return search.category
        case let .lastSearch(search):
            return search.category
        }
    }

    var isTrending: Bool {
        switch self {
        case .user, .suggestive, .collection, .lastSearch, .feed:
            return false
        case .trending:
            return true
        }
    }
    
    var isSuggestive: Bool {
        switch self {
        case .user, .trending, .collection, .lastSearch, .feed:
            return false
        case .suggestive:
            return true
        }
    }

    var isCollection: Bool {
        switch self {
        case .user, .suggestive, .trending, .lastSearch, .feed:
            return false
        case .collection:
            return true
        }
    }
    
    var isLastSearch: Bool {
        switch self {
        case .user, .suggestive, .trending, .collection, .feed:
            return false
        case .lastSearch:
            return true
        }
    }

    var isUserSearch: Bool {
        switch self {
        case .user:
            return true
        case .lastSearch, .suggestive, .trending, .collection, .feed:
            return false
        }
    }
    
    var indexSelected: Int? { // Needed to track suggestive search selections
        switch self {
        case let .suggestive(_, indexSelected):
            return indexSelected
        case .user, .trending, .lastSearch, .collection, .feed:
            return nil
        }
    }
}
