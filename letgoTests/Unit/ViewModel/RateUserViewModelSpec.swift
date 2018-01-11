//
//  RateUserViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift
import RxTest

class RateUserViewModelSpec: BaseViewModelSpec {
    var delegateReceivedUpdateDescriptionLastValue: String?
    var delegateReceivedUpdateTags: Bool = false
    
    var navigatorReceivedRateUserCancel: Bool = false
    var navigatorReceivedRateUserSkip: Bool = false
    var navigatorReceivedRateUserFinishLastValue: Int?
    
    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        delegateReceivedUpdateDescriptionLastValue = nil
        delegateReceivedUpdateTags = false
        
        navigatorReceivedRateUserCancel = false
        navigatorReceivedRateUserSkip = false
        navigatorReceivedRateUserFinishLastValue = nil
    }
    
    override func spec() {
        describe("RateUserViewModel") {
            var sut: RateUserViewModel!
            
            var data: RateUserData!
            var userRatingRepository: MockUserRatingRepository!
            var tracker: MockTracker!
            
            var isLoadingObserver: TestableObserver<Bool>!
            var stateObserver: TestableObserver<RateUserState>!
            var sendTextObserver: TestableObserver<String?>!
            var sendEnabledObserver: TestableObserver<Bool>!
            var ratingObserver: TestableObserver<Int?>!
            var descriptionObserver: TestableObserver<String?>!
            var descriptionCharLimitObserver: TestableObserver<Int>!
            var disposeBag: DisposeBag!
            
            beforeEach {
                self.resetViewModelSpec()
                
                var user = MockUserListing.makeMock()
                user.name = String.makeRandom()
                var avatar = MockFile.makeMock()
                avatar.fileURL = URL.makeRandom()
                user.avatar = avatar
                data = RateUserData(user: user)
                userRatingRepository = MockUserRatingRepository()
                tracker = MockTracker()
                sut = RateUserViewModel(source: .markAsSold,
                                        data: data,
                                        userRatingRepository: userRatingRepository,
                                        tracker: tracker)
                sut.delegate = self
                sut.navigator = self
                
                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                
                isLoadingObserver = scheduler.createObserver(Bool.self)
                stateObserver = scheduler.createObserver(RateUserState.self)
                sendTextObserver = scheduler.createObserver(Optional<String>.self)
                sendEnabledObserver = scheduler.createObserver(Bool.self)
                ratingObserver = scheduler.createObserver(Optional<Int>.self)
                descriptionObserver = scheduler.createObserver(Optional<String>.self)
                descriptionCharLimitObserver = scheduler.createObserver(Int.self)
                disposeBag = DisposeBag()
                
                sut.isLoading.asObservable().bind(to: isLoadingObserver).disposed(by: disposeBag)
                sut.state.asObservable().bind(to: stateObserver).disposed(by: disposeBag)
                sut.sendText.asObservable().bind(to: sendTextObserver).disposed(by: disposeBag)
                sut.sendEnabled.asObservable().bind(to: sendEnabledObserver).disposed(by: disposeBag)
                sut.rating.asObservable().bind(to: ratingObserver).disposed(by: disposeBag)
                sut.description.asObservable().bind(to: descriptionObserver).disposed(by: disposeBag)
                sut.descriptionCharLimit.asObservable().bind(to: descriptionCharLimitObserver).disposed(by: disposeBag)
            }
            
            describe("initialization") {
                it("returns data's userAvatar when calling userAvatar") {
                    expect(sut.userAvatar).to(equal(data.userAvatar))
                }
                it("returns data's userName when calling userName") {
                    expect(sut.userName).to(equal(data.userName))
                }
                it("is not loading") {
                    expect(sut.isLoading.value).to(beFalse())
                }
                it("has review positive state") {
                    expect(sut.state.value).to(equal(RateUserState.review(positive: true)))
                }
                it("has send text") {
                    expect(sut.sendText.value).notTo(beNil())
                }
                it("has send disabled") {
                    expect(sut.sendEnabled.value).to(beFalse())
                }
                it("has no rating") {
                    expect(sut.rating.value).to(beNil())
                }
                it("has no description") {
                    expect(sut.description.value).to(beNil())
                }
                it("has a 255 description char limit") {
                    expect(sut.descriptionCharLimit.value).to(equal(255))
                }
                it("has the positive user rating tags") {
                    let tags = (0..<sut.numberOfTags).flatMap { sut.titleForTagAt(index: $0) }
                    let positiveTags = PositiveUserRatingTag.allValues.map { $0.localizedText }
                    expect(tags).to(equal(positiveTags))
                }
                it("has no selected tag") {
                    let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                    expect(selectedTags).to(beEmpty())
                }
                it("tracks a userRatingStart event") {
                    let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                    expect(trackedEventNames).to(equal([EventName.userRatingStart]))
                }
            }
            
            describe("become active for the first time") {
                context("user did not have a previous rating and retrieval request succeeds") {
                    beforeEach {
                        userRatingRepository.ratingResult = UserRatingResult(error: .notFound)
                        
                        sut.didBecomeActive(true)
                    }
                    
                    it("isLoading emits: false, true, false") {
                         expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                    }
                }
                
                context("user had a previous rating and retrieval request succeeds") {
                    var userRating: MockUserRating!
                    beforeEach {
                        userRating = MockUserRating.makeMock()
                    }
                    
                    context("comment has tags") {
                        beforeEach {
                            let tag = PositiveUserRatingTag.allValues[0]
                            userRating.comment = String.make(tagsString: [tag.localizedText],
                                                             comment: "Comment")
                            userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                            
                            sut.didBecomeActive(true)
                        }
                        
                        it("isLoading emits: false, true, false") {
                            expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                        }
                        it("sendEnabled emits: true, false, true") {
                            expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                        }
                        it("rating emits: number") {
                            expect(ratingObserver.eventValues.flatMap { $0 }).toEventually(equal([userRating.value]))
                        }
                        it("calls delegate to update description") {
                            expect(self.delegateReceivedUpdateDescriptionLastValue).toEventually(equal("Comment"))
                        }
                        it("description emits: string") {
                            expect(descriptionObserver.eventValues.flatMap { $0 }).toEventually(equal(["Comment"]))
                        }
                        it("calls delegate to update tags") {
                            expect(self.delegateReceivedUpdateTags).toEventually(equal(true))
                        }
                        it("has a selected tag") {
                            expect((0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }).toEventually(equal([0]))
                        }
                    }
                    
                    context("comments has no tags") {
                        beforeEach {
                            userRating.comment = "Comment"
                            userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                            
                            sut.didBecomeActive(true)
                        }
                        
                        it("isLoading emits: false, true, false") {
                            expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                        }
                        it("sendEnabled emits: true, false, true") {
                            expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                        }
                        it("rating emits: number") {
                            expect(ratingObserver.eventValues.flatMap { $0 }).toEventually(equal([userRating.value]))
                        }
                        it("calls delegate to update description") {
                            expect(self.delegateReceivedUpdateDescriptionLastValue).toEventually(equal(userRating.comment))
                        }
                        it("description emits: string") {
                            expect(descriptionObserver.eventValues.flatMap { $0 }).toEventually(equal([userRating.comment!]))
                        }
                        it("calls delegate to update tags") {
                            expect(self.delegateReceivedUpdateTags).toEventually(beTrue())
                        }
                        it("has no selected tag") {
                            let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                            expect(selectedTags).toEventually(beEmpty())
                        }
                    }
                }
                
                context("user rating retrieval request fails") {
                    beforeEach {
                        userRatingRepository.ratingResult = UserRatingResult(error: .serverError(code: 500))
                        
                        sut.didBecomeActive(true)
                    }
                    
                    it("isLoading emits: false, true, false") {
                        expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                    }
                    it("sendEnabled emits: true, false, true") {
                        expect(isLoadingObserver.eventValues).toEventually(equal([false, true, false]))
                    }
                    it("rating emits: nil") {
                        expect(ratingObserver.eventValues.flatMap { $0 }).toEventually(equal([]))
                    }
                    it("does not call delegate to update description") {
                        expect(self.delegateReceivedUpdateDescriptionLastValue).toEventually(beNil())
                    }
                    it("description emits: nil") {
                        expect(descriptionObserver.eventValues.flatMap { $0 }).toEventually(equal([]))
                    }
                    it("calls delegate to update tags") {
                        expect(self.delegateReceivedUpdateTags).toEventually(equal(false))
                    }
                    it("has no selected tag") {
                        let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                        expect(selectedTags).toEventually(beEmpty())
                    }
                }
            }
            
            describe("become active for the next times") {
                beforeEach {
                    sut.didBecomeActive(false)
                }
                
                it("does not load again") {
                    expect(isLoadingObserver.eventValues).toEventually(equal([false]))
                }
            }
            
            describe("closeButtonPressed") {
                beforeEach {
                    sut.closeButtonPressed()
                }
                
                it("calls rate user cancel in navigator") {
                    expect(self.navigatorReceivedRateUserCancel) == true
                }
            }
            
            describe("skipButtonPressed") {
                beforeEach {
                    sut.skipButtonPressed()
                }
                
                it("calls rate user skip in navigator") {
                    expect(self.navigatorReceivedRateUserSkip) == true
                }
            }
            
            describe("ratingStarPressed") {
                context("negative rating") {
                    beforeEach {
                        sut.ratingStarPressed(1)
                    }
                    
                    it("rating emits: 1") {
                        expect(ratingObserver.eventValues.flatMap { $0 }) == [1]
                    }
                    
                    it("state emits: .review(positive: true), .review(positive: false)") {
                        expect(stateObserver.eventValues) == [.review(positive: true), .review(positive: false)]
                    }
                    
                    it("sendEnabled emits: false, false") {
                        expect(sendEnabledObserver.eventValues) == [false, false]
                    }
                }
                
                context("positive rating") {
                    beforeEach {
                        sut.ratingStarPressed(5)
                    }
                    
                    it("rating emits: 5") {
                        expect(ratingObserver.eventValues.flatMap { $0 }) == [5]
                    }
                    
                    it("state emits: .review(positive: true)") {
                        expect(stateObserver.eventValues) == [ .review(positive: true)]
                    }
                    
                    it("does not enable send button") {
                        expect(sendEnabledObserver.eventValues) == [false]
                    }
                }
                
                context("switch between negative & positive") {
                    beforeEach {
                        sut.ratingStarPressed(1)
                        sut.selectTagAt(index: 0)
                        sut.ratingStarPressed(3)
                    }
                    
                    it("has no selected tag") {
                        let selectedTags = (0..<sut.numberOfTags).filter { sut.isSelectedTagAt(index: $0) }
                        expect(selectedTags).to(beEmpty())
                    }
                }
            }
            
            context("review state") {
                context("rating not selected and tags not selected") {
                    it("does not enable send button") {
                        expect(sendEnabledObserver.eventValues) == [false]
                    }
                }
                
                context("rating selected and tags not selected") {
                    beforeEach {
                        sut.ratingStarPressed(3)
                    }
                    
                    it("does not enable send button") {
                        expect(sendEnabledObserver.eventValues) == [false]
                    }
                }
                
                context("rating not selected and tags selected") {
                    beforeEach {
                        sut.selectTagAt(index: 0)
                    }
                    
                    it("does not enable send button") {
                        expect(sendEnabledObserver.eventValues) == [false, false]
                    }
                    
                    it("description char limit gets updated") {
                        expect(sut.descriptionCharLimit.value) != 255
                    }
                }
                
                context("rating selected and tags selected") {
                    beforeEach {
                        sut.ratingStarPressed(3)
                        sut.selectTagAt(index: 0)
                    }
                    
                    it("enables send button") {
                        expect(sendEnabledObserver.eventValues) == [false, true]
                    }
                    
                    describe("sendButtonPressed") {
                        context("create/update request succeeds") {
                            beforeEach {
                                let userRating = MockUserRating.makeMock()
                                userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                                sut.sendButtonPressed()
                            }

                            it("sets the state to comment mode") {
                                expect(stateObserver.eventValues).toEventually(equal([.review(positive: true), .comment]))
                            }
                            
                            it("tracks a userRatingComplete event") {
                                expect(tracker.trackedEvents).toEventually(haveCount(2))
                                expect(tracker.trackedEvents.flatMap { $0.name }) == [EventName.userRatingStart, EventName.userRatingComplete]
                            }
                        }
                        
                        context("create/update request fails") {
                            beforeEach {
                                userRatingRepository.ratingResult = UserRatingResult(error: .serverError(code: 500))
                                sut.sendButtonPressed()
                            }
                            
                            it("calls delegate to show an auto fading message") {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                            }
                        }
                    }
                }
            }
            
            context("comment state") {
                var previousDescriptionCharLimit: Int!
                
                beforeEach {
                    sut.ratingStarPressed(3)
                    sut.selectTagAt(index: 0)
                    let userRating = MockUserRating.makeMock()
                    userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                    sut.sendButtonPressed()
                    
                    previousDescriptionCharLimit = sut.descriptionCharLimit.value
                }
                
                describe("leave comment empty") {
                    it("disables send button") {
                        expect(sut.sendEnabled.value).toEventually(equal(false))
                    }
                }
                
                describe("type a comment") {
                    beforeEach {
                        sut.description.value = "comment"
                    }
                    
                    it("enables send button") {
                        expect(sut.sendEnabled.value).toEventually(beTrue())
                    }
                    
                    it("updates the description char limit") {
                        expect(sut.descriptionCharLimit.value) != previousDescriptionCharLimit
                    }
                    
                    describe("wait for send button to be enabled and press send button") {
                        beforeEach {
                            expect(sut.sendEnabled.value).toEventually(beTrue())
                        }
                        
                        context("create/update request succeeds") {
                            beforeEach {
                                let userRating = MockUserRating.makeMock()
                                userRatingRepository.ratingResult = UserRatingResult(value: userRating)
                                sut.sendButtonPressed()
                            }
                            
                            it("calls rate user finish in navigator") {
                                expect(self.navigatorReceivedRateUserFinishLastValue).toEventuallyNot(beNil())
                            }
                            
                            it("tracks a second userRatingComplete event") {
                                expect(tracker.trackedEvents.flatMap { $0.name }).toEventually(equal([EventName.userRatingStart, EventName.userRatingComplete, EventName.userRatingComplete]))
                            }
                        }
                        
                        context("create/update request fails") {
                            beforeEach {
                                userRatingRepository.ratingResult = UserRatingResult(error: .serverError(code: 500))
                                sut.sendButtonPressed()
                            }
                            
                            it("calls delegate to show an auto fading message") {
                                expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                            }
                        }
                    }
                }
                
                describe("type a super long comment") {
                    beforeEach {
                        sut.description.value = "comment comment comment comment comment comment comment comment " +
                                                "comment comment comment comment comment comment comment comment " +
                                                "comment comment comment comment comment comment comment comment " +
                                                "comment comment comment comment comment comment comment comment " +
                                                "comment comment comment comment comment comment comment comment " +
                                                "comment comment comment comment comment comment comment comment "
                    }
                    
                    it("disables send button") {
                        expect(sut.sendEnabled.value).toEventually(beFalse())
                    }
                    
                    it("updates the description char limit to negative value") {
                        expect(sut.descriptionCharLimit.value) < 0
                    }
                }
            }
        }
    }
}

extension RateUserViewModelSpec: RateUserNavigator {
    func rateUserCancel() {
        navigatorReceivedRateUserCancel = true
    }
    
    func rateUserSkip() {
        navigatorReceivedRateUserSkip = true
    }
    
    func rateUserFinish(withRating rating: Int) {
        navigatorReceivedRateUserFinishLastValue = rating
    }
}

extension RateUserViewModelSpec: RateUserViewModelDelegate {
    func vmUpdateDescription(_ description: String?) {
        delegateReceivedUpdateDescriptionLastValue = description
    }
    
    func vmUpdateTags() {
        delegateReceivedUpdateTags = true
    }
}