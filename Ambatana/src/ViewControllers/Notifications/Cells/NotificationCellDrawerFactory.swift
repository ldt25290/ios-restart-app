//
//  NotificationCellDrawerFactory.swift
//  LetGo
//
//  Created by Eli Kohen on 27/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

public class NotificationCellDrawerFactory {

    static func drawerForNotificationData(notification: NotificationData) -> NotificationCellDrawer {
        return ProductNotificationCellDrawer()
    }

    static func registerCells(tableView: UITableView) {
        ProductNotificationCellDrawer.registerCell(tableView)
    }
}
