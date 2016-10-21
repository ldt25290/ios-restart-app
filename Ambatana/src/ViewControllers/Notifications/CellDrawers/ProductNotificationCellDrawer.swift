//
//  ProductSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductNotificationCellDrawer: BaseNotificationCellDrawer<ProductNotificationCell> {
    
    override func draw(cell: ProductNotificationCell, data: NotificationData) {
        cell.actionLabel.text = data.subtitle
        cell.iconImage.image = data.icon
        if let urlStr = data.letfImage, leftUrl = NSURL(string: urlStr) {
            cell.primaryImage.lg_setImageWithURL(leftUrl, placeholderImage: data.leftImagePlaceholder)
        } else {
            cell.primaryImage.image = data.leftImagePlaceholder
        }
        cell.primaryImageAction = data.leftImageAction
        cell.timeLabel.text = data.date.relativeTimeString(false)
        cell.actionButton.setTitle(data.primaryActionText, forState: .Normal)
    }
}
