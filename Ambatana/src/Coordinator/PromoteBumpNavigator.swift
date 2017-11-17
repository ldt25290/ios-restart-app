//
//  PromoteBumpNavigator.swift
//  LetGo
//
//  Created by Dídac on 16/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol PromoteBumpNavigator {
    func promoteBumpDidCancel()
    func openSellFasterForListingId(listingId: String, purchaseableProduct: PurchaseableProduct)
}
