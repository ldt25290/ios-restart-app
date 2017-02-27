//
//  LogInEmailViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift

class LogInEmailViewModelSpec: BaseViewModelSpec {
    var delegateReceivedShowGodModeAlert = false

    var navigatorReceivedCancel = false
    var navigatorReceivedOpenHelp = false
    var navigatorReceivedOpenRememberPassword = false
    var navigatorReceivedOpenSignUp = false
    var navigatorReceiverOpenScammerAlert = false
    var navigatorReceivedCloseAfterLogIn = false

    override func spec() {
        describe("LogInEmailViewModel") {
            var sessionManager: MockSessionManager!
            var installationRepository: MockInstallationRepository!
            var keyValueStorage: MockKeyValueStorage!
            var tracker: MockTracker!

            var email: String!
            var suggestedEmail: String!
            var logInEnabled: Bool!

            var disposeBag: DisposeBag!
            var sut: LogInEmailViewModel!

            beforeEach {
                self.resetViewModelSpec()
                self.delegateReceivedShowGodModeAlert = false

                self.navigatorReceivedOpenHelp = false
                self.navigatorReceivedOpenRememberPassword = false
                self.navigatorReceivedOpenSignUp = false
                self.navigatorReceiverOpenScammerAlert = false
                self.navigatorReceivedCloseAfterLogIn = false

                email = nil
                suggestedEmail = nil
                logInEnabled = nil

                sessionManager = MockSessionManager()
                installationRepository = MockInstallationRepository()
                installationRepository.installationVar.value = MockInstallation()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()
                disposeBag = DisposeBag()

                let myUser = MockMyUser()
                myUser.email = "albert@letgo.com"
                sessionManager.logInResult = SessionMyUserResult(value: myUser)

                sut = LogInEmailViewModel(email: nil, isRememberedEmail: false,
                                          source: .sell, collapsedEmail: nil,
                                          sessionManager: sessionManager,
                                          installationRepository: installationRepository,
                                          keyValueStorage: keyValueStorage, tracker: tracker)
                sut.email.asObservable().subscribeNext { newEmail in
                    email = newEmail
                }.addDisposableTo(disposeBag)
                sut.suggestedEmail.subscribeNext { email in
                    suggestedEmail = email
                }.addDisposableTo(disposeBag)
                sut.logInEnabled.subscribeNext { enabled in
                    logInEnabled = enabled
                }.addDisposableTo(disposeBag)
                sut.delegate = self
                sut.navigator = self
            }

            describe("initialization") {
                context("did not log in previously") {
                    beforeEach {
                        sut = LogInEmailViewModel(email: nil, isRememberedEmail: false,
                                                  source: .sell, collapsedEmail: nil,
                                                  sessionManager: sessionManager,
                                                  installationRepository: installationRepository,
                                                  keyValueStorage: keyValueStorage, tracker: tracker)
                    }

                    it("has no email") {
                        expect(sut.email.value).to(beNil())
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }

                context("previously logged in by email") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "letgo"
                        keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                        sut = LogInEmailViewModel(source: .sell, collapsedEmail: nil, keyValueStorage: keyValueStorage)
                    }

                    it("has an email") {
                        expect(sut.email.value) == "albert@letgo.com"
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }

                context("previously logged in by facebook") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "facebook"
                        keyValueStorage[.previousUserEmailOrName] = "Albert FB"

                        sut = LogInEmailViewModel(source: .sell, collapsedEmail: nil, keyValueStorage: keyValueStorage)
                    }

                    it("has no email") {
                        expect(sut.email.value).to(beNil())
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }

                context("previously logged in by google") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "google"
                        keyValueStorage[.previousUserEmailOrName] = "Albert Google"

                        sut = LogInEmailViewModel(source: .sell, collapsedEmail: nil, keyValueStorage: keyValueStorage)
                    }

                    it("has no email") {
                        expect(sut.email.value).to(beNil())
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }
            }

            describe("accept autosuggested email") {
                var result: Bool!

                beforeEach {
                    result = nil
                }

                describe("empty") {
                    beforeEach {
                        sut.email.value = ""
                        result = sut.acceptSuggestedEmail()
                    }

                    it("returns false") {
                        expect(result) == false
                    }
                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                    }
                    it("does not update the email when accepting") {
                        expect(email) == ""
                    }
                }

                describe("user letters") {
                    beforeEach {
                        sut.email.value = "albert"
                        result = sut.acceptSuggestedEmail()
                    }

                    it("returns false") {
                        expect(result) == false
                    }
                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert"
                    }
                }

                describe("user letters and @ sign") {
                    beforeEach {
                        sut.email.value = "albert@"
                        result = sut.acceptSuggestedEmail()
                    }

                    it("returns false") {
                        expect(result) == false
                    }
                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert@"
                    }
                }

                describe("user letters, @ sign & first domain letters") {
                    beforeEach {
                        sut.email.value = "albert@g"
                        result = sut.acceptSuggestedEmail()
                    }

                    it("returns true") {
                        expect(result) == true
                    }
                    it("suggests first domain ocurrence") {
                        expect(suggestedEmail) == "albert@gmail.com"
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert@gmail.com"
                    }
                }
            }

            describe("log in button press with invalid form") {
                var errors: LogInEmailFormErrors!

                describe("empty") {
                    beforeEach {
                        sut.email.value = ""
                        sut.password.value = ""
                        errors = sut.logInButtonPressed()
                    }

                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                    it("does not return any error") {
                        expect(errors) == []
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                }

                describe("with email non-valid & short password") {
                    beforeEach {
                        sut.email.value = "a"
                        sut.password.value = "a"
                        errors = sut.logInButtonPressed()
                    }

                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns that the email is invalid and the password is short") {
                        expect(errors) == [.invalidEmail, .shortPassword]
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                }

                describe("with valid email & long password") {
                    beforeEach {
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "abcdefghijklmnopqrstuvwxyz"
                        errors = sut.logInButtonPressed()
                    }

                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns that the password is long") {
                        expect(errors) == [.longPassword]
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                }

                describe("with valid email & password") {
                    beforeEach {
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "letitgo"
                        errors = sut.logInButtonPressed()
                    }

                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns no errors") {
                        expect(errors) == []
                    }
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                }
            }

            describe("log in button press with valid form") {
                var errors: LogInEmailFormErrors!

                beforeEach {
                    sut.email.value = "albert@letgo.com"
                    sut.password.value = "letitgo"
                    errors = sut.logInButtonPressed()
                }

                it("has log in enabled") {
                    expect(logInEnabled) == true
                }
                it("returns no errors") {
                    expect(errors) == []
                }
                it("does not track any event") {
                    let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                    expect(trackedEventNames) == []
                }
                it("calls show and hide loading in delegate") {
                    expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                    expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                }
            }

            context("valid form") {
                beforeEach {
                    sut.email.value = "albert@letgo.com"
                    sut.password.value = "letitgo"
                }

                describe("log in fails once with unauthorized error") {
                    beforeEach {
                        sessionManager.logInResult = SessionMyUserResult(error: .unauthorized)
                        _ = sut.logInButtonPressed()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("does not call show alert in the delegate to suggest reset pwd") {
                        expect(self.delegateReceivedShowAlert) == false
                    }
                }

                describe("log in fails twice with unauthorized error") {
                    beforeEach {
                        sessionManager.logInResult = SessionMyUserResult(error: .unauthorized)
                        _ = sut.logInButtonPressed()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        self.delegateReceivedHideLoading = false

                        _ = sut.logInButtonPressed()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks two loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("calls show alert in the delegate to suggest reset pwd") {
                        expect(self.delegateReceivedShowAlert).toEventually(beTrue())
                    }
                }

                describe("log in fails twice with another error") {
                    beforeEach {
                        sessionManager.logInResult = SessionMyUserResult(error: .network)
                        _ = sut.logInButtonPressed()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        self.delegateReceivedHideLoading = false

                        _ = sut.logInButtonPressed()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks two loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("does not call show alert in the delegate to suggest reset pwd") {
                        expect(self.delegateReceivedShowAlert) == false
                    }
                }

                describe("log in fails with scammer error") {
                    beforeEach {
                        sessionManager.logInResult = SessionMyUserResult(error: .scammer)
                        _ = sut.logInButtonPressed()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("calls open scammer alert in the navigator") {
                        expect(self.navigatorReceiverOpenScammerAlert).toEventually(beTrue())
                    }
                }

                describe("log in succeeds") {
                    let email = "albert.hernandez@gmail.com"

                    beforeEach {
                        let myUser = MockMyUser()
                        myUser.email = email
                        sessionManager.logInResult = SessionMyUserResult(value: myUser)
                        _ = sut.logInButtonPressed()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a loginEmail event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmail]
                    }
                    it("calls close after login in navigator when signup succeeds") {
                        expect(self.navigatorReceivedCloseAfterLogIn).toEventually(beTrue())
                    }
                    it("saves letgo as previous user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider) == "letgo"
                    }
                    it("saves the user email as previous email") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username) == email
                    }
                }
            }


            context("god mode") {
                describe("fill form with admin values") {
                    beforeEach {
                        sut.email.value = "admin"
                        sut.password.value = "wat"
                        _ = sut.logInButtonPressed()
                    }

                    it("calls show god mode alert in delegate") {
                        expect(self.delegateReceivedShowGodModeAlert) == true
                    }
                }

                describe("enable god mode") {
                    context("wrong password") {
                        beforeEach {
                            sut.godModePasswordTyped(godPassword: "whatever")
                        }

                        it("does not enable god mode") {
                            expect(keyValueStorage[.isGod]) == false
                        }
                    }

                    context("correct password") {
                        beforeEach {
                            sut.godModePasswordTyped(godPassword: "mellongod")
                        }

                        it("enables god mode") {
                            expect(keyValueStorage[.isGod]) == true
                        }
                    }
                }

                describe("remember password press") {
                    beforeEach {
                        sut.rememberPasswordButtonPressed()
                    }

                    it("calls open remember password in navigator") {
                        expect(self.navigatorReceivedOpenRememberPassword) == true
                    }
                }
            }

            describe("footer button press") {
                beforeEach {
                    sut.footerButtonPressed()
                }

                it("calls open sign up navigator") {
                    expect(self.navigatorReceivedOpenSignUp) == true
                }
            }

            describe("help button press") {
                beforeEach {
                    sut.helpButtonPressed()
                }
                
                it("calls open help in navigator") {
                    expect(self.navigatorReceivedOpenHelp) == true
                }
            }

            describe("close button press") {
                beforeEach {
                    sut.closeButtonPressed()
                }

                it("calls cancel in navigator") {
                    expect(self.navigatorReceivedCancel) == true
                }
            }
        }
    }
}

extension LogInEmailViewModelSpec: LogInEmailViewModelDelegate {
    func vmGodModePasswordAlert() {
        delegateReceivedShowGodModeAlert = true
    }
}

extension LogInEmailViewModelSpec: LogInEmailNavigator {
    func cancelLogInEmail() {
        navigatorReceivedCancel = true
    }

    func openHelpFromLogInEmail() {
        navigatorReceivedOpenHelp = true
    }

    func openRememberPasswordFromLogInEmail(email: String?) {
        navigatorReceivedOpenRememberPassword = true
    }

    func openSignUpEmailFromLogInEmail(email: String?,
                                       isRememberedEmail: Bool, collapsedEmail: EventParameterBoolean?) {
        navigatorReceivedOpenSignUp = true
    }

    func openScammerAlertFromLogInEmail(contactURL: URL) {
        navigatorReceiverOpenScammerAlert = true
    }

    func closeAfterLogInSuccessful() {
        navigatorReceivedCloseAfterLogIn = true
    }
}