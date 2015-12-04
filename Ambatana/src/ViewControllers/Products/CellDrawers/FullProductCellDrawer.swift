//
//  FullProductCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 03/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

class FullProductCellDrawer: BaseCollectionCellDrawer<ProductCell>, ProductCellDrawer {

    func draw(collectionCell: UICollectionViewCell, data: ProductCellData) {

        guard let cell = collectionCell as? ProductCell else { return }

        // Name
        let title = data.title?.lg_capitalizedWords() ?? ""
        cell.nameLabel.text = title
        cell.nameTopConstraint.constant = title.isEmpty ? 2 : 8

        // Price
        cell.priceLabel.text = data.price ?? ""

        // Thumb
        if let thumbURL = data.thumbUrl {
            cell.setImageUrl(thumbURL)
        }

        // Status (stripe)
        switch data.status {
        case .Sold, .SoldOld:
            cell.stripeImageView.image = UIImage(named: "stripe_sold")
            cell.stripeLabel.text = LGLocalizedString.productListItemSoldStatusLabel

        case .Pending, .Approved, .Discarded, .Deleted:
            if let createdAt = data.date {
                if NSDate().timeIntervalSinceDate(createdAt) < 60*60*24 {
                    cell.stripeImageView.image = UIImage(named: "stripe_new")
                    cell.stripeLabel.text = LGLocalizedString.productListItemNewStatusLabel
                }
            }
        }
    }
}
