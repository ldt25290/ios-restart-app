//
//  Double+Rounding.swift
//  LetGo
//
//  Created by Dídac on 26/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//


extension Double {
    /* Rounds to the nearest given decimal. Examples:

     Double(4.24).roundNearest(0.5) -> 4
     Double(4.5).roundNearest(0.5)  -> 4.5
     Double(4.74).roundNearest(0.5) -> 4.5
     Double(4.76).roundNearest(0.5) -> 5

     Double(4.24).roundNearest(0.1) -> 4.2
     Double(4.25).roundNearest(0.1) -> 4.3 */
    func roundNearest(nearest: Double) -> Double {
        let n = 1/nearest
        return round(self * n) / n
    }
}
