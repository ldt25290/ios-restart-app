//
//  QuickChatViewBinderSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 01/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble

final class QuickChatViewBinderSpec: QuickSpec {

    override func spec() {
        var sut: QuickChatViewBinder!
        var quickChatView: MockQuickChatView!
        var quickChatVM: MockQuickChatViewModelRx!

        describe("QuickChatView is visible") {
            beforeEach {
                quickChatView = MockQuickChatView()
                quickChatVM = MockQuickChatViewModelRx()

                sut = QuickChatViewBinder()
                sut.quickChatView = quickChatView
                sut.bind(to: quickChatVM)
            }

            afterEach {
                quickChatView.resetVariables()
            }

            context("new placeholder changes") {
                beforeEach {
                    quickChatVM.directChatPlaceholder.value = String.makeRandom()
                }
                it("setInitialText is called") {
                    expect(quickChatView.setInitialTextCalled).toEventually(equal(1))
                }
            }

            context("new quickAnswers changes") {
                beforeEach {
                    quickChatVM.quickAnswers.value = [QuickAnswer.availabilityQuickAnswers(isFree: true)]
                }
                it("updateDirectChatCalledWith is called") {
                    expect(quickChatView.updateDirectChatCalled).toEventually(equal(1))
                }
            }

            context("chatViewMessages changes") {
                beforeEach {
                    let message = ChatViewMessage(objectId: nil,
                                                  talkerId: String.makeRandom(),
                                                  sentAt: nil,
                                                  receivedAt: nil,
                                                  readAt: nil,
                                                  type: .text(text: String.makeRandom()),
                                                  status: nil,
                                                  warningStatus: .normal)
                    quickChatVM.directChatMessages.value = [message]
                }
                it("handleChatChange is called") {
                    expect(quickChatView.handleChatChangeCalled).toEventually(equal(1))
                }
            }

            context("we dealloc the view") {
                beforeEach {
                    quickChatView = MockQuickChatView()
                }
                it("and the binder's view reference dies too (so weak)") {
                    expect(sut.quickChatView).to(beNil())
                }
            }
        }
    }
}

private class MockQuickChatView: QuickChatViewType {
    var rx_chatTextView: Reactive<ChatTextView> { return textView.rx }

    var setInitialTextCalled: Int = 0
    var updateDirectChatCalled: Int = 0
    var handleChatChangeCalled: Int = 0

    private var textView = ChatTextView()

    func resetVariables() {
        setInitialTextCalled = 0
        updateDirectChatCalled = 0
        handleChatChangeCalled = 0
    }
    func setInitialText(_ text: String) {
        setInitialTextCalled = setInitialTextCalled + 1
    }
    func updateDirectChatWith(answers: [[QuickAnswer]], isDynamic: Bool) {
        updateDirectChatCalled = updateDirectChatCalled + 1
    }
    func handleChatChange(_ change: CollectionChange<ChatViewMessage>) {
        handleChatChangeCalled = handleChatChangeCalled + 1
    }
}

fileprivate extension QuickChatViewType {
    func resetVariables() {}
}

private class MockQuickChatViewModelRx: QuickChatViewModelRx {

    var areAnswersDynamic: Bool = true
    var rx_directChatPlaceholder: Observable<String> { return directChatPlaceholder.asObservable() }
    var rx_quickAnswers: Observable<[[QuickAnswer]]> { return quickAnswers.asObservable() }
    var isChatEnabled: Observable<Bool> { return chatEnabled.asObservable() }
    var rx_directMessages: Observable<CollectionChange<ChatViewMessage>> { return directChatMessages.changesObservable }

    let directChatPlaceholder = Variable<String>("")
    let quickAnswers = Variable<[[QuickAnswer]]>([])
    let chatEnabled = Variable<Bool>(false)
    let directChatMessages = CollectionVariable<ChatViewMessage>([])
}
