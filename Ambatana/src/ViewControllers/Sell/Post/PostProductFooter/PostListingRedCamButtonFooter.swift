import UIKit
import LGComponents

final class PostListingRedCamButtonFooter: UIView {
    static let galleryIconSide: CGFloat = 70
    static let cameraIconSide: CGFloat = 84
    
    let galleryButton = UIButton()
    let photoButton = UIButton()
    let videoButton = UIButton()
    let cameraButton = UIButton()
    let infoButton = UIButton()
    private let infoButtonIncluded: Bool
    fileprivate var cameraButtonCenterXConstraint: NSLayoutConstraint?
    
    
    // MARK: - Lifecycle
    
    init(infoButtonIncluded: Bool) {
        self.infoButtonIncluded = infoButtonIncluded
        super.init(frame: CGRect.zero)
        
        setupUI()
        setupAccessibilityIds()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {       
        return [galleryButton, cameraButton, infoButton].flatMap { $0 }.reduce(false) { (result, view) -> Bool in
            let convertedPoint = view.convert(point, from: self)
            return result || (!view.isHidden && view.point(inside: convertedPoint, with: event))
        }
    }
}


// MARK: - PostListingFooter

extension PostListingRedCamButtonFooter: PostListingFooter {
    
    func startRecording() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func stopRecording() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func updateToPhotoMode() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func updateToVideoMode() {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }

    func update(scroll: CGFloat) {
        galleryButton.alpha = scroll
        infoButton.alpha = scroll
        
        let rightOffset = cameraButton.frame.width/2 + Metrics.margin
        let movement = width/2 - rightOffset
        cameraButtonCenterXConstraint?.constant = movement * (1.0 - scroll)
    }

    func updateVideoRecordingDurationProgress(progress: CGFloat, remainingTime: TimeInterval) {
        // This view doesn't implement video posting, check VPPostListingRedCamFooter
    }
}


// MARK: - Private methods

fileprivate extension PostListingRedCamButtonFooter {
    func setupUI() {
        galleryButton.setImage(R.Asset.IconsButtons.icPostGallery.image, for: .normal)
        
        cameraButton.setImage(R.Asset.IconsButtons.icPostTakePhotoIcon.image, for: .normal)
        cameraButton.setBackgroundImage(R.Asset.IconsButtons.icPostTakePhoto.image, for: .normal)
        
        infoButton.setImage(R.Asset.IconsButtons.info.image, for: .normal)
        addSubviewsForAutoLayout([galleryButton, cameraButton, infoButton])
    }
    
    func setupAccessibilityIds() {
        galleryButton.set(accessibilityId: .postingGalleryButton)
        cameraButton.set(accessibilityId: .postingPhotoButton)
        infoButton.set(accessibilityId: .postingInfoButton)
    }
    
    func setupLayout() {
        infoButton.layout(with: self)
            .trailing()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        infoButton.layout()
            .width(PostListingRedCamButtonFooter.galleryIconSide)
            .widthProportionalToHeight()
        
        galleryButton.layout(with: self)
            .leading()
            .top(relatedBy: .greaterThanOrEqual)
            .bottom()
        galleryButton.layout()
            .width(PostListingRedCamButtonFooter.galleryIconSide)
            .widthProportionalToHeight()
        
        cameraButton.layout(with: self)
            .centerX(constraintBlock: { [weak self] constraint in self?.cameraButtonCenterXConstraint = constraint })
            .top(relatedBy: .greaterThanOrEqual)
            .bottom(by: -Metrics.margin)
        cameraButton.layout().width(PostListingRedCamButtonFooter.cameraIconSide).widthProportionalToHeight()
        
        infoButton.isHidden = !infoButtonIncluded
    }
}
