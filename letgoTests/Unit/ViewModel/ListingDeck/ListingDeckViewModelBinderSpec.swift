//
//  ListingDeckViewModelBinderSpec.swift
//  LetGo
//
//  Created by Facundo Menzella on 31/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import RxTest
import RxSwift
import LGCoreKit
import Quick
import Nimble


class ListingDeckViewModelBinderSpec: QuickSpec {

    override func spec() {
        var sut: ListingDeckViewModelBinder!
        var listing: Listing!

        var listingViewModelMaker: MockListingViewModelMaker!
        var listingListRequester: MockListingListRequester!
        var imageDownloader: MockImageDownloader!
        var listingDeckViewModel: ListingDeckViewModel!

        var scheduler: TestScheduler!
        var disposeBag: DisposeBag!

        var productInfoObserver: TestableObserver<ListingVMProductInfo?>!
        var productImageUrlsObserver: TestableObserver<[URL]>!
        var userInfoObserver: TestableObserver<ListingVMUserInfo?>!
        var productStatsObserver: TestableObserver<ListingStats?>!
        var navBarButtonsObserver: TestableObserver<[UIAction]>!
        var actionButtonsObserver: TestableObserver<[UIAction]>!

        var statusObserver: TestableObserver<ListingViewModelStatus>!
        var isFeaturedObserver: TestableObserver<Bool>!
        var quickAnswersObserver: TestableObserver<[[QuickAnswer]]>!
        var chatEnabled: TestableObserver<Bool>!
        var directChatPlaceholderObserver: TestableObserver<String>!
        var isFavoriteObserver: TestableObserver<Bool>!
        var favoriteButtonStateObserver: TestableObserver<ButtonState>!
        var shareButtonStateObserver: TestableObserver<ButtonState>!
        var bumpUpBannerInfoObserver: TestableObserver<BumpUpInfo?>!
        var socialMessageObserver: TestableObserver<SocialMessage?>!
        var socialSharerObserver: TestableObserver<SocialSharer>!


        describe("ListingDeckViewModelBinderSpec") {
            beforeEach {
                sut = ListingDeckViewModelBinder()
                var productMock = MockProduct.makeMock()
                productMock.status = .approved
                listing = .product(productMock)

                listingViewModelMaker = MockListingViewModelMaker(myUserRepository: MockMyUserRepository(),
                                                                  listingRepository: MockListingRepository(),
                                                                  chatWrapper: MockChatWrapper(),
                                                                  locationManager: MockLocationManager(),
                                                                  countryHelper: CountryHelper.mock(),
                                                                  featureFlags: MockFeatureFlags(),
                                                                  purchasesShopper: MockPurchasesShopper(),
                                                                  monetizationRepository: MockMonetizationRepository(),
                                                                  tracker: MockTracker())
                listingListRequester = MockListingListRequester(canRetrieve: true, offset: 0, pageSize: 20)
                imageDownloader = MockImageDownloader()

                let pagination = Pagination.makePagination(first: 0, next: 1, isLast: false)
                let prefetching = Prefetching(previousCount: 1, nextCount: 3)
                let myUserRepo = MockMyUserRepository.makeMock()

                listingDeckViewModel = ListingDeckViewModel(productListModels: nil,
                                                            initialListing: listing,
                                                            listingListRequester: listingListRequester,
                                                            detailNavigator: self,
                                                            source: .listingList,
                                                            imageDownloader: imageDownloader,
                                                            listingViewModelMaker: listingViewModelMaker,
                                                            myUserRepository: myUserRepo,
                                                            pagination: pagination,
                                                            prefetching: prefetching,
                                                            shouldSyncFirstListing: false,
                                                            binder: sut)


                scheduler = TestScheduler(initialClock: 0)
                scheduler.start()

                productInfoObserver = scheduler.createObserver(Optional<ListingVMProductInfo>.self)
                productImageUrlsObserver = scheduler.createObserver(Array<URL>.self)
                userInfoObserver = scheduler.createObserver(Optional<ListingVMUserInfo>.self)
                productStatsObserver = scheduler.createObserver(Optional<ListingStats>.self)
                navBarButtonsObserver = scheduler.createObserver(Array<UIAction>.self)
                actionButtonsObserver = scheduler.createObserver(Array<UIAction>.self)

                statusObserver = scheduler.createObserver(ListingViewModelStatus.self)
                isFeaturedObserver = scheduler.createObserver(Bool.self)
                quickAnswersObserver = scheduler.createObserver(Array<Array<QuickAnswer>>.self)
                chatEnabled = scheduler.createObserver(Bool.self)
                directChatPlaceholderObserver = scheduler.createObserver(String.self)
                isFavoriteObserver = scheduler.createObserver(Bool.self)
                favoriteButtonStateObserver = scheduler.createObserver(ButtonState.self)
                shareButtonStateObserver = scheduler.createObserver(ButtonState.self)
                bumpUpBannerInfoObserver = scheduler.createObserver(Optional<BumpUpInfo>.self)
                socialMessageObserver = scheduler.createObserver(Optional<SocialMessage>.self)
                socialSharerObserver = scheduler.createObserver(SocialSharer.self)

                disposeBag = DisposeBag()
                listingDeckViewModel.navBarButtons.asObservable().skip(1).bindTo(navBarButtonsObserver).disposed(by:disposeBag)
                listingDeckViewModel.actionButtons.asObservable().skip(1).bindTo(actionButtonsObserver).disposed(by:disposeBag)
                listingDeckViewModel.quickChatViewModel.quickAnswers.asObservable().skip(1).bindTo(quickAnswersObserver).disposed(by:disposeBag)
                listingDeckViewModel.quickChatViewModel.chatEnabled.asObservable().skip(1).bindTo(chatEnabled).disposed(by:disposeBag)
                listingDeckViewModel.quickChatViewModel.directChatPlaceholder.asObservable().skip(1).bindTo(directChatPlaceholderObserver).disposed(by:disposeBag)
                listingDeckViewModel.bumpUpBannerInfo.asObservable().skip(1).bindTo(bumpUpBannerInfoObserver).disposed(by:disposeBag)

                listingDeckViewModel.moveToProductAtIndex(0, movement: .initial)
            }

            afterEach {
                scheduler.stop()
                disposeBag = nil
            }

            context("after moving to the current viewmodel") {
                it("productInfoObserver changed") {
                    expect(productInfoObserver.eventValues.count) > 0
                }

                it("productImageUrlsObserver changed") {
                    expect(productImageUrlsObserver.eventValues.count) > 0
                }

                it("userInfoObserver changed") {
                    expect(userInfoObserver.eventValues.count) > 0
                }

                it("productStatsObserver changed") {
                    expect(productStatsObserver.eventValues.count) > 0
                }

                it("navBarButtonsObserver changed") {
                    expect(navBarButtonsObserver.eventValues.count) > 0
                }

                it("actionButtonsObserver changed") {
                    expect(actionButtonsObserver.eventValues.count) > 0
                }

                it("statusObserver changed") {
                    expect(statusObserver.eventValues.count) > 0
                }

                it("isFeaturedObserver changed") {
                    expect(isFeaturedObserver.eventValues.count) > 0
                }

                it("quickAnswersObserver changed") {
                    expect(quickAnswersObserver.eventValues.count) > 0
                }

                it("chatEnabled changed") {
                    expect(chatEnabled.eventValues.count) > 0
                }

                it("directChatPlaceholderObserver changed") {
                    expect(directChatPlaceholderObserver.eventValues.count) > 0
                }

                it("isFavoriteObserver changed") {
                    expect(isFavoriteObserver.eventValues.count) > 0
                }

                it("favoriteButtonStateObserver changed") {
                    expect(favoriteButtonStateObserver.eventValues.count) > 0
                }

                it("shareButtonStateObserver changed") {
                    expect(shareButtonStateObserver.eventValues.count) > 0
                }

                it("socialSharerObserver changed") {
                    expect(socialSharerObserver.eventValues.count) > 0
                }
                
                it("socialMessageObserver changed") {
                    expect(socialMessageObserver.eventValues.count) > 0
                }
                
                it("bumpUpBannerInfoObserver changed") {
                    expect(bumpUpBannerInfoObserver.eventValues.count) > 0
                }
            }
        }
    }
}

extension ListingDeckViewModelBinderSpec: ListingDetailNavigator {
    func openHome() {}
    func openSell(source: PostingSource, postCategory: PostCategory?) {}
    func openAppRating(_ source: EventParameterRatingSource) {}
    func openUserRating(_ source: RateUserSource, data: RateUserData) {}
    func openUser(_ data: UserDetailData) {}
    func openListing(_ data: ListingDetailData, source: EventParameterListingVisitSource, actionOnFirstAppear: ProductCarouselActionOnFirstAppear) {}
    func openChat(_ data: ChatDetailData, source: EventParameterTypePage, predefinedMessage: String?) {}
    func openVerifyAccounts(_ types: [VerificationType], source: VerifyAccountsSource, completionBlock: (() -> Void)?) {}
    func openAppInvite() {}
    func canOpenAppInvite() -> Bool { return true }
    func openRatingList(_ userId: String) {}
    func closeProductDetail() {}
    func editListing(_ listing: Listing) {}
    func openListingChat(_ listing: Listing, source: EventParameterTypePage) {}
    func closeListingAfterDelete(_ listing: Listing) {}
    func openFreeBumpUp(forListing listing: Listing, socialMessage: SocialMessage, paymentItemId: String) {}
    func openPayBumpUp(forListing listing: Listing,
                       purchaseableProduct: PurchaseableProduct,
                       paymentItemId: String) {}
    func selectBuyerToRate(source: RateUserSource,
                           buyers: [UserListing],
                           listingId: String,
                           sourceRateBuyers: SourceRateBuyers?,
                           trackingInfo: MarkAsSoldTrackingInfo) {}
    func showProductFavoriteBubble(with data: BubbleNotificationData) {}
    func openLoginIfNeededFromProductDetail(from: EventParameterLoginSourceValue, infoMessage: String,
                                            loggedInAction: @escaping (() -> Void)) {}
    func showBumpUpNotAvailableAlertWithTitle(title: String,
                                              text: String,
                                              alertType: AlertType,
                                              buttonsLayout: AlertButtonsLayout,
                                              actions: [UIAction]) {}
    func openContactUs(forListing listing: Listing, contactUstype: ContactUsType) {}
    func openFeaturedInfo() {}
    func closeFeaturedInfo() {}
}

