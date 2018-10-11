//
//  BumperFeatures.swift
//  Letgo
//
//  GENERATED - DO NOT MODIFY - use flags_generator instead.
// 
//  Copyright © 2016 Letgo. All rights reserved.
//

import Foundation
import bumper
#if (RX_BUMPER)
import RxSwift
#endif

extension Bumper  {
    static func initialize() {
        var flags = [BumperFeature.Type]()
        flags.append(RealEstateEnabled.self)
        flags.append(RequestsTimeOut.self)
        flags.append(MarkAsSoldQuickAnswerNewFlow.self)
        flags.append(ShouldMoveLetsMeetAction.self)
        flags.append(ShowAdsInFeedWithRatio.self)
        flags.append(RealEstateFlowType.self)
        flags.append(DummyUsersInfoProfile.self)
        flags.append(ShowInactiveConversations.self)
        flags.append(SearchImprovements.self)
        flags.append(RelaxedSearch.self)
        flags.append(ShowChatSafetyTips.self)
        flags.append(OnboardingIncentivizePosting.self)
        flags.append(CopyForChatNowInTurkey.self)
        flags.append(ChatNorris.self)
        flags.append(ShowProTagUserProfile.self)
        flags.append(CopyForChatNowInEnglish.self)
        flags.append(ShowExactLocationForPros.self)
        flags.append(ShowPasswordlessLogin.self)
        flags.append(CopyForSellFasterNowInEnglish.self)
        flags.append(EmergencyLocate.self)
        flags.append(PersonalizedFeed.self)
        flags.append(OffensiveReportAlert.self)
        flags.append(FullScreenAdsWhenBrowsingForUS.self)
        flags.append(PreventMessagesFromFeedToProUsers.self)
        flags.append(SimplifiedChatButton.self)
        flags.append(ShowChatConnectionStatusBar.self)
        flags.append(ReportingFostaSesta.self)
        flags.append(ShowChatHeaderWithoutUser.self)
        flags.append(NewItemPageV3.self)
        flags.append(AppInstallAdsInFeed.self)
        flags.append(EnableCTAMessageType.self)
        flags.append(OpenChatFromUserProfile.self)
        flags.append(SearchAlertsInSearchSuggestions.self)
        flags.append(EngagementBadging.self)
        flags.append(ShowCommunity.self)
        flags.append(SmartQuickAnswers.self)
        flags.append(AlwaysShowBumpBannerWithLoading.self)
        flags.append(ServicesPaymentFrequency.self)
        flags.append(SearchAlertsDisableOldestIfMaximumReached.self)
        flags.append(ShowSellFasterInProfileCells.self)
        flags.append(BumpInEditCopys.self)
        flags.append(MultiAdRequestMoreInfo.self)
        flags.append(EnableJobsAndServicesCategory.self)
        flags.append(CopyForSellFasterNowInTurkish.self)
        flags.append(RandomImInterestedMessages.self)
        flags.append(CarPromoCells.self)
        flags.append(RealEstatePromoCells.self)
        flags.append(AdvancedReputationSystem11.self)
        flags.append(AdvancedReputationSystem12.self)
        flags.append(AdvancedReputationSystem13.self)
        flags.append(ProUsersExtraImages.self)
        flags.append(SectionedDiscoveryFeed.self)
        flags.append(ServicesPromoCells.self)
        flags.append(MultiDayBumpUp.self)
        flags.append(ImInterestedInProfile.self)
        flags.append(ClickToTalk.self)
        flags.append(BulkPosting.self)
        flags.append(ShareAfterScreenshot.self)
        flags.append(MutePushNotifications.self)
        flags.append(MultiAdRequestInChatSectionForUS.self)
        flags.append(MultiAdRequestInChatSectionForTR.self)
        flags.append(AffiliationEnabled.self)
        flags.append(BumpUpButtonOnConversationCells.self)
        flags.append(BumpPromoAfterSellNoLimit.self)
        flags.append(MakeAnOfferButton.self)
        flags.append(NewSearchAPIEndPoint.self)
        flags.append(ImageSizesNotificationCenter.self)
        flags.append(BlockingSignUp.self)
        flags.append(FacebookUnavailable.self)
        flags.append(BoostSmokeTest.self)
        flags.append(PolymorphFeedAdsUSA.self)
        flags.append(GoogleUnifiedNativeAds.self)
        flags.append(AdvancedReputationSystem14.self)
        Bumper.initialize(flags)
    } 

    static var realEstateEnabled: RealEstateEnabled {
        guard let value = Bumper.value(for: RealEstateEnabled.key) else { return .control }
        return RealEstateEnabled(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var realEstateEnabledObservable: Observable<RealEstateEnabled> {
        return Bumper.observeValue(for: RealEstateEnabled.key).map {
            RealEstateEnabled(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var requestsTimeOut: RequestsTimeOut {
        guard let value = Bumper.value(for: RequestsTimeOut.key) else { return .baseline }
        return RequestsTimeOut(rawValue: value) ?? .baseline 
    } 

    #if (RX_BUMPER)
    static var requestsTimeOutObservable: Observable<RequestsTimeOut> {
        return Bumper.observeValue(for: RequestsTimeOut.key).map {
            RequestsTimeOut(rawValue: $0 ?? "") ?? .baseline
        }
    }
    #endif

    static var markAsSoldQuickAnswerNewFlow: MarkAsSoldQuickAnswerNewFlow {
        guard let value = Bumper.value(for: MarkAsSoldQuickAnswerNewFlow.key) else { return .control }
        return MarkAsSoldQuickAnswerNewFlow(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var markAsSoldQuickAnswerNewFlowObservable: Observable<MarkAsSoldQuickAnswerNewFlow> {
        return Bumper.observeValue(for: MarkAsSoldQuickAnswerNewFlow.key).map {
            MarkAsSoldQuickAnswerNewFlow(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var shouldMoveLetsMeetAction: Bool {
        guard let value = Bumper.value(for: ShouldMoveLetsMeetAction.key) else { return false }
        return ShouldMoveLetsMeetAction(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var shouldMoveLetsMeetActionObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShouldMoveLetsMeetAction.key).map {
            ShouldMoveLetsMeetAction(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio {
        guard let value = Bumper.value(for: ShowAdsInFeedWithRatio.key) else { return .control }
        return ShowAdsInFeedWithRatio(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showAdsInFeedWithRatioObservable: Observable<ShowAdsInFeedWithRatio> {
        return Bumper.observeValue(for: ShowAdsInFeedWithRatio.key).map {
            ShowAdsInFeedWithRatio(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var realEstateFlowType: RealEstateFlowType {
        guard let value = Bumper.value(for: RealEstateFlowType.key) else { return .standard }
        return RealEstateFlowType(rawValue: value) ?? .standard 
    } 

    #if (RX_BUMPER)
    static var realEstateFlowTypeObservable: Observable<RealEstateFlowType> {
        return Bumper.observeValue(for: RealEstateFlowType.key).map {
            RealEstateFlowType(rawValue: $0 ?? "") ?? .standard
        }
    }
    #endif

    static var dummyUsersInfoProfile: DummyUsersInfoProfile {
        guard let value = Bumper.value(for: DummyUsersInfoProfile.key) else { return .control }
        return DummyUsersInfoProfile(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var dummyUsersInfoProfileObservable: Observable<DummyUsersInfoProfile> {
        return Bumper.observeValue(for: DummyUsersInfoProfile.key).map {
            DummyUsersInfoProfile(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showInactiveConversations: Bool {
        guard let value = Bumper.value(for: ShowInactiveConversations.key) else { return false }
        return ShowInactiveConversations(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var showInactiveConversationsObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowInactiveConversations.key).map {
            ShowInactiveConversations(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var searchImprovements: SearchImprovements {
        guard let value = Bumper.value(for: SearchImprovements.key) else { return .control }
        return SearchImprovements(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchImprovementsObservable: Observable<SearchImprovements> {
        return Bumper.observeValue(for: SearchImprovements.key).map {
            SearchImprovements(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var relaxedSearch: RelaxedSearch {
        guard let value = Bumper.value(for: RelaxedSearch.key) else { return .control }
        return RelaxedSearch(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var relaxedSearchObservable: Observable<RelaxedSearch> {
        return Bumper.observeValue(for: RelaxedSearch.key).map {
            RelaxedSearch(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showChatSafetyTips: Bool {
        guard let value = Bumper.value(for: ShowChatSafetyTips.key) else { return false }
        return ShowChatSafetyTips(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var showChatSafetyTipsObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowChatSafetyTips.key).map {
            ShowChatSafetyTips(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var onboardingIncentivizePosting: OnboardingIncentivizePosting {
        guard let value = Bumper.value(for: OnboardingIncentivizePosting.key) else { return .control }
        return OnboardingIncentivizePosting(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var onboardingIncentivizePostingObservable: Observable<OnboardingIncentivizePosting> {
        return Bumper.observeValue(for: OnboardingIncentivizePosting.key).map {
            OnboardingIncentivizePosting(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var copyForChatNowInTurkey: CopyForChatNowInTurkey {
        guard let value = Bumper.value(for: CopyForChatNowInTurkey.key) else { return .control }
        return CopyForChatNowInTurkey(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForChatNowInTurkeyObservable: Observable<CopyForChatNowInTurkey> {
        return Bumper.observeValue(for: CopyForChatNowInTurkey.key).map {
            CopyForChatNowInTurkey(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var chatNorris: ChatNorris {
        guard let value = Bumper.value(for: ChatNorris.key) else { return .control }
        return ChatNorris(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var chatNorrisObservable: Observable<ChatNorris> {
        return Bumper.observeValue(for: ChatNorris.key).map {
            ChatNorris(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showProTagUserProfile: Bool {
        guard let value = Bumper.value(for: ShowProTagUserProfile.key) else { return false }
        return ShowProTagUserProfile(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var showProTagUserProfileObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowProTagUserProfile.key).map {
            ShowProTagUserProfile(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var copyForChatNowInEnglish: CopyForChatNowInEnglish {
        guard let value = Bumper.value(for: CopyForChatNowInEnglish.key) else { return .control }
        return CopyForChatNowInEnglish(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForChatNowInEnglishObservable: Observable<CopyForChatNowInEnglish> {
        return Bumper.observeValue(for: CopyForChatNowInEnglish.key).map {
            CopyForChatNowInEnglish(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showExactLocationForPros: Bool {
        guard let value = Bumper.value(for: ShowExactLocationForPros.key) else { return true }
        return ShowExactLocationForPros(rawValue: value)?.asBool ?? true
    } 

    #if (RX_BUMPER)
    static var showExactLocationForProsObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowExactLocationForPros.key).map {
            ShowExactLocationForPros(rawValue: $0 ?? "")?.asBool ?? true
        }
    }
    #endif

    static var showPasswordlessLogin: ShowPasswordlessLogin {
        guard let value = Bumper.value(for: ShowPasswordlessLogin.key) else { return .control }
        return ShowPasswordlessLogin(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showPasswordlessLoginObservable: Observable<ShowPasswordlessLogin> {
        return Bumper.observeValue(for: ShowPasswordlessLogin.key).map {
            ShowPasswordlessLogin(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var copyForSellFasterNowInEnglish: CopyForSellFasterNowInEnglish {
        guard let value = Bumper.value(for: CopyForSellFasterNowInEnglish.key) else { return .control }
        return CopyForSellFasterNowInEnglish(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForSellFasterNowInEnglishObservable: Observable<CopyForSellFasterNowInEnglish> {
        return Bumper.observeValue(for: CopyForSellFasterNowInEnglish.key).map {
            CopyForSellFasterNowInEnglish(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var emergencyLocate: EmergencyLocate {
        guard let value = Bumper.value(for: EmergencyLocate.key) else { return .control }
        return EmergencyLocate(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var emergencyLocateObservable: Observable<EmergencyLocate> {
        return Bumper.observeValue(for: EmergencyLocate.key).map {
            EmergencyLocate(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var personalizedFeed: PersonalizedFeed {
        guard let value = Bumper.value(for: PersonalizedFeed.key) else { return .control }
        return PersonalizedFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var personalizedFeedObservable: Observable<PersonalizedFeed> {
        return Bumper.observeValue(for: PersonalizedFeed.key).map {
            PersonalizedFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var offensiveReportAlert: OffensiveReportAlert {
        guard let value = Bumper.value(for: OffensiveReportAlert.key) else { return .control }
        return OffensiveReportAlert(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var offensiveReportAlertObservable: Observable<OffensiveReportAlert> {
        return Bumper.observeValue(for: OffensiveReportAlert.key).map {
            OffensiveReportAlert(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var fullScreenAdsWhenBrowsingForUS: FullScreenAdsWhenBrowsingForUS {
        guard let value = Bumper.value(for: FullScreenAdsWhenBrowsingForUS.key) else { return .control }
        return FullScreenAdsWhenBrowsingForUS(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var fullScreenAdsWhenBrowsingForUSObservable: Observable<FullScreenAdsWhenBrowsingForUS> {
        return Bumper.observeValue(for: FullScreenAdsWhenBrowsingForUS.key).map {
            FullScreenAdsWhenBrowsingForUS(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var preventMessagesFromFeedToProUsers: PreventMessagesFromFeedToProUsers {
        guard let value = Bumper.value(for: PreventMessagesFromFeedToProUsers.key) else { return .control }
        return PreventMessagesFromFeedToProUsers(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var preventMessagesFromFeedToProUsersObservable: Observable<PreventMessagesFromFeedToProUsers> {
        return Bumper.observeValue(for: PreventMessagesFromFeedToProUsers.key).map {
            PreventMessagesFromFeedToProUsers(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var simplifiedChatButton: SimplifiedChatButton {
        guard let value = Bumper.value(for: SimplifiedChatButton.key) else { return .control }
        return SimplifiedChatButton(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var simplifiedChatButtonObservable: Observable<SimplifiedChatButton> {
        return Bumper.observeValue(for: SimplifiedChatButton.key).map {
            SimplifiedChatButton(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showChatConnectionStatusBar: ShowChatConnectionStatusBar {
        guard let value = Bumper.value(for: ShowChatConnectionStatusBar.key) else { return .control }
        return ShowChatConnectionStatusBar(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showChatConnectionStatusBarObservable: Observable<ShowChatConnectionStatusBar> {
        return Bumper.observeValue(for: ShowChatConnectionStatusBar.key).map {
            ShowChatConnectionStatusBar(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var reportingFostaSesta: ReportingFostaSesta {
        guard let value = Bumper.value(for: ReportingFostaSesta.key) else { return .control }
        return ReportingFostaSesta(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var reportingFostaSestaObservable: Observable<ReportingFostaSesta> {
        return Bumper.observeValue(for: ReportingFostaSesta.key).map {
            ReportingFostaSesta(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showChatHeaderWithoutUser: Bool {
        guard let value = Bumper.value(for: ShowChatHeaderWithoutUser.key) else { return true }
        return ShowChatHeaderWithoutUser(rawValue: value)?.asBool ?? true
    } 

    #if (RX_BUMPER)
    static var showChatHeaderWithoutUserObservable: Observable<Bool> {
        return Bumper.observeValue(for: ShowChatHeaderWithoutUser.key).map {
            ShowChatHeaderWithoutUser(rawValue: $0 ?? "")?.asBool ?? true
        }
    }
    #endif

    static var newItemPageV3: NewItemPageV3 {
        guard let value = Bumper.value(for: NewItemPageV3.key) else { return .control }
        return NewItemPageV3(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var newItemPageV3Observable: Observable<NewItemPageV3> {
        return Bumper.observeValue(for: NewItemPageV3.key).map {
            NewItemPageV3(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var appInstallAdsInFeed: AppInstallAdsInFeed {
        guard let value = Bumper.value(for: AppInstallAdsInFeed.key) else { return .control }
        return AppInstallAdsInFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var appInstallAdsInFeedObservable: Observable<AppInstallAdsInFeed> {
        return Bumper.observeValue(for: AppInstallAdsInFeed.key).map {
            AppInstallAdsInFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var enableCTAMessageType: Bool {
        guard let value = Bumper.value(for: EnableCTAMessageType.key) else { return false }
        return EnableCTAMessageType(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var enableCTAMessageTypeObservable: Observable<Bool> {
        return Bumper.observeValue(for: EnableCTAMessageType.key).map {
            EnableCTAMessageType(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var openChatFromUserProfile: OpenChatFromUserProfile {
        guard let value = Bumper.value(for: OpenChatFromUserProfile.key) else { return .control }
        return OpenChatFromUserProfile(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var openChatFromUserProfileObservable: Observable<OpenChatFromUserProfile> {
        return Bumper.observeValue(for: OpenChatFromUserProfile.key).map {
            OpenChatFromUserProfile(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var searchAlertsInSearchSuggestions: SearchAlertsInSearchSuggestions {
        guard let value = Bumper.value(for: SearchAlertsInSearchSuggestions.key) else { return .control }
        return SearchAlertsInSearchSuggestions(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchAlertsInSearchSuggestionsObservable: Observable<SearchAlertsInSearchSuggestions> {
        return Bumper.observeValue(for: SearchAlertsInSearchSuggestions.key).map {
            SearchAlertsInSearchSuggestions(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var engagementBadging: EngagementBadging {
        guard let value = Bumper.value(for: EngagementBadging.key) else { return .control }
        return EngagementBadging(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var engagementBadgingObservable: Observable<EngagementBadging> {
        return Bumper.observeValue(for: EngagementBadging.key).map {
            EngagementBadging(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showCommunity: ShowCommunity {
        guard let value = Bumper.value(for: ShowCommunity.key) else { return .control }
        return ShowCommunity(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showCommunityObservable: Observable<ShowCommunity> {
        return Bumper.observeValue(for: ShowCommunity.key).map {
            ShowCommunity(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var smartQuickAnswers: SmartQuickAnswers {
        guard let value = Bumper.value(for: SmartQuickAnswers.key) else { return .control }
        return SmartQuickAnswers(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var smartQuickAnswersObservable: Observable<SmartQuickAnswers> {
        return Bumper.observeValue(for: SmartQuickAnswers.key).map {
            SmartQuickAnswers(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var alwaysShowBumpBannerWithLoading: AlwaysShowBumpBannerWithLoading {
        guard let value = Bumper.value(for: AlwaysShowBumpBannerWithLoading.key) else { return .control }
        return AlwaysShowBumpBannerWithLoading(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var alwaysShowBumpBannerWithLoadingObservable: Observable<AlwaysShowBumpBannerWithLoading> {
        return Bumper.observeValue(for: AlwaysShowBumpBannerWithLoading.key).map {
            AlwaysShowBumpBannerWithLoading(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var servicesPaymentFrequency: ServicesPaymentFrequency {
        guard let value = Bumper.value(for: ServicesPaymentFrequency.key) else { return .control }
        return ServicesPaymentFrequency(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var servicesPaymentFrequencyObservable: Observable<ServicesPaymentFrequency> {
        return Bumper.observeValue(for: ServicesPaymentFrequency.key).map {
            ServicesPaymentFrequency(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var searchAlertsDisableOldestIfMaximumReached: SearchAlertsDisableOldestIfMaximumReached {
        guard let value = Bumper.value(for: SearchAlertsDisableOldestIfMaximumReached.key) else { return .control }
        return SearchAlertsDisableOldestIfMaximumReached(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var searchAlertsDisableOldestIfMaximumReachedObservable: Observable<SearchAlertsDisableOldestIfMaximumReached> {
        return Bumper.observeValue(for: SearchAlertsDisableOldestIfMaximumReached.key).map {
            SearchAlertsDisableOldestIfMaximumReached(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var showSellFasterInProfileCells: ShowSellFasterInProfileCells {
        guard let value = Bumper.value(for: ShowSellFasterInProfileCells.key) else { return .control }
        return ShowSellFasterInProfileCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var showSellFasterInProfileCellsObservable: Observable<ShowSellFasterInProfileCells> {
        return Bumper.observeValue(for: ShowSellFasterInProfileCells.key).map {
            ShowSellFasterInProfileCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var bumpInEditCopys: BumpInEditCopys {
        guard let value = Bumper.value(for: BumpInEditCopys.key) else { return .control }
        return BumpInEditCopys(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var bumpInEditCopysObservable: Observable<BumpInEditCopys> {
        return Bumper.observeValue(for: BumpInEditCopys.key).map {
            BumpInEditCopys(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiAdRequestMoreInfo: MultiAdRequestMoreInfo {
        guard let value = Bumper.value(for: MultiAdRequestMoreInfo.key) else { return .control }
        return MultiAdRequestMoreInfo(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiAdRequestMoreInfoObservable: Observable<MultiAdRequestMoreInfo> {
        return Bumper.observeValue(for: MultiAdRequestMoreInfo.key).map {
            MultiAdRequestMoreInfo(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var enableJobsAndServicesCategory: EnableJobsAndServicesCategory {
        guard let value = Bumper.value(for: EnableJobsAndServicesCategory.key) else { return .control }
        return EnableJobsAndServicesCategory(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var enableJobsAndServicesCategoryObservable: Observable<EnableJobsAndServicesCategory> {
        return Bumper.observeValue(for: EnableJobsAndServicesCategory.key).map {
            EnableJobsAndServicesCategory(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var copyForSellFasterNowInTurkish: CopyForSellFasterNowInTurkish {
        guard let value = Bumper.value(for: CopyForSellFasterNowInTurkish.key) else { return .control }
        return CopyForSellFasterNowInTurkish(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var copyForSellFasterNowInTurkishObservable: Observable<CopyForSellFasterNowInTurkish> {
        return Bumper.observeValue(for: CopyForSellFasterNowInTurkish.key).map {
            CopyForSellFasterNowInTurkish(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var randomImInterestedMessages: RandomImInterestedMessages {
        guard let value = Bumper.value(for: RandomImInterestedMessages.key) else { return .control }
        return RandomImInterestedMessages(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var randomImInterestedMessagesObservable: Observable<RandomImInterestedMessages> {
        return Bumper.observeValue(for: RandomImInterestedMessages.key).map {
            RandomImInterestedMessages(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var carPromoCells: CarPromoCells {
        guard let value = Bumper.value(for: CarPromoCells.key) else { return .control }
        return CarPromoCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var carPromoCellsObservable: Observable<CarPromoCells> {
        return Bumper.observeValue(for: CarPromoCells.key).map {
            CarPromoCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var realEstatePromoCells: RealEstatePromoCells {
        guard let value = Bumper.value(for: RealEstatePromoCells.key) else { return .control }
        return RealEstatePromoCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var realEstatePromoCellsObservable: Observable<RealEstatePromoCells> {
        return Bumper.observeValue(for: RealEstatePromoCells.key).map {
            RealEstatePromoCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var advancedReputationSystem11: AdvancedReputationSystem11 {
        guard let value = Bumper.value(for: AdvancedReputationSystem11.key) else { return .control }
        return AdvancedReputationSystem11(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var advancedReputationSystem11Observable: Observable<AdvancedReputationSystem11> {
        return Bumper.observeValue(for: AdvancedReputationSystem11.key).map {
            AdvancedReputationSystem11(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var advancedReputationSystem12: AdvancedReputationSystem12 {
        guard let value = Bumper.value(for: AdvancedReputationSystem12.key) else { return .control }
        return AdvancedReputationSystem12(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var advancedReputationSystem12Observable: Observable<AdvancedReputationSystem12> {
        return Bumper.observeValue(for: AdvancedReputationSystem12.key).map {
            AdvancedReputationSystem12(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var advancedReputationSystem13: AdvancedReputationSystem13 {
        guard let value = Bumper.value(for: AdvancedReputationSystem13.key) else { return .control }
        return AdvancedReputationSystem13(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var advancedReputationSystem13Observable: Observable<AdvancedReputationSystem13> {
        return Bumper.observeValue(for: AdvancedReputationSystem13.key).map {
            AdvancedReputationSystem13(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var proUsersExtraImages: ProUsersExtraImages {
        guard let value = Bumper.value(for: ProUsersExtraImages.key) else { return .control }
        return ProUsersExtraImages(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var proUsersExtraImagesObservable: Observable<ProUsersExtraImages> {
        return Bumper.observeValue(for: ProUsersExtraImages.key).map {
            ProUsersExtraImages(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var sectionedDiscoveryFeed: SectionedDiscoveryFeed {
        guard let value = Bumper.value(for: SectionedDiscoveryFeed.key) else { return .control }
        return SectionedDiscoveryFeed(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var sectionedDiscoveryFeedObservable: Observable<SectionedDiscoveryFeed> {
        return Bumper.observeValue(for: SectionedDiscoveryFeed.key).map {
            SectionedDiscoveryFeed(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var servicesPromoCells: ServicesPromoCells {
        guard let value = Bumper.value(for: ServicesPromoCells.key) else { return .control }
        return ServicesPromoCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var servicesPromoCellsObservable: Observable<ServicesPromoCells> {
        return Bumper.observeValue(for: ServicesPromoCells.key).map {
            ServicesPromoCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiDayBumpUp: MultiDayBumpUp {
        guard let value = Bumper.value(for: MultiDayBumpUp.key) else { return .control }
        return MultiDayBumpUp(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiDayBumpUpObservable: Observable<MultiDayBumpUp> {
        return Bumper.observeValue(for: MultiDayBumpUp.key).map {
            MultiDayBumpUp(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var imInterestedInProfile: ImInterestedInProfile {
        guard let value = Bumper.value(for: ImInterestedInProfile.key) else { return .control }
        return ImInterestedInProfile(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var imInterestedInProfileObservable: Observable<ImInterestedInProfile> {
        return Bumper.observeValue(for: ImInterestedInProfile.key).map {
            ImInterestedInProfile(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var clickToTalk: ClickToTalk {
        guard let value = Bumper.value(for: ClickToTalk.key) else { return .control }
        return ClickToTalk(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var clickToTalkObservable: Observable<ClickToTalk> {
        return Bumper.observeValue(for: ClickToTalk.key).map {
            ClickToTalk(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var bulkPosting: BulkPosting {
        guard let value = Bumper.value(for: BulkPosting.key) else { return .control }
        return BulkPosting(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var bulkPostingObservable: Observable<BulkPosting> {
        return Bumper.observeValue(for: BulkPosting.key).map {
            BulkPosting(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var shareAfterScreenshot: ShareAfterScreenshot {
        guard let value = Bumper.value(for: ShareAfterScreenshot.key) else { return .control }
        return ShareAfterScreenshot(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var shareAfterScreenshotObservable: Observable<ShareAfterScreenshot> {
        return Bumper.observeValue(for: ShareAfterScreenshot.key).map {
            ShareAfterScreenshot(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var mutePushNotifications: MutePushNotifications {
        guard let value = Bumper.value(for: MutePushNotifications.key) else { return .control }
        return MutePushNotifications(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var mutePushNotificationsObservable: Observable<MutePushNotifications> {
        return Bumper.observeValue(for: MutePushNotifications.key).map {
            MutePushNotifications(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiAdRequestInChatSectionForUS: MultiAdRequestInChatSectionForUS {
        guard let value = Bumper.value(for: MultiAdRequestInChatSectionForUS.key) else { return .control }
        return MultiAdRequestInChatSectionForUS(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiAdRequestInChatSectionForUSObservable: Observable<MultiAdRequestInChatSectionForUS> {
        return Bumper.observeValue(for: MultiAdRequestInChatSectionForUS.key).map {
            MultiAdRequestInChatSectionForUS(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var multiAdRequestInChatSectionForTR: MultiAdRequestInChatSectionForTR {
        guard let value = Bumper.value(for: MultiAdRequestInChatSectionForTR.key) else { return .control }
        return MultiAdRequestInChatSectionForTR(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var multiAdRequestInChatSectionForTRObservable: Observable<MultiAdRequestInChatSectionForTR> {
        return Bumper.observeValue(for: MultiAdRequestInChatSectionForTR.key).map {
            MultiAdRequestInChatSectionForTR(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var affiliationEnabled: AffiliationEnabled {
        guard let value = Bumper.value(for: AffiliationEnabled.key) else { return .control }
        return AffiliationEnabled(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var affiliationEnabledObservable: Observable<AffiliationEnabled> {
        return Bumper.observeValue(for: AffiliationEnabled.key).map {
            AffiliationEnabled(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var bumpUpButtonOnConversationCells: BumpUpButtonOnConversationCells {
        guard let value = Bumper.value(for: BumpUpButtonOnConversationCells.key) else { return .control }
        return BumpUpButtonOnConversationCells(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var bumpUpButtonOnConversationCellsObservable: Observable<BumpUpButtonOnConversationCells> {
        return Bumper.observeValue(for: BumpUpButtonOnConversationCells.key).map {
            BumpUpButtonOnConversationCells(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var bumpPromoAfterSellNoLimit: BumpPromoAfterSellNoLimit {
        guard let value = Bumper.value(for: BumpPromoAfterSellNoLimit.key) else { return .control }
        return BumpPromoAfterSellNoLimit(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var bumpPromoAfterSellNoLimitObservable: Observable<BumpPromoAfterSellNoLimit> {
        return Bumper.observeValue(for: BumpPromoAfterSellNoLimit.key).map {
            BumpPromoAfterSellNoLimit(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var makeAnOfferButton: MakeAnOfferButton {
        guard let value = Bumper.value(for: MakeAnOfferButton.key) else { return .control }
        return MakeAnOfferButton(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var makeAnOfferButtonObservable: Observable<MakeAnOfferButton> {
        return Bumper.observeValue(for: MakeAnOfferButton.key).map {
            MakeAnOfferButton(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var newSearchAPIEndPoint: NewSearchAPIEndPoint {
        guard let value = Bumper.value(for: NewSearchAPIEndPoint.key) else { return .control }
        return NewSearchAPIEndPoint(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var newSearchAPIEndPointObservable: Observable<NewSearchAPIEndPoint> {
        return Bumper.observeValue(for: NewSearchAPIEndPoint.key).map {
            NewSearchAPIEndPoint(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var imageSizesNotificationCenter: ImageSizesNotificationCenter {
        guard let value = Bumper.value(for: ImageSizesNotificationCenter.key) else { return .control }
        return ImageSizesNotificationCenter(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var imageSizesNotificationCenterObservable: Observable<ImageSizesNotificationCenter> {
        return Bumper.observeValue(for: ImageSizesNotificationCenter.key).map {
            ImageSizesNotificationCenter(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var blockingSignUp: BlockingSignUp {
        guard let value = Bumper.value(for: BlockingSignUp.key) else { return .control }
        return BlockingSignUp(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var blockingSignUpObservable: Observable<BlockingSignUp> {
        return Bumper.observeValue(for: BlockingSignUp.key).map {
            BlockingSignUp(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var facebookUnavailable: Bool {
        guard let value = Bumper.value(for: FacebookUnavailable.key) else { return false }
        return FacebookUnavailable(rawValue: value)?.asBool ?? false
    } 

    #if (RX_BUMPER)
    static var facebookUnavailableObservable: Observable<Bool> {
        return Bumper.observeValue(for: FacebookUnavailable.key).map {
            FacebookUnavailable(rawValue: $0 ?? "")?.asBool ?? false
        }
    }
    #endif

    static var boostSmokeTest: BoostSmokeTest {
        guard let value = Bumper.value(for: BoostSmokeTest.key) else { return .control }
        return BoostSmokeTest(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var boostSmokeTestObservable: Observable<BoostSmokeTest> {
        return Bumper.observeValue(for: BoostSmokeTest.key).map {
            BoostSmokeTest(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var polymorphFeedAdsUSA: PolymorphFeedAdsUSA {
        guard let value = Bumper.value(for: PolymorphFeedAdsUSA.key) else { return .control }
        return PolymorphFeedAdsUSA(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var polymorphFeedAdsUSAObservable: Observable<PolymorphFeedAdsUSA> {
        return Bumper.observeValue(for: PolymorphFeedAdsUSA.key).map {
            PolymorphFeedAdsUSA(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var googleUnifiedNativeAds: GoogleUnifiedNativeAds {
        guard let value = Bumper.value(for: GoogleUnifiedNativeAds.key) else { return .control }
        return GoogleUnifiedNativeAds(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var googleUnifiedNativeAdsObservable: Observable<GoogleUnifiedNativeAds> {
        return Bumper.observeValue(for: GoogleUnifiedNativeAds.key).map {
            GoogleUnifiedNativeAds(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif

    static var advancedReputationSystem14: AdvancedReputationSystem14 {
        guard let value = Bumper.value(for: AdvancedReputationSystem14.key) else { return .control }
        return AdvancedReputationSystem14(rawValue: value) ?? .control 
    } 

    #if (RX_BUMPER)
    static var advancedReputationSystem14Observable: Observable<AdvancedReputationSystem14> {
        return Bumper.observeValue(for: AdvancedReputationSystem14.key).map {
            AdvancedReputationSystem14(rawValue: $0 ?? "") ?? .control
        }
    }
    #endif
}


enum RealEstateEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstateEnabled.control.rawValue }
    static var enumValues: [RealEstateEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Allow to see Real Estate category" } 
    static func fromPosition(_ position: Int) -> RealEstateEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RequestsTimeOut: String, BumperFeature  {
    case baseline, thirty, forty_five, sixty, hundred_and_twenty
    static var defaultValue: String { return RequestsTimeOut.baseline.rawValue }
    static var enumValues: [RequestsTimeOut] { return [.baseline, .thirty, .forty_five, .sixty, .hundred_and_twenty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "API requests timeout" } 
    static func fromPosition(_ position: Int) -> RequestsTimeOut {
        switch position { 
            case 0: return .baseline
            case 1: return .thirty
            case 2: return .forty_five
            case 3: return .sixty
            case 4: return .hundred_and_twenty
            default: return .baseline
        }
    }
}

enum MarkAsSoldQuickAnswerNewFlow: String, BumperFeature  {
    case control, baseline, markAsSoldNewFlowQuickAnswer
    static var defaultValue: String { return MarkAsSoldQuickAnswerNewFlow.control.rawValue }
    static var enumValues: [MarkAsSoldQuickAnswerNewFlow] { return [.control, .baseline, .markAsSoldNewFlowQuickAnswer]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "New flow when marking an item as sold on chat using quick answers" } 
    static func fromPosition(_ position: Int) -> MarkAsSoldQuickAnswerNewFlow {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .markAsSoldNewFlowQuickAnswer
            default: return .control
        }
    }
}

enum ShouldMoveLetsMeetAction: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShouldMoveLetsMeetAction.no.rawValue }
    static var enumValues: [ShouldMoveLetsMeetAction] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Put the lets meet icon inside the chat bar" } 
    var asBool: Bool { return self == .yes }
}

enum ShowAdsInFeedWithRatio: String, BumperFeature  {
    case control, baseline, ten, fifteen, twenty
    static var defaultValue: String { return ShowAdsInFeedWithRatio.control.rawValue }
    static var enumValues: [ShowAdsInFeedWithRatio] { return [.control, .baseline, .ten, .fifteen, .twenty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] show ads in feed every X cells" } 
    static func fromPosition(_ position: Int) -> ShowAdsInFeedWithRatio {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .ten
            case 3: return .fifteen
            case 4: return .twenty
            default: return .control
        }
    }
}

enum RealEstateFlowType: String, BumperFeature  {
    case standard, turkish
    static var defaultValue: String { return RealEstateFlowType.standard.rawValue }
    static var enumValues: [RealEstateFlowType] { return [.standard, .turkish]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Real Estate Flow Type" } 
    static func fromPosition(_ position: Int) -> RealEstateFlowType {
        switch position { 
            case 0: return .standard
            case 1: return .turkish
            default: return .standard
        }
    }
}

enum DummyUsersInfoProfile: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return DummyUsersInfoProfile.control.rawValue }
    static var enumValues: [DummyUsersInfoProfile] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Add info for dummy users in profile" } 
    static func fromPosition(_ position: Int) -> DummyUsersInfoProfile {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowInactiveConversations: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowInactiveConversations.no.rawValue }
    static var enumValues: [ShowInactiveConversations] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Show button to access inactive conversations" } 
    var asBool: Bool { return self == .yes }
}

enum SearchImprovements: String, BumperFeature  {
    case control, baseline, mWE, mWERelaxedSynonyms, mWERelaxedSynonymsMM100, mWERelaxedSynonymsMM75, mWS, boostingScoreDistance, boostingDistance, boostingFreshness, boostingDistAndFreshness
    static var defaultValue: String { return SearchImprovements.control.rawValue }
    static var enumValues: [SearchImprovements] { return [.control, .baseline, .mWE, .mWERelaxedSynonyms, .mWERelaxedSynonymsMM100, .mWERelaxedSynonymsMM75, .mWS, .boostingScoreDistance, .boostingDistance, .boostingFreshness, .boostingDistAndFreshness]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Search improvements related to multi word, boosting distance, score and freshness" } 
    static func fromPosition(_ position: Int) -> SearchImprovements {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .mWE
            case 3: return .mWERelaxedSynonyms
            case 4: return .mWERelaxedSynonymsMM100
            case 5: return .mWERelaxedSynonymsMM75
            case 6: return .mWS
            case 7: return .boostingScoreDistance
            case 8: return .boostingDistance
            case 9: return .boostingFreshness
            case 10: return .boostingDistAndFreshness
            default: return .control
        }
    }
}

enum RelaxedSearch: String, BumperFeature  {
    case control, baseline, relaxedQuery, relaxedQueryORFallback
    static var defaultValue: String { return RelaxedSearch.control.rawValue }
    static var enumValues: [RelaxedSearch] { return [.control, .baseline, .relaxedQuery, .relaxedQueryORFallback]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Search improvements with relaxed queries" } 
    static func fromPosition(_ position: Int) -> RelaxedSearch {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .relaxedQuery
            case 3: return .relaxedQueryORFallback
            default: return .control
        }
    }
}

enum ShowChatSafetyTips: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowChatSafetyTips.no.rawValue }
    static var enumValues: [ShowChatSafetyTips] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Show chat safety tips to new users" } 
    var asBool: Bool { return self == .yes }
}

enum OnboardingIncentivizePosting: String, BumperFeature  {
    case control, baseline, blockingPosting, blockingPostingSkipWelcome
    static var defaultValue: String { return OnboardingIncentivizePosting.control.rawValue }
    static var enumValues: [OnboardingIncentivizePosting] { return [.control, .baseline, .blockingPosting, .blockingPostingSkipWelcome]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Leads the user through the posting feature and onboarding improvements" } 
    static func fromPosition(_ position: Int) -> OnboardingIncentivizePosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .blockingPosting
            case 3: return .blockingPostingSkipWelcome
            default: return .control
        }
    }
}

enum CopyForChatNowInTurkey: String, BumperFeature  {
    case control, variantA, variantB, variantC, variantD
    static var defaultValue: String { return CopyForChatNowInTurkey.control.rawValue }
    static var enumValues: [CopyForChatNowInTurkey] { return [.control, .variantA, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Try different copies for Chat now button in Turkey" } 
    static func fromPosition(_ position: Int) -> CopyForChatNowInTurkey {
        switch position { 
            case 0: return .control
            case 1: return .variantA
            case 2: return .variantB
            case 3: return .variantC
            case 4: return .variantD
            default: return .control
        }
    }
}

enum ChatNorris: String, BumperFeature  {
    case control, baseline, redButton, whiteButton, greenButton
    static var defaultValue: String { return ChatNorris.control.rawValue }
    static var enumValues: [ChatNorris] { return [.control, .baseline, .redButton, .whiteButton, .greenButton]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Show the create meeting option in chat detail view." } 
    static func fromPosition(_ position: Int) -> ChatNorris {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .redButton
            case 3: return .whiteButton
            case 4: return .greenButton
            default: return .control
        }
    }
}

enum ShowProTagUserProfile: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowProTagUserProfile.no.rawValue }
    static var enumValues: [ShowProTagUserProfile] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show Professional tag in user profile" } 
    var asBool: Bool { return self == .yes }
}

enum CopyForChatNowInEnglish: String, BumperFeature  {
    case control, variantA, variantB, variantC, variantD
    static var defaultValue: String { return CopyForChatNowInEnglish.control.rawValue }
    static var enumValues: [CopyForChatNowInEnglish] { return [.control, .variantA, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Try different copies for Chat now button in English" } 
    static func fromPosition(_ position: Int) -> CopyForChatNowInEnglish {
        switch position { 
            case 0: return .control
            case 1: return .variantA
            case 2: return .variantB
            case 3: return .variantC
            case 4: return .variantD
            default: return .control
        }
    }
}

enum ShowExactLocationForPros: String, BumperFeature  {
    case yes, no
    static var defaultValue: String { return ShowExactLocationForPros.yes.rawValue }
    static var enumValues: [ShowExactLocationForPros] { return [.yes, .no]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show exact location for professional delaers in listing detail map" } 
    var asBool: Bool { return self == .yes }
}

enum ShowPasswordlessLogin: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowPasswordlessLogin.control.rawValue }
    static var enumValues: [ShowPasswordlessLogin] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show Passwordless login option" } 
    static func fromPosition(_ position: Int) -> ShowPasswordlessLogin {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum CopyForSellFasterNowInEnglish: String, BumperFeature  {
    case control, baseline, variantB, variantC, variantD
    static var defaultValue: String { return CopyForSellFasterNowInEnglish.control.rawValue }
    static var enumValues: [CopyForSellFasterNowInEnglish] { return [.control, .baseline, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Try different copies for 'Sell faster now' banner in English" } 
    static func fromPosition(_ position: Int) -> CopyForSellFasterNowInEnglish {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantB
            case 3: return .variantC
            case 4: return .variantD
            default: return .control
        }
    }
}

enum EmergencyLocate: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return EmergencyLocate.control.rawValue }
    static var enumValues: [EmergencyLocate] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Activate the Emergency Locate feature" } 
    static func fromPosition(_ position: Int) -> EmergencyLocate {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum PersonalizedFeed: String, BumperFeature  {
    case control, baseline, personalized
    static var defaultValue: String { return PersonalizedFeed.control.rawValue }
    static var enumValues: [PersonalizedFeed] { return [.control, .baseline, .personalized]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Personalize the feed" } 
    static func fromPosition(_ position: Int) -> PersonalizedFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .personalized
            default: return .control
        }
    }
}

enum OffensiveReportAlert: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return OffensiveReportAlert.control.rawValue }
    static var enumValues: [OffensiveReportAlert] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Offensive Report alert active" } 
    static func fromPosition(_ position: Int) -> OffensiveReportAlert {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum FullScreenAdsWhenBrowsingForUS: String, BumperFeature  {
    case control, baseline, adsForAllUsers, adsForOldUsers
    static var defaultValue: String { return FullScreenAdsWhenBrowsingForUS.control.rawValue }
    static var enumValues: [FullScreenAdsWhenBrowsingForUS] { return [.control, .baseline, .adsForAllUsers, .adsForOldUsers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show full screen Interstitial while browsing through items" } 
    static func fromPosition(_ position: Int) -> FullScreenAdsWhenBrowsingForUS {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .adsForAllUsers
            case 3: return .adsForOldUsers
            default: return .control
        }
    }
}

enum PreventMessagesFromFeedToProUsers: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return PreventMessagesFromFeedToProUsers.control.rawValue }
    static var enumValues: [PreventMessagesFromFeedToProUsers] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] If buyer taps 'I'm interested' button in the feed and the listing is from a PRO user, show the phone number request screen" } 
    static func fromPosition(_ position: Int) -> PreventMessagesFromFeedToProUsers {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SimplifiedChatButton: String, BumperFeature  {
    case control, baseline, variantA, variantB, variantC, variantD, variantE, variantF
    static var defaultValue: String { return SimplifiedChatButton.control.rawValue }
    static var enumValues: [SimplifiedChatButton] { return [.control, .baseline, .variantA, .variantB, .variantC, .variantD, .variantE, .variantF]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[PRODUCTS] Show a simplified chat button on item page" } 
    static func fromPosition(_ position: Int) -> SimplifiedChatButton {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            case 4: return .variantC
            case 5: return .variantD
            case 6: return .variantE
            case 7: return .variantF
            default: return .control
        }
    }
}

enum ShowChatConnectionStatusBar: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowChatConnectionStatusBar.control.rawValue }
    static var enumValues: [ShowChatConnectionStatusBar] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Show a toast in the chat with the websocket and network connection status" } 
    static func fromPosition(_ position: Int) -> ShowChatConnectionStatusBar {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ReportingFostaSesta: String, BumperFeature  {
    case control, baseline, withIcons, withoutIcons
    static var defaultValue: String { return ReportingFostaSesta.control.rawValue }
    static var enumValues: [ReportingFostaSesta] { return [.control, .baseline, .withIcons, .withoutIcons]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show new user/product reporting flow (FOSTA-SESTA compliance)" } 
    static func fromPosition(_ position: Int) -> ReportingFostaSesta {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .withIcons
            case 3: return .withoutIcons
            default: return .control
        }
    }
}

enum ShowChatHeaderWithoutUser: String, BumperFeature  {
    case yes, no
    static var defaultValue: String { return ShowChatHeaderWithoutUser.yes.rawValue }
    static var enumValues: [ShowChatHeaderWithoutUser] { return [.yes, .no]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Use the new header WITHOUT USER in chat detail" } 
    var asBool: Bool { return self == .yes }
}

enum NewItemPageV3: String, BumperFeature  {
    case control, baseline, infoWithLaterals, infoWithoutLaterals, buttonWithLaterals, buttonWithoutLaterals
    static var defaultValue: String { return NewItemPageV3.control.rawValue }
    static var enumValues: [NewItemPageV3] { return [.control, .baseline, .infoWithLaterals, .infoWithoutLaterals, .buttonWithLaterals, .buttonWithoutLaterals]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[Products] New item page V3 -- all in" } 
    static func fromPosition(_ position: Int) -> NewItemPageV3 {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .infoWithLaterals
            case 3: return .infoWithoutLaterals
            case 4: return .buttonWithLaterals
            case 5: return .buttonWithoutLaterals
            default: return .control
        }
    }
}

enum AppInstallAdsInFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AppInstallAdsInFeed.control.rawValue }
    static var enumValues: [AppInstallAdsInFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show App Install Ads from Google Adx in feed" } 
    static func fromPosition(_ position: Int) -> AppInstallAdsInFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EnableCTAMessageType: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return EnableCTAMessageType.no.rawValue }
    static var enumValues: [EnableCTAMessageType] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Enable the CTA message type" } 
    var asBool: Bool { return self == .yes }
}

enum OpenChatFromUserProfile: String, BumperFeature  {
    case control, baseline, vatiant1NoQuickAnswers, variant2WithOneTimeQuickAnswers
    static var defaultValue: String { return OpenChatFromUserProfile.control.rawValue }
    static var enumValues: [OpenChatFromUserProfile] { return [.control, .baseline, .vatiant1NoQuickAnswers, .variant2WithOneTimeQuickAnswers]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CHAT] Open a chat from the user profile" } 
    static func fromPosition(_ position: Int) -> OpenChatFromUserProfile {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .vatiant1NoQuickAnswers
            case 3: return .variant2WithOneTimeQuickAnswers
            default: return .control
        }
    }
}

enum SearchAlertsInSearchSuggestions: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SearchAlertsInSearchSuggestions.control.rawValue }
    static var enumValues: [SearchAlertsInSearchSuggestions] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Show search alerts in search suggestions view" } 
    static func fromPosition(_ position: Int) -> SearchAlertsInSearchSuggestions {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EngagementBadging: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return EngagementBadging.control.rawValue }
    static var enumValues: [EngagementBadging] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Show recent items bubble in feed basic approach" } 
    static func fromPosition(_ position: Int) -> EngagementBadging {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowCommunity: String, BumperFeature  {
    case control, baseline, communityOnNavBar, communityOnTabBar
    static var defaultValue: String { return ShowCommunity.control.rawValue }
    static var enumValues: [ShowCommunity] { return [.control, .baseline, .communityOnNavBar, .communityOnTabBar]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[Users] Show button/tab to open the new Community feature" } 
    static func fromPosition(_ position: Int) -> ShowCommunity {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .communityOnNavBar
            case 3: return .communityOnTabBar
            default: return .control
        }
    }
}

enum SmartQuickAnswers: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SmartQuickAnswers.control.rawValue }
    static var enumValues: [SmartQuickAnswers] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show smart quick answer events" } 
    static func fromPosition(_ position: Int) -> SmartQuickAnswers {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AlwaysShowBumpBannerWithLoading: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AlwaysShowBumpBannerWithLoading.control.rawValue }
    static var enumValues: [AlwaysShowBumpBannerWithLoading] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Always show bump banner with a loading till we get the info" } 
    static func fromPosition(_ position: Int) -> AlwaysShowBumpBannerWithLoading {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ServicesPaymentFrequency: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ServicesPaymentFrequency.control.rawValue }
    static var enumValues: [ServicesPaymentFrequency] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[SERVICES] shows services paymentFrequency functionality (e.g 2 euro per day, etc.)" } 
    static func fromPosition(_ position: Int) -> ServicesPaymentFrequency {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SearchAlertsDisableOldestIfMaximumReached: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SearchAlertsDisableOldestIfMaximumReached.control.rawValue }
    static var enumValues: [SearchAlertsDisableOldestIfMaximumReached] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Disable oldest search alert if a new one is created and the maximum has been reached" } 
    static func fromPosition(_ position: Int) -> SearchAlertsDisableOldestIfMaximumReached {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowSellFasterInProfileCells: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowSellFasterInProfileCells.control.rawValue }
    static var enumValues: [ShowSellFasterInProfileCells] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Add CTA to bump up to profile listing cells" } 
    static func fromPosition(_ position: Int) -> ShowSellFasterInProfileCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum BumpInEditCopys: String, BumperFeature  {
    case control, baseline, attractMoreBuyers, attractMoreBuyersToSellFast, showMeHowToAttract
    static var defaultValue: String { return BumpInEditCopys.control.rawValue }
    static var enumValues: [BumpInEditCopys] { return [.control, .baseline, .attractMoreBuyers, .attractMoreBuyersToSellFast, .showMeHowToAttract]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Test different variants for bump up in edit listing screen" } 
    static func fromPosition(_ position: Int) -> BumpInEditCopys {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .attractMoreBuyers
            case 3: return .attractMoreBuyersToSellFast
            case 4: return .showMeHowToAttract
            default: return .control
        }
    }
}

enum MultiAdRequestMoreInfo: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MultiAdRequestMoreInfo.control.rawValue }
    static var enumValues: [MultiAdRequestMoreInfo] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Test different ad sizes in more info view" } 
    static func fromPosition(_ position: Int) -> MultiAdRequestMoreInfo {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum EnableJobsAndServicesCategory: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return EnableJobsAndServicesCategory.control.rawValue }
    static var enumValues: [EnableJobsAndServicesCategory] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[SERVICES] Services category becomes Jobs & Services, enables features related to jobs" } 
    static func fromPosition(_ position: Int) -> EnableJobsAndServicesCategory {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum CopyForSellFasterNowInTurkish: String, BumperFeature  {
    case control, baseline, variantB, variantC, variantD
    static var defaultValue: String { return CopyForSellFasterNowInTurkish.control.rawValue }
    static var enumValues: [CopyForSellFasterNowInTurkish] { return [.control, .baseline, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Try different copies for 'Sell faster now' banner in Turkish" } 
    static func fromPosition(_ position: Int) -> CopyForSellFasterNowInTurkish {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantB
            case 3: return .variantC
            case 4: return .variantD
            default: return .control
        }
    }
}

enum RandomImInterestedMessages: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RandomImInterestedMessages.control.rawValue }
    static var enumValues: [RandomImInterestedMessages] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Random Im Interested messages from listing list" } 
    static func fromPosition(_ position: Int) -> RandomImInterestedMessages {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum CarPromoCells: String, BumperFeature  {
    case control, baseline, variantA, variantB
    static var defaultValue: String { return CarPromoCells.control.rawValue }
    static var enumValues: [CarPromoCells] { return [.control, .baseline, .variantA, .variantB]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CARS] Show promo cells for cars" } 
    static func fromPosition(_ position: Int) -> CarPromoCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            default: return .control
        }
    }
}

enum RealEstatePromoCells: String, BumperFeature  {
    case control, baseline, variantA
    static var defaultValue: String { return RealEstatePromoCells.control.rawValue }
    static var enumValues: [RealEstatePromoCells] { return [.control, .baseline, .variantA]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[REAL ESTATE] Show NEW promo cells for real Estate" } 
    static func fromPosition(_ position: Int) -> RealEstatePromoCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            default: return .control
        }
    }
}

enum AdvancedReputationSystem11: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AdvancedReputationSystem11.control.rawValue }
    static var enumValues: [AdvancedReputationSystem11] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[USERS] ARS v1.1" } 
    static func fromPosition(_ position: Int) -> AdvancedReputationSystem11 {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AdvancedReputationSystem12: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AdvancedReputationSystem12.control.rawValue }
    static var enumValues: [AdvancedReputationSystem12] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[USERS] ARS v1.2" } 
    static func fromPosition(_ position: Int) -> AdvancedReputationSystem12 {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AdvancedReputationSystem13: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AdvancedReputationSystem13.control.rawValue }
    static var enumValues: [AdvancedReputationSystem13] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[USERS] ARS v1.3" } 
    static func fromPosition(_ position: Int) -> AdvancedReputationSystem13 {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ProUsersExtraImages: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ProUsersExtraImages.control.rawValue }
    static var enumValues: [ProUsersExtraImages] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[Cars] allow up to 25 images to be displayed on the product detail page" } 
    static func fromPosition(_ position: Int) -> ProUsersExtraImages {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum SectionedDiscoveryFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return SectionedDiscoveryFeed.control.rawValue }
    static var enumValues: [SectionedDiscoveryFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[Discovery] Show SectionedFeed" } 
    static func fromPosition(_ position: Int) -> SectionedDiscoveryFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ServicesPromoCells: String, BumperFeature  {
    case control, baseline, activeWithCallToAction, activeWithoutCallToAction
    static var defaultValue: String { return ServicesPromoCells.control.rawValue }
    static var enumValues: [ServicesPromoCells] { return [.control, .baseline, .activeWithCallToAction, .activeWithoutCallToAction]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[SERVICES] Show promo cells for Services" } 
    static func fromPosition(_ position: Int) -> ServicesPromoCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .activeWithCallToAction
            case 3: return .activeWithoutCallToAction
            default: return .control
        }
    }
}

enum MultiDayBumpUp: String, BumperFeature  {
    case control, baseline, show1Day, show3Days, show7Days
    static var defaultValue: String { return MultiDayBumpUp.control.rawValue }
    static var enumValues: [MultiDayBumpUp] { return [.control, .baseline, .show1Day, .show3Days, .show7Days]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Add options to bump a listing for several days" } 
    static func fromPosition(_ position: Int) -> MultiDayBumpUp {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .show1Day
            case 3: return .show3Days
            case 4: return .show7Days
            default: return .control
        }
    }
}

enum ImInterestedInProfile: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ImInterestedInProfile.control.rawValue }
    static var enumValues: [ImInterestedInProfile] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Show Im Interested buttons in public profiles" } 
    static func fromPosition(_ position: Int) -> ImInterestedInProfile {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ClickToTalk: String, BumperFeature  {
    case control, baseline, variantA, variantB, variantC
    static var defaultValue: String { return ClickToTalk.control.rawValue }
    static var enumValues: [ClickToTalk] { return [.control, .baseline, .variantA, .variantB, .variantC]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[VERTICALS] Show Click to talk" } 
    static func fromPosition(_ position: Int) -> ClickToTalk {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            case 4: return .variantC
            default: return .control
        }
    }
}

enum BulkPosting: String, BumperFeature  {
    case control, baseline, variantA, variantB, variantC, variantD
    static var defaultValue: String { return BulkPosting.control.rawValue }
    static var enumValues: [BulkPosting] { return [.control, .baseline, .variantA, .variantB, .variantC, .variantD]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[PRODUCTS] Bulk posting" } 
    static func fromPosition(_ position: Int) -> BulkPosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            case 4: return .variantC
            case 5: return .variantD
            default: return .control
        }
    }
}

enum ShareAfterScreenshot: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShareAfterScreenshot.control.rawValue }
    static var enumValues: [ShareAfterScreenshot] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Show a share view after the user takes a screenshot" } 
    static func fromPosition(_ position: Int) -> ShareAfterScreenshot {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MutePushNotifications: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MutePushNotifications.control.rawValue }
    static var enumValues: [MutePushNotifications] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CORE] Push notifications won't make a sound during some night hours." } 
    static func fromPosition(_ position: Int) -> MutePushNotifications {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MultiAdRequestInChatSectionForUS: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MultiAdRequestInChatSectionForUS.control.rawValue }
    static var enumValues: [MultiAdRequestInChatSectionForUS] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Muti ad request in Chat section. For US" } 
    static func fromPosition(_ position: Int) -> MultiAdRequestInChatSectionForUS {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MultiAdRequestInChatSectionForTR: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MultiAdRequestInChatSectionForTR.control.rawValue }
    static var enumValues: [MultiAdRequestInChatSectionForTR] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Muti ad request in Chat section. For Turkey" } 
    static func fromPosition(_ position: Int) -> MultiAdRequestInChatSectionForTR {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AffiliationEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AffiliationEnabled.control.rawValue }
    static var enumValues: [AffiliationEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Enables Affiliation / Referral Program" } 
    static func fromPosition(_ position: Int) -> AffiliationEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum BumpUpButtonOnConversationCells: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return BumpUpButtonOnConversationCells.control.rawValue }
    static var enumValues: [BumpUpButtonOnConversationCells] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show a bump up button option in selling conversation cells" } 
    static func fromPosition(_ position: Int) -> BumpUpButtonOnConversationCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum BumpPromoAfterSellNoLimit: String, BumperFeature  {
    case control, baseline, alwaysShow, straightToBump
    static var defaultValue: String { return BumpPromoAfterSellNoLimit.control.rawValue }
    static var enumValues: [BumpPromoAfterSellNoLimit] { return [.control, .baseline, .alwaysShow, .straightToBump]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Remove the 24h limit in bump after sell promo" } 
    static func fromPosition(_ position: Int) -> BumpPromoAfterSellNoLimit {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .alwaysShow
            case 3: return .straightToBump
            default: return .control
        }
    }
}

enum MakeAnOfferButton: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return MakeAnOfferButton.control.rawValue }
    static var enumValues: [MakeAnOfferButton] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[P2P PAYMENTS] Show make an offer button" } 
    static func fromPosition(_ position: Int) -> MakeAnOfferButton {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum NewSearchAPIEndPoint: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return NewSearchAPIEndPoint.control.rawValue }
    static var enumValues: [NewSearchAPIEndPoint] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[DISCOVERY] Use New Search API Endpoint" } 
    static func fromPosition(_ position: Int) -> NewSearchAPIEndPoint {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ImageSizesNotificationCenter: String, BumperFeature  {
    case control, baseline, nineSix, oneTwoEight
    static var defaultValue: String { return ImageSizesNotificationCenter.control.rawValue }
    static var enumValues: [ImageSizesNotificationCenter] { return [.control, .baseline, .nineSix, .oneTwoEight]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] Notification center with different thumbnails sizes" } 
    static func fromPosition(_ position: Int) -> ImageSizesNotificationCenter {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .nineSix
            case 3: return .oneTwoEight
            default: return .control
        }
    }
}

enum BlockingSignUp: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return BlockingSignUp.control.rawValue }
    static var enumValues: [BlockingSignUp] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[RETENTION] User needs to sign up/sign in even after killing the app in log in screen" } 
    static func fromPosition(_ position: Int) -> BlockingSignUp {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum FacebookUnavailable: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return FacebookUnavailable.no.rawValue }
    static var enumValues: [FacebookUnavailable] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[CORE] Show Facebook unavailable message when user tries to authenticate with Facebook." } 
    var asBool: Bool { return self == .yes }
}

enum BoostSmokeTest: String, BumperFeature  {
    case control, baseline, variantA, variantB, variantC, variantD, variantE, variantF
    static var defaultValue: String { return BoostSmokeTest.control.rawValue }
    static var enumValues: [BoostSmokeTest] { return [.control, .baseline, .variantA, .variantB, .variantC, .variantD, .variantE, .variantF]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[VERTICALS] Show Boost and Super Boost Smoke Test" } 
    static func fromPosition(_ position: Int) -> BoostSmokeTest {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .variantA
            case 3: return .variantB
            case 4: return .variantC
            case 5: return .variantD
            case 6: return .variantE
            case 7: return .variantF
            default: return .control
        }
    }
}

enum PolymorphFeedAdsUSA: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return PolymorphFeedAdsUSA.control.rawValue }
    static var enumValues: [PolymorphFeedAdsUSA] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] Show Polymorph ads in feed for USA" } 
    static func fromPosition(_ position: Int) -> PolymorphFeedAdsUSA {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum GoogleUnifiedNativeAds: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return GoogleUnifiedNativeAds.control.rawValue }
    static var enumValues: [GoogleUnifiedNativeAds] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[MONEY] New unified Google Native Ads" } 
    static func fromPosition(_ position: Int) -> GoogleUnifiedNativeAds {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AdvancedReputationSystem14: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AdvancedReputationSystem14.control.rawValue }
    static var enumValues: [AdvancedReputationSystem14] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "[USERS] ARS v1.4" } 
    static func fromPosition(_ position: Int) -> AdvancedReputationSystem14 {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

