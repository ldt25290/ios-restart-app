//
//  ConfigurationManager.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 05/02/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

// private singleton instance
private let _singletonInstance = ConfigurationManager()

/**
 * The ConfigurationManager is in charge of handling the configuration of the user, including his/her data and profile picture.
 * It also handles the user-specified settings for the application.
 * ConfigurationManager follows the Singleton pattern, so it's accessed by means of the shared method sharedInstance().
 */
class ConfigurationManager: NSObject {
    // data
    var userName: String = translate("user")
    var userLocation: String = ""
    var userEmail: String = ""
    var userProfileImage: UIImage?
    var currentFilterForSearch: String? = "createdAt"
    var currentFilterOrderForSearch: NSComparisonResult = .OrderedDescending
    
    /** Shared instance */
    class var sharedInstance: ConfigurationManager {
        return _singletonInstance
    }

    // MARK: - Setting and reading user's profile data
    
    // loads the initial facebook profile data in the user's profile
    func loadInitialFacebookProfileData() {
        if let currentUser = PFUser.currentUser() {
            let fbRequest = FBRequest.requestForMe()
            fbRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if let userData = result as? NSDictionary {
                    // start filling user profile data.
                    //println("Datos de Facebook: \(userData)")
                    
                    // user name
                    let firstName = userData["first_name"] as? String
                    let lastName = userData["last_name"] as? String
                    if firstName != nil && lastName != nil {
                        let lastNameInitial: String = countElements(lastName!) > 0 ? lastName!.substringToIndex(advance(lastName!.startIndex, 1)) : ""
                        currentUser["username_public"] = "\(firstName!) \(lastNameInitial)."
                        self.userName = "\(firstName!) \(lastNameInitial)."
                    } else {
                        if let userName = userData["name"] as? NSString {
                            currentUser["username_public"] = userName
                            self.userName = userName
                        }
                    }
                    
                    // user location
                    /*
                    if let userLocation = userData.objectForKey("location") as? NSDictionary {
                        if let userLocationName = userLocation.objectForKey("name") as? NSString {
                            let components = userLocationName.componentsSeparatedByString(",")
                            if let first = components[0] as? NSString {
                                currentUser["city"] = first
                                self.userLocation = first
                            }
                        }
                    }
                    */
                    
                    // user email
                    if let userEmail = userData["email"] as? NSString {
                        currentUser["username"] = userEmail
                        currentUser["email"] = userEmail
                        self.userEmail = userEmail
                    }
                    
                    // user picture & facebookID
                    let facebookId: String = userData["id"] as String
                    let userPictureURL = "https://graph.facebook.com/\(facebookId)/picture?type=large&return_ssl_resources=1"
                    self.setUserPictureFromURL(userPictureURL)
                    
                    // save user profile
                    currentUser.saveInBackgroundWithBlock(nil)
                    self.checkIfInstallationNeedsToBeUpdatedWithCurrentUserData()
                } else { // error
                    var oauthSessionExpired = false
                    if error != nil {
                        if let userInfo = error!.userInfo {
                            if let errorType = userInfo["type"] as? String {
                                if errorType == "OAuthException" {
                                    oauthSessionExpired = true
                                }
                            }
                        }
                    }
                    if oauthSessionExpired { // logout
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaSessionInvalidatedNotification, object: nil)
                    } else { // notify error
                        NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaInvalidCredentialsNotification, object: nil)
                    }
                }
            })
        }
    }
    
    func logOutUser() {
        userName = translate("user")
        userLocation = ""
        userEmail = ""
        userProfileImage = nil
    }
    
    // loads the user data from the already configured & authenticated PFUser
    func loadDataFromCurrentUser() {
        // name
        if let userName = PFUser.currentUser()["username_public"] as? String { self.userName = userName }
        // user email
        if let userEmail = PFUser.currentUser()["email"] as? String { self.userEmail = userEmail }
        // user location
        if let userLocation = PFUser.currentUser()["city"] as? String { self.userLocation = userLocation }
        // profile picture
        if let avatarFile = PFUser.currentUser()["avatar"] as? PFFile {
            avatarFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil && data != nil { // success
                    let updatedImage = UIImage(data: data)
                    self.userProfileImage = updatedImage
                    NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaUserPictureUpdatedNotification, object: updatedImage)
                }
            })
        }
        checkIfInstallationNeedsToBeUpdatedWithCurrentUserData()
    }
    
    // checks if we need to update the installation data, linking it with our current user information.
    func checkIfInstallationNeedsToBeUpdatedWithCurrentUserData() {
        var installationModified = false
        if PFUser.currentUser() != nil && PFInstallation.currentInstallation() != nil { // associate installation and user.
            PFInstallation.currentInstallation()["user_objectId"] = PFUser.currentUser().objectId
            if let installationUsername = PFUser.currentUser()["username"] as? String {
                PFInstallation.currentInstallation()["username"] = installationUsername
            }
            installationModified = true
        }
        if installationModified {
            PFInstallation.currentInstallation().saveInBackgroundWithBlock(nil)
        }
        // once we know that we have been logged in and we have updated the user data, is a good moment for retrieving the currency list.
        CurrencyManager.sharedInstance.refreshCurrenciesFromBackend()
    }
    
    // loads the picture from a URL
    func setUserPictureFromURL(urlAsString: String) {
        if let url = NSURL(string: urlAsString) {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                if error == nil && data != nil { // success
                    let updatedImage = UIImage(data: data)
                    
                    // update user image in Parse
                    let parseImage: PFFile = PFFile(data: data)
                    PFUser.currentUser()["avatar"] = parseImage
                    PFUser.currentUser().saveInBackgroundWithBlock(nil)
                    
                    // update image in local interface.
                    self.userProfileImage = updatedImage
                    NSNotificationCenter.defaultCenter().postNotificationName(kAmbatanaUserPictureUpdatedNotification, object: updatedImage)
                    
                    
                }
            })
        }
    }
    
}













