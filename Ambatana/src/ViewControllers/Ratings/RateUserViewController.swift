//
//  UserRatingViewController.swift
//  LetGo
//
//  Created by Eli Kohen on 12/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RateUserViewController: KeyboardViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameText: UILabel!
    @IBOutlet weak var rateInfoText: UILabel!
    
    @IBOutlet weak var starsContainer: UIView!
    @IBOutlet var stars: [UIButton]!
    
    @IBOutlet weak var ratingsContainer: UIView!
    @IBOutlet weak var ratingsContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingsTitle: UILabel!
    @IBOutlet weak var ratingTagsCollectionView: UICollectionView!
    @IBOutlet weak var ratingTagsHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionContainer: UIView!
    @IBOutlet weak var descriptionContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var descriptionCharCounter: UILabel!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var footerLabel: UILabel!

    fileprivate let descrPlaceholderColor = UIColor.gray
    fileprivate static let sendButtonMargin: CGFloat = 15
    fileprivate let showSkipButton: Bool

    fileprivate let viewModel: RateUserViewModel
    fileprivate let keyboardHelper: KeyboardHelper
    fileprivate let disposeBag = DisposeBag()

    
    // MARK: - Lifecycle

    convenience init(viewModel: RateUserViewModel, showSkipButton: Bool) {
        self.init(viewModel: viewModel, showSkipButton: showSkipButton, keyboardHelper: KeyboardHelper())
    }

    init(viewModel: RateUserViewModel, showSkipButton: Bool, keyboardHelper: KeyboardHelper) {
        self.viewModel = viewModel
        self.showSkipButton = showSkipButton
        self.keyboardHelper = keyboardHelper
        super.init(viewModel: viewModel, nibName: "RateUserViewController",
                   navBarBackgroundStyle: .transparent(substyle: .light))
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setAccesibilityIds()
        setupRx()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ratingTagsHeightConstraint.constant = ratingTagsCollectionView.collectionViewLayout.collectionViewContentSize.height
    }

    
    // MARK: - Actions

    @IBAction func sendButtonPressed(_ sender: Any) {
        viewModel.sendButtonPressed()
    }

    @IBAction func starHighlighted(_ sender: AnyObject) {
        guard let tag = (sender as? UIButton)?.tag else { return }
        stars.forEach { $0.isHighlighted = ($0.tag <= tag) }
        descriptionText.resignFirstResponder()
    }

    @IBAction func starSelected(_ sender: AnyObject) {
        guard let button = sender as? UIButton else { return }
        viewModel.ratingStarPressed(button.tag)
    }

    @objc dynamic private func closeButtonPressed() {
        viewModel.closeButtonPressed()
    }

    @objc dynamic private func skipButtonPressed() {
        viewModel.skipButtonPressed()
    }


    // MARK: - Private methods

    private func setupUI() {
        // In the xib bottom constraints are remove at runtime
        scrollView.layout(with: keyboardView).bottom(to: .top)
        footerView.layout(with: keyboardView).bottom(to: .top)
        
        automaticallyAdjustsScrollViewInsets = false
        
        if showSkipButton {
            setLetGoRightButtonWith(text: LGLocalizedString.userRatingSkipButton, selector: #selector(skipButtonPressed))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbar_close"), style: .plain,
                                                               target: self, action: #selector(closeButtonPressed))
        }
        
        setNavBarTitle(LGLocalizedString.userRatingTitle)

        userImage.layer.cornerRadius = userImage.width / 2
        if let avatar = viewModel.userAvatar {
            userImage.lg_setImageWithURL(avatar)
        }
        userNameText.text = viewModel.userName
        rateInfoText.text = viewModel.infoText
        
        ratingsTitle.text = LGLocalizedString.userRatingSelectATag
        ratingTagsCollectionView.collectionViewLayout = CenterAlignedCollectionViewFlowLayout()
        ratingTagsCollectionView.allowsSelection = true
        ratingTagsCollectionView.allowsMultipleSelection = true
        ratingTagsCollectionView.register(UserRatingTagCell.self,
                                          forCellWithReuseIdentifier: UserRatingTagCell.reuseIdentifier)
        
        descriptionContainer.layer.borderColor = UIColor.lineGray.cgColor
        descriptionContainer.layer.borderWidth = LGUIKitConstants.onePixelSize
        descriptionText.text = viewModel.descriptionPlaceholder
        descriptionText.textColor = descrPlaceholderColor
        
        footerView.backgroundColor = UIColor.viewControllerBackground
        footerLabel.text = LGLocalizedString.userRatingReviewInfo

        footerView.layoutIfNeeded()
        descriptionContainerBottomConstraint.constant = footerView.height + Metrics.margin
        ratingsContainerBottomConstraint.constant = footerView.height + Metrics.margin
        sendButton.setStyle(.primary(fontSize: .big))
    }
    
    private func setupRx() {
        viewModel.state.asObservable().bindNext { [weak self] state in
            self?.updateUI(with: state)
        }.addDisposableTo(disposeBag)
        
        viewModel.rating.asObservable().bindNext { [weak self] rating in
            onMainThread { [weak self] in
                let value = rating ?? 0
                self?.stars.forEach { $0.isHighlighted = ($0.tag <= value) }
            }
        }.addDisposableTo(disposeBag)
        
        viewModel.sendText.asObservable().bindTo(sendButton.rx.title(for: .normal)).addDisposableTo(disposeBag)
        viewModel.sendEnabled.asObservable().bindTo(sendButton.rx.isEnabled).addDisposableTo(disposeBag)
        viewModel.isLoading.asObservable().bindTo(activityIndicator.rx.isAnimating).addDisposableTo(disposeBag)
        
        viewModel.descriptionCharLimit.asObservable()
            .map { return String($0) }
            .bindTo(descriptionCharCounter.rx.text)
            .addDisposableTo(disposeBag)

        keyboardChanges.bindNext { [weak self] change in
            guard let strongSelf = self, change.visible else { return }

            // Current scroll view frame (as it gets resized) at the bottom
            let scrollViewHeight = strongSelf.scrollView.frame.height
            let visibleScrollViewHeight = scrollViewHeight - change.height
            let lastVisibleRectTop = strongSelf.scrollView.contentSize.height - visibleScrollViewHeight
            
            // Top of the description should be visible
            let descriptionTop = strongSelf.descriptionContainer.top
            let y = min(descriptionTop, lastVisibleRectTop)
            let offset = CGPoint(x: 0, y: y)
            
            strongSelf.scrollView.setContentOffset(offset, animated: true)
            
        }.addDisposableTo(disposeBag)
    }
    
    private func updateUI(with state: RateUserState) {
        switch state {
        case .review:
            ratingTagsCollectionView.isHidden = false
            vmUpdateTags()
            starsContainer.isHidden = false
            descriptionContainer.isHidden = true
        case .comment:
            ratingTagsCollectionView.isHidden = true
            starsContainer.isHidden = true
            descriptionContainer.isHidden = false
        }
    }
}


// MARK: - UserRatingViewModelDelegate

extension RateUserViewController: RateUserViewModelDelegate {
    func vmUpdateDescription(_ description: String?) {
        if let description = description, !description.isEmpty {
            descriptionText.text = description
            descriptionText.textColor = UIColor.grayDark
        } else {
            descriptionText.text = viewModel.descriptionPlaceholder
            descriptionText.textColor = descrPlaceholderColor
        }
    }

    func vmUpdateTags() {
        ratingTagsCollectionView.reloadData()
        // Forces relayout so viewDidLayoutSubviews is called and then collection view height is adjusted
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}


// MARK: - UIColllectionView Delegate & Datasource

extension RateUserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let title = viewModel.titleForTagAt(index: indexPath.row) else { return CGSize.zero }
        return UserRatingTagCell.size(with: title)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfTags
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserRatingTagCell.reuseIdentifier,
                                                            for: indexPath) as? UserRatingTagCell else {
                                                                return UICollectionViewCell()
        }
        let index = indexPath.row
        cell.title = viewModel.titleForTagAt(index: index)
        let isSelected = viewModel.isSelectedTagAt(index: index)
        cell.isSelected = isSelected
        if isSelected {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectTagAt(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        viewModel.deselectTagAt(index: indexPath.row)
    }
}


// MARK: - Textfield handling

extension RateUserViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // clear text view placeholder
        if textView.text == viewModel.descriptionPlaceholder && textView.textColor ==  descrPlaceholderColor {
            textView.text = nil
            textView.textColor = UIColor.grayDark
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = viewModel.descriptionPlaceholder
            textView.textColor = descrPlaceholderColor
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textViewText = textView.text else { return true }
        let finalText = (textViewText as NSString).replacingCharacters(in: range, with: text)
        return viewModel.setDescription(text: finalText)
    }
}


// MARK: - Accesibility

extension RateUserViewController {
    func setAccesibilityIds() {
        userNameText.accessibilityId = .rateUserUserNameLabel
        if stars.count == 5 {
            stars[0].accessibilityId = .rateUserStarButton1
            stars[1].accessibilityId = .rateUserStarButton2
            stars[2].accessibilityId = .rateUserStarButton3
            stars[3].accessibilityId = .rateUserStarButton4
            stars[4].accessibilityId = .rateUserStarButton5
        }
        descriptionText.accessibilityId = .rateUserDescriptionField
        activityIndicator.accessibilityId = .rateUserLoading
        sendButton.accessibilityId = .rateUserSendButton
    }
}
