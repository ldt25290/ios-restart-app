//
//  NotificationUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol NotificationUser {
    var id: String { get }
    var name: String? { get }
    var avatar: String? { get }
}
