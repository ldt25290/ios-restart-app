//
//  ABTests.swift
//  LetGo
//
//  Created by Isaac Roldan on 20/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation

public struct ABTests {
    public static let navBarTintColor = OptimizelyABLiveVariable.colorVariable("NavBarTintColor", colorValue: StyleHelper.red)
    public static let productsWithinFilterEnabled = OptimizelyABLiveVariable.boolVariable("ProductsWithinFilter", boolValue: true)

    public static let allValues = [ABTests.navBarTintColor, ABTests.productsWithinFilterEnabled]
}