#import <UIKit/UIKit.h>

#import "AirshipLib.h"
#import "UANativeBridge.h"
#import "UALandingPageAction.h"
#import "NSJSONSerialization+UAAdditions.h"
#import "NSString+UAURLEncoding.h"
#import "UAAction+Operators.h"
#import "UAAction.h"
#import "UAActionArguments.h"
#import "UAActionJSDelegate.h"
#import "UAActionRegistry.h"
#import "UAActionRegistryEntry.h"
#import "UAActionResult.h"
#import "UAActionRunner.h"
#import "UAActivityViewController.h"
#import "UAAddCustomEventAction.h"
#import "UAAddTagsAction.h"
#import "UAAggregateActionResult.h"
#import "UAAnalytics.h"
#import "UAAnalyticsDBManager.h"
#import "UAApplicationMetrics.h"
#import "UABaseLocationProvider.h"
#import "UABespokeCloseView.h"
#import "UABeveledLoadingIndicator.h"
#import "UAChannelCapture.h"
#import "UACircularRegion.h"
#import "UACloseWindowAction.h"
#import "UAColorUtils.h"
#import "UAConfig.h"
#import "UACustomEvent.h"
#import "UADelayOperation.h"
#import "UADisplayInboxAction.h"
#import "UADisposable.h"
#import "UAEvent.h"
#import "UAEventAppBackground.h"
#import "UAEventAppExit.h"
#import "UAEventAppForeground.h"
#import "UAEventAppInit.h"
#import "UAEventDeviceRegistration.h"
#import "UAEventPushReceived.h"
#import "UAGlobal.h"
#import "UAHTTPConnection.h"
#import "UAHTTPConnectionOperation.h"
#import "UAHTTPRequest.h"
#import "UAHTTPRequestEngine.h"
#import "UAInAppDisplayEvent.h"
#import "UAInAppMessage.h"
#import "UAInAppMessageButtonActionBinding.h"
#import "UAInAppMessageController.h"
#import "UAInAppMessageControllerDefaultDelegate.h"
#import "UAInAppMessageControllerDelegate.h"
#import "UAInAppMessageView.h"
#import "UAInAppMessaging.h"
#import "UAInAppResolutionEvent.h"
#import "UAIncomingInAppMessageAction.h"
#import "UAIncomingPushAction.h"
#import "UAInteractiveNotificationEvent.h"
#import "UAirship.h"
#import "UAJavaScriptDelegate.h"
#import "UAKeychainUtils.h"
#import "UALandingPageOverlayController.h"
#import "UALocationCommonValues.h"
#import "UALocationEvent.h"
#import "UALocationProviderDelegate.h"
#import "UALocationProviderProtocol.h"
#import "UALocationService.h"
#import "UAModifyTagsAction.h"
#import "UAOpenExternalURLAction.h"
#import "UAOverlayInboxMessageAction.h"
#import "UAPasteboardAction.h"
#import "UAPreferenceDataStore.h"
#import "UAProximityRegion.h"
#import "UARegionEvent.h"
#import "UARemoveTagsAction.h"
#import "UARichContentWindow.h"
#import "UAShareAction.h"
#import "UASignificantChangeProvider.h"
#import "UAStandardLocationProvider.h"
#import "UATagUtils.h"
#import "UAURLProtocol.h"
#import "UAUser.h"
#import "UAUserAPIClient.h"
#import "UAUserData.h"
#import "UAUtils.h"
#import "UAWalletAction.h"
#import "UAWebViewCallData.h"
#import "UAWebViewDelegate.h"
#import "UAWhitelist.h"
#import "UIWebView+UAAdditions.h"
#import "UA_Base64.h"
#import "UAInbox.h"
#import "UAInboxAPIClient.h"
#import "UAInboxMessage.h"
#import "UAInboxMessageData.h"
#import "UAInboxMessageList.h"
#import "UAInboxPushHandler.h"
#import "UAInboxUtils.h"
#import "UAJSONValueTransformer.h"
#import "UAChannelAPIClient.h"
#import "UAChannelRegistrar.h"
#import "UAChannelRegistrationPayload.h"
#import "UAMutableUserNotificationAction.h"
#import "UAMutableUserNotificationCategory.h"
#import "UANamedUser.h"
#import "UANamedUserAPIClient.h"
#import "UAPush.h"
#import "UATagGroupsAPIClient.h"
#import "UAUserNotificationAction.h"
#import "UAUserNotificationCategories.h"
#import "UAUserNotificationCategory.h"
#import "NSString+UALocalization.h"
#import "NSString+UASizeWithFontCompatibility.h"
#import "UACommon.h"
#import "UADateUtils.h"
#import "UAInboxAlertHandler.h"
#import "UAInboxLocalization.h"
#import "UAInboxMessageListCell.h"
#import "UAInboxMessageListController.h"
#import "UAInboxMessageViewController.h"
#import "UALocationDemoAnnotation.h"
#import "UALocationSettingsViewController.h"
#import "UAMapPresentationController.h"
#import "UAPushLocalization.h"
#import "UAPushMoreSettingsViewController.h"
#import "UAPushNotificationHandler.h"
#import "UAPushSettingsAddTagViewController.h"
#import "UAPushSettingsAliasViewController.h"
#import "UAPushSettingsNamedUserViewController.h"
#import "UAPushSettingsSoundsViewController.h"
#import "UAPushSettingsTagsViewController.h"
#import "UAPushSettingsViewController.h"
#import "UA-UI-Bridging-Header.h"

FOUNDATION_EXPORT double UrbanAirship_iOS_SDKVersionNumber;
FOUNDATION_EXPORT const unsigned char UrbanAirship_iOS_SDKVersionString[];

