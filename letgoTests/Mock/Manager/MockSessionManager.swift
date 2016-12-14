//
//  MockSessionManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class MockSessionManager: SessionManager {
    var myUserResult: SessionMyUserResult!
    var resetPasswordResult: SessionEmptyResult!

    
    // MARK: - SessionManager

    var sessionEvents: Observable<SessionEvent> = PublishSubject<SessionEvent>()

    var loggedIn: Bool = false

    func signUp(email: String, password: String, name: String, newsletter: Bool?,
                completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func signUp(email: String, password: String, name: String, newsletter: Bool?, recaptchaToken: String,
                completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func login(email: String, password: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func loginFacebook(token: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func loginGoogle(token: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func recoverPassword(email: String, completion: SessionEmptyCompletion?) {
        performAfterDelayWithCompletion(completion, result: resetPasswordResult)
    }

    func logout() {
    }

    func connectChat() {
    }

    func disconnectChat() {
    }
}