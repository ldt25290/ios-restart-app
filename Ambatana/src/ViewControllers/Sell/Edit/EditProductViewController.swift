//
//  EditProductViewController.swift
//  LetGo
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import FBSDKShareKit
import LGCoreKit
import Result
import RxSwift
import KMPlaceholderTextView


class EditProductViewController: BaseViewController, UITextFieldDelegate,
    UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    // UI
    private static let loadingTitleDisclaimerLeadingConstraint: CGFloat = 8
    private static let completeTitleDisclaimerLeadingConstraint: CGFloat = -20
    private static let titleDisclaimerHeightConstraint: CGFloat = 16
    private static let titleDisclaimerBottomConstraintVisible: CGFloat = 24
    private static let titleDisclaimerBottomConstraintHidden: CGFloat = 8
    private static let separatorOptionsViewDistance = LGUIKitConstants.onePixelSize
    private static let viewOptionGenericHeight: CGFloat = 50
    private static let carsInfoContainerHeight: CGFloat = 134 // (3 x 44 + 2 separators)

    enum TextFieldTag: Int {
        case productTitle = 1000, productPrice, productDescription
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var containerEditOptionsView: UIView!
    
    @IBOutlet var separatorContainerViewsConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var priceViewSeparatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var freePostViewSeparatorTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleTextField: LGTextField!
    @IBOutlet weak var titleDisclaimer: UILabel!
    @IBOutlet weak var autoGeneratedTitleButton: UIButton!
    @IBOutlet weak var titleDisclaimerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDisclaimerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleDisclaimerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var updateButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postFreeView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var priceContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postFreeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var freePostingSwitch: UISwitch!
    
    @IBOutlet weak var postFreeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceTextField: LGTextField!
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionCharCountLabel: UILabel!
    @IBOutlet weak var titleDisclaimerActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!

    @IBOutlet weak var setLocationTitleLabel: UILabel!
    @IBOutlet weak var setLocationLocationLabel: UILabel!
    @IBOutlet weak var setLocationButton: UIButton!

    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categorySelectedLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!

    @IBOutlet weak var carsMakeTitleLabel: UILabel!
    @IBOutlet weak var carsMakeSelectedLabel: UILabel!
    @IBOutlet weak var carsMakeButton: UIButton!

    @IBOutlet weak var carsModelTitleLabel: UILabel!
    @IBOutlet weak var carsModelSelectedLabel: UILabel!
    @IBOutlet weak var carsModelButton: UIButton!

    @IBOutlet weak var carsYearTitleLabel: UILabel!
    @IBOutlet weak var carsYearSelectedLabel: UILabel!
    @IBOutlet weak var carsYearButton: UIButton!

    @IBOutlet weak var carsInfoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var carsInfoContainerSeparatorTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var shareFBSwitch: UISwitch!
    @IBOutlet weak var shareFBLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingProgressView: UIProgressView!

    var hideKbTapRecognizer: UITapGestureRecognizer?

    // viewModel
    fileprivate var viewModel : EditProductViewModel
    fileprivate var keyboardHelper: KeyboardHelper
    private var featureFlags: FeatureFlaggeable
    // Rx
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var activeField: UIView? = nil

    // MARK: - Lifecycle
    
    convenience init(viewModel: EditProductViewModel) {
        self.init(viewModel: viewModel, keyboardHelper: KeyboardHelper.sharedInstance, featureFlags: FeatureFlags.sharedInstance)
    }
    
    required init(viewModel: EditProductViewModel, keyboardHelper: KeyboardHelper, featureFlags: FeatureFlaggeable) {
        self.keyboardHelper = keyboardHelper
        self.viewModel = viewModel
        self.featureFlags = featureFlags
        super.init(viewModel: viewModel, nibName: "EditProductViewController")
        self.viewModel.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAccesibilityIds()
        setupRxBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        descriptionTextView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
    }
    
    // MARK: - Public methods
    
    // MARK: > Actions
  
    @IBAction func categoryButtonPressed(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: LGLocalizedString.sellChooseCategoryDialogTitle, message: nil,
            preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = categoryButton
        alert.popoverPresentationController?.sourceRect = categoryButton.frame

        for i in 0..<viewModel.numberOfCategories {
            alert.addAction(UIAlertAction(title: viewModel.categoryNameAtIndex(i), style: .default,
                handler: { (categoryAction) -> Void in
                    self.viewModel.selectCategoryAtIndex(i)
            }))
        }
        
        alert.addAction(UIAlertAction(title: LGLocalizedString.sellChooseCategoryDialogCancelButton,
            style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        viewModel.sendButtonPressed()
    }
    
    @IBAction func shareFBSwitchChanged(_ sender: AnyObject) {
        viewModel.shouldShareInFB = shareFBSwitch.isOn
    }

    // MARK: - TextField Delegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // textField is inside a container, so we need to know which container is focused (to scroll to visible when keyboard was up)
        activeField = textField.superview
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tag = TextFieldTag(rawValue: textField.tag), tag == .productTitle else { return }
        if let text = textField.text {
            viewModel.userFinishedEditingTitle(text)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == priceTextField && !textField.shouldChangePriceInRange(range, replacementString: string,
                                                                              acceptsSeparator: true) {
             return false
        }

        let cleanReplacement = string.stringByRemovingEmoji()

        let text = textField.textReplacingCharactersInRange(range, replacementString: cleanReplacement)
        if let tag = TextFieldTag(rawValue: textField.tag) {
            switch (tag) {
            case .productTitle:
                viewModel.title = text.isEmpty ? nil : text
                if string.hasEmojis() {
                    //Forcing the new text (without emojis) by returning false
                    textField.text = text
                    return false
                }
                viewModel.userWritesTitle(text)
            case .productPrice:
                viewModel.price = text.isEmpty ? nil : text
            case .productDescription:
                break
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == TextFieldTag.productTitle.rawValue && !freePostingSwitch.isOn {
            let nextTag = textField.tag + 1
            if let nextView = view.viewWithTag(nextTag) {
                nextView.becomeFirstResponder()
            }
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let tag = TextFieldTag(rawValue: textField.tag), tag == .productTitle {
            viewModel.title = ""
            viewModel.userWritesTitle(textField.text)
        }
        return true
    }

    // MARK: - UITextViewDelegate Methods
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // textView is inside a container, so we need to know which container is focused (to scroll to visible when keyboard was up)
        activeField = textView.superview
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text {
            let cleanReplacement = text.stringByRemovingEmoji()
            let finalText = (textViewText as NSString).replacingCharacters(in: range, with: cleanReplacement)
            viewModel.descr = finalText.isEmpty ? nil : finalText
            if text.hasEmojis() {
                //Forcing the new text (without emojis) by returning false
                textView.text = finalText
                return false
            }
        }
        return true
    }
    
    
    // MARK: - Collection View Data Source methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.maxImageCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SellProductCell.reusableID,
                for: indexPath) as? SellProductCell else { return UICollectionViewCell() }
            cell.layer.cornerRadius = LGUIKitConstants.defaultCornerRadius
            if indexPath.item < viewModel.numberOfImages {
                cell.setupCellWithImageType(viewModel.imageAtIndex(indexPath.item))
                cell.label.text = ""
            } else if indexPath.item == viewModel.numberOfImages {
                cell.setupAddPictureCell()
            } else {
                cell.setupEmptyCell()
            }
            return cell
    }
    
    
    // MARK: - Collection View Delegate methods

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.numberOfImages {
            // add image
            let cell = collectionView.cellForItem(at: indexPath) as? SellProductCell
            cell?.highlight()
            MediaPickerManager.showImagePickerIn(self)
            if indexPath.item > 1 && indexPath.item < 4 {
                collectionView.scrollToItem(at: IndexPath(item: indexPath.item+1, section: 0),
                    at: UICollectionViewScrollPosition.right, animated: true)
            }
            
        } else if (indexPath.item < viewModel.numberOfImages) {
            // remove image
            let alert = UIAlertController(title: LGLocalizedString.sellPictureSelectedTitle, message: nil,
                preferredStyle: .actionSheet)
            
            let cell = collectionView.cellForItem(at: indexPath) as? SellProductCell
            alert.popoverPresentationController?.sourceView = cell
            alert.popoverPresentationController?.sourceRect = cell?.bounds ?? CGRect.zero
            
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedDeleteButton,
                style: .destructive, handler: { (deleteAction) -> Void in
                    self.deleteAlreadyUploadedImageWithIndex(indexPath.row)
                    guard indexPath.item > 0 else { return }
                    collectionView.scrollToItem(at: IndexPath(item: indexPath.item-1, section: 0),
                            at: UICollectionViewScrollPosition.left, animated: true)
            }))
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedSaveIntoCameraRollButton,
                style: .default, handler: { (saveAction) -> Void in
                    self.saveProductImageToDiskAtIndex(indexPath.row)
            }))
            alert.addAction(UIAlertAction(title: LGLocalizedString.sellPictureSelectedCancelButton,
                style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    // MARK: UIImagePicker Delegate
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [String : Any]) {
            var image = info[UIImagePickerControllerEditedImage] as? UIImage
            if image == nil { image = info[UIImagePickerControllerOriginalImage] as? UIImage }
            
            self.dismiss(animated: true, completion: nil)

            if let theImage = image {
                viewModel.appendImage(theImage)
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: - Managing images.
    
    func deleteAlreadyUploadedImageWithIndex(_ index: Int) {
        // delete the image file locally
        viewModel.deleteImageAtIndex(index)
    }
    
    func saveProductImageToDiskAtIndex(_ index: Int) {
        showLoadingMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollLoading)
        
        // get the image and launch the saving action.
        let imageTypeAtIndex = viewModel.imageAtIndex(index)
        switch imageTypeAtIndex {
        case .local(let image):
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(EditProductViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
        case .remote(let file):
            guard let fileUrl = file.fileURL else {
                self.dismissLoadingMessageAlert(){
                    self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollErrorGeneric)
                }
                return
            }
            ImageDownloader.sharedInstance.downloadImageWithURL(fileUrl) { [weak self] (result, _) in
                guard let strongSelf = self, let image = result.value?.image else { return }
                UIImageWriteToSavedPhotosAlbum(image, strongSelf, #selector(EditProductViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    func image(_ image: UIImage!, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        self.dismissLoadingMessageAlert(){
            if error == nil { // success
                self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollOk)
            } else {
                self.showAutoFadingOutMessageAlert(LGLocalizedString.sellPictureSaveIntoCameraRollErrorGeneric)
            }
        }
    }


    // MARK: - Private methods

    func setupUI() {

        setNavBarTitle(LGLocalizedString.editProductTitle)
        let closeButton = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: UIBarButtonItemStyle.plain,
                                          target: self, action: #selector(EditProductViewController.closeButtonPressed))
        self.navigationItem.leftBarButtonItem = closeButton;
        
        separatorContainerViewsConstraints.forEach { $0.constant = EditProductViewController.separatorOptionsViewDistance }
        containerEditOptionsView.layer.cornerRadius = LGUIKitConstants.containerCornerRadius
        updateButtonBottomConstraint.constant = 0
        
        titleTextField.placeholder = LGLocalizedString.sellTitleFieldHint
        titleTextField.text = viewModel.title
        titleTextField.tag = TextFieldTag.productTitle.rawValue
        titleDisclaimer.textColor = UIColor.darkGrayText
        titleDisclaimer.font = UIFont.smallBodyFont

        autoGeneratedTitleButton.rounded = true
        titleDisclaimerActivityIndicator.transform = titleDisclaimerActivityIndicator.transform.scaledBy(x: 0.8, y: 0.8)

        postFreeLabel.text = LGLocalizedString.sellPostFreeLabel
        
        currencyLabel.text = viewModel.currency?.code

        priceTextField.placeholder = LGLocalizedString.productNegotiablePrice
        priceTextField.text = viewModel.price
        priceTextField.tag = TextFieldTag.productPrice.rawValue
        priceTextField.insetX = 16.0

        descriptionTextView.text = viewModel.descr ?? ""
        descriptionTextView.textColor = UIColor.blackText
        descriptionTextView.placeholder = LGLocalizedString.sellDescriptionFieldHint
        descriptionTextView.placeholderColor = UIColor.gray
        descriptionTextView.textContainerInset = UIEdgeInsetsMake(12.0, 11.0, 12.0, 11.0)
        descriptionTextView.tintColor = UIColor.primaryColor
        descriptionTextView.tag = TextFieldTag.productDescription.rawValue
        descriptionCharCountLabel.text = "\(viewModel.descriptionCharCount)"

        setLocationTitleLabel.text = LGLocalizedString.settingsChangeLocationButton

        categoryTitleLabel.text = LGLocalizedString.sellCategorySelectionLabel
        categorySelectedLabel.text = viewModel.categoryName ?? ""

        carsMakeTitleLabel.text = LGLocalizedString.postCategoryDetailCarMake
        carsModelTitleLabel.text = LGLocalizedString.postCategoryDetailCarModel
        carsYearTitleLabel.text = LGLocalizedString.postCategoryDetailCarYear

        sendButton.setTitle(LGLocalizedString.editProductSendButton, for: .normal)
        sendButton.setStyle(.primary(fontSize:.big))
        
        shareFBSwitch.isOn = viewModel.shouldShareInFB
        shareFBLabel.text = LGLocalizedString.sellShareOnFacebookLabel

        if featureFlags.freePostingModeAllowed {
            postFreeViewHeightConstraint.constant = EditProductViewController.viewOptionGenericHeight
            freePostViewSeparatorTopConstraint.constant = EditProductViewController.separatorOptionsViewDistance
        } else {
            postFreeViewHeightConstraint.constant = 0
            freePostViewSeparatorTopConstraint.constant = 0
        }
        
        // CollectionView
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        let cellNib = UINib(nibName: SellProductCell.reusableID, bundle: nil)
        self.imageCollectionView.register(cellNib, forCellWithReuseIdentifier: SellProductCell.reusableID)
        
        loadingLabel.text = LGLocalizedString.sellUploadingLabel
        view.bringSubview(toFront: loadingView)
        
        // hide keyboard on tap
        hideKbTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
    }

    fileprivate func setupRxBindings() {
        Observable.combineLatest(
            viewModel.titleAutogenerated.asObservable(),
            viewModel.titleAutotranslated.asObservable()) { (titleAutogenerated, titleAutotranslated) -> String? in
                if titleAutogenerated && titleAutotranslated {
                    return LGLocalizedString.sellTitleAutogenAutotransLabel
                } else if titleAutogenerated {
                    return LGLocalizedString.sellTitleAutogenLabel
                } else {
                    return nil
                }
            }
            .bindTo(titleDisclaimer.rx.optionalText)
            .addDisposableTo(disposeBag)

        viewModel.titleDisclaimerStatus.asObservable().bindNext { [weak self] status in
            guard let strongSelf = self else { return }
            switch status {
            case .completed:
                strongSelf.autoGeneratedTitleButton.isHidden = true
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()

                if strongSelf.viewModel.titleAutogenerated.value || strongSelf.viewModel.titleAutotranslated.value {
                    strongSelf.titleDisclaimer.isHidden = false
                    strongSelf.titleDisclaimerLeadingConstraint.constant = EditProductViewController.completeTitleDisclaimerLeadingConstraint
                    strongSelf.titleDisclaimerHeightConstraint.constant = EditProductViewController.titleDisclaimerHeightConstraint
                    strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintVisible
                } else {
                    strongSelf.titleDisclaimer.isHidden = true
                    strongSelf.titleDisclaimerLeadingConstraint.constant = EditProductViewController.loadingTitleDisclaimerLeadingConstraint
                    strongSelf.titleDisclaimerHeightConstraint.constant = 0
                    strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintHidden
                }
            case .ready:
                strongSelf.autoGeneratedTitleButton.isHidden = false
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()
                strongSelf.titleDisclaimer.isHidden = true
                strongSelf.titleDisclaimerHeightConstraint.constant = EditProductViewController.titleDisclaimerHeightConstraint
                strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintVisible
            case .loading:
                strongSelf.autoGeneratedTitleButton.isHidden = true
                strongSelf.titleDisclaimerActivityIndicator.startAnimating()
                strongSelf.titleDisclaimerLeadingConstraint.constant = 8
                strongSelf.titleDisclaimer.isHidden = false
                strongSelf.titleDisclaimerHeightConstraint.constant = EditProductViewController.titleDisclaimerHeightConstraint
                strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintVisible
                strongSelf.titleDisclaimer.text = LGLocalizedString.editProductSuggestingTitle
            case .clean:
                strongSelf.autoGeneratedTitleButton.isHidden = true
                strongSelf.titleDisclaimerActivityIndicator.stopAnimating()
                strongSelf.titleDisclaimer.isHidden = true
                strongSelf.titleDisclaimerHeightConstraint.constant = 0
                strongSelf.titleDisclaimerBottomConstraint.constant = EditProductViewController.titleDisclaimerBottomConstraintHidden
            }
            strongSelf.view.layoutIfNeeded()
        }.addDisposableTo(disposeBag)

        viewModel.proposedTitle.asObservable().bindTo(autoGeneratedTitleButton.rx.title).addDisposableTo(disposeBag)

        autoGeneratedTitleButton.rx.tap.bindNext { [weak self] in
            self?.titleTextField.text = self?.autoGeneratedTitleButton.titleLabel?.text
            self?.viewModel.title = self?.titleTextField.text
            self?.viewModel.userSelectedSuggestedTitle()
        }.addDisposableTo(disposeBag)


        viewModel.locationInfo.asObservable().bindTo(setLocationLocationLabel.rx.text).addDisposableTo(disposeBag)
        setLocationButton.rx.tap.bindNext { [weak self] in
            self?.viewModel.openMap()
        }.addDisposableTo(disposeBag)
        
        viewModel.isFreePosting.asObservable().bindTo(freePostingSwitch.rx.value).addDisposableTo(disposeBag)
        freePostingSwitch.rx.value.bindTo(viewModel.isFreePosting).addDisposableTo(disposeBag)
        viewModel.isFreePosting.asObservable().bindNext{[weak self] active in
            self?.updateFreePostViews(active)
            }.addDisposableTo(disposeBag)

        viewModel.category.asObservable().bindNext{ [weak self] category in
            guard let category = category else {
                self?.categorySelectedLabel.text = ""
                self?.updateCarsFields(isCar: false)
                return
            }
            self?.categorySelectedLabel.text = category.name 
            self?.updateCarsFields(isCar: category == .cars)
        }.addDisposableTo(disposeBag)

        carsMakeButton.rx.tap.bindNext { [weak self] in
            self?.viewModel.carMakeButtonPressed()
            }.addDisposableTo(disposeBag)
        carsModelButton.rx.tap.bindNext { [weak self] in
            self?.viewModel.carModelButtonPressed()
            }.addDisposableTo(disposeBag)
        carsYearButton.rx.tap.bindNext { [weak self] in
            self?.viewModel.carYearButtonPressed()
            }.addDisposableTo(disposeBag)

        viewModel.loadingProgress.asObservable().map { $0 == nil }.bindTo(loadingView.rx.isHidden).addDisposableTo(disposeBag)
        viewModel.loadingProgress.asObservable().ignoreNil().bindTo(loadingProgressView.rx.progress).addDisposableTo(disposeBag)

        viewModel.saveButtonEnabled.asObservable().bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
        
        var previousKbOrigin: CGFloat = CGFloat.greatestFiniteMagnitude
        keyboardHelper.rx_keyboardOrigin.asObservable().skip(1).distinctUntilChanged().bindNext { [weak self] origin in
            guard let strongSelf = self else { return }
            let viewHeight = strongSelf.view.height
            let animationTime = strongSelf.keyboardHelper.animationTime
            guard viewHeight >= origin else { return }

            self?.updateButtonBottomConstraint.constant = viewHeight - origin
            UIView.animate(withDuration: Double(animationTime)) {
                strongSelf.view.layoutIfNeeded()
                if let active = strongSelf.activeField, origin < previousKbOrigin {
                    var frame = active.frame
                    frame.top = frame.top + strongSelf.containerEditOptionsView.top
                    strongSelf.scrollView.scrollRectToVisible(frame, animated: false)
                }
                previousKbOrigin = origin
            }
        }.addDisposableTo(disposeBag)

        keyboardHelper.rx_keyboardVisible.asObservable().distinctUntilChanged().bindNext { [weak self] kbVisible in
            self?.updateTapRecognizer(kbVisible)
        }.addDisposableTo(disposeBag)
    }

    private func updateTapRecognizer(_ add: Bool) {
        guard let tapRec = hideKbTapRecognizer else { return }
        scrollView.removeGestureRecognizer(tapRec)
        if add {
            scrollView.addGestureRecognizer(tapRec)
        }
    }
    
    
    // MARK: - Private methods
    
    private func updateFreePostViews(_ active: Bool) {
        if active {
            priceContainerHeightConstraint.constant = 0
            priceViewSeparatorTopConstraint.constant = 0
        } else {
            priceContainerHeightConstraint.constant = EditProductViewController.viewOptionGenericHeight
            priceViewSeparatorTopConstraint.constant = EditProductViewController.separatorOptionsViewDistance
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }

    private func updateCarsFields(isCar: Bool) {
        print(isCar)
        if isCar {
            carsInfoContainerHeightConstraint.constant = EditProductViewController.carsInfoContainerHeight
            carsInfoContainerSeparatorTopConstraint.constant = EditProductViewController.separatorOptionsViewDistance
        } else {
            carsInfoContainerHeightConstraint.constant = 0
            carsInfoContainerSeparatorTopConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }

    dynamic func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }
    
    private dynamic func scrollViewTapped() {
        activeField?.endEditing(true)
    }
}


// MARK: - EditProductViewModelDelegate Methods

extension EditProductViewController: EditProductViewModelDelegate {

    func vmShouldUpdateDescriptionWithCount(_ count: Int) {
        if count <= 0 {
            descriptionCharCountLabel.textColor = UIColor.primaryColor
        } else {
            descriptionCharCountLabel.textColor = UIColor.black
        }
        descriptionCharCountLabel.text = "\(count)"
    }

    func vmDidAddOrDeleteImage() {
        imageCollectionView.reloadSections(IndexSet(integer: 0))
    }

    func vmShareOnFbWith(content: FBSDKShareLinkContent) {
        FBSDKShareDialog.show(from: self, with: content, delegate: self)
    }

    func vmShouldOpenMapWithViewModel(_ locationViewModel: EditLocationViewModel) {
        let vc = EditLocationViewController(viewModel: locationViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func vmHideKeyboard() {
        activeField?.endEditing(true)
    }
}


// MARK: - FBSDKSharingDelegate 

extension EditProductViewController: FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        viewModel.fbSharingFinishedOk()
    }

    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        viewModel.fbSharingFinishedWithError()
    }

    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        viewModel.fbSharingCancelled()
    }
}


// MARK: - Accesibility 

extension EditProductViewController {
    func setAccesibilityIds() {
        navigationItem.leftBarButtonItem?.accessibilityId = .editProductCloseButton
        scrollView.accessibilityId = .editProductScroll
        titleTextField.accessibilityId = .editProductTitleField
        autoGeneratedTitleButton.accessibilityId = .editProductAutoGenTitleButton
        imageCollectionView.accessibilityId = .editProductImageCollection
        currencyLabel.accessibilityId = .editProductCurrencyLabel
        priceTextField.accessibilityId = .editProductPriceField
        descriptionTextView.accessibilityId = .editProductDescriptionField
        setLocationButton.accessibilityId = .editProductLocationButton
        categoryButton.accessibilityId = .editProductCategoryButton
        sendButton.accessibilityId = .editProductSendButton
        shareFBSwitch.accessibilityId = .editProductShareFBSwitch
        loadingView.accessibilityId = .editProductLoadingView
        freePostingSwitch.accessibilityId = .editProductPostFreeSwitch
    }
}
