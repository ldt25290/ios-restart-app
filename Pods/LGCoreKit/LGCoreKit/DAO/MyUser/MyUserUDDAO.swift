//
//  MyUserUserDefaultsDAO.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import RxSwift

class MyUserUDDAO: MyUserDAO {

    // Constants
    static let MyUserKeyMainKey = "MyUser"

    // iVars
    var myUser: MyUser? {
        return myUserVar.value
    }
    var rx_myUser: Observable<MyUser?> {
        return myUserVar.asObservable()
    }

    private let userDefaults: UserDefaults
    private let myUserVar = Variable<MyUser?>(nil)


    // MARK: - Lifecycle

    convenience init() {
        let userDefaults = UserDefaults.standard
        self.init(userDefaults: userDefaults)
    }

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        self.myUserVar.value = fetch()
    }


    // MARK : - MyUserDAO

    func save(_ theMyUser: MyUser) {
        myUserVar.value = theMyUser

        let localMyUser = LocalMyUser(myUser: theMyUser)
        let dict: [String: Any] = localMyUser.encode()
        userDefaults.setValue(dict, forKey: MyUserUDDAO.MyUserKeyMainKey)
    }

    func delete() {
        myUserVar.value = nil
        userDefaults.removeObject(forKey: MyUserUDDAO.MyUserKeyMainKey)
    }


    // MARK: - Private methods

    private func fetch() -> MyUser? {
        guard let dict = userDefaults.dictionary(forKey: MyUserUDDAO.MyUserKeyMainKey) else { return nil }
        return LocalMyUser.decode(dict)
    }
}