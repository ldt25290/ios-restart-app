//
//  LGSliderThumb.swift
//  LetGo
//
//  Created by Nestor on 04/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import UIKit


protocol LGSliderDataSource: class {
    func minimumConstraintConstant(sliderThumb: LGSliderThumb) -> CGFloat
    func maximumConstraintConstant(sliderThumb: LGSliderThumb) -> CGFloat
}


class LGSliderThumb {
    static let shadowRadius: CGFloat = 1.5
    private var transformBackUp: CGAffineTransform = CGAffineTransform.identity
    let touchableView = UIView()
    let imageView: UIImageView
    var previousLocationInView = CGPoint.zero
    var constraint = NSLayoutConstraint()
    var isDragging = false {
        didSet {
            if isDragging {
                imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2).concatenating(transformBackUp)
            } else {
                imageView.transform = transformBackUp
            }
        }
    }
    
    weak var dataSource: LGSliderDataSource?
    
    var minimumConstraintConstant: CGFloat {
        return dataSource?.minimumConstraintConstant(sliderThumb: self) ?? 0
    }
    
    var maximumConstraintConstant: CGFloat {
        return dataSource?.maximumConstraintConstant(sliderThumb: self) ?? 0
    }
    
    
    // MARK: - Lifecycle
    
    init(image: UIImage, rotate: Bool = false) {
        touchableView.isUserInteractionEnabled = true
        
        imageView = UIImageView(image: image)
        imageView.layer.masksToBounds = false
        imageView.layer.shadowOffset = CGSize(width: 0,
                                              height: rotate ? -LGSliderThumb.shadowRadius : 
                                                LGSliderThumb.shadowRadius)
        imageView.layer.shadowRadius = LGSliderThumb.shadowRadius
        imageView.layer.shadowOpacity = 0.3
        imageView.transform = rotate ? CGAffineTransform(rotationAngle: .pi) : CGAffineTransform.identity
        
        transformBackUp = imageView.transform
    }
}