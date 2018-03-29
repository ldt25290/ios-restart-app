//
//  ABDynamicVar.swift
//  LetGo
//
//  Created by Dídac on 12/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol ABRegistrable {
    func register()
}

enum ABGroupType {
    case legacyABTests
    case core
    case realEstate
    case money
    case retention
    case chat
    case products
}

protocol ABVariable {
    var trackingData: String { get }
    var abGroupType: ABGroupType { get }
}

protocol ABTrackable {
    var tuple: (String, ABGroupType) { get }
}

final class LeanplumABVariable<U: Hashable>: Hashable, ABVariable, ABTrackable {
    var value: U { return unwrap(lpVar) }
    private let lpVar: LPVar
    private let unwrap: ((LPVar) -> U)
    let defaultValue: U

    var tuple: (String, ABGroupType) { return (trackingData, abGroupType) }
    var trackingData: String { return "\(key)-\(value)" }
    let abGroupType: ABGroupType
    private let key: String

    init(key: String,
         defaultValue: U,
         unwrap: @escaping ((LPVar) -> U),
         groupType: ABGroupType,
         lpVar: LPVar) {
        self.key = key
        self.defaultValue = defaultValue
        self.unwrap = unwrap
        self.abGroupType = groupType
        self.lpVar = lpVar
    }

    var hashValue: Int {
        return value.hashValue
    }

    static func ==(lhs: LeanplumABVariable<U>, rhs: LeanplumABVariable<U>) -> Bool {
        return lhs.value == rhs.value
    }

    static func makeBool(key: String, defaultValue: Bool, groupType: ABGroupType) -> LeanplumABVariable<Bool> {
        let lpVar = LPVar.define(key, with: defaultValue)!
        return LeanplumABVariable<Bool>.init(key: key,
                                             defaultValue: defaultValue,
                                             unwrap: { (lpvar) -> Bool in return lpvar.boolValue() },
                                             groupType: groupType,
                                             lpVar: lpVar)
    }

    static func makeInt(key: String, defaultValue: Int, groupType: ABGroupType) -> LeanplumABVariable<Int> {
        let lpVar = LPVar.define(key, with: defaultValue)!
        return LeanplumABVariable<Int>.init(key: key,
                                            defaultValue: defaultValue,
                                            unwrap: { (lpvar) -> Int in return lpvar.longValue() },
                                            groupType: groupType,
                                            lpVar: lpVar)
    }

    static func makeInt(key: String, defaultValue: Float, groupType: ABGroupType) -> LeanplumABVariable<Float> {
        let lpVar = LPVar.define(key, with: defaultValue)!
        return LeanplumABVariable<Float>.init(key: key,
                                              defaultValue: defaultValue,
                                              unwrap: { (lpvar) -> Float in return lpvar.floatValue() },
                                              groupType: groupType,
                                              lpVar: lpVar)
    }

    static func makeString(key: String, defaultValue: String, groupType: ABGroupType) -> LeanplumABVariable<String> {
        let lpVar = LPVar.define(key, with: defaultValue)!
        return LeanplumABVariable<String>.init(key: key,
                                               defaultValue: defaultValue,
                                               unwrap: { (lpvar) -> String in return lpvar.stringValue() },
                                               groupType: groupType,
                                               lpVar: lpVar)
    }
}

extension LeanplumABVariable: ABRegistrable {
    func register() {
        let _ = value
    }
}
