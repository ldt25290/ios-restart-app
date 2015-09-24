//
//  KahunaTracker.swift
//  LetGo
//
//  Created by Dídac on 22/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Kahuna

private struct KahunaParams {
    let name: String
    let specificParams: [String:String]?
    
    init(name: String, params: [String:String]?) {
        self.name = name
        self.specificParams = params
    }
    
    func createParams() -> [NSObject:AnyObject] {
        var userAttributes : [NSObject:AnyObject] = [:]

        if let actualParams = specificParams {
            for (key, value) in actualParams {
                userAttributes[key] = value
            }
        }
        
        return userAttributes
    }
}

private extension TrackerEvent {
    var kahunaEvents: KahunaParams? {
        get {
            switch name {
            case .LoginEmail:
                return KahunaParams(name: "login_email", params: ["last_login_type":"login_email"])
            case .LoginFB:
                return KahunaParams(name: "login_fb", params: ["last_login_type":"login_fb"])
            case .SignupEmail:
                return KahunaParams(name: "signup_email", params: ["last_login_type":"signup_email"])
            case .ProductSellComplete:
                return KahunaParams(name: "product_sell_complete", params: nil)
            case .ProductSellStart:
                return KahunaParams(name: "product_sell_start", params: nil)
            default:
                return nil
            }
        }
    }
}

private extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .LoginEmail, .LoginFB, .SignupEmail:
                return true
            case .ProductSellStart:
                return true
            case .ProductSellComplete:
                return true
            default:
                return false
            }
        }
    }
}

private extension TrackerEvent {
    var isSellComplete: Bool {
        get {
            switch name {
            case .ProductSellComplete:
                return true
            default:
                return false
            }
        }
    }
}

public class KahunaTracker: Tracker {
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {

    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
    
    }
    
    public func applicationDidEnterBackground(application: UIApplication) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var userAttributes : Dictionary = Dictionary(dictionaryLiteral:("last_session_end_date", dateFormatter.stringFromDate(NSDate())), ("UUID", ""))
        
        if let userID = MyUserManager.sharedInstance.myUser()?.objectId {
            userAttributes["UUID"] = userID
        }

        Kahuna.setUserAttributes(userAttributes);
        
        Kahuna.trackEvent("session_end");
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        var userAttributes : Dictionary = Dictionary(dictionaryLiteral:("last_session_start_date", dateFormatter.stringFromDate(NSDate())), ("UUID", ""))

        if let userID = MyUserManager.sharedInstance.myUser()?.objectId {
            userAttributes["UUID"] = userID
        }
        
        Kahuna.setUserAttributes(userAttributes)
        
        Kahuna.trackEvent("session_start")
        
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
    
    }
    

    public func setUser(user: User?) {
        
        if let actualUser = user {
            
            var userAttributes : [NSObject:AnyObject] = [:]
            
            let version =  NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
            let language = NSLocale.preferredLanguages()[0] as? String ?? ""

            userAttributes["public_username"] = actualUser.publicUsername ?? ""
            userAttributes["language"] = language
            userAttributes["app_version"] = version
            
            if let latitude = actualUser.gpsCoordinates?.latitude, let longitude = actualUser.gpsCoordinates?.longitude {
                userAttributes["latitude"] = latitude
                userAttributes["longitude"] = longitude
                
                userAttributes["city"] = actualUser.postalAddress.city ?? ""
                userAttributes["country_code"] = actualUser.postalAddress.countryCode ?? ""
            }

            // TODO: kahuna os???
            //sign_in [public_username, city, country, country_code, longitude, latitude, language, app_version, MISSING@Kahuna_OS]

            Kahuna.setUserAttributes(userAttributes)
            Kahuna.trackEvent("sign_in")
            
        } else {
            Kahuna.trackEvent("logout");
        }
    }
    
    public func trackEvent(event: TrackerEvent) {
        if event.shouldTrack {
    
            var userAttributes : [NSObject:AnyObject] = [:]

            if let attributes = event.kahunaEvents?.createParams() {
                userAttributes = attributes
            }
            
            if event.isSellComplete {
                if let productId = event.params?.stringKeyParams["product-id"] as? String {
                    userAttributes["sell_complete_product_id"] = productId
                }

                if let categoryId = event.params?.stringKeyParams["category-id"] as? String {
                    userAttributes["sell_complete_category_id"] = categoryId
                }
            }
            
            Kahuna.setUserAttributes(userAttributes)
            Kahuna.trackEvent(event.name.rawValue)
        }

    }
    
    public func updateCoordinates() {
        
    }
    
}