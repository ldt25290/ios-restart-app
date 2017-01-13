//
//  SearchesRouter.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 06/06/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

enum TrendingSearchesRouter: URLRequestAuthenticable {

    static let endpoint = "/api/trending_searches"

    case index(params: [String: Any])

    var requiredAuthLevel: AuthLevel {
        return .nonexistent
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .index(let params):
            return try Router<APIBaseURL>.index(endpoint: TrendingSearchesRouter.endpoint, params: params).asURLRequest()
        }
    }
}
