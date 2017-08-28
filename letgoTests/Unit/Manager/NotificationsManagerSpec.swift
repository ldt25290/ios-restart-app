//
//  NotificationsManagerSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 17/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxTest
import Result
@testable import LGCoreKit
@testable import LetGoGodMode


class NotificationsManagerSpec: QuickSpec {

    override func spec() {

        var sut: LGNotificationsManager!
        var sessionManager: MockSessionManager!
        var myUserRepository: MockMyUserRepository!
        var chatRepository: MockChatRepository!
        var oldChatRepository: MockOldChatRepository!
        var notificationsRepository: MockNotificationsRepository!
        var keyValueStorage: KeyValueStorage!
        var featureFlags: MockFeatureFlags!
        var deepLinksRouter: MockDeepLinksRouter!

        var disposeBag: DisposeBag!

        var unreadMessagesObserver: TestableObserver<Int?>!
        var unreadNotificationsObserver: TestableObserver<Int?>!
        var globalCountObserver: TestableObserver<Int>!
        var marketingNotificationsObserver: TestableObserver<Bool>!
        var loggedInMarketingNotificationsObserver: TestableObserver<Bool>!

        describe("NotificationsManagerSpec") {
            func createNotificationsManager() {
                sut = LGNotificationsManager(sessionManager: sessionManager,
                                             chatRepository: chatRepository,
                                             oldChatRepository: oldChatRepository,
                                             notificationsRepository: notificationsRepository,
                                             keyValueStorage: keyValueStorage,
                                             featureFlags: featureFlags,
                                             deepLinksRouter: deepLinksRouter)

                disposeBag = nil
                disposeBag = DisposeBag()
                sut.unreadMessagesCount.asObservable().bindTo(unreadMessagesObserver).addDisposableTo(disposeBag)
                sut.unreadNotificationsCount.asObservable().bindTo(unreadNotificationsObserver).addDisposableTo(disposeBag)
                sut.globalCount.bindTo(globalCountObserver).addDisposableTo(disposeBag)
                sut.marketingNotifications.asObservable().bindTo(marketingNotificationsObserver).addDisposableTo(disposeBag)
                sut.loggedInMktNofitications.asObservable().bindTo(loggedInMarketingNotificationsObserver).addDisposableTo(disposeBag)
            }

            func setMyUser() {
                var myUser = MockMyUser.makeMock()
                myUser.objectId = String.makeRandom(length: 20)
                myUserRepository.myUserVar.value = myUser
            }

            func doLogin() {
                if myUserRepository.myUser == nil {
                    setMyUser()
                }
                sessionManager.loggedIn = true
                sessionManager.sessionEventsPublishSubject.onNext(.login)
            }

            func doLogout() {
                myUserRepository.myUserVar.value = nil
                sessionManager.loggedIn = false
                sessionManager.sessionEventsPublishSubject.onNext(.logout(kickedOut: false))
            }

            func populateCountersResults() {
                oldChatRepository.unreadMsgCountResult = Result<Int, RepositoryError>(10)
                let chatUnread = MockChatUnreadMessages(totalUnreadMessages: 7)
                chatRepository.unreadMessagesResult = ChatUnreadMessagesResult(chatUnread)
                let notifications = MockUnreadNotificationsCounts(listingSold: 2,
                                                                  listingLike: 2,
                                                                  review: 2,
                                                                  reviewUpdated: 2,
                                                                  buyersInterested: 2,
                                                                  listingSuggested: 2,
                                                                  facebookFriendshipCreated: 2,
                                                                  modular: 2,
                                                                  total: 16)
                notificationsRepository.unreadCountResult = NotificationsUnreadCountResult(notifications)
            }

            func populateEmptyCountersResults() {
                oldChatRepository.unreadMsgCountResult = Result<Int, RepositoryError>(0)
                let chatUnread = MockChatUnreadMessages(totalUnreadMessages: 0)
                chatRepository.unreadMessagesResult = ChatUnreadMessagesResult(chatUnread)
                let notifications = MockUnreadNotificationsCounts(listingSold: 0,
                                                                  listingLike: 0,
                                                                  review: 0,
                                                                  reviewUpdated: 0,
                                                                  buyersInterested: 0,
                                                                  listingSuggested: 0,
                                                                  facebookFriendshipCreated: 0,
                                                                  modular: 0,
                                                                  total: 0)
                notificationsRepository.unreadCountResult = NotificationsUnreadCountResult(notifications)
            }

            beforeEach {
                sessionManager = MockSessionManager()
                chatRepository = MockChatRepository.makeMock()
                oldChatRepository = MockOldChatRepository.makeMock()
                notificationsRepository = MockNotificationsRepository.makeMock()
                myUserRepository = MockMyUserRepository.makeMock()
                keyValueStorage = KeyValueStorage(storage: MockKeyValueStorage(), myUserRepository: myUserRepository)
                featureFlags = MockFeatureFlags()
                deepLinksRouter = MockDeepLinksRouter()

                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()

                unreadMessagesObserver = scheduler.createObserver(Optional<Int>.self)
                unreadNotificationsObserver = scheduler.createObserver(Optional<Int>.self)
                globalCountObserver = scheduler.createObserver(Int.self)
                marketingNotificationsObserver = scheduler.createObserver(Bool.self)
                loggedInMarketingNotificationsObserver = scheduler.createObserver(Bool.self)
            }

            describe("initialisation (setup)") {
                describe("notifications & chat counters") {
                    beforeEach {
                        populateCountersResults()
                        createNotificationsManager()
                    }
                    context("not logged in") {
                        beforeEach {
                            sessionManager.loggedIn = false
                            sut.setup()
                        }
                        it("unreadMessagesCount just emits a nil value") {
                            XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil)])
                        }
                        it("unreadNotificationsCount just emits a nil value") {
                            XCTAssertEqual(unreadNotificationsObserver.events, [next(0, nil)])
                        }
                        it("globalCount is 0") {
                            XCTAssertEqual(globalCountObserver.events, [next(0, 0)])
                        }
                    }
                    context("logged in") {
                        beforeEach {
                            sessionManager.loggedIn = true
                        }
                        context("old chat") {
                            beforeEach {
                                featureFlags.websocketChat = false
                                sut.setup()
                            }
                            it("unreadMessagesCount emits a nil and then the 10") {
                                expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 10]))
                            }
                            it("unreadNotificationsCount emits and then the 16") {
                                expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16]))
                            }
                            it("globalCount is 26") {
                                expect(globalCountObserver.events.last?.value.element!).toEventually(equal(26))
                            }
                        }
                        context("new chat") {
                            beforeEach {
                                featureFlags.websocketChat = true
                                sut.setup()
                            }
                            it("unreadMessagesCount emits a nil and then the 7") {
                                expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 7]))
                            }
                            it("unreadNotificationsCount emits and then the 14") {
                                expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16]))
                            }
                            it("globalCount is 23") {
                                expect(globalCountObserver.events.last?.value.element!).toEventually(equal(23))
                            }
                        }
                    }
                }
                describe("mkt notifications") {
                    context("not logged in") {
                        beforeEach {
                            sessionManager.loggedIn = false
                            createNotificationsManager()
                        }
                        context("no stored value") {
                            beforeEach {
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored true value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = true
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored false value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = false
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                    }
                    context("logged in") {
                        beforeEach {
                            doLogin()
                        }
                        context("no stored value") {
                            beforeEach {
                                createNotificationsManager()
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just default value true") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored true value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = true
                                createNotificationsManager()
                                sut.setup()
                            }
                            it("enabledMktNotifications emits true") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true)])
                            }
                        }
                        context("stored false value") {
                            beforeEach {
                                keyValueStorage.userMarketingNotifications = false
                                createNotificationsManager()
                                sut.setup()
                            }
                            it("enabledMktNotifications emits just false") {
                                XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                            }
                            it("loggedInMktNofitications emits true") {
                                XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, false)])
                            }
                        }
                    }
                }
            }
            describe("login event") {
                beforeEach {
                    sessionManager.loggedIn = false
                    populateCountersResults()
                }
                describe("notifications & chat counters") {
                    beforeEach {
                        createNotificationsManager()
                    }
                    context("old chat") {
                        beforeEach {
                            featureFlags.websocketChat = false
                            sut.setup()
                            doLogin()
                        }
                        it("unreadMessagesCount emits a nil and then the 10") {
                            expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 10]))
                        }
                        it("unreadNotificationsCount emits and then the 16") {
                            expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16]))
                        }
                        it("globalCount is 26") {
                            expect(globalCountObserver.events.last?.value.element!).toEventually(equal(26))
                        }
                    }
                    context("new chat") {
                        beforeEach {
                            featureFlags.websocketChat = true
                            sut.setup()
                            doLogin()
                        }
                        it("unreadMessagesCount emits a nil and then the 7") {
                            expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 7]))
                        }
                        it("unreadNotificationsCount emits and then the 16") {
                            expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16]))
                        }
                        it("globalCount is 23") {
                            expect(globalCountObserver.events.last?.value.element!).toEventually(equal(23))
                        }
                    }
                }
                describe("mkt notification") {
                    beforeEach {
                        createNotificationsManager()
                        sut.setup()
                    }
                    context("no stored value") {
                        beforeEach {
                            doLogin()
                        }
                        it("enabledMktNotifications emits false, and then true after login") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false), next(0, true)])
                        }
                        it("loggedInMktNofitications emits true on init, true on setup and then true again after login") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true), next(0, true)])
                        }
                    }
                    context("stored true value") {
                        beforeEach {
                            setMyUser()
                            keyValueStorage.userMarketingNotifications = true
                            doLogin()
                        }
                        it("enabledMktNotifications emits false, and then true after login") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false), next(0, true)])
                        }
                        it("loggedInMktNofitications emits true, true on setup and then true again after login") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true), next(0, true)])
                        }
                    }
                    context("stored false value") {
                        beforeEach {
                            setMyUser()
                            keyValueStorage.userMarketingNotifications = false
                            doLogin()
                        }
                        it("enabledMktNotifications emits false, and then false again after login") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false), next(0, false)])
                        }
                        it("loggedInMktNofitications emits true on init, true on setup and then false after login") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0,true), next(0, false)])
                        }
                    }
                }
            }
            describe("logout event") {
                beforeEach {
                    doLogin()
                    populateCountersResults()
                }
                describe("notifications & chat counters") {
                    beforeEach {
                        createNotificationsManager()
                    }
                    context("old chat") {
                        beforeEach {
                            featureFlags.websocketChat = false
                            sut.setup()
                            expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 10]))
                            expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16]))
                            doLogout()
                        }
                        it("unreadMessagesCount emits a nil, 10 and 0") {
                            expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 10, nil]))
                        }
                        it("unreadNotificationsCount emits nil, 16 and 0") {
                            expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16, nil]))
                        }
                        it("globalCount is 0") {
                            expect(globalCountObserver.events.last?.value.element!) == 0
                        }
                    }
                    context("new chat") {
                        beforeEach {
                            featureFlags.websocketChat = true
                            sut.setup()
                            expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 7]))
                            expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16]))
                            doLogout()
                        }
                        it("unreadMessagesCount emits a nil, 7 and 0") {
                            expect(unreadMessagesObserver.eventValues).toEventually(equal([nil, 7, nil]))
                        }
                        it("unreadNotificationsCount emits nil, 16 and 0") {
                            expect(unreadNotificationsObserver.eventValues).toEventually(equal([nil, 16, nil]))
                        }
                        it("globalCount is 0") {
                            expect(globalCountObserver.events.last?.value.element!) == 0
                        }
                    }
                }
                describe("mkt notification") {
                    context("no stored value") {
                        beforeEach {
                            createNotificationsManager()
                            sut.setup()
                            doLogout()
                        }
                        it("enabledMktNotifications emits true") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                        }
                        it("loggedInMktNofitications emits true, and then true after logout") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true)])
                        }
                    }
                    context("stored true value") {
                        beforeEach {
                            keyValueStorage.userMarketingNotifications = true
                            createNotificationsManager()
                            sut.setup()
                            doLogout()
                        }
                        it("enabledMktNotifications emits true") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, true)])
                        }
                        it("loggedInMktNofitications emits true, and then true again after logout") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, true), next(0, true)])
                        }
                    }
                    context("stored false value") {
                        beforeEach {
                            keyValueStorage.userMarketingNotifications = false
                            createNotificationsManager()
                            sut.setup()
                            doLogout()
                        }
                        it("enabledMktNotifications emits false") {
                            XCTAssertEqual(marketingNotificationsObserver.events, [next(0, false)])
                        }
                        it("loggedInMktNofitications emits false, and then true after logout") {
                            XCTAssertEqual(loggedInMarketingNotificationsObserver.events, [next(0, false), next(0, true)])
                        }
                    }
                }
            }
            describe("push notification") {
                context("old chat") {
                    beforeEach {
                        featureFlags.websocketChat = false
                        doLogin()
                        populateEmptyCountersResults()
                        createNotificationsManager()
                        sut.setup()
                        expect(unreadMessagesObserver.eventValues.count).toEventually(equal(2)) // initial + setup
                        populateCountersResults()
                        deepLinksRouter.deepLinksSignal.onNext(DeepLink.makeChatMock())
                        expect(unreadMessagesObserver.eventValues.count).toEventually(equal(3))
                    }
                    it("unreadMessagesCount value becomes 10") {
                        XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 0), next(0, 10)])
                    }
                }
                context("new chat") {
                    beforeEach {
                        featureFlags.websocketChat = true
                        doLogin()
                        populateEmptyCountersResults()
                        createNotificationsManager()
                        sut.setup()
                        expect(unreadMessagesObserver.eventValues.count).toEventually(equal(2)) // initial + setup
                        populateCountersResults()
                    }
                    it("unread messages changed from nil to 0") {
                        XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 0)])
                    }
                    context("chat status is connected") {
                        beforeEach {
                            chatRepository.chatStatusPublishSubject.onNext(.openAuthenticated)
                        }
                        describe("user receives push notification") {
                            beforeEach {
                                deepLinksRouter.deepLinksSignal.onNext(DeepLink.makeChatMock())
                            }
                            it("doesn't update anything") {
                                XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 0)])
                            }
                        }
                        describe("user receives message event from chat") {
                            beforeEach {
                                chatRepository.chatEventsPublishSubject.onNext(MockChatEvent.makeMessageSentMock())
                                expect(unreadMessagesObserver.eventValues.count).toEventually(equal(3))
                            }
                            it("unreadMessagesCount value becomes 7") {
                                XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 0), next(0, 7)])
                            }
                        }
                    }
                    context("chat status is not connected") {
                        beforeEach {
                            chatRepository.chatStatusPublishSubject.onNext(.closed)
                        }
                        describe("user receives push notification") {
                            beforeEach {
                                deepLinksRouter.deepLinksSignal.onNext(DeepLink.makeChatMock())
                                expect(unreadMessagesObserver.eventValues.count).toEventually(equal(3))
                            }
                            it("unreadMessagesCount value becomes 7") {
                                XCTAssertEqual(unreadMessagesObserver.events, [next(0, nil), next(0, 0), next(0, 7)])
                            }
                        }
                    }
                }
            }
        }
    }
}
