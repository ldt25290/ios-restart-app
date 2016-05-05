//
//  AppRatingBannerCell.swift
//  LetGo
//
//  Created by Eli Kohen on 05/05/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit

protocol AppRatingBannerDelegate: class {
    func appRatingBannerClose()
    func appRatingBannerShowRating()
}

class AppRatingBannerCell: UICollectionReusableView {

    static var height: CGFloat = 105

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!

    weak var delegate: AppRatingBannerDelegate?

    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupUI() {
        backgroundImage.backgroundColor = StyleHelper.ratingBannerBackgroundColor
        backgroundImage.layer.cornerRadius = StyleHelper.defaultCornerRadius
        textLabel.text = LGLocalizedString.ratingViewTitleLabel
    }

    // MARK: - Actions

    @IBAction func closeButtonPressed(sender: AnyObject) {
        delegate?.appRatingBannerClose()
    }
    
    @IBAction func mainActionPressed(sender: AnyObject) {
        delegate?.appRatingBannerShowRating()
    }
}
