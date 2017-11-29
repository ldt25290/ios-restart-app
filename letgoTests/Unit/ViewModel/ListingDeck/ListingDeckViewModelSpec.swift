//
//  ListingDeckViewModelSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 02/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble


class ListingDeckViewModelSpec: BaseViewModelSpec {

    override func spec() {
        var sut: ListingDeckViewModel!

        var listingViewModelMaker: MockListingViewModelMaker!
        var listingListRequester: MockListingListRequester!
        var imageDownloader: MockImageDownloader!

        var myUserRepository: MockMyUserRepository!
        var listingRepository: MockListingRepository!
        var chatWrapper: MockChatWrapper!
        var locationManager: MockLocationManager!
        var countryHelper: CountryHelper!
        var product: MockProduct!
        var featureFlags: MockFeatureFlags!
        var purchasesShopper: MockPurchasesShopper!
        var notificationsManager: MockNotificationsManager!
        var monetizationRepository: MockMonetizationRepository!
        var tracker: MockTracker!

        var disposeBag: DisposeBag!
        var scheduler: TestScheduler!

        var cellModelsObserver: TestableObserver<[ListingCardViewModel]>!
        var productInfoObserver: TestableObserver<ListingVMProductInfo?>!
        var productImageUrlsObserver: TestableObserver<[URL]>!
        var userInfoObserver: TestableObserver<ListingVMUserInfo?>!
        var productStatsObserver: TestableObserver<ListingStats?>!
        var navBarButtonsObserver: TestableObserver<[UIAction]>!
        var actionButtonsObserver: TestableObserver<[UIAction]>!
        var statusObserver: TestableObserver<ListingViewModelStatus>!
        var isFeaturedObserver: TestableObserver<Bool>!
        var quickAnswersObserver: TestableObserver<[[QuickAnswer]]>!
        var quickAnswersAvailableObserver: TestableObserver<Bool>!
        var directChatEnabledObserver: TestableObserver<Bool>!
        var directChatPlaceholderObserver: TestableObserver<String>!
        var directChatMessagesObserver: TestableObserver<[ChatViewMessage]>!
        var isFavoriteObserver: TestableObserver<Bool>!
        var bumpUpBannerInfoObserver: TestableObserver<BumpUpInfo?>!

        fdescribe("ListingDeckViewModelSpec") {

            func startObserving() {
                disposeBag = DisposeBag()

                sut.objects.observable.bindTo(cellModelsObserver).addDisposableTo(disposeBag)
                sut.productInfo.asObservable().bindTo(productInfoObserver).addDisposableTo(disposeBag)
                sut.productImageURLs.asObservable().bindTo(productImageUrlsObserver).addDisposableTo(disposeBag)
                sut.userInfo.asObservable().bindTo(userInfoObserver).addDisposableTo(disposeBag)
                sut.listingStats.asObservable().bindTo(productStatsObserver).addDisposableTo(disposeBag)
                sut.navBarButtons.asObservable().bindTo(navBarButtonsObserver).addDisposableTo(disposeBag)
                sut.actionButtons.asObservable().bindTo(actionButtonsObserver).addDisposableTo(disposeBag)
                sut.status.asObservable().bindTo(statusObserver).addDisposableTo(disposeBag)
                sut.isFeatured.asObservable().bindTo(isFeaturedObserver).addDisposableTo(disposeBag)
                sut.quickAnswers.asObservable().bindTo(quickAnswersObserver).addDisposableTo(disposeBag)

                sut.chatEnabled.asObservable().bindTo(quickAnswersAvailableObserver).addDisposableTo(disposeBag)
                sut.chatEnabled.asObservable().bindTo(directChatEnabledObserver).addDisposableTo(disposeBag)
                sut.directChatPlaceholder.asObservable().bindTo(directChatPlaceholderObserver).addDisposableTo(disposeBag)
                sut.directChatMessages.observable.bindTo(directChatMessagesObserver).addDisposableTo(disposeBag)
                sut.isFavorite.asObservable().bindTo(isFavoriteObserver).addDisposableTo(disposeBag)
                sut.bumpUpBannerInfo.asObservable().bindTo(bumpUpBannerInfoObserver).addDisposableTo(disposeBag)
            }

            func buildSut(productListModels: [ListingCellModel]? = nil,
                          initialProduct: Product? = nil,
                          source: EventParameterListingVisitSource = .listingList,
                          actionOnFirstAppear: ProductCarouselActionOnFirstAppear = .nonexistent,
                          trackingIndex: Int? = nil,
                          firstProductSyncRequired: Bool = false) {

                var initialListing: Listing? = nil
                if let initialProduct = initialProduct {
                    initialListing = .product(initialProduct)
                }

                sut = ListingDeckViewModel(productListModels: productListModels,
                                           initialListing: initialListing,
                                           listingListRequester: listingListRequester,
                                           source: source,
                                           imageDownloader: imageDownloader,
                                           listingViewModelMaker: listingViewModelMaker,
                                           shouldSyncFirstListing: firstProductSyncRequired,
                                           binder: ListingViewModelBinder())

                sut.delegate = self
            }

            beforeEach {
                myUserRepository = MockMyUserRepository.makeMock()
                listingRepository = MockListingRepository.makeMock()
                chatWrapper = MockChatWrapper()
                locationManager = MockLocationManager()
                countryHelper = CountryHelper.mock()
                product = MockProduct.makeMock()
                featureFlags = MockFeatureFlags()
                purchasesShopper = MockPurchasesShopper()
                notificationsManager = MockNotificationsManager()
                monetizationRepository = MockMonetizationRepository.makeMock()
                tracker = MockTracker()

                listingListRequester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                imageDownloader = MockImageDownloader()

                listingViewModelMaker = MockListingViewModelMaker(myUserRepository: myUserRepository,
                                                                  listingRepository: listingRepository,
                                                                  chatWrapper: chatWrapper,
                                                                  locationManager: locationManager,
                                                                  countryHelper: countryHelper,
                                                                  featureFlags: featureFlags,
                                                                  purchasesShopper: purchasesShopper,
                                                                  monetizationRepository: monetizationRepository,
                                                                  tracker: tracker)

                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()
                cellModelsObserver = scheduler.createObserver(Array<ListingCardViewModel>.self)
                productInfoObserver = scheduler.createObserver(Optional<ListingVMProductInfo>.self)
                productImageUrlsObserver = scheduler.createObserver(Array<URL>.self)
                userInfoObserver = scheduler.createObserver(Optional<ListingVMUserInfo>.self)
                productStatsObserver = scheduler.createObserver(Optional<ListingStats>.self)
                navBarButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                actionButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                statusObserver = scheduler.createObserver(ListingViewModelStatus.self)
                isFeaturedObserver = scheduler.createObserver(Bool.self)
                quickAnswersObserver = scheduler.createObserver(Array<Array<QuickAnswer>>.self)
                quickAnswersAvailableObserver = scheduler.createObserver(Bool.self)
                directChatEnabledObserver = scheduler.createObserver(Bool.self)
                directChatPlaceholderObserver = scheduler.createObserver(String.self)
                directChatMessagesObserver = scheduler.createObserver(Array<ChatViewMessage>.self)
                isFavoriteObserver = scheduler.createObserver(Bool.self)
                bumpUpBannerInfoObserver = scheduler.createObserver(Optional<BumpUpInfo>.self)

                self.resetViewModelSpec()
            }
            afterEach {
                scheduler.stop()
                disposeBag = nil
            }
            describe("quick answers") {
                describe("ab test non-dynamic") {
                    beforeEach {
                        featureFlags.dynamicQuickAnswers = .control
                    }
                    context("product is mine and available") {
                        beforeEach {
                            let myUser = MockMyUser.makeMock()
                            myUserRepository.myUserVar.value = myUser
                            var productUser = MockUserListing.makeMock()
                            productUser.objectId = myUser.objectId
                            product.user = productUser
                            product.status = .approved
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("quick answers are not available") {
                            print("CHAT ENABLED \(sut.chatEnabled.value)")
                            expect(quickAnswersAvailableObserver.eventValues) == [false] //first product
                        }
                        it("quickAnswers are empty") {
                            expect(quickAnswersObserver.eventValues.map { $0.isEmpty }) == [true] //first product
                        }
                    }
                    context("product is not mine and available") {
                        context("non free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .normal(25)
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 3 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 3
                            }
                            it("matches first group with the right availability quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.stillAvailable]
                            }
                            it("matches second group with the right negotiable quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.isNegotiable]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition]
                            }
                        }
                        context("free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .free
                                featureFlags.freePostingModeAllowed = true
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 3 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 3
                            }
                            it("matches first group with the right interested quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.interested]
                            }
                            it("matches second group with the right meet up quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.meetUp]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition]
                            }
                        }
                    }
                }

                describe("ab test dynamic") {
                    beforeEach {
                        featureFlags.dynamicQuickAnswers = .dynamicNoKeyboard
                    }
                    context("product is mine and available") {
                        beforeEach {
                            let myUser = MockMyUser.makeMock()
                            myUserRepository.myUserVar.value = myUser
                            var productUser = MockUserListing.makeMock()
                            productUser.objectId = myUser.objectId
                            product.user = productUser
                            product.status = .approved
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("quick answers are not available") {
                            expect(quickAnswersAvailableObserver.eventValues) == [false] //first product
                        }
                        it("quickAnswers are empty") {
                            expect(quickAnswersObserver.eventValues.map { $0.isEmpty }) == [true] //first product
                        }
                    }
                    context("product is not mine and available") {
                        context("non free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .normal(25)
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 4 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 4
                            }
                            it("matches first group with the right availability quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.stillAvailable, .stillForSale, .freeStillHave]
                            }
                            it("matches second group with the right meet up quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition, .listingConditionGood, .listingConditionDescribe]
                            }
                            it("matches fourth group with the right price quick answers") {
                                expect(quickAnswersObserver.lastValue?[3]) == [.isNegotiable, .priceFirm, .priceWillingToNegotiate]
                            }
                        }
                        context("free product") {
                            beforeEach {
                                let myUser = MockMyUser.makeMock()
                                myUserRepository.myUserVar.value = myUser
                                product.status = .approved
                                product.price = .free
                                featureFlags.freePostingModeAllowed = true
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("quick answers are available") {
                                expect(quickAnswersAvailableObserver.eventValues) == [true] //first product
                            }
                            it("receives 3 groups of quick answers") {
                                expect(quickAnswersObserver.lastValue?.count) == 3
                            }
                            it("matches first group with the right availability quick answers") {
                                expect(quickAnswersObserver.lastValue?[0]) == [.stillAvailable, .freeStillHave]
                            }
                            it("matches second group with the right meet up quick answers") {
                                expect(quickAnswersObserver.lastValue?[1]) == [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
                            }
                            it("matches third group with the right condition quick answers") {
                                expect(quickAnswersObserver.lastValue?[2]) == [.listingCondition, .listingConditionGood, .listingConditionDescribe]
                            }
                        }
                    }
                }
            }
            describe("first product needs update") {
                var newProduct: MockProduct!
                beforeEach {
                    product.name = String.makeRandom()
                    newProduct = MockProduct.makeMock()
                    newProduct.name = String.makeRandom()
                    newProduct.objectId = product.objectId
                    newProduct.user = product.user
                    listingRepository.listingResult = ListingResult(.product(newProduct))
                    buildSut(initialProduct: product, firstProductSyncRequired: true)
                    sut.active = true
                    startObserving()
                }
                it("product info title passes trough both items title") {
                    expect(productInfoObserver.eventValues.flatMap { $0?.title }).toEventually(equal([product.title, newProduct.title].flatMap { $0 }))
                }
            }
            describe("pagination") {
                context("single item") {
                    beforeEach {
                        listingListRequester.generateItems(30)
                        buildSut(initialProduct: product)
                        sut.active = true
                        startObserving()
                    }
                    it("items count automatically becomes 21") {
                        expect(sut.objectCount).toEventually(equal(21))
                    }
                }
                context("multiple items") {
                    context("item before the threshold") {
                        beforeEach {
                            var products = MockProduct.makeMocks(count: 20)
                            products[0] = product
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            listingListRequester.generateItems(30)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("doesn't paginate initially") {
                            expect(sut.objectCount).toNot(beGreaterThan(20))
                        }
                        describe("switch to item after threshold") {
                            beforeEach {
                                sut.moveToProductAtIndex(18, movement: .swipeRight)
                            }
                            it("gets one extra page") {
                                expect(sut.objectCount).toEventually(equal(40))
                            }
                        }
                    }
                    context("item after the threshold") {
                        beforeEach {
                            var products = MockProduct.makeMocks(count: 20)
                            products[18] = product
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            listingListRequester.generateItems(30)
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("paginates initially") {
                            expect(sut.objectCount).toEventually(equal(40))
                        }
                    }
                }
                context("long pagination") {
                    beforeEach {
                        //Simulating that we're on page 8-10
                        var products = MockProduct.makeMocks(count: 180)
                        products[160] = product
                        listingListRequester.generateItems(200)
                        listingListRequester.offset = 180
                        let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                        buildSut(productListModels: productListModels, initialProduct: product)
                        sut.active = true
                        startObserving()
                    }
                    describe("move to item before threshold") {
                        beforeEach {
                            sut.moveToProductAtIndex(172, movement: .swipeRight)
                        }
                        it("doesn't paginate") {
                            expect(sut.objectCount).toNot(beGreaterThan(180))
                        }
                    }
                    describe("move to item after threshold") {
                        beforeEach {
                            sut.moveToProductAtIndex(178, movement: .swipeRight)
                        }
                        it("paginates") {
                            expect(sut.objectCount).toEventually(equal(200))
                        }
                    }
                }
            }
            describe("products navigation") {
                describe("image pre-caching") {
                    var products: [MockProduct]!
                    beforeEach {
                        products = MockProduct.makeMocks(count: 20)
                        for i in 0..<products.count {
                            var product = products[i]
                            var image = MockFile.makeMock()
                            image.fileURL = URL.makeRandom()
                            product.images = [image]
                            products[i] = product
                        }
                    }
                    context("first item is 0") {
                        beforeEach {
                            product = products[0]
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("requests images for items 0-3") {
                            let images = products.prefix(through: 3).flatMap { $0.images.first?.fileURL }
                            expect(imageDownloader.downloadImagesRequested) == images
                        }
                        describe("swipe right") {
                            beforeEach {
                                sut.moveToProductAtIndex(1, movement: .swipeRight)
                            }
                            it("just requests one more image on the right") {
                                let images = [products[4].images.first?.fileURL].flatMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                    }
                    context("first item is in the middle of list") {
                        beforeEach {
                            product = products[10]
                            let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                            buildSut(productListModels: productListModels, initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("requests images for items 9-13") {
                            let images = products[9...13].flatMap { $0.images.first?.fileURL }
                            expect(imageDownloader.downloadImagesRequested) == images
                        }
                        describe("swipe right") {
                            beforeEach {
                                sut.moveToProductAtIndex(11, movement: .swipeRight)
                            }
                            it("just requests one more image on the right") {
                                let images = [products[14].images.first?.fileURL].flatMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                        describe("swipe left") {
                            beforeEach {
                                sut.moveToProductAtIndex(9, movement: .swipeLeft)
                            }
                            it("just requests one more image on the left") {
                                let images = [products[8].images.first?.fileURL].flatMap { $0 }
                                expect(imageDownloader.downloadImagesRequested) == images
                            }
                        }
                    }
                }
                describe("elements update and visit trackings") {
                    var products: [MockProduct]!
                    beforeEach {
                        products = MockProduct.makeMocks(count: 20)
                        let productListModels = products.map { ListingCellModel.listingCell(listing: .product($0)) }
                        buildSut(productListModels: productListModels)
                        sut.active = true
                        startObserving()
                    }
                    context("viewmodel inactive") {
                        beforeEach {
                            sut.active = false
                            sut.moveToProductAtIndex(1, movement: .tap)
                            sut.moveToProductAtIndex(2, movement: .tap)
                        }
                        it("doesn't track any product visit") {
                            expect(tracker.trackedEvents.count) == 0
                        }
                        it("product info changed twice") {
                            expect(productInfoObserver.eventValues.count) == 3
                        }
                        it("product images changed twice") {
                            expect(productImageUrlsObserver.eventValues.count) == 3
                        }
                        it("user info changed twice") {
                            expect(userInfoObserver.eventValues.count) == 3
                        }
                        it("navbarButtons changed twice") {
                            expect(navBarButtonsObserver.eventValues.count) == 3
                        }
                        it("actionButtons changed twice") {
                            expect(actionButtonsObserver.eventValues.count) == 3
                        }
                        it("status changed twice") {
                            expect(statusObserver.eventValues.count) == 3
                        }
                        it("quickanswersavailable changed twice") {
                            expect(quickAnswersAvailableObserver.eventValues.count) == 3
                        }
                        it("directChagEnabled changed twice") {
                            expect(directChatEnabledObserver.eventValues.count) == 3
                        }
                        describe("view model gets active") {
                            beforeEach {
                                sut.active = true
                            }
                            it("has just one tracking") {
                                expect(tracker.trackedEvents.count) == 1
                            }
                            it("tracks product visit") {
                                expect(tracker.trackedEvents.last?.actualName) == "product-detail-visit"
                            }
                            it("tracks with product Id of product index 2") {
                                let firstEvent = tracker.trackedEvents.last
                                expect(firstEvent?.params?.stringKeyParams["product-id"] as? String) == products[2].objectId
                            }
                        }
                    }
                    context("viewmodel active") {
                        beforeEach {
                            sut.active = true
                            sut.moveToProductAtIndex(1, movement: .tap)
                            sut.moveToProductAtIndex(2, movement: .tap)
                        }
                        it("tracks 3 product visits") {
                            expect(tracker.trackedEvents.map { $0.actualName }) == ["product-detail-visit","product-detail-visit","product-detail-visit"]
                        }
                        it("tracks with product ids of first 3 products") {
                            expect(tracker.trackedEvents.flatMap { $0.params?.stringKeyParams["product-id"] as? String })
                                == products.prefix(through: 2).flatMap { $0.objectId }
                        }
                        it("product info changed twice") {
                            expect(productInfoObserver.eventValues.count) == 3
                        }
                        it("product images changed twice") {
                            expect(productImageUrlsObserver.eventValues.count) == 3
                        }
                        it("user info changed twice") {
                            expect(userInfoObserver.eventValues.count) == 3
                        }
                        it("navbarButtons changed twice") {
                            expect(navBarButtonsObserver.eventValues.count) == 3
                        }
                        it("actionButtons changed twice") {
                            expect(actionButtonsObserver.eventValues.count) == 3
                        }
                        it("status changed twice") {
                            expect(statusObserver.eventValues.count) == 3
                        }
                        it("quickanswersavailable changed twice") {
                            expect(quickAnswersAvailableObserver.eventValues.count) == 3
                        }
                        it("directChagEnabled changed twice") {
                            expect(directChatEnabledObserver.eventValues.count) == 3
                        }
                    }
                }
            }
            describe("changes after myUser update") {
                var stats: MockListingStats!
                beforeEach {
                    var relation = MockUserListingRelation.makeMock()
                    relation.isFavorited = true
                    relation.isReported = false
                    listingRepository.userProductRelationResult = ListingUserRelationResult(relation)
                    stats = MockListingStats.makeMock()
                    listingRepository.statsResult = ListingStatsResult(stats)
                    product.status = .approved
                }
                context("user not logged in") {
                    beforeEach {
                        buildSut(initialProduct: product)
                        sut.active = true
                        startObserving()
                    }
                    it("doesn't update favorite / reported as user is logged out") {
                        expect(isFavoriteObserver.eventValues.count) == 1
                    }
                    it("updates product stats") {
                        expect(productStatsObserver.eventValues.count).toEventually(equal(2))
                    }
                    it("matches product views") {
                        expect(productStatsObserver.eventValues.flatMap {$0}.last?.viewsCount).toEventually(equal(stats.viewsCount))
                    }
                    it("matches product favorites") {
                        expect(productStatsObserver.eventValues.flatMap {$0}.last?.favouritesCount).toEventually(equal(stats.favouritesCount))
                    }
                    it("there's a share navbar button") {
                        let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                        expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                    }
                    it("directchatenabled is true") {
                        expect(directChatEnabledObserver.eventValues) == [true]
                    }
                    it("action buttons are empty") {
                        expect(actionButtonsObserver.eventValues.map { $0.count }) == [0]
                    }
                    describe("user logs in, product is not mine") {
                        beforeEach {
                            let myUser = MockMyUser.makeMock()
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("product vm status updates otherAvailable") {
                            expect(statusObserver.eventValues) == [.otherAvailable, .otherAvailable]
                        }
                        it("directchatenabled is true again") {
                            expect(directChatEnabledObserver.eventValues) == [true, true]
                        }
                        it("action buttons are again empty") {
                            expect(actionButtonsObserver.eventValues.map { $0.count }) == [0, 0]
                        }
                        it("share navbar button remains share") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                    }
                    describe("user logs in, product is mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = product.user.objectId
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("product vm status updates available") {
                            expect(statusObserver.eventValues) == [.otherAvailable, .available]
                        }
                        it("directchatenabled is false") {
                            expect(directChatEnabledObserver.eventValues) == [true, false]
                        }
                        it("action buttons have one item") {
                            expect(actionButtonsObserver.eventValues.map { $0.count }) == [0, 1]
                        }
                        it("action buttons item is to mark as sold") {
                            expect(actionButtonsObserver.lastValue?.first?.text) == LGLocalizedString.productMarkAsSoldButton
                        }
                        it("navbar buttons now have share and edit") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                    }
                }
            }
            describe("overlay elements state") {
                beforeEach {
                    product.name = String.makeRandom()
                    var productUser = MockUserListing.makeMock()
                    productUser.name = String.makeRandom()
                    product.user = productUser

                    // Already selected as winners but not removed
                    featureFlags.freePostingModeAllowed = true
                }
                context("product is mine") {
                    var myUser: MockMyUser!
                    beforeEach {
                        myUser = MockMyUser.makeMock()
                        myUser.objectId = product.user.objectId
                        myUser.name = String.makeRandom()
                        myUserRepository.myUserVar.value = myUser
                        listingRepository.transactionsResult = ListingTransactionsResult(value: [])
                    }
                    context("pending") {
                        context("not featured") {
                            beforeEach {
                                product.status = .pending
                                product.name = String.makeRandom()
                                product.featured = false
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("product title matches") {
                                expect(productInfoObserver.lastValue??.title) == product.title
                            }
                            it("images match") {
                                expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                            }
                            it("user name matches") {
                                expect(userInfoObserver.lastValue??.name) == myUser.shortName
                            }
                            it("navbar buttons have edit and options") {
                                let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                                expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                            }
                            it("there are no action buttons") {
                                expect(actionButtonsObserver.lastValue?.count) == 0
                            }
                            it("product vm status is pending") {
                                expect(statusObserver.lastValue) == .pending
                            }
                            it("isFeatured is false") {
                                expect(isFeaturedObserver.lastValue) == product.featured ?? false
                            }
                            it("quick answers are disabled") {
                                expect(quickAnswersAvailableObserver.lastValue) == false
                            }
                            it("direct chat is disabled") {
                                expect(directChatEnabledObserver.lastValue) == false
                            }
                        }
                        context("featured") {
                            beforeEach {
                                product.status = .pending
                                product.name = String.makeRandom()
                                product.featured = true
                                buildSut(initialProduct: product)
                                sut.active = true
                                startObserving()
                            }
                            it("product title matches") {
                                expect(productInfoObserver.lastValue??.title) == product.title
                            }
                            it("images match") {
                                expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                            }
                            it("user name matches") {
                                expect(userInfoObserver.lastValue??.name) == myUser.shortName
                            }
                            it("navbar buttons have edit and options") {
                                let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                                expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                            }
                            it("there are no action buttons") {
                                expect(actionButtonsObserver.lastValue?.count) == 0
                            }
                            it("product vm status is pendingAndFeatured") {
                                expect(statusObserver.lastValue) == .pendingAndFeatured
                            }
                            it("isFeatured is true") {
                                expect(isFeaturedObserver.lastValue) == true
                            }
                            it("quick answers are disabled") {
                                expect(quickAnswersAvailableObserver.lastValue) == false
                            }
                            it("direct chat is disabled") {
                                expect(directChatEnabledObserver.lastValue) == false
                            }
                        }
                    }
                    context("approved - normal") {
                        beforeEach {
                            product.status = .approved
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == myUser.shortName
                        }
                        it("navbar buttons have edit and options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a mark sold action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productMarkAsSoldButton]
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .available
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == product.featured ?? false
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("approved - free") {
                        beforeEach {
                            product.status = .approved
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == myUser.shortName
                        }
                        it("navbar buttons have edit and options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarEditButton, .listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a mark sold action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productMarkAsSoldFreeButton]
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .availableFree
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == product.featured ?? false
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("sold - normal") {
                        beforeEach {
                            product.status = .sold
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == myUser.shortName
                        }
                        it("navbar buttons have just options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a sell again action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productSellAgainButton]
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .sold
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == false
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("sold - free") {
                        beforeEach {
                            product.status = .sold
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == myUser.shortName
                        }
                        it("navbar buttons have just options") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarActionsButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there is a sell again action") {
                            expect(actionButtonsObserver.lastValue?.flatMap { $0.text }) == [LGLocalizedString.productSellAgainFreeButton]
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .soldFree
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == false
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                }
                context("product isn't mine") {
                    context("pending") {
                        beforeEach {
                            product.status = .pending
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == product.user.shortName
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .notAvailable
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == false
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("approved - normal") {
                        beforeEach {
                            product.status = .approved
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == product.user.shortName
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .otherAvailable
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == false
                        }
                        it("quick answers are enabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == true
                        }
                        it("direct chat is enabled") {
                            expect(directChatEnabledObserver.lastValue) == true
                        }
                    }
                    context("approved - free") {
                        beforeEach {
                            product.status = .approved
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == product.user.shortName
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .otherAvailableFree
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == false
                        }
                        it("quick answers are enabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == true
                        }
                        it("direct chat is enabled") {
                            expect(directChatEnabledObserver.lastValue) == true
                        }
                    }
                    context("sold - normal") {
                        beforeEach {
                            product.status = .sold
                            product.price = .normal(25)
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == product.user.shortName
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .otherSold
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == false
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                    context("sold - free") {
                        beforeEach {
                            product.status = .sold
                            product.price = .free
                            product.name = String.makeRandom()
                            buildSut(initialProduct: product)
                            sut.active = true
                            startObserving()
                        }
                        it("product title matches") {
                            expect(productInfoObserver.lastValue??.title) == product.title
                        }
                        it("images match") {
                            expect(productImageUrlsObserver.lastValue) == product.images.flatMap { $0.fileURL }
                        }
                        it("user name matches") {
                            expect(userInfoObserver.lastValue??.name) == product.user.shortName
                        }
                        it("navbar buttons has share button") {
                            let accesibilityIds: [AccessibilityId] = [.listingCarouselNavBarShareButton]
                            expect(navBarButtonsObserver.lastValue?.flatMap { $0.accessibilityId }) == accesibilityIds
                        }
                        it("there are no action buttons") {
                            expect(actionButtonsObserver.lastValue?.count) == 0
                        }
                        it("product vm status is pending") {
                            expect(statusObserver.lastValue) == .otherSoldFree
                        }
                        it("isFeatured is false") {
                            expect(isFeaturedObserver.lastValue) == false
                        }
                        it("quick answers are disabled") {
                            expect(quickAnswersAvailableObserver.lastValue) == false
                        }
                        it("direct chat is disabled") {
                            expect(directChatEnabledObserver.lastValue) == false
                        }
                    }
                }
            }
            describe("product update events") {
                var productUpdated: MockProduct!
                beforeEach {
                    buildSut(initialProduct: product)
                    sut.active = true
                    startObserving()

                    productUpdated = MockProduct.makeMock()
                    productUpdated.objectId = product.objectId
                    productUpdated.user = product.user
                    listingRepository.eventsPublishSubject.onNext(.update(.product(productUpdated)))
                }
                it("has two events for product info") {
                    expect(productInfoObserver.eventValues.count) == 2
                }
                it("has two events for status") {
                    expect(statusObserver.eventValues.count) == 2
                }
            }
        }
    }

}


extension ListingDeckViewModelSpec: ListingDeckViewModelDelegate {
    func vmRemoveMoreInfoTooltip() { }
    func vmShowOnboarding() { }

    // Forward from ListingViewModelDelegate
    func vmAskForRating() {}
    func vmShowCarouselOptions(_ cancelLabel: String, actions: [UIAction]) {}
    func vmShareViewControllerAndItem() -> (UIViewController, UIBarButtonItem?) {
        return (UIViewController(), nil)
    }
    func vmResetBumpUpBannerCountdown() {}
}
