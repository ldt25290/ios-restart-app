//
//  ProductVMProductInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 28/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct ProductVMProductInfo {
    let title: String?
    let titleAutoGenerated: Bool
    let titleAutoTranslated: Bool
    let price: String
    let description: String?
    let address: String?
    let location: LGLocationCoordinates2D?
    let distance: String?
    let creationDate: Date?

    init(product: Product, isAutoTranslated: Bool, distance: String?) {
        self.title = product.title
        self.titleAutoGenerated = product.isTitleAutoGenerated
        self.titleAutoTranslated = isAutoTranslated
        self.price = product.priceString()
        self.description = product.description?.trim
        self.address = product.postalAddress.zipCodeCityString
        self.location = product.location
        self.distance = distance
        self.creationDate = product.createdAt
    }
}