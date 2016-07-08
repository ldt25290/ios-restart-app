//
//  RelationInfoView.swift
//  LetGo
//
//  Created by Dídac on 17/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

public enum ChatInfoViewStatus: Int {

    case Forbidden
    case Blocked
    case BlockedBy
    case ProductDeleted
    case ProductSold
    case Available

    func infoText(otherUserName userName: String?) -> String {
        switch self {
        case .Forbidden:
            if let userName = userName {
                return LGLocalizedString.accountDeactivatedWName(userName)
            } else {
                return LGLocalizedString.accountDeactivated
            }
        case .Blocked:
            if let userName = userName {
                return LGLocalizedString.chatBlockedByMeLabelWName(userName)
            } else {
                return LGLocalizedString.chatBlockedByMeLabel
            }
        case .BlockedBy:
            return LGLocalizedString.chatBlockedByOtherLabel
        case .ProductDeleted:
            return LGLocalizedString.commonProductNotAvailable
        case .ProductSold:
            return LGLocalizedString.chatProductSoldLabel
        case .Available:
            return ""
        }
    }


    var infoTextColor: UIColor {
        return UIColor.whiteColor()
    }

    var bgColor: UIColor {
        switch self {
        case .Forbidden:
            return UIColor.black
        case .Blocked:
            return UIColor.primaryColor
        case .BlockedBy:
            return UIColor.black
        case .ProductDeleted:
            return UIColor.black
        case .ProductSold:
            return UIColor.soldColor
        case .Available:
            return UIColor.clearColor()
        }
    }

    var iconImage: UIImage {
        switch self {
        case .Forbidden:
            return UIImage(named: "ic_alert_yellow_white_inside") ?? UIImage()
        case .Blocked:
            return UIImage(named: "ic_blocked_white") ?? UIImage()
        case .BlockedBy:
            return UIImage(named: "ic_blocked_white_line") ?? UIImage()
        case .ProductDeleted:
            return UIImage(named: "ic_alert_yellow_white_inside") ?? UIImage()
        case .ProductSold:
            return UIImage(named: "ic_sold_white") ?? UIImage()
        case .Available:
            return UIImage()
        }
    }

    var isHidden: Bool {
        switch self {
        case .Forbidden, .Blocked, .BlockedBy, .ProductDeleted, .ProductSold:
            return false
        case .Available:
            return true
        }
    }

    var heightValue: CGFloat {
        switch self {
        case .Forbidden, .Blocked, .BlockedBy, .ProductDeleted, .ProductSold:
            return 28
        case .Available:
            return 0
        }
    }
}

public class RelationInfoView: UIView {

    static let defaultHeight: CGFloat = 28

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var chatInfoIcon: UIImageView!
    @IBOutlet weak var chatInfoLabel: UILabel!

    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    public static func relationInfoView() -> RelationInfoView {
        return NSBundle.mainBundle().loadNibNamed("RelationInfoView", owner: self, options: nil).first as! RelationInfoView
    }

    public init(status: ChatInfoViewStatus, otherUserName: String?, frame: CGRect) {
        super.init(frame: frame)
        setupUIForStatus(status, otherUserName: otherUserName)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupUIForStatus(status: ChatInfoViewStatus, otherUserName: String?) {
        setupBasicUI()

        // Status dependant setup
        heightConstraint.constant = status.heightValue
        backgroundColor = status.bgColor
        chatInfoLabel.textColor = status.infoTextColor
        chatInfoLabel.text = status.infoText(otherUserName: otherUserName)
        chatInfoIcon.image = status.iconImage
    }

    func setupBasicUI() {
        // Non-Status dependant setup
        containerView.backgroundColor = UIColor.clearColor()
        chatInfoLabel.font = UIFont.smallBodyFont
        chatInfoLabel.textAlignment = .Left
        chatInfoIcon.contentMode = .ScaleAspectFill
        chatInfoIcon.clipsToBounds = true
    }
}
