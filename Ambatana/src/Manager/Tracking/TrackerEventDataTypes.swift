//
//  TrackerEventDataTypes.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum EventName: String {
    case location                           = "location"
    
    case loginVisit                         = "login-screen"
    case loginAbandon                       = "login-abandon"
    case loginFB                            = "login-fb"
    case loginGoogle                        = "login-google"
    case loginEmail                         = "login-email"
    case signupEmail                        = "signup-email"
    case logout                             = "logout"
    case passwordResetVisit                 = "login-reset-password"
    
    case loginEmailError                    = "login-error"
    case loginFBError                       = "login-signup-error-facebook"
    case loginGoogleError                   = "login-signup-error-google"
    case signupError                        = "signup-error"
    case passwordResetError                 = "password-reset-error"
    case loginBlockedAccountStart           = "login-blocked-account-start"
    case loginBlockedAccountContactUs       = "login-blocked-account-contact-us"
    case loginBlockedAccountKeepBrowsing    = "login-blocked-account-keep-browsing"

    case productList                        = "product-list"
    case productListVertical                = "product-list-vertical"
    case exploreCollection                  = "explore-collection"
    
    case searchStart                        = "search-start"
    case searchComplete                     = "search-complete"
    
    case filterStart                        = "filter-start"
    case filterComplete                     = "filter-complete"
    case filterLocationStart                = "filter-location-start"
    
    case productDetailVisit                 = "product-detail-visit"
    case productDetailVisitMoreInfo         = "product-detail-visit-more-info"
    case productNotAvailable                = "product-not-available"
    
    case productFavorite                    = "product-detail-favorite"
    case productShare                       = "product-detail-share"
    case productShareCancel                 = "product-detail-share-cancel"
    case productShareComplete               = "product-detail-share-complete"
    
    case firstMessage                       = "product-detail-ask-question"
    case productOpenChat                    = "product-detail-open-chat"
    case productMarkAsSold                  = "product-detail-sold"
    case productMarkAsSoldAtLetgo           = "product-detail-sold-at-letgo"
    case productMarkAsSoldOutsideLetgo      = "product-detail-sold-outside-letgo"
    case productMarkAsUnsold                = "product-detail-unsold"
    
    case productReport                      = "product-detail-report"
    
    case productSellStart                   = "product-sell-start"
    case productSellSharedFB                = "product-sell-shared-fb"
    case productSellComplete                = "product-sell-complete"
    case productSellComplete24h             = "product-sell-complete-24h"
    case productSellError                   = "product-sell-error"
    case productSellErrorClose              = "product-sell-error-close"
    case productSellErrorPost               = "product-sell-error-post"
    case productSellErrorData               = "product-sell-error-data"
    case productSellConfirmation            = "product-sell-confirmation"
    case productSellConfirmationPost        = "product-sell-confirmation-post"
    case productSellConfirmationClose       = "product-sell-confirmation-close"
    case productSellConfirmationEdit        = "product-sell-confirmation-edit"
    case productSellConfirmationShare       = "product-sell-confirmation-share"
    case productSellConfirmationShareCancel = "product-sell-confirmation-share-cancel"
    case productSellConfirmationShareComplete = "product-sell-confirmation-share-complete"
    
    case productEditStart                   = "product-edit-start"
    case productEditFormValidationFailed    = "product-edit-form-validation-failed"
    case productEditSharedFB                = "product-edit-shared-fb"
    case productEditComplete                = "product-edit-complete"
    
    case productDeleteStart                 = "product-delete-start"
    case productDeleteComplete              = "product-delete-complete"
    
    case userMessageSent                    = "user-sent-message"
    case userMessageSentError               = "user-sent-message-error"
    case chatRelatedItemsStart              = "chat-related-items-start"
    case chatRelatedItemsComplete           = "chat-related-items-complete"

    case profileVisit                       = "profile-visit"
    case profileEditStart                   = "profile-edit-start"
    case profileEditEditName                = "profile-edit-edit-name"
    case profileEditEditLocationStart       = "profile-edit-edit-location-start"
    case profileEditEditPicture             = "profile-edit-edit-picture"
    case profileReport                      = "profile-report"
    case profileBlock                       = "profile-block"
    case profileUnblock                     = "profile-unblock"
    case profileShareStart                  = "profile-share-start"
    case profileShareComplete               = "profile-share-complete"
    case profileEditEmailStart              = "profile-edit-email-start"
    case profileEditEmailComplete           = "profile-edit-email-complete"

    case appInviteFriendStart               = "app-invite-friend-start"
    case appInviteFriend                    = "app-invite-friend"
    case appInviteFriendCancel              = "app-invite-friend-cancel"
    case appInviteFriendComplete            = "app-invite-friend-complete"
    case appInviteFriendDontAsk             = "app-invite-friend-dont-ask"
    
    case appRatingStart                     = "app-rating-start"
    case appRatingRate                      = "app-rating-rate"
    case appRatingSuggest                   = "app-rating-suggest"
    case appRatingDontAsk                   = "app-rating-dont-ask"
    case appRatingRemindMeLater             = "app-rating-remind-later"

    case permissionAlertStart               = "permission-alert-start"
    case permissionAlertCancel              = "permission-alert-cancel"
    case permissionAlertComplete            = "permission-alert-complete"
    case permissionSystemStart              = "permission-system-start"
    case permissionSystemCancel             = "permission-system-cancel"
    case permissionSystemComplete           = "permission-system-complete"

    case locationMap                        = "location-map"

    case commercializerStart                = "commercializer-start"
    case commercializerError                = "commercializer-error"
    case commercializerComplete             = "commercializer-complete"
    case commercializerOpen                 = "commercializer-open"
    case commercializerShareStart           = "commercializer-share-start"
    case commercializerShareComplete        = "commercializer-share-complete"

    case userRatingStart                    = "user-rating-start"
    case userRatingComplete                 = "user-rating-complete"
    case userRatingReport                   = "user-rating-report"

    case openApp                            = "open-app-external"

    case expressChatStart                   = "express-chat-start"
    case expressChatComplete                = "express-chat-complete"
    case expressChatDontAsk                 = "express-chat-dont-ask"

    case npsStart                           = "nps-start"
    case npsComplete                        = "nps-complete"
    case surveyStart                        = "survey-start"
    case surveyCompleted                    = "survey-completed"

    case verifyAccountStart                 = "verify-account-start"
    case verifyAccountComplete              = "verify-account-complete"

    case inappChatNotificationStart         = "in-app-chat-notification-start"
    case inappChatNotificationComplete      = "in-app-chat-notification-complete"

    case signupCaptcha                      = "signup-captcha"

    case notificationCenterStart            = "notification-center-start"
    case notificationCenterComplete         = "notification-center-complete"

    case marketingPushNotifications         = "marketing-push-notifications"
    
    case passiveBuyerStart                 = "passive-buyer-start"
    case passiveBuyerComplete              = "passive-buyer-complete"
    case passiveBuyerAbandon               = "passive-buyer-abandon"

    case bumpUpStart                        = "bump-up-start"
    case bumpUpComplete                     = "bump-up-complete"
    case chatWindowVisit                     = "chat-window-open"
    
    case emptyStateError                    = "empty-state-error"
    

    // Constants
    private static let eventNameDummyPrefix  = "dummy-"
    
    // Computed iVars
    var actualEventName: String {
        get {
            let eventName: String
            if let isDummyUser = Core.myUserRepository.myUser?.isDummy {
                if isDummyUser {
                    eventName = EventName.eventNameDummyPrefix + rawValue
                }
                else {
                    eventName = rawValue
                }
            }
            else {
                eventName = rawValue
            }
            return eventName
        }
    }
}

enum EventParameterName: String {
    case categoryId           = "category-id"           // 0 if there's no category
    case productId            = "product-id"
    case productCity          = "product-city"
    case productCountry       = "product-country"
    case productZipCode       = "product-zipcode"
    case productLatitude      = "product-lat"
    case productLongitude     = "product-lng"
    case productName          = "product-name"
    case productPrice         = "product-price"
    case productCurrency      = "product-currency"
    case productDescription   = "product-description"
    case productType          = "item-type"             // real (1) / dummy (0).
    case userId               = "user-id"
    case userToId             = "user-to-id"
    case userEmail            = "user-email"
    case userCity             = "user-city"
    case userCountry          = "user-country"
    case userZipCode          = "user-zipcode"
    case searchString         = "search-keyword"
    case searchSuccess        = "search-success"
    case trendingSearch       = "trending-search"
    case description          = "description"           // error description: why form validation failure.
    case loginSource          = "login-type"            // the login source
    case loginRememberedAccount = "existing"
    case locationType         = "location-type"
    case zipCode              = "zipcode"
    case shareNetwork         = "share-network"
    case buttonPosition       = "button-position"
    case locationEnabled      = "location-enabled"
    case locationAllowed      = "location-allowed"
    case buttonName           = "button-name"
    case buttonType           = "button-type"
    case filterLat            = "filter-lat"
    case filterLng            = "filter-lng"
    case filterDistanceRadius = "distance-radius"
    case filterDistanceUnit   = "distance-unit"
    case filterSortBy         = "sort-by"
    case filterPostedWithin   = "posted-within"
    case errorDescription     = "error-description"
    case errorDetails         = "error-details"
    case permissionType       = "permission-type"
    case typePage             = "type-page"
    case alertType            = "alert-type"
    case permissionGoToSettings = "permission-go-to-settings"
    case negotiablePrice      = "negotiable-price"
    case pictureSource        = "picture-source"
    case editedFields         = "edited-fields"
    case newsletter           = "newsletter"
    case quickAnswer          = "quick-answer"
    case reportReason         = "report-reason"
    case tab                  = "tab"
    case template             = "template"
    case userAction           = "user-action"
    case appRatingSource      = "app-rating-source"
    case messageType          = "message-type"
    case ratingStars          = "rating-stars"
    case ratingComments       = "rating-comments"
    case sellerUserRating     = "seller-user-rating"
    case campaign             = "campaign"
    case medium               = "medium"
    case source               = "source"
    case itemPosition         = "item-position"
    case expressConversations = "express-conversations"
    case collectionTitle      = "collection-title"
    case productVisitSource   = "visit-source"
    case numberOfUsers        = "number-of-users"
    case priceFrom            = "price-from"
    case priceTo              = "price-to"
    case npsScore             = "nps-score"
    case accountNetwork       = "account-network"
    case profileType          = "profile-type"
    case notificationType     = "notification-type"
    case notificationClickArea = "notification-click-area"
    case notificationAction   = "notification-action"
    case notificationCampaign = "notification-campaign"
    case shownReason          = "shown-reason"
    case freePosting          = "free-posting"
    case sellButtonPosition   = "sell-button-position"
    case enabled              = "enabled"
    case lastSearch           = "last-search"
    case expressChatTrigger   = "express-chat-trigger"
    case numberPhotosPosting  = "number-photos-posting"
    case bumpUpPrice          = "price"
    case passiveConversations = "passive-conversations"
    case feedPosition         = "feed-position"
    case feedSource           = "feed-source"
    case rating               = "rating"
    case userSoldTo           = "user-sold-to"
    case isBumpedUp           = "bump-up"
    case chatEnabled          = "chat-enabled"
    case reason               = "reason"
    case quickAnswerType      = "quick-answer-type"
    case listSuccess          = "list-success"
    case userFromId           = "user-from-id"
    case notAvailableReason   = "not-available-reason"
    case surveyUrl            = "survey-url"
    case blockButtonPosition  = "block-button-position"
    case postingType          = "posting-type"
    case make                 = "product-make"
    case model                = "product-model"
    case year                 = "product-year"
    case yearStart            = "product-year-start"
    case yearEnd              = "product-year-end"
    case verticalKeyword            = "vertical-keyword"
    case verticalMatchingFields     = "vertical-matching-fields"
    case verticalNoMatchingFields   = "vertical-no-matching-fields"
    case verticalFields             = "vertical-fields"
}

enum EventParameterBoolean: String {
    case trueParameter = "true"
    case falseParameter = "false"
    case notAvailable = "N/A"
}

enum EventParameterLoginSourceValue: String {
    case sell = "posting"
    case chats = "messages"
    case profile = "view-profile"
    case notifications = "notifications"
    case favourite = "favourite"
    case markAsSold = "mark-as-sold"
    case markAsUnsold = "mark-as-unsold"
    case askQuestion = "question"
    case reportFraud = "report-fraud"
    case delete = "delete"
    case install = "install"
    case directChat = "direct-chat"
    case directQuickAnswer = "direct-quick-answer"
}

enum EventParameterProductItemType: String {
    case real = "1"
    case dummy = "0"
}

enum EventParameterButtonNameType: String {
    case close = "close"
    case skip = "skip"
    case done = "done"
    case sellYourStuff = "sell-your-stuff"
    case startMakingCash = "start-making-cash"
}

enum EventParameterButtonType: String {
    case button = "button"
    case itemPicture = "item-picture"
}

enum EventParameterButtonPosition: String {
    case top = "top"
    case bottom = "bottom"
    case bumpUp = "bump-up"
    case none = "N/A"
}

enum EventParameterSellButtonPosition: String {
    case tabBar = "tabbar-camera"
    case floatingButton = "big-button"
    case none = "N/A"
}

enum EventParameterShareNetwork: String {
    case email = "email"
    case facebook = "facebook"
    case whatsapp = "whatsapp"
    case twitter = "twitter"
    case fbMessenger = "facebook-messenger"
    case telegram = "telegram"
    case sms = "sms"
    case copyLink = "copy_link"
    case native = "native"
    case notAvailable = "N/A"
}

enum EventParameterNegotiablePrice: String {
    case yes = "yes"
    case no = "no"
}

enum EventParameterPictureSource: String {
    case camera = "camera"
    case gallery = "gallery"
}

enum EventParameterSortBy: String {
    case distance = "distance"
    case creationDate = "creation-date"
    case priceAsc = "price-asc"
    case priceDesc = "price-desc"
}

enum EventParameterPostedWithin: String {
    case day = "day"
    case week = "week"
    case month = "month"
    case all = ""
}

enum EventParameterPostingType: String {
    case car = "car"
    case stuff = "stuff"
    case none = "N/A"
}

enum EventParameterMake {
    case make(name: String?)
    case none

    var name: String {
        switch self {
        case .make(let name):
            guard let name = name, !name.isEmpty else { return "N/A" }
            return name
        case .none:
            return "N/A"
        }
    }
}

enum EventParameterModel {
    case model(name: String?)
    case none

    var name: String {
        switch self {
        case .model(let name):
            guard let name = name, !name.isEmpty else { return "N/A" }
            return name
        case .none:
            return "N/A"
        }
    }
}

enum EventParameterYear {
    case year(year: Int?)
    case none

    var year: String {
        switch self {
        case .year(let year):
            guard let year = year, year != 0 else { return "N/A" }
            return String(year)
        case .none:
            return "N/A"
        }
    }
}

enum EventParameterMessageType: String {
    case text       = "text"
    case offer      = "offer"
    case sticker    = "sticker"
    case favorite   = "favorite"
    case quickAnswer = "quick-answer"
    case expressChat = "express-chat"
    case periscopeDirect = "periscope-direct"
}

enum EventParameterLoginError {
    
    case network
    case internalError(description: String)
    case unauthorized
    case notFound
    case forbidden
    case invalidEmail
    case nonExistingEmail
    case deviceNotAllowed
    case invalidPassword
    case invalidUsername
    case userNotFoundOrWrongPassword
    case emailTaken
    case passwordMismatch
    case usernameTaken
    case termsNotAccepted
    case tooManyRequests
    case scammer
    case blacklistedDomain
    case badRequest

    var description: String {
        switch self {
        case .network:
            return "Network"
        case .internalError:
            return "Internal"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "NotFound"
        case .forbidden:
            return "Forbidden"
        case .invalidEmail:
            return "InvalidEmail"
        case .nonExistingEmail:
            return "NonExistingEmail"
        case .deviceNotAllowed:
            return "DeviceNotAllowed"
        case .invalidPassword:
            return "InvalidPassword"
        case .invalidUsername:
            return "InvalidUsername"
        case .userNotFoundOrWrongPassword:
            return "UserNotFoundOrWrongPassword"
        case .emailTaken:
            return "EmailTaken"
        case .passwordMismatch:
            return "PasswordMismatch"
        case .usernameTaken:
            return "UsernameTaken"
        case .termsNotAccepted:
            return "TermsNotAccepted"
        case .tooManyRequests:
            return "TooManyRequests"
        case .scammer:
            return "Scammer"
        case .blacklistedDomain:
            return "BlacklistedDomain"
        case .badRequest:
            return "BadRequest"
        }

    }

    var details: String? {
        switch self {
        case let .internalError(description):
            return description
        case .network, .unauthorized, .notFound, .forbidden, .invalidEmail, .nonExistingEmail, .invalidPassword,
             .invalidUsername, .userNotFoundOrWrongPassword, .emailTaken, .passwordMismatch, .usernameTaken,
             .termsNotAccepted, .tooManyRequests, .scammer, .blacklistedDomain, .badRequest, .deviceNotAllowed:
            return nil
        }
    }
}

enum EventParameterPostProductError {
    case network
    case internalError
    case serverError(code: Int?)

    var description: String {
        switch self {
        case .network:
            return "product-sell-network"
        case .internalError:
            return "product-sell-internal"
        case .serverError:
            return "product-sell-server-error"
        }
    }

    var details: Int? {
        switch self {
        case .network, .internalError:
            return nil
        case let .serverError(errorCode):
            return errorCode
        }
    }
}

enum EventParameterChatError {
    case network
    case internalError(description: String?)
    case serverError(code: Int?)

    var description: String {
        switch self {
        case .network:
            return "chat-network"
        case .internalError:
            return "chat-internal"
        case .serverError:
            return "chat-server"
        }
    }

    var details: String? {
        switch self {
        case .network:
            break
        case let .internalError(description):
            return description
        case let .serverError(errorCode):
            if let errorCode = errorCode {
                return String(errorCode)
            }
        }
        return nil
    }
}

enum EventParameterEditedFields: String {
    case picture = "picture"
    case title = "title"
    case price = "price"
    case description = "description"
    case category = "category"
    case location = "location"
    case share = "share"
    case freePosting = "free-posting"
    case make = "make"
    case model = "model"
    case year = "year"
}

enum EventParameterTypePage: String {
    case productList = "product-list"
    case productListBanner = "product-list-banner"
    case chat = "chat"
    case tabBar = "tab-bar"
    case chatList = "chat-list"
    case sell = "product-sell"
    case edit = "product-edit"
    case productDetail = "product-detail"
    case productDetailMoreInfo = "product-detail-more-info"
    case settings = "settings"
    case install = "install"
    case profile = "profile"
    case commercializerPlayer = "commercializer-player"
    case commercializerPreview = "commercializer-preview"
    case pushNotification = "push-notification"
    case email = "email"
    case onboarding = "onboarding"
    case external = "external"
    case notifications = "notifications"
    case openApp = "open-app"
    case incentivizePosting = "incentivize-posting"
    case userRatingList = "user-rating-list"
    case expressChat = "express-chat"
    case productDelete = "product-delete"
    case productSold = "product-sold"
    case inAppNotification = "in-app-notification"
}

enum EventParameterPermissionType: String {
    case push = "push-notification"
    case location = "gps"
    case camera = "camera"
}

enum EventParameterPermissionAlertType: String {
    case custom = "custom"
    case nativeLike = "native-alike"
    case fullScreen = "full-screen"
}

enum EventParameterTab: String {
    case selling = "selling"
    case sold = "sold"
    case favorites = "favorites"
}

enum EventParameterSearchCompleteSuccess: String {
    case success = "yes"
    case fail = "no"
}

enum EventParameterReportReason: String {
    case offensive = "offensive"
    case scammer = "scammer"
    case mia = "mia"
    case suspicious = "suspicious"
    case inactive = "inactive"
    case prohibitedItems = "prohibited-items"
    case spammer = "spammer"
    case counterfeitItems = "counterfeit-items"
    case other = "other"
}

enum EventParameterCommercializerError: String {
    case network = "commercializer-network"
    case internalError = "commercializer-internal"
    case duplicated = "commercializer-duplicated"
}

enum ProductVisitUserAction: String {
    case tap = "tap"
    case swipeLeft = "swipe-left"
    case swipeRight = "swipe-right"
    case none = "N/A"
}

enum EventParameterRatingSource: String {
    case chat = "chat"
    case productSellComplete = "product-sell-complete"
    case markedSold = "marked-sold"
    case favorite = "favorite"
}

enum EventParameterProductVisitSource: String {
    case productList = "product-list"
    case moreInfoRelated = "more-info-related"
    case collection = "collection"
    case search = "search"
    case filter = "filter"
    case searchAndFilter = "search & filter"
    case category = "category"
    case profile = "profile"
    case chat = "chat"
    case openApp = "open-app"
    case notifications = "notifications"
    case unknown = "N/A"
}


enum EventParameterFeedPosition {
    case position(index: Int)
    case none
    
    var value: String {
        switch self {
        case let .position(index):
            let value = index + 1
            return String(value)
        case .none:
            return "N/A"
        }
    }
}

enum EventParameterFeedSource: String {
    case home = "home"
    case search = "search"
    case filter = "filter"
    case searchAndFilter = "search&filter"
    case collection = "collection"
}

enum EventParameterAccountNetwork: String {
    case facebook = "facebook"
    case google = "google"
    case email = "email"
}

enum EventParameterBlockedAccountReason: String {
    case secondDevice = "second-device"
    case accountUnderReview = "account-under-review"
}

enum EventParameterProfileType: String {
    case publicParameter = "public"
    case privateParameter = "private"
}

enum EventParameterNotificationType: String {
    case favorite = "favorite"
    case productSold = "favorite-sold"
    case rating = "rating"
    case ratingUpdated = "rating-updated"
    case buyersInterested = "passive-buyer-seller"
    case productSuggested = "passive-buyer-make-offer"
    case facebookFriendshipCreated = "facebook-friendship-created"
    case modular = "modular"
}

enum EventParameterNotificationClickArea: String {
    case basicImage = "basic-image"
    case heroImage = "hero-image"
    case text = "text"
    case thumbnail1 = "thumbnail-1"
    case thumbnail2 = "thumbnail-2"
    case thumbnail3 = "thumbnail-3"
    case thumbnail4 = "thumbnail-4"
    case cta1 = "cta-1"
    case cta2 = "cta-2"
    case cta3 = "cta-3"
    case main = "main"
    case unknown = "N/A"
}

enum EventParameterNotificationAction: String {
    case home = "product-list"
    case sell = "product-sell-start"
    case product = "product-detail-visit"
    case user = "profile-visit"
    case conversations = "conversations"
    case conversation = "conversation"
    case message = "message"
    case search = "search"
    case resetPassword = "reset-password"
    case userRatings = "user-ratings"
    case userRating = "user-rating"
    case passiveBuyers = "passive-buyers"
    case unknown = "N/A"
}

enum EventParameterRelatedShownReason: String {
    case productSold = "product-sold"
    case productDeleted = "product-deleted"
    case userDeleted = "user-deleted"
    case unanswered48h = "unanswered-48h"
    case forbidden = "forbidden"

    init(chatInfoStatus: ChatInfoViewStatus) {
        switch chatInfoStatus {
        case .forbidden:
            self = .forbidden
        case .blocked, .blockedBy:
            self = .unanswered48h
        case .productDeleted:
            self = .productDeleted
        case .productSold:
            self = .productSold
        case .userPendingDelete, .userDeleted:
            self = .userDeleted
        case .available:
            self = .unanswered48h
        }
    }
}

enum EventParameterExpressChatTrigger: String {
    case automatic = "automatic"
    case manual = "manual"
}

enum EventParameterBumpUpPrice {
    case free
    case pay(price: String)

    var description: String {
        switch self {
        case .free:
            return "free"
        case let .pay(price):
            return price
        }
    }
}

enum EventParameterEmptyReason: String {
    case noInternetConection = "no-internet-connection"
    case serverError         = "server-error"
    case emptyResults        = "empty-results"
    case unknown             = "unknown"
    case verification        = "verification"
}

enum EventParameterQuickAnswerType: String {
    case interested = "interested"
    case notInterested = "not-interested"
    case meetUp = "meet-up"
    case stillAvailable = "still-available"
    case isNegotiable = "is-negotiable"
    case likeToBuy = "like-to-buy"
    case productCondition = "condition"
    case productStillForSale = "still-for-sale"
    case productSold = "sold"
    case whatsOffer = "whats-offer"
    case negotiableYes = "negotiable-yes"
    case negotiableNo = "negotiable-no"
    case freeStillHave = "free-still-have"
    case freeYours = "free-yours"
    case freeAvailable = "free-available"
    case freeNotAvailable = "free-not-available"
}

enum EventParameterNotAvailableReason: String {
    
    case internalError       = "internal-error"
    case notFound            = "not-found"
    case unauthorized        = "unauthorized"
    case forbidden           = "forbidden"
    case tooManyRequests     = "too-many-requests"
    case userNotVerified     = "user-not-verified"
    case serverError         = "server-error"
    case network             = "network"
    
}

enum EventParameterBlockButtonPosition: String {
    case threeDots          = "three-dots"
    case safetyPopup        = "safety-popup"
    case others             = "N/A"
}

enum EventParamenterLocationTypePage: String {
    case filter     = "filter"
    case profile    = "profile"
    case feedBubble = "feed-bubble"
    case automatic  = "automatic"
}

struct EventParameters {
    private var params: [EventParameterName : Any] = [:]
    
    // transforms the params to [String: Any]
    var stringKeyParams: [String: Any] {
        get {
            var res = [String: Any]()
            for (paramName, value) in params {
                res[paramName.rawValue] = value
            }
            return res
        }
    }
    
    internal mutating func addLoginParams(_ source: EventParameterLoginSourceValue, rememberedAccount: Bool? = nil) {
        params[.loginSource] = source.rawValue
        params[.loginRememberedAccount] = rememberedAccount
    }
    
    internal mutating func addProductParams(_ product: Product) {
        params[.productId] = product.objectId
        params[.productLatitude] = product.location.latitude
        params[.productLongitude] = product.location.longitude
        params[.productPrice] = product.price.value
        params[.productCurrency] = product.currency.code
        params[.categoryId] = product.category.rawValue
        params[.productType] = product.user.isDummy ?
            EventParameterProductItemType.dummy.rawValue : EventParameterProductItemType.real.rawValue
        params[.userToId] = product.user.objectId
    }

    internal mutating func addListingParams(_ listing: Listing) {
        params[.productId] = listing.objectId
        params[.productLatitude] = listing.location.latitude
        params[.productLongitude] = listing.location.longitude
        params[.productPrice] = listing.price.value
        params[.productCurrency] = listing.currency.code
        params[.categoryId] = listing.category.rawValue
        params[.productType] = listing.user.isDummy ?
            EventParameterProductItemType.dummy.rawValue : EventParameterProductItemType.real.rawValue
        params[.userToId] = listing.user.objectId
    }

    internal mutating func addChatListingParams(_ listing: ChatListing) {
        params[.productId] = listing.objectId
        params[.productPrice] = listing.price.value
        params[.productCurrency] = listing.currency.code
        params[.productType] = EventParameterProductItemType.real.rawValue
    }

    internal subscript(paramName: EventParameterName) -> Any? {
        get {
            return params[paramName]
        }
        set(newValue) {
            params[paramName] = newValue
        }
    }
}
