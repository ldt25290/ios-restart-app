//
//  LGChatProduct.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGChatProduct: ChatProduct {
    let objectId: String?
    let name: String?
    let status: String
    let image: File?
    let price: Double?
    let currency: Currency?
}

extension LGChatProduct: Decodable {
    
    struct JSONKeys {
        static let objectId = "id"
        static let name = "name"
        static let status = "status"
        static let image = "image"
        static let price = ["price", "amount"]
        static let currency = ["price", "currency"]
    }
    
    static func decode(j: JSON) -> Decoded<LGChatProduct> {
        let init1 = curry(LGChatProduct.init)
            <^> j <|? JSONKeys.objectId
            <*> j <|? JSONKeys.name
            <*> j <| JSONKeys.status
            <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.image)
            <*> j <|? JSONKeys.price
            <*> LGArgo.jsonToCurrency(j, currencyKey: JSONKeys.currency)
        
        return init1
    }
    
    static func decodeOptional(json: JSON?) -> Decoded<LGChatProduct?> {
        guard let j = json else { return Decoded<LGChatProduct?>.Success(nil) }
        return Decoded<LGChatProduct?>.Success(LGChatProduct.decode(j).value)
    }
}
