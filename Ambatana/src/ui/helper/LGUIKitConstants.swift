//
//  LGUIKitConstants.swift
//  LetGo
//
//  Created by Dídac on 23/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct LGUIKitConstants {

    // MARK: - Constraint Constants
    // Distance To main view
    static let itemDistanceToTop = 15
    static let itemDistanceToBottom = 15
    static let itemDistanceToLeft = 15
    static let itemDistanceToRight = 15

    // Distance Between elements
    static let verticalDistanceLarge = 30
    static let verticalDistanceMedium = 20
    static let verticalDistanceSmall = 10

    static let horitzontalDistanceMedium = 10
    static let horitzontalDistanceSmall = 5
    
    static let tabBarSellFloatingButtonDistance: CGFloat = 15

    // Message Distances
    private static let messageLongDistance = 50
    private static let messageShortDistance = 10

    static let myMessageLeading = messageLongDistance
    static let myMessageTrailing = messageShortDistance
    static let otherMessageLeading = messageShortDistance
    static let otherMessageTrailing = messageLongDistance
    static let verticalDistanceMessages = 5

    // Max Widths
    static let alertWidth = 270
    static let tooltipWidth: CGFloat = 270

    // MARK: - Corner radius
    static let defaultCornerRadius: CGFloat = 4
    static let productCellCornerRadius: CGFloat = 10
    static let notificationCellCornerRadius: CGFloat = 10
    static let chatTextViewCornerRadius: CGFloat = 10
    static let tooltipCornerRadius: CGFloat = 10
    static let chatCellCornerRadius: CGFloat = 10
    static let textfieldCornerRadius: CGFloat = 10
    static let alertCornerRadius: CGFloat = 15
    static let mapCornerRadius: CGFloat = 15
    static let containerCornerRadius: CGFloat = 15
    
    // MARK: - Button Heights
    static let bigButtonHeight: CGFloat = 50
    static let mediumButtonHeight: CGFloat = 44
    static let smallButtonHeight: CGFloat = 30
    static let tabBarSellFloatingButtonHeight: CGFloat = 60

    // MARK: - Sizes
    static var onePixelSize: CGFloat {
        return 1 / UIScreen.main.scale
    }
    static let enabledButtonHeight: CGFloat = 44

    //0.9 so it will consider images that are slightly vertical as horizontal ones (for better rendering)
    static let horizontalImageMinAspectRatio: CGFloat = 0.9

    // MARK: - Highlighted
    static let highlightedStateAlpha: CGFloat = 0.6
}
