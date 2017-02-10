//
//  ProductViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble


class ProductViewModelSpec: BaseViewModelSpec {

    var lastBuyersToRate: [UserProduct]?
    var buyerToRateResult: String?
    var shownAlertText: String?

    override func spec() {
        var sut: ProductViewModel!

        var sessionManager: MockSessionManager!
        var myUserRepository: MockMyUserRepository!
        var productRepository: MockProductRepository!
        var commercializerRepository: MockCommercializerRepository!
        var stickersRepository: MockStickersRepository!
        var chatWrapper: MockChatWrapper!
        var locationManager: MockLocationManager!
        var countryHelper: CountryHelper!
        var product: MockProduct!
        var bubbleNotificationManager: MockBubbleNotificationManager!
        var featureFlags: MockFeatureFlags!
        var purchasesShopper: MockPurchasesShopper!
        var notificationsManager: MockNotificationsManager!
        var monetizationRepository: MockMonetizationRepository!
        var tracker: MockTracker!

        var disposeBag: DisposeBag!
        var bottomButtonsObserver: TestableObserver<[UIAction]>!


        describe("ProductViewModelSpec") {

            func buildProductViewModel() {
                let socialSharer = SocialSharer()
                sut = ProductViewModel(sessionManager: sessionManager, myUserRepository: myUserRepository, productRepository: productRepository,
                                       commercializerRepository: commercializerRepository, chatWrapper: chatWrapper,
                                       stickersRepository: stickersRepository, locationManager: locationManager, countryHelper: countryHelper,
                                       product: product, thumbnailImage: nil, socialSharer: socialSharer, navigator: self,
                                       bubbleManager: bubbleNotificationManager, featureFlags: featureFlags, purchasesShopper: purchasesShopper,
                                       notificationsManager: notificationsManager, monetizationRepository: monetizationRepository, tracker: tracker)
                sut.delegate = self
                sut.navigator = self

                disposeBag = DisposeBag()
                sut.actionButtons.asObservable().bindTo(bottomButtonsObserver).addDisposableTo(disposeBag)
            }

            beforeEach {
                sessionManager = MockSessionManager()
                myUserRepository = MockMyUserRepository()
                productRepository = MockProductRepository()
                commercializerRepository = MockCommercializerRepository()
                stickersRepository = MockStickersRepository()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct()
                bubbleNotificationManager = MockBubbleNotificationManager()
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                notificationsManager = MockNotificationsManager()
                monetizationRepository = MockMonetizationRepository()
                tracker = MockTracker()

                let scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                bottomButtonsObserver = scheduler.createObserver(Array<UIAction>.self)

                self.resetViewModelSpec()
            }
            describe("mark as sold") {
                beforeEach {
                    sessionManager.loggedIn = true
                    let myUser = MockMyUser()
                    myUserRepository.myUserVar.value = myUser
                    product = MockProduct()
                    product.user = MockUserProduct(myUser: myUser)
                    product.status = .approved

                    productRepository.voidResult = ProductVoidResult(Void())
                    let soldProduct = MockProduct.productFromProduct(product)
                    soldProduct.status = .sold
                    productRepository.productResult = ProductResult(soldProduct)
                }
                context("there are possible buyers") {
                    var possibleBuyers: [UserProduct]!
                    beforeEach {
                        possibleBuyers = [UserProduct]()
                        for _ in 0..<5 {
                            possibleBuyers.append(MockUserProduct())
                        }
                        productRepository.buyersResult = ProductBuyersResult(possibleBuyers)
                    }
                    context("one is selected") {
                        beforeEach {
                            self.buyerToRateResult = possibleBuyers.last?.objectId

                            buildProductViewModel()
                            sut.active = true

                            // There should appear one button
                            expect(sut.actionButtons.value.count).toEventually(equal(1))
                            sut.actionButtons.value.first?.action()

                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("has mark as sold and then sell it again button") {
                            let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                            expect(buttonTexts) == [LGLocalizedString.productMarkAsSoldButton, LGLocalizedString.productSellAgainButton]
                        }
                        it("has requested buyer selection with buyers array") {
                            expect(self.lastBuyersToRate?.count) == possibleBuyers.count
                        }
                        it("has called to mark as sold with correct buyerId") {
                            expect(productRepository.markAsSoldBuyerId) == self.buyerToRateResult
                        }
                        it("has a mark as sold tracked event with correct user-sold-to") {
                            let event = tracker.trackedEvents.last
                            expect(event?.name.rawValue) == "product-detail-sold"
                            expect(event?.params?[.userSoldTo] as? String) == "true"
                        }
                    }
                    context("outside letgo is selected") {
                        beforeEach {
                            self.buyerToRateResult = nil

                            buildProductViewModel()
                            sut.active = true

                            // There should appear one button
                            expect(sut.actionButtons.value.count).toEventually(equal(1))
                            sut.actionButtons.value.first?.action()

                            expect(tracker.trackedEvents.count).toEventually(equal(1))
                        }
                        it("has mark as sold and then sell it again button") {
                            let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                            expect(buttonTexts) == [LGLocalizedString.productMarkAsSoldButton, LGLocalizedString.productSellAgainButton]
                        }
                        it("has requested buyer selection with buyers array") {
                            expect(self.lastBuyersToRate?.count) == possibleBuyers.count
                        }
                        it("has called to mark as sold with correct buyerId") {
                            expect(productRepository.markAsSoldBuyerId).to(beNil())
                        }
                        it("has a mark as sold tracked event with correct user-sold-to") {
                            let event = tracker.trackedEvents.last
                            expect(event?.name.rawValue) == "product-detail-sold"
                            expect(event?.params?[.userSoldTo] as? String) == "false"
                        }
                    }
                }
                context("there are no possible buyers") {
                    beforeEach {
                        productRepository.buyersResult = ProductBuyersResult([])

                        buildProductViewModel()
                        sut.active = true

                        // There should appear one button
                        expect(sut.actionButtons.value.count).toEventually(equal(1))
                        sut.actionButtons.value.first?.action()

                        expect(tracker.trackedEvents.count).toEventually(equal(1))
                    }
                    it("has mark as sold and then sell it again button") {
                        let buttonTexts: [String] = bottomButtonsObserver.eventValues.flatMap { $0.first?.text }
                        expect(buttonTexts) == [LGLocalizedString.productMarkAsSoldButton, LGLocalizedString.productSellAgainButton]
                    }
                    it("hasn't requested buyer selection") {
                        expect(self.lastBuyersToRate).to(beNil())
                    }
                    it("has shown mark as sold alert") {
                        expect(self.shownAlertText!) == LGLocalizedString.productMarkAsSoldConfirmMessage
                    }
                    it("has called to mark as sold with correct buyerId") {
                        expect(productRepository.markAsSoldBuyerId).to(beNil())
                    }
                    it("has a mark as sold tracked event with correct user-sold-to") {
                        let event = tracker.trackedEvents.last!
                        expect(event.name.rawValue) == "product-detail-sold"
                        expect(event.params![.userSoldTo] as? String) == "no-conversations"
                    }
                }
            }
        }
    }

    override func resetViewModelSpec() {
        super.resetViewModelSpec()
        lastBuyersToRate = nil
        buyerToRateResult = nil
        shownAlertText = nil
    }

    override func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        shownAlertText = message
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            actions.last?.action()
        }
    }
}

extension ProductViewModelSpec: ProductViewModelDelegate {
    func vmShowShareFromMain(_ socialMessage: SocialMessage) {}
    func vmShowShareFromMoreInfo(_ socialMessage: SocialMessage) {}

    func vmOpenMainSignUp(_ signUpVM: SignUpViewModel, afterLoginAction: @escaping () -> ()) {}

    func vmOpenStickersSelector(_ stickers: [Sticker]) {}

    func vmOpenPromoteProduct(_ promoteVM: PromoteProductViewModel) {}
    func vmOpenCommercialDisplay(_ displayVM: CommercialDisplayViewModel) {}
    func vmAskForRating() {}
    func vmShowOnboarding() {}
    func vmShowProductDelegateActionSheet(_ cancelLabel: String, actions: [UIAction]) {}

    func vmShareDidFailedWith(_ error: String) {}
    func vmViewControllerToShowShareOptions() -> UIViewController { return UIViewController() }

    // Bump Up
    func vmShowFreeBumpUpView() {}
    func vmShowPaymentBumpUpView() {}
    func vmResetBumpUpBannerCountdown() {}
}

extension ProductViewModelSpec: ProductDetailNavigator {
    func closeProductDetail() {

    }
    func editProduct(_ product: Product) {

    }
    func openProductChat(_ product: Product) {

    }
    func closeAfterDelete() {

    }
    func openFreeBumpUpForProduct(product: Product, socialMessage: SocialMessage, withPaymentItemId: String) {

    }
    func openPayBumpUpForProduct(product: Product, purchaseableProduct: PurchaseableProduct) {

    }
    func selectBuyerToRate(source: RateUserSource, buyers: [UserProduct], completion: @escaping (String?) -> Void) {
        let result = self.buyerToRateResult
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion(result)
            self.lastBuyersToRate = buyers
        }
    }
}