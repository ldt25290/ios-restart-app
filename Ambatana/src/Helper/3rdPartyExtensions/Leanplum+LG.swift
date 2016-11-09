//
//  Leanplum+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 08/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol CustomLeanplumPresenter {
    func showLeanplumAlert(title: String, text: String, image: String, action: UIAction)
}

extension Leanplum {
    
    private static let leamplumCustomPopUp =  "LETGO_POPUP"
    private static let titleIdentifier = "Title"
    private static let messageTextIdentifier = "MessageText"
    private static let imageIdentifier = "Image"
    private static let buttonTextIdentifier = "ButtonText"
    private static let actionIdentifier = "Accept action"
    
    static func customLeanplumAlert(presenter: CustomLeanplumPresenter) {
        
        let argumentTitle = LPActionArg(named: titleIdentifier, withString: "")
        let argumentMessage = LPActionArg(named: messageTextIdentifier, withString: "")
        let argumentImage = LPActionArg(named: imageIdentifier, withFile: nil)
        let argumentButton = LPActionArg(named: buttonTextIdentifier, withString: "")
        let argumentAction = LPActionArg(named: actionIdentifier, withAction: nil)
        let arguments = [argumentTitle, argumentMessage, argumentImage, argumentButton, argumentAction]
        // ofKind: LeanplumActionKind | kLeanplumActionKindAction  need to be set as rawValue.
        Leanplum.defineAction(leamplumCustomPopUp, ofKind: LeanplumActionKind(rawValue: 0b11), withArguments: arguments, withResponder:  { context in
            let okAction = UIAction(interface: .Button(context.stringNamed(buttonTextIdentifier), .Default),
                                    action: { context.runTrackedActionNamed(actionIdentifier) },
                                    accessibilityId: .AcceptPopUpButton)
            presenter.showLeanplumAlert(context.stringNamed(titleIdentifier), text: context.stringNamed(messageTextIdentifier), image: context.fileNamed(imageIdentifier) , action: okAction)
            return true
        })
    }
}