//
//  ProfileTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//
import LGCoreKit

protocol ProfileTabNavigator: TabNavigator {
    func openSettings()
    func openEditUserBio()
    func editListing(_ listing: Listing, pageType: EventParameterTypePage?)
    func openVerificationView()
}

protocol SettingsNavigator: class {
    func openEditUserName()
    func openEditEmail()
    func openEditLocation(withDistanceRadius distanceRadius: Int?)
    func openChangePassword()
    func openHelp()
    func closeSettings()
    func open(url: URL)
    func openEditUserBio()
}

protocol ChangeUsernameNavigator: class {
    func closeChangeUsername()
}

protocol ChangeEmailNavigator: class {
    func closeChangeEmail()
}

protocol ChangePasswordNavigator: class {
    func closeChangePassword()
}

protocol EditLocationNavigator: class {
    func closeEditLocation()
}

protocol HelpNavigator: class {
    func closeHelp()
}

protocol EditUserBioNavigator: class {
    func closeEditUserBio()
}

protocol VerifyUserEmailNavigator: class {
    func closeEmailVerification()
}

protocol UserVerificationNavigator: class {
    func closeUserVerification()
    func openEditUserBio()
    func openEmailVerification()
}
