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

extension Bumper  {
    static func initialize() {
        var flags = [BumperFeature.Type]()
        flags.append(ShowNPSSurvey.self)
        flags.append(SurveyEnabled.self)
        flags.append(FreeBumpUpEnabled.self)
        flags.append(PricedBumpUpEnabled.self)
        flags.append(UserReviewsReportEnabled.self)
        flags.append(DynamicQuickAnswers.self)
        flags.append(DefaultRadiusDistanceFeed.self)
        flags.append(RealEstateEnabled.self)
        flags.append(SearchAutocomplete.self)
        flags.append(ShowPriceAfterSearchOrFilter.self)
        flags.append(RequestsTimeOut.self)
        flags.append(NewBumpUpExplanation.self)
        flags.append(HomeRelatedEnabled.self)
        flags.append(HideChatButtonOnFeaturedCells.self)
        flags.append(TaxonomiesAndTaxonomyChildrenInFeed.self)
        flags.append(NewItemPage.self)
        flags.append(ShowPriceStepRealEstatePosting.self)
        flags.append(ShowClockInDirectAnswer.self)
        flags.append(BumpUpPriceDifferentiation.self)
        flags.append(PromoteBumpUpAfterSell.self)
        flags.append(MoreInfoAFShOrDFP.self)
        flags.append(ShowSecurityMeetingChatMessage.self)
        flags.append(AllowCallsForProfessionals.self)
        flags.append(RealEstateImprovements.self)
        flags.append(RealEstatePromos.self)
        flags.append(AllowEmojisOnChat.self)
        flags.append(ShowAdsInFeedWithRatio.self)
        flags.append(RealEstateFlowType.self)
        flags.append(RemoveCategoryWhenClosingPosting.self)
        flags.append(RealEstateNewCopy.self)
        flags.append(DummyUsersInfoProfile.self)
        Bumper.initialize(flags)
    } 

    static var showNPSSurvey: Bool {
        guard let value = Bumper.value(for: ShowNPSSurvey.key) else { return false }
        return ShowNPSSurvey(rawValue: value)?.asBool ?? false
    }

    static var surveyEnabled: Bool {
        guard let value = Bumper.value(for: SurveyEnabled.key) else { return false }
        return SurveyEnabled(rawValue: value)?.asBool ?? false
    }

    static var freeBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: FreeBumpUpEnabled.key) else { return false }
        return FreeBumpUpEnabled(rawValue: value)?.asBool ?? false
    }

    static var pricedBumpUpEnabled: Bool {
        guard let value = Bumper.value(for: PricedBumpUpEnabled.key) else { return false }
        return PricedBumpUpEnabled(rawValue: value)?.asBool ?? false
    }

    static var userReviewsReportEnabled: Bool {
        guard let value = Bumper.value(for: UserReviewsReportEnabled.key) else { return false }
        return UserReviewsReportEnabled(rawValue: value)?.asBool ?? false
    }

    static var dynamicQuickAnswers: DynamicQuickAnswers {
        guard let value = Bumper.value(for: DynamicQuickAnswers.key) else { return .control }
        return DynamicQuickAnswers(rawValue: value) ?? .control 
    }

    static var defaultRadiusDistanceFeed: DefaultRadiusDistanceFeed {
        guard let value = Bumper.value(for: DefaultRadiusDistanceFeed.key) else { return .control }
        return DefaultRadiusDistanceFeed(rawValue: value) ?? .control 
    }

    static var realEstateEnabled: RealEstateEnabled {
        guard let value = Bumper.value(for: RealEstateEnabled.key) else { return .control }
        return RealEstateEnabled(rawValue: value) ?? .control 
    }

    static var searchAutocomplete: SearchAutocomplete {
        guard let value = Bumper.value(for: SearchAutocomplete.key) else { return .control }
        return SearchAutocomplete(rawValue: value) ?? .control 
    }

    static var showPriceAfterSearchOrFilter: ShowPriceAfterSearchOrFilter {
        guard let value = Bumper.value(for: ShowPriceAfterSearchOrFilter.key) else { return .control }
        return ShowPriceAfterSearchOrFilter(rawValue: value) ?? .control 
    }

    static var requestsTimeOut: RequestsTimeOut {
        guard let value = Bumper.value(for: RequestsTimeOut.key) else { return .baseline }
        return RequestsTimeOut(rawValue: value) ?? .baseline 
    }

    static var newBumpUpExplanation: NewBumpUpExplanation {
        guard let value = Bumper.value(for: NewBumpUpExplanation.key) else { return .control }
        return NewBumpUpExplanation(rawValue: value) ?? .control 
    }

    static var homeRelatedEnabled: HomeRelatedEnabled {
        guard let value = Bumper.value(for: HomeRelatedEnabled.key) else { return .control }
        return HomeRelatedEnabled(rawValue: value) ?? .control 
    }

    static var hideChatButtonOnFeaturedCells: HideChatButtonOnFeaturedCells {
        guard let value = Bumper.value(for: HideChatButtonOnFeaturedCells.key) else { return .control }
        return HideChatButtonOnFeaturedCells(rawValue: value) ?? .control 
    }

    static var taxonomiesAndTaxonomyChildrenInFeed: TaxonomiesAndTaxonomyChildrenInFeed {
        guard let value = Bumper.value(for: TaxonomiesAndTaxonomyChildrenInFeed.key) else { return .control }
        return TaxonomiesAndTaxonomyChildrenInFeed(rawValue: value) ?? .control 
    }

    static var newItemPage: NewItemPage {
        guard let value = Bumper.value(for: NewItemPage.key) else { return .control }
        return NewItemPage(rawValue: value) ?? .control 
    }

    static var showPriceStepRealEstatePosting: ShowPriceStepRealEstatePosting {
        guard let value = Bumper.value(for: ShowPriceStepRealEstatePosting.key) else { return .control }
        return ShowPriceStepRealEstatePosting(rawValue: value) ?? .control 
    }

    static var showClockInDirectAnswer: ShowClockInDirectAnswer {
        guard let value = Bumper.value(for: ShowClockInDirectAnswer.key) else { return .control }
        return ShowClockInDirectAnswer(rawValue: value) ?? .control 
    }

    static var bumpUpPriceDifferentiation: BumpUpPriceDifferentiation {
        guard let value = Bumper.value(for: BumpUpPriceDifferentiation.key) else { return .control }
        return BumpUpPriceDifferentiation(rawValue: value) ?? .control 
    }

    static var promoteBumpUpAfterSell: PromoteBumpUpAfterSell {
        guard let value = Bumper.value(for: PromoteBumpUpAfterSell.key) else { return .control }
        return PromoteBumpUpAfterSell(rawValue: value) ?? .control 
    }

    static var moreInfoAFShOrDFP: MoreInfoAFShOrDFP {
        guard let value = Bumper.value(for: MoreInfoAFShOrDFP.key) else { return .control }
        return MoreInfoAFShOrDFP(rawValue: value) ?? .control 
    }

    static var showSecurityMeetingChatMessage: ShowSecurityMeetingChatMessage {
        guard let value = Bumper.value(for: ShowSecurityMeetingChatMessage.key) else { return .control }
        return ShowSecurityMeetingChatMessage(rawValue: value) ?? .control 
    }

    static var allowCallsForProfessionals: AllowCallsForProfessionals {
        guard let value = Bumper.value(for: AllowCallsForProfessionals.key) else { return .control }
        return AllowCallsForProfessionals(rawValue: value) ?? .control 
    }

    static var realEstateImprovements: RealEstateImprovements {
        guard let value = Bumper.value(for: RealEstateImprovements.key) else { return .control }
        return RealEstateImprovements(rawValue: value) ?? .control 
    }

    static var realEstatePromos: RealEstatePromos {
        guard let value = Bumper.value(for: RealEstatePromos.key) else { return .control }
        return RealEstatePromos(rawValue: value) ?? .control 
    }

    static var allowEmojisOnChat: AllowEmojisOnChat {
        guard let value = Bumper.value(for: AllowEmojisOnChat.key) else { return .control }
        return AllowEmojisOnChat(rawValue: value) ?? .control 
    }

    static var showAdsInFeedWithRatio: ShowAdsInFeedWithRatio {
        guard let value = Bumper.value(for: ShowAdsInFeedWithRatio.key) else { return .control }
        return ShowAdsInFeedWithRatio(rawValue: value) ?? .control 
    }

    static var realEstateFlowType: RealEstateFlowType {
        guard let value = Bumper.value(for: RealEstateFlowType.key) else { return .standard }
        return RealEstateFlowType(rawValue: value) ?? .standard 
    }

    static var removeCategoryWhenClosingPosting: RemoveCategoryWhenClosingPosting {
        guard let value = Bumper.value(for: RemoveCategoryWhenClosingPosting.key) else { return .control }
        return RemoveCategoryWhenClosingPosting(rawValue: value) ?? .control 
    }

    static var realEstateNewCopy: RealEstateNewCopy {
        guard let value = Bumper.value(for: RealEstateNewCopy.key) else { return .control }
        return RealEstateNewCopy(rawValue: value) ?? .control 
    }

    static var dummyUsersInfoProfile: DummyUsersInfoProfile {
        guard let value = Bumper.value(for: DummyUsersInfoProfile.key) else { return .control }
        return DummyUsersInfoProfile(rawValue: value) ?? .control 
    } 
}


enum ShowNPSSurvey: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return ShowNPSSurvey.no.rawValue }
    static var enumValues: [ShowNPSSurvey] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show nps survey" } 
    var asBool: Bool { return self == .yes }
}

enum SurveyEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return SurveyEnabled.no.rawValue }
    static var enumValues: [SurveyEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show qualitative survey" } 
    var asBool: Bool { return self == .yes }
}

enum FreeBumpUpEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return FreeBumpUpEnabled.no.rawValue }
    static var enumValues: [FreeBumpUpEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User can bump sharing" } 
    var asBool: Bool { return self == .yes }
}

enum PricedBumpUpEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return PricedBumpUpEnabled.no.rawValue }
    static var enumValues: [PricedBumpUpEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User can bump paying" } 
    var asBool: Bool { return self == .yes }
}

enum UserReviewsReportEnabled: String, BumperFeature  {
    case no, yes
    static var defaultValue: String { return UserReviewsReportEnabled.no.rawValue }
    static var enumValues: [UserReviewsReportEnabled] { return [.no, .yes]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "User reviews report enabled" } 
    var asBool: Bool { return self == .yes }
}

enum DynamicQuickAnswers: String, BumperFeature  {
    case control, baseline, dynamicNoKeyboard, dynamicWithKeyboard
    static var defaultValue: String { return DynamicQuickAnswers.control.rawValue }
    static var enumValues: [DynamicQuickAnswers] { return [.control, .baseline, .dynamicNoKeyboard, .dynamicWithKeyboard]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Random quick answers with different approaches" } 
    static func fromPosition(_ position: Int) -> DynamicQuickAnswers {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .dynamicNoKeyboard
            case 3: return .dynamicWithKeyboard
            default: return .control
        }
    }
}

enum DefaultRadiusDistanceFeed: String, BumperFeature  {
    case control, baseline, two, five, ten, thirty
    static var defaultValue: String { return DefaultRadiusDistanceFeed.control.rawValue }
    static var enumValues: [DefaultRadiusDistanceFeed] { return [.control, .baseline, .two, .five, .ten, .thirty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Default distance radius main feed." } 
    static func fromPosition(_ position: Int) -> DefaultRadiusDistanceFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .two
            case 3: return .five
            case 4: return .ten
            case 5: return .thirty
            default: return .control
        }
    }
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

enum SearchAutocomplete: String, BumperFeature  {
    case control, baseline, withCategories
    static var defaultValue: String { return SearchAutocomplete.control.rawValue }
    static var enumValues: [SearchAutocomplete] { return [.control, .baseline, .withCategories]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Search suggestions with/without categories filtering." } 
    static func fromPosition(_ position: Int) -> SearchAutocomplete {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .withCategories
            default: return .control
        }
    }
}

enum ShowPriceAfterSearchOrFilter: String, BumperFeature  {
    case control, baseline, priceOnSearchOrFilter
    static var defaultValue: String { return ShowPriceAfterSearchOrFilter.control.rawValue }
    static var enumValues: [ShowPriceAfterSearchOrFilter] { return [.control, .baseline, .priceOnSearchOrFilter]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show price in feed products when user applies any search or filter" } 
    static func fromPosition(_ position: Int) -> ShowPriceAfterSearchOrFilter {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .priceOnSearchOrFilter
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

enum NewBumpUpExplanation: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return NewBumpUpExplanation.control.rawValue }
    static var enumValues: [NewBumpUpExplanation] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show new bump up explanation view" } 
    static func fromPosition(_ position: Int) -> NewBumpUpExplanation {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum HomeRelatedEnabled: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return HomeRelatedEnabled.control.rawValue }
    static var enumValues: [HomeRelatedEnabled] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show the related button in the main feed" } 
    static func fromPosition(_ position: Int) -> HomeRelatedEnabled {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum HideChatButtonOnFeaturedCells: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return HideChatButtonOnFeaturedCells.control.rawValue }
    static var enumValues: [HideChatButtonOnFeaturedCells] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "hide chat button on the featured listing cells" } 
    static func fromPosition(_ position: Int) -> HideChatButtonOnFeaturedCells {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum TaxonomiesAndTaxonomyChildrenInFeed: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return TaxonomiesAndTaxonomyChildrenInFeed.control.rawValue }
    static var enumValues: [TaxonomiesAndTaxonomyChildrenInFeed] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Taxonomies and taxonomy children in feed as filter tags" } 
    static func fromPosition(_ position: Int) -> TaxonomiesAndTaxonomyChildrenInFeed {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum NewItemPage: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return NewItemPage.control.rawValue }
    static var enumValues: [NewItemPage] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "New item page with card appearance and different navigation" } 
    static func fromPosition(_ position: Int) -> NewItemPage {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowPriceStepRealEstatePosting: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowPriceStepRealEstatePosting.control.rawValue }
    static var enumValues: [ShowPriceStepRealEstatePosting] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show price on real estate listing" } 
    static func fromPosition(_ position: Int) -> ShowPriceStepRealEstatePosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowClockInDirectAnswer: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowClockInDirectAnswer.control.rawValue }
    static var enumValues: [ShowClockInDirectAnswer] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show a clock until the message is delivered correctly" } 
    static func fromPosition(_ position: Int) -> ShowClockInDirectAnswer {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum BumpUpPriceDifferentiation: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return BumpUpPriceDifferentiation.control.rawValue }
    static var enumValues: [BumpUpPriceDifferentiation] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Scale bump prices according to listing price" } 
    static func fromPosition(_ position: Int) -> BumpUpPriceDifferentiation {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum PromoteBumpUpAfterSell: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return PromoteBumpUpAfterSell.control.rawValue }
    static var enumValues: [PromoteBumpUpAfterSell] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Show a bump up alert after posting (once every 24h)" } 
    static func fromPosition(_ position: Int) -> PromoteBumpUpAfterSell {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum MoreInfoAFShOrDFP: String, BumperFeature  {
    case control, baseline, afsh, dfp
    static var defaultValue: String { return MoreInfoAFShOrDFP.control.rawValue }
    static var enumValues: [MoreInfoAFShOrDFP] { return [.control, .baseline, .afsh, .dfp]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show ad in more info, could be Adsense for shopping or DFP" } 
    static func fromPosition(_ position: Int) -> MoreInfoAFShOrDFP {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .afsh
            case 3: return .dfp
            default: return .control
        }
    }
}

enum ShowSecurityMeetingChatMessage: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return ShowSecurityMeetingChatMessage.control.rawValue }
    static var enumValues: [ShowSecurityMeetingChatMessage] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show a disclaimer message on chat after the first conversation from the interlocutor" } 
    static func fromPosition(_ position: Int) -> ShowSecurityMeetingChatMessage {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum AllowCallsForProfessionals: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AllowCallsForProfessionals.control.rawValue }
    static var enumValues: [AllowCallsForProfessionals] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Users can call professional sellers" } 
    static func fromPosition(_ position: Int) -> AllowCallsForProfessionals {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RealEstateImprovements: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstateImprovements.control.rawValue }
    static var enumValues: [RealEstateImprovements] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show onboarding improvements on real estate category" } 
    static func fromPosition(_ position: Int) -> RealEstateImprovements {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RealEstatePromos: String, BumperFeature  {
    case control, baseline, deactivate
    static var defaultValue: String { return RealEstatePromos.control.rawValue }
    static var enumValues: [RealEstatePromos] { return [.control, .baseline, .deactivate]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show real estate promos" } 
    static func fromPosition(_ position: Int) -> RealEstatePromos {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .deactivate
            default: return .control
        }
    }
}

enum AllowEmojisOnChat: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return AllowEmojisOnChat.control.rawValue }
    static var enumValues: [AllowEmojisOnChat] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "allow user to write / read emojis" } 
    static func fromPosition(_ position: Int) -> AllowEmojisOnChat {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum ShowAdsInFeedWithRatio: String, BumperFeature  {
    case control, baseline, ten, fifteen, twenty
    static var defaultValue: String { return ShowAdsInFeedWithRatio.control.rawValue }
    static var enumValues: [ShowAdsInFeedWithRatio] { return [.control, .baseline, .ten, .fifteen, .twenty]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "show ads in feed every X cells" } 
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

enum RemoveCategoryWhenClosingPosting: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RemoveCategoryWhenClosingPosting.control.rawValue }
    static var enumValues: [RemoveCategoryWhenClosingPosting] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Remove category real estate if user closes posting" } 
    static func fromPosition(_ position: Int) -> RemoveCategoryWhenClosingPosting {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
        }
    }
}

enum RealEstateNewCopy: String, BumperFeature  {
    case control, baseline, active
    static var defaultValue: String { return RealEstateNewCopy.control.rawValue }
    static var enumValues: [RealEstateNewCopy] { return [.control, .baseline, .active]}
    static var values: [String] { return enumValues.map{$0.rawValue} }
    static var description: String { return "Try real estate copy instead of housing" } 
    static func fromPosition(_ position: Int) -> RealEstateNewCopy {
        switch position { 
            case 0: return .control
            case 1: return .baseline
            case 2: return .active
            default: return .control
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

