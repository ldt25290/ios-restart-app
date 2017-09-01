//
//  CarouselUIHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 04/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct CarouselUI {
    static let bannerHeight: CGFloat = 64
    static let shareButtonVerticalSpacing: CGFloat = 5
    static let shareButtonHorizontalSpacing: CGFloat = 3

    static let pageControlWidth: CGFloat = 18
    static let pageControlMargin: CGFloat = 18
    static let moreInfoDragMargin: CGFloat = 45
    static let moreInfoExtraHeight: CGFloat = 64
    static let bottomOverscrollDragMargin: CGFloat = 70

    static let itemsMargin: CGFloat = 15
    static let buttonHeight: CGFloat = 50
    static let chatContainerMaxHeight: CGFloat = CarouselUI.buttonHeight + CarouselUI.itemsMargin + DirectAnswersHorizontalView.defaultHeight
    static let buttonTrailingWithIcon: CGFloat = 75
}

class CarouselUIHelper {
    static func setupPageControl(_ pageControl: UIPageControl, topBarHeight: CGFloat) {
        pageControl.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        pageControl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        pageControl.frame.origin = CGPoint(x: CarouselUI.pageControlMargin, y: topBarHeight + CarouselUI.pageControlMargin)
        pageControl.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.hidesForSinglePage = true
        pageControl.layer.cornerRadius = CarouselUI.pageControlWidth/2
        pageControl.clipsToBounds = true
    }

    static func buildShareButton(_ text: String?, icon: UIImage?) -> UIButton {
        let shareButton = UIButton(type: .system)
        setupShareButton(shareButton, text: text, icon: icon)
        return shareButton
    }

    static func setupShareButton(_ shareButton: UIButton, text: String?, icon: UIImage?) {
        shareButton.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                   left: CarouselUI.shareButtonHorizontalSpacing,
                                                   bottom: 0,
                                                   right: -CarouselUI.shareButtonHorizontalSpacing)
        shareButton.contentEdgeInsets = UIEdgeInsets(top: CarouselUI.shareButtonVerticalSpacing,
                                                     left: 2*CarouselUI.shareButtonHorizontalSpacing,
                                                     bottom: CarouselUI.shareButtonVerticalSpacing,
                                                     right: 3*CarouselUI.shareButtonHorizontalSpacing)
        shareButton.setTitle(text, for: .normal)
        shareButton.setTitleColor(UIColor.white, for: .normal)
        shareButton.titleLabel?.font = UIFont.systemSemiBoldFont(size: 15)
        if let imageIcon = icon {
            shareButton.setImage(imageIcon.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        shareButton.tintColor = UIColor.white
        shareButton.sizeToFit()
        shareButton.layer.cornerRadius = shareButton.height/2
        shareButton.layer.backgroundColor = UIColor.blackTextLowAlpha.cgColor
    }

    static func buildMoreInfoTooltipText() -> NSAttributedString {
        let tapTextAttributes: [String : Any] = [NSForegroundColorAttributeName : UIColor.white,
                                                       NSFontAttributeName : UIFont.systemBoldFont(size: 17)]
        let infoTextAttributes: [String : Any] = [ NSForegroundColorAttributeName : UIColor.grayLighter,
                                                         NSFontAttributeName : UIFont.systemSemiBoldFont(size: 17)]
        let plainText = LGLocalizedString.productMoreInfoTooltipPart2(LGLocalizedString.productMoreInfoTooltipPart1)
        let resultText = NSMutableAttributedString(string: plainText, attributes: infoTextAttributes)
        let boldRange = NSString(string: plainText).range(of: LGLocalizedString.productMoreInfoTooltipPart1,
                                                                  options: .caseInsensitive)
        resultText.addAttributes(tapTextAttributes, range: boldRange)
        return resultText
    }
}