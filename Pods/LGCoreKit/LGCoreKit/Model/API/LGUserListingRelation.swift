//
//  LGUserListingRelation.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGUserListingRelation: UserListingRelation {

    public var isFavorited: Bool
    public var isReported: Bool

}

extension LGUserListingRelation: Decodable {

    /**
    Expects a json in the form:

        {
          "is_reported": false,
          "is_favorited": false
        }
    */
    public static func decode(_ j: JSON) -> Decoded<LGUserListingRelation> {

        return curry(LGUserListingRelation.init)
            <^> LGArgo.mandatoryWithFallback(json: j, key: "is_favorited", fallback: false)
            <*> LGArgo.mandatoryWithFallback(json: j, key: "is_reported", fallback: false)
    }
}
