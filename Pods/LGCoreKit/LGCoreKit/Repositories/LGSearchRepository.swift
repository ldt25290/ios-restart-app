//
//  LGSearchRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


final class LGSearchRepository: SearchRepository {
    private var searchesByCountry: [String : [String]] = [:]
    private let dataSource: SearchDataSource

    
    // MARK: - Lifecycle

    init(dataSource: SearchDataSource) {
        self.dataSource = dataSource
    }

    
    // MARK: - Public methods

    func index(countryCode: String,
               completion: TrendingSearchesCompletion?) {
        if let cached = searchesByCountry[countryCode] {
            completion?(TrendingSearchesResult(value: cached))
            return
        }

        dataSource.index(countryCode: countryCode) { [weak self] result in
            if let searches = result.value {
                self?.searchesByCountry[countryCode] = searches
            }
            handleApiResult(result, completion: completion)
        }
    }
    
    func retrieveSuggestiveSearches(language: String,
                                    limit: Int,
                                    term: String,
                                    shouldIncludeCategories: Bool,
                                    completion: SuggestiveSearchesCompletion?) {
        dataSource.retrieveSuggestiveSearches(language: language,
                                              limit: limit,
                                              term: term,
                                              shouldIncludeCategories: shouldIncludeCategories) { result in
            handleApiResult(result, completion: completion)
        }
    }
}