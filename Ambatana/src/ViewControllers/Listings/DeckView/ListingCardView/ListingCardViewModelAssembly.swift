final class ListingCardViewModelBuilder: ListingCardViewModelAssembly {
    let detailNavigator: ListingDetailNavigator
    init(detailNavigator: ListingDetailNavigator) {
        self.detailNavigator = detailNavigator
    }

    func build(listing: Listing, visitSource source: EventParameterListingVisitSource) -> ListingCardViewModel {
        let vm =  ListingCardViewModel(listing: listing,
                                       visitSource: source,
                                       myUserRepository: Core.myUserRepository,
                                       userRepository: Core.userRepository,
                                       listingRepository: Core.listingRepository,
                                       chatWrapper: LGChatWrapper(),
                                       chatViewMessageAdapter: ChatViewMessageAdapter(),
                                       locationManager: Core.locationManager,
                                       countryHelper: Core.countryHelper,
                                       socialSharer: SocialSharer(),
                                       featureFlags: FeatureFlags.sharedInstance,
                                       purchasesShopper: LGPurchasesShopper.sharedInstance,
                                       monetizationRepository: Core.monetizationRepository,
                                       tracker: TrackerProxy.sharedInstance,
                                       keyValueStorage: KeyValueStorage.sharedInstance)
        vm.navigator = detailNavigator
        return vm
    }
}
