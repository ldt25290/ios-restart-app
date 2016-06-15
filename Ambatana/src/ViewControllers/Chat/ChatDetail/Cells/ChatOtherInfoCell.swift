//
//  ChatOtherInfoCell.swift
//  LetGo
//
//  Created by Eli Kohen on 14/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

class ChatOtherInfoCell: UITableViewCell, ReusableCell {

    @IBOutlet weak var userInfoContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verifyIcon: UIImageView!
    @IBOutlet weak var verifyIconHeight: NSLayoutConstraint!
    @IBOutlet weak var verifyIconTop: NSLayoutConstraint!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var verifyContainer: UIView!
    @IBOutlet weak var fbIconWidth: NSLayoutConstraint!
    @IBOutlet weak var googleIconWidth: NSLayoutConstraint!
    @IBOutlet weak var mailIconWidth: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!

    private static let iconsMargin: CGFloat = 8
    private static let verifyIconHeight: CGFloat = 14
    private static let verifyIconsWidth: CGFloat = 20


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
}


// MARK: - Public

extension ChatOtherInfoCell {
    func setupVerifiedInfo(facebook facebook: Bool, google: Bool, email: Bool) {
        guard facebook || google || email else {
            verifyIconTop.constant = 0
            verifyIconHeight.constant = 0
            verifyLabel.hidden = true
            verifyContainer.hidden = true
            return
        }
        verifyIconTop.constant = ChatOtherInfoCell.iconsMargin
        verifyIconHeight.constant = ChatOtherInfoCell.verifyIconHeight
        verifyLabel.hidden = false
        verifyContainer.hidden = false

        fbIconWidth.constant = facebook ? ChatOtherInfoCell.verifyIconsWidth : 0
        googleIconWidth.constant = google ? ChatOtherInfoCell.verifyIconsWidth : 0
        mailIconWidth.constant = email ? ChatOtherInfoCell.verifyIconsWidth : 0
    }
}


// MARK: - Private

private extension ChatOtherInfoCell {
    func setupUI() {
        userInfoContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        StyleHelper.applyDefaultShadow(userInfoContainer.layer)
        userInfoContainer.layer.shouldRasterize = true
        userInfoContainer.layer.rasterizationScale = UIScreen.mainScreen().scale
    }
}
