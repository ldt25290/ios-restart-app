//
//  PostProductWhiteCamButtonFooter.swift
//  LetGo
//
//  Created by Albert Hernández López on 08/03/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit

final class PostProductWhiteCamButtonFooter: UIView {
    fileprivate static let maxSideCameraIcon: CGFloat = 84
    fileprivate static let minSideCameraIcon: CGFloat = 50
    fileprivate static let rightMarginCameraIcon: CGFloat = 15.0
    
    let galleryButton = UIButton()
    let cameraButton = UIButton()
    fileprivate var cameraButtonCenterXConstraint: NSLayoutConstraint?
    fileprivate var cameraButtonWidthConstraint: NSLayoutConstraint?
    
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - PostProductFooter

extension PostProductWhiteCamButtonFooter: PostProductFooter {
    func updateCameraButton(isHidden: Bool) {
        cameraButton.isHidden = isHidden
    }
    
    func update(scroll: CGFloat) {
        galleryButton.alpha = scroll
        
        let rightOffset = cameraButton.frame.width/2 + PostProductWhiteCamButtonFooter.rightMarginCameraIcon
        let movement = width/2 - rightOffset
        cameraButtonCenterXConstraint?.constant = movement * (1.0 - scroll)
        cameraButtonWidthConstraint?.constant = PostProductWhiteCamButtonFooter.maxSideCameraIcon -
            (PostProductWhiteCamButtonFooter.maxSideCameraIcon - PostProductWhiteCamButtonFooter.minSideCameraIcon) * (1.0 - scroll)
    }
}


// MARK: - Private methods

fileprivate extension PostProductWhiteCamButtonFooter {
    func setupUI() {
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.setImage(#imageLiteral(resourceName: "ic_post_gallery"), for: .normal)
        addSubview(galleryButton)
        
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setBackgroundImage(#imageLiteral(resourceName: "ic_post_take_photo_white"), for: .normal)
        addSubview(cameraButton)
    }
    
    func setupAccessibilityIds() {
        galleryButton.accessibilityId = .postingGalleryButton
        cameraButton.accessibilityId = .postingPhotoButton
    }
    
    func setupLayout() {
        galleryButton.layout(with: self)
            .leading()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        galleryButton.layout().width(70).widthProportionalToHeight()
        
        cameraButton.layout(with: self)
            .centerX(constraintBlock: { [weak self] constraint in self?.cameraButtonCenterXConstraint = constraint })
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -15)
        cameraButton.layout()
            .width(PostProductWhiteCamButtonFooter.maxSideCameraIcon, constraintBlock: { [weak self] constraint in
                self?.cameraButtonWidthConstraint = constraint
            })
            .widthProportionalToHeight()
    }
}
