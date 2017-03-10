//
//  PostProductViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 11/12/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import RxSwift

class PostProductViewController: BaseViewController, PostProductViewModelDelegate {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var cameraGalleryContainer: UIView!
    @IBOutlet weak var selectPriceContainer: UIView!
    @IBOutlet weak var customLoadingView: LoadingIndicator!
    @IBOutlet weak var postedInfoLabel: UILabel!
    @IBOutlet weak var detailsScroll: UIScrollView!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var postErrorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    fileprivate var productDetailView: UIView

    fileprivate var viewPager: LGViewPager
    fileprivate var cameraView: PostProductCameraView
    fileprivate var galleryView: PostProductGalleryView
    fileprivate var footer: PostProductFooter
    fileprivate var footerView: UIView
    fileprivate let gradientView = UIView()
    fileprivate let gradientLayer = CAGradientLayer.gradientWithColor(UIColor.black,
                                                                      alphas: [0, 0.4],
                                                                      locations: [0, 1])
    fileprivate let keyboardHelper: KeyboardHelper
    fileprivate let postingGallery: PostingGallery
    private var viewDidAppear: Bool = false

    fileprivate static let detailTopMarginPrice: CGFloat = 100

    private let forceCamera: Bool
    private var initialTab: Int {
        if forceCamera { return 1 }
        return KeyValueStorage.sharedInstance.userPostProductLastTabSelected
    }

    private let disposeBag = DisposeBag()


    // ViewModel
    fileprivate var viewModel: PostProductViewModel


    // MARK: - Lifecycle

    convenience init(viewModel: PostProductViewModel,
                     forceCamera: Bool) {
        self.init(viewModel: viewModel,
                  forceCamera: forceCamera,
                  keyboardHelper: KeyboardHelper.sharedInstance,
                  postingGallery: FeatureFlags.sharedInstance.postingGallery)
    }

    required init(viewModel: PostProductViewModel,
                  forceCamera: Bool,
                  keyboardHelper: KeyboardHelper,
                  postingGallery: PostingGallery) {
        
        let tabPosition: LGViewPagerTabPosition
        let topRightButtonIsUsePhoto: Bool
        switch postingGallery {
        case .singleSelection, .multiSelection:
            tabPosition = .hidden
            let postFooter = PostProductRedCamButtonFooter()
            self.footer = postFooter
            self.footerView = postFooter
            topRightButtonIsUsePhoto = true
        case .multiSelectionWhiteButton:
            tabPosition = .hidden
            let postFooter = PostProductWhiteCamButtonFooter()
            self.footer = postFooter
            self.footerView = postFooter
            topRightButtonIsUsePhoto = true
        case .multiSelectionTabs:
            tabPosition = .bottom(tabsOverPages: true)
            let postFooter = PostProductTabsFooter()
            self.footer = postFooter
            self.footerView = postFooter
            topRightButtonIsUsePhoto = true
        case .multiSelectionPostBottom:
            tabPosition = .hidden
            let postFooter = PostProductPostFooter()
            self.footer = postFooter
            self.footerView = postFooter
            topRightButtonIsUsePhoto = false
        }
        
        let viewPagerConfig = LGViewPagerConfig(tabPosition: tabPosition, tabLayout: .fixed, tabHeight: 50)
        self.viewPager = LGViewPager(config: viewPagerConfig, frame: CGRect.zero)
        self.cameraView = PostProductCameraView(viewModel: viewModel.postProductCameraViewModel)
        self.galleryView = PostProductGalleryView(topRightButtonIsUsePhoto: topRightButtonIsUsePhoto)
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        self.forceCamera = forceCamera
        self.productDetailView = PostProductDetailPriceView(viewModel: viewModel.postDetailViewModel)
        self.postingGallery = postingGallery
        super.init(viewModel: viewModel, nibName: "PostProductViewController",
                   statusBarStyle: UIApplication.shared.statusBarStyle)
        modalPresentationStyle = .overCurrentContext
        viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setAccesibilityIds()
        setupRx()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !viewDidAppear {
            viewPager.delegate = self
            viewPager.selectTabAtIndex(initialTab)
            footer.update(scroll: CGFloat(initialTab))
        }
        
        switch postingGallery {
        case .singleSelection, .multiSelection, .multiSelectionWhiteButton, .multiSelectionPostBottom:
            break
        case .multiSelectionTabs:
            gradientLayer.frame = gradientView.bounds
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true)
        cameraView.active = true
        galleryView.active = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setStatusBarHidden(false)
        galleryView.active = false
        cameraView.active = false
    }


    // MARK: - Actions
    
    @IBAction func onCloseButton(_ sender: AnyObject) {
        productDetailView.resignFirstResponder()
        viewModel.closeButtonPressed()
    }

    dynamic func galleryButtonPressed() {
        guard viewPager.scrollEnabled else { return }
        viewPager.selectTabAtIndex(0, animated: true)
    }
    
    dynamic func galleryPostButtonPressed() {
        galleryView.postButtonPressed()
    }

    dynamic func cameraButtonPressed() {
        if viewPager.currentPage == 1 {
            cameraView.takePhoto()
        } else {
            viewPager.selectTabAtIndex(1, animated: true)
        }
    }

    @IBAction func onRetryButton(_ sender: AnyObject) {
        viewModel.retryButtonPressed()
    }


    // MARK: - Private methods

    private func setupView() {
        
        cameraView.delegate = self
        cameraView.usePhotoButtonText = viewModel.usePhotoButtonText

        galleryView.delegate = self
        galleryView.usePhotoButtonText = viewModel.usePhotoButtonText

        setupViewPager()
        setupDetailView()
        setupFooter()

        setSelectImageState()
    }

    private func setupDetailView() {
        retryButton.setTitle(LGLocalizedString.commonErrorListRetryButton, for: .normal)
        retryButton.setStyle(.primary(fontSize: .medium))

        productDetailView.translatesAutoresizingMaskIntoConstraints = false
        detailsContainer.addSubview(productDetailView)
        productDetailView.alpha = 0

        let top = NSLayoutConstraint(item: productDetailView, attribute: .top, relatedBy: .equal,
                                     toItem: postedInfoLabel, attribute: .bottom, multiplier: 1.0, constant: 15)
        let left = NSLayoutConstraint(item: productDetailView, attribute: .left, relatedBy: .equal,
                                      toItem: detailsContainer, attribute: .left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: productDetailView, attribute: .right, relatedBy: .equal,
                                       toItem: detailsContainer, attribute: .right, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: productDetailView, attribute: .bottom, relatedBy: .equal,
                                        toItem: detailsContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        detailsContainer.addConstraints([top, left, right, bottom])
    }
    
    private func setupFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footer.galleryButton?.addTarget(self, action: #selector(galleryButtonPressed), for: .touchUpInside)
        footer.cameraButton.addTarget(self, action: #selector(cameraButtonPressed), for: .touchUpInside)
        footer.postButton?.setTitle(viewModel.usePhotoButtonText, for: .normal)
        footer.postButton?.addTarget(self, action: #selector(galleryPostButtonPressed), for: .touchUpInside)
        cameraGalleryContainer.addSubview(footerView)
        
        footerView.layout(with: cameraGalleryContainer)
            .leading()
            .trailing()
            .bottom()
    }

    private func setupRx() {
        viewModel.state.asObservable().bindNext { [weak self] state in
            switch state {
            case .imageSelection:
                self?.setSelectImageState()
            case .uploadingImage:
                self?.setSelectPriceState(loading: true, error: nil)
            case .errorUpload(let message):
                self?.setSelectPriceState(loading: false, error: message)
            case .detailsSelection:
               self?.setSelectPriceState(loading: false, error: nil)
            }
        }.addDisposableTo(disposeBag)

        keyboardHelper.rx_keyboardOrigin.asObservable().bindNext { [weak self] origin in
            guard origin > 0 else { return }
            guard let scrollView = self?.detailsScroll, let viewHeight = self?.view.height,
            let detailsRect = self?.productDetailView.frame else { return }
            scrollView.contentInset.bottom = viewHeight - origin
            let showingKeyboard = (viewHeight - origin) > 0
            self?.loadingViewHidden(hide: showingKeyboard)
            scrollView.scrollRectToVisible(detailsRect, animated: false)
            
        }.addDisposableTo(disposeBag)
    }
    
    private func loadingViewHidden(hide: Bool) {
        guard !DeviceFamily.current.isWiderOrEqualThan(.iPhone6) else { return }
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.customLoadingView.alpha = hide ? 0.0 : 1.0
        })
    }
}


// MARK: - State selection

extension PostProductViewController {
    fileprivate func setSelectImageState() {
        selectPriceContainer.isHidden = true
    }

    fileprivate func setSelectPriceState(loading: Bool, error: String?) {
        detailsScroll.contentInset.top = (view.height / 3) - customLoadingView.height

        selectPriceContainer.isHidden = false
        let hasError = error != nil

        if(loading) {
            customLoadingView.startAnimating()
            setSelectPriceItems(loading, error: error)
        }
        else {
            customLoadingView.stopAnimating(!hasError) { [weak self] in
                self?.setSelectPriceItems(loading, error: error)
            }
        }
    }

    fileprivate func setSelectPriceItems(_ loading: Bool, error: String?) {
        postedInfoLabel.alpha = 0
        postedInfoLabel.text = error != nil ?
            LGLocalizedString.commonErrorTitle.capitalized : viewModel.confirmationOkText
        postErrorLabel.text = error

        if (loading) {
            setSelectPriceBottomItems(loading, error: error)
        } else {
            UIView.animate(withDuration: 0.2,
                                       animations: { [weak self] in
                                        self?.postedInfoLabel.alpha = 1
                },
                                       completion: { [weak self] completed in
                                        self?.postedInfoLabel.alpha = 1
                                        self?.setSelectPriceBottomItems(loading, error: error)
                }
            )
        }
    }

    fileprivate func setSelectPriceBottomItems(_ loading: Bool, error: String?) {
        productDetailView.alpha = 0
        postErrorLabel.alpha = 0
        retryButton.alpha = 0

        guard !loading else { return }

        let okItemsAlpha: CGFloat = error != nil ? 0 : 1
        let wrongItemsAlpha: CGFloat = error == nil ? 0 : 1
        let loadingItemAlpha: CGFloat = 1
        let finalAlphaBlock = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.productDetailView.alpha = okItemsAlpha
            strongSelf.postErrorLabel.alpha = wrongItemsAlpha
            strongSelf.retryButton.alpha = wrongItemsAlpha
            strongSelf.customLoadingView.alpha = loadingItemAlpha
            strongSelf.postedInfoLabel.alpha = loadingItemAlpha
            strongSelf.detailsScroll.contentInset.top = PostProductViewController.detailTopMarginPrice
        }
        UIView.animate(withDuration: 0.2, delay: 0.8, options: UIViewAnimationOptions(),
                                   animations: { () -> Void in
                                    finalAlphaBlock()
            }, completion: { [weak self] (completed: Bool) -> Void in
                finalAlphaBlock()

                if okItemsAlpha == 1 {
                    self?.productDetailView.becomeFirstResponder()
                } else {
                    self?.productDetailView.resignFirstResponder()
                }
            }
        )
    }
}


// MARK: - PostProductCameraViewDelegate

extension PostProductViewController: PostProductCameraViewDelegate {
    func productCameraCloseButton() {
        onCloseButton(cameraView)
    }

    func productCameraDidTakeImage(_ image: UIImage) {
        viewModel.imagesSelected([image], source: .camera)
    }

    func productCameraRequestHideTabs(_ hide: Bool) {
        footer.isHidden = hide
        
        switch postingGallery {
        case .singleSelection, .multiSelection, .multiSelectionWhiteButton, .multiSelectionPostBottom:
            break
        case .multiSelectionTabs:
            gradientView.isHidden = hide
            viewPager.tabsHidden = hide
        }
    }

    func productCameraRequestsScrollLock(_ lock: Bool) {
        viewPager.scrollEnabled = !lock
    }
}


// MARK: - PostProductGalleryViewDelegate

extension PostProductViewController: PostProductGalleryViewDelegate {
    func productGalleryCloseButton() {
        onCloseButton(galleryView)
    }

    func productGalleryDidSelectImages(_ images: [UIImage]) {
        viewModel.imagesSelected(images, source: .gallery)
    }

    func productGalleryRequestsScrollLock(_ lock: Bool) {
        viewPager.scrollEnabled = !lock
    }

    func productGalleryDidPressTakePhoto() {
        viewPager.selectTabAtIndex(1)
    }

    func productGalleryShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {
        showActionSheet(cancelAction, actions: actions, sourceView: galleryView.albumButton,
                        sourceRect: galleryView.albumButton.frame, completion: nil)
    }

    func productGallerySelection(selection: ImageSelection) {
        switch (selection, postingGallery) {
        case (.nothing, _),
             (.any, .singleSelection), (.any, .multiSelection),
             (.any, .multiSelectionWhiteButton), (.any, .multiSelectionTabs),
             (.all, .singleSelection), (.all, .multiSelection),
             (.all, .multiSelectionWhiteButton), (.all, .multiSelectionTabs):
            footer.cameraButton.isHidden = false
            footer.postButton?.isHidden = true
        case (.any, .multiSelectionPostBottom), (.all, .multiSelectionPostBottom):
            footer.cameraButton.isHidden = true
            footer.postButton?.isHidden = false
        }
    }
    
    func productGallerySwitchToCamera() {
        viewPager.selectTabAtIndex(1, animated: true)
    }
}


// MARK: - LGViewPager

extension PostProductViewController: LGViewPagerDataSource, LGViewPagerDelegate, LGViewPagerScrollDelegate {
    func setupViewPager() {
        viewPager.dataSource = self
        viewPager.scrollDelegate = self
        viewPager.indicatorSelectedColor = UIColor.white
        viewPager.tabsBackgroundColor = UIColor.clear
        viewPager.tabsSeparatorColor = UIColor.clear
        viewPager.translatesAutoresizingMaskIntoConstraints = false
        cameraGalleryContainer.insertSubview(viewPager, at: 0)
        
        switch postingGallery {
        case .singleSelection, .multiSelection, .multiSelectionWhiteButton, .multiSelectionPostBottom:
            break
        case .multiSelectionTabs:
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            gradientView.layer.insertSublayer(gradientLayer, at: 0)
            // This is a bit hackish... if this variant is the winner add it as option @ LGViewPager
            viewPager.insertSubview(gradientView, belowSubview: viewPager.tabsScrollView)
            
            gradientView.layout(with: viewPager)
                .leading()
                .trailing()
                .bottom()
            gradientView.layout().height(150)
        }
        
        setupViewPagerConstraints()
        viewPager.reloadData()
    }

    private func setupViewPagerConstraints() {
        let views = ["viewPager": viewPager]
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        cameraGalleryContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[viewPager]|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }

    func viewPager(_ viewPager: LGViewPager, willDisplayView view: UIView, atIndex index: Int) {
        KeyValueStorage.sharedInstance.userPostProductLastTabSelected = index
    }

    func viewPager(_ viewPager: LGViewPager, didEndDisplayingView view: UIView, atIndex index: Int) {}

    func viewPager(_ viewPager: LGViewPager, didScrollToPagePosition pagePosition: CGFloat) {
        cameraView.showHeader(pagePosition == 1.0)
        galleryView.showHeader(pagePosition == 0.0)

        footer.update(scroll: pagePosition)
    }

    func viewPagerNumberOfTabs(_ viewPager: LGViewPager) -> Int {
        return 2
    }

    func viewPager(_ viewPager: LGViewPager, viewForTabAtIndex index: Int) -> UIView {
        if index == 0 {
            return galleryView
        }
        else {
            return cameraView
        }
    }

    func viewPager(_ viewPager: LGViewPager, showInfoBadgeAtIndex index: Int) -> Bool {
        return false
    }

    func viewPager(_ viewPager: LGViewPager, titleForUnselectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAt(index: index)
    }

    func viewPager(_ viewPager: LGViewPager, titleForSelectedTabAtIndex index: Int) -> NSAttributedString {
        return titleForTabAt(index: index)
    }
    
    func viewPager(_ viewPager: LGViewPager, accessibilityIdentifierAtIndex index: Int) -> AccessibilityId? {
        return nil
    }

    private func titleForTabAt(index: Int) -> NSAttributedString {
        let text: String
        let icon: UIImage?
        let attributes = tabTitleTextAttributes()
        if index == 0 {
            icon = #imageLiteral(resourceName: "ic_post_tab_gallery")
            text = LGLocalizedString.productPostGalleryTab
        } else {
            icon = #imageLiteral(resourceName: "ic_post_tab_camera")
            text = LGLocalizedString.productPostCameraTabV2
        }
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = CGRect(x: 0, y: UIFont.activeTabFont.descender + 1,
                                   width: icon?.size.width ?? 0,
                                   height: icon?.size.height ?? 0)
        let title = NSMutableAttributedString()
        title.append(NSAttributedString(attachment: attachment))
        title.append(NSAttributedString(string: "  "))
        title.append(NSMutableAttributedString(string: text, attributes: attributes))
        return title
    }
    
    private func tabTitleTextAttributes()-> [String : Any] {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
        shadow.shadowBlurRadius = 2
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        
        var titleAttributes = [String : Any]()
        titleAttributes[NSShadowAttributeName] = shadow
        titleAttributes[NSForegroundColorAttributeName] = UIColor.white
        titleAttributes[NSFontAttributeName] = UIFont.activeTabFont
        return titleAttributes
    }
}


// MARK: - Accesibility

extension PostProductViewController {
    func setAccesibilityIds() {
        closeButton.accessibilityId = .postingCloseButton
        customLoadingView.accessibilityId = .postingLoading
        retryButton.accessibilityId = .postingRetryButton
    }
}
