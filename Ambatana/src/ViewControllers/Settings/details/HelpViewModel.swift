//
//  HelpViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 24/09/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//


import LGCoreKit
import DeviceUtil

enum HelpURLType {
    case Terms
    case Privacy
}

protocol HelpViewModelDelegate: class {
    func openURL(url: NSURL)
}

public class HelpViewModel: BaseViewModel {
   
    let myUserRepository: MyUserRepository
    let installationRepository: InstallationRepository
    weak var navigator: HelpNavigator?
    weak var delegate: HelpViewModelDelegate?
    
    convenience override init() {
        self.init(myUserRepository: Core.myUserRepository, installationRepository: Core.installationRepository)
    }
    
    init(myUserRepository: MyUserRepository, installationRepository: InstallationRepository) {
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
    }
    
    override func backButtonPressed() -> Bool {
        navigator?.closeHelp()
        return true
    }
    
    public var url: NSURL? {
        return LetgoURLHelper.buildHelpURL(myUserRepository.myUser, installation: installationRepository.installation)
    }

    var termsAndConditionsURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.termsAndConditionsURL)
    }
    
    var privacyURL: NSURL? {
        return LetgoURLHelper.composeURL(Constants.privacyURL)
    }
    
    func termsButtonPressed() {
        guard let url = termsAndConditionsURL else { return }
        if let navigator = navigator {
            navigator.openURL(url)
        } else {
            delegate?.openURL(url)
        }
    }
    
    func privacyButtonPressed() {
        guard let url = privacyURL else { return }
        if let navigator = navigator {
            navigator.openURL(url)
        } else {
            delegate?.openURL(url)
        }
    }
}
