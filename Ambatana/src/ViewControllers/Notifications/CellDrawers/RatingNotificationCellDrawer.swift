//
//  ProductSoldNotificationCellDrawer.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class RatingNotificationCellDrawer: BaseNotificationCellDrawer<NotificationCell> {
    
    override func draw(cell: NotificationCell, data: NotificationData) {
        let placeholder: UIImage?
        let userImageUri: String?
        let message: String

        switch data.type {
        case let .Rating(userId, userName, userImage):
            placeholder = LetgoAvatar.avatarWithID(userId, name: userName)
            message = LGLocalizedString.notificationsTypeRating(userName ?? "")
            userImageUri = userImage
        case let .RatingUpdated(userId, userName, userImage):
            placeholder = LetgoAvatar.avatarWithID(userId, name: userName)
            message = LGLocalizedString.notificationsTypeRatingUpdated(userName ?? "")
            userImageUri = userImage
        default:
            return
        }

        cell.actionLabel.text = message
        cell.iconImage.image = UIImage(named: "ic_rating_star")
        if let urlStr = userImageUri, leftUrl = NSURL(string: urlStr) {
            cell.primaryImage.lg_setImageWithURL(leftUrl, placeholderImage: placeholder)
        } else {
            cell.primaryImage.image = placeholder
        }
        cell.timeLabel.text = data.date.relativeTimeString(true)
        cell.actionButton.setTitle(LGLocalizedString.notificationsTypeRatingButton, forState: .Normal)
    }
}