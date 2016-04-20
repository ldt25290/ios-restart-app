//
//  ProductCarouselViewController.swift
//  LetGo
//
//  Created by Isaac Roldan on 14/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import SDWebImage
import LGCoreKit
import RxSwift

class ProductCarouselViewController: BaseViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var shadowGradientView: UIView!
    
    var userView: UserView
    var viewModel: ProductCarouselViewModel
    let disposeBag: DisposeBag = DisposeBag()
    var currentIndex = Variable<Int>(0)

    var moreInfoView: UIView = UIView()
    
    // To restore navbar
    private var navBarBgImage: UIImage?
    private var navBarShadowImage: UIImage?
    
    
    // MARK: - Init
    
    init(viewModel: ProductCarouselViewModel) {
        self.viewModel = viewModel
        self.userView = UserView.userView(.Full)!
        super.init(viewModel: viewModel, nibName: nil, statusBarStyle: .LightContent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setupUI()
        setupNavigationBar()
        setupGradientView()
        setupAlphaRxBindings()
        navBarBgImage = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        navBarShadowImage = navigationController?.navigationBar.shadowImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let layers = shadowGradientView.layer.sublayers {
            layers.forEach { $0.frame = shadowGradientView.bounds }
        }
	}

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.setBackgroundImage(navBarBgImage, forBarPosition: .Any, barMetrics: .Default)
        navigationController?.navigationBar.shadowImage = navBarShadowImage
    }
    
    func addSubviews() {
        view.addSubview(userView)
        view.addSubview(moreInfoView)
    }
    
    func setupUI() {
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = view.bounds.size
        flowLayout.scrollDirection = .Horizontal
        
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        collectionView.dataSource = self
        collectionView.registerClass(ProductCarouselCell.self, forCellWithReuseIdentifier: ProductCarouselCell.identifier)
        collectionView.pagingEnabled = true
        collectionView.backgroundColor = UIColor.greenColor()
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.allowsSelection = true
        collectionView.directionalLockEnabled = true
        automaticallyAdjustsScrollViewInsets = false
        
        chatButton.setPrimaryStyleRounded()
        chatButton.setTitle("Chat With Seller", forState: .Normal)
    }
    
    private func setupNavigationBar() {
        let backIcon = UIImage(named: "ic_post_close")
        setLetGoNavigationBarStyle("", backIcon: backIcon)
    }
    
    private func setupGradientView() {
        let shadowLayer = CAGradientLayer.gradientWithColor(UIColor.blackColor(), alphas:[0.4,0.0],
                                                            locations: [0.0,1.0])
        shadowLayer.frame = shadowGradientView.bounds
        shadowGradientView.layer.insertSublayer(shadowLayer, atIndex: 0)
    }
    
    var previousContentOffset: CGFloat = -10000
    
    private func setupAlphaRxBindings() {
        let width = view.bounds.width
        let midPoint = width/2
        let minMargin = midPoint * 0.15
        
        let alphaSignal: Observable<CGFloat> = collectionView.rx_contentOffset
            .map {
                let midValue = fabs($0.x % width - midPoint)
                if midValue <= minMargin { return 0 }
                if midValue >= (midPoint-minMargin) { return 1}
                let newValue = (midValue - minMargin) / (midPoint - minMargin*2)
                return newValue
        }
        
        alphaSignal.bindTo(chatButton.rx_alpha).addDisposableTo(disposeBag)
        alphaSignal.bindTo(userView.rx_alpha).addDisposableTo(disposeBag)
        
        if let navBar = navigationController?.navigationBar {
            alphaSignal.bindTo(navBar.rx_alpha).addDisposableTo(disposeBag)
        }
        
        let indexSignal: Observable<Int> = collectionView.rx_contentOffset.map { Int(($0.x + midPoint) / width) }
        indexSignal
            .distinctUntilChanged()
            .bindNext { index in
                self.viewModel.moveToProductAtIndex(index, delegate: self)
                self.refreshOverlayElements()
            }
            .addDisposableTo(disposeBag)
    }
}


// MARK: > Configure Carousel With ProductViewModel

extension ProductCarouselViewController {
    
    private func refreshOverlayElements() {
        guard let viewModel = viewModel.currentProductViewModel else { return }
        setupUserView(viewModel)
        setupRxNavbarBindings(viewModel)
    }
    
    private func setupUserView(viewModel: ProductViewModel) {
        userView.setupWith(userAvatar: viewModel.ownerAvatar, placeholder: viewModel.ownerAvatarPlaceholder,
                           userName: viewModel.ownerName, subtitle: nil)
        
        userView.translatesAutoresizingMaskIntoConstraints = false
        userView.delegate = self
        view.addSubview(userView)
        let leftMargin = NSLayoutConstraint(item: userView, attribute: .Leading, relatedBy: .Equal, toItem: view,
                                            attribute: .Leading, multiplier: 1, constant: 15)
        let bottomMargin = NSLayoutConstraint(item: userView, attribute: .Bottom, relatedBy: .Equal, toItem: chatButton,
                                              attribute: .Top, multiplier: 1, constant: -15)
        let rightMargin = NSLayoutConstraint(item: userView, attribute: .Trailing, relatedBy: .LessThanOrEqual,
                                             toItem: view, attribute: .Trailing, multiplier: 1, constant: 15)
        let height = NSLayoutConstraint(item: userView, attribute: .Height, relatedBy: .Equal, toItem: nil,
                                        attribute: .NotAnAttribute, multiplier: 1, constant: 50)
        view.addConstraints([leftMargin, rightMargin, bottomMargin, height])
    }
    
    private func setupRxNavbarBindings(viewModel: ProductViewModel) {
        self.setNavigationBarRightButtons([])
        viewModel.navBarButtons.asObservable().subscribeNext { [weak self] navBarButtons in
            guard let strongSelf = self else { return }
            
            var buttons = [UIButton]()
            navBarButtons.forEach { navBarButton in
                let button = UIButton(type: .System)
                button.setImage(navBarButton.image, forState: .Normal)
                button.rx_tap.bindNext { _ in
                    navBarButton.action()
                    }.addDisposableTo(strongSelf.disposeBag)
                buttons.append(button)
            }
            strongSelf.setNavigationBarRightButtons(buttons)
            }.addDisposableTo(disposeBag)
    }
}


extension ProductCarouselViewController: UserViewDelegate {
    func userViewAvatarPressed(userView: UserView) {
        // TODO
    }
}


// MARK: > ProductCarousel Cell Delegate

extension ProductCarouselViewController: ProductCarouselCellDelegate {
    func didTapOnCarouselCell(cell: UICollectionViewCell) {
        let indexPath = collectionView.indexPathForCell(cell)!
        let newIndexRow = indexPath.row + 1
        if newIndexRow < collectionView.numberOfItemsInSection(0) {
            let nextIndexPath = NSIndexPath(forItem: newIndexRow, inSection: 0)
            collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: .Right, animated: false)
        } else {
            collectionView.showRubberBandEffect(.Right)
        }
    }
}


// MARK: > CollectionView Data Source

extension ProductCarouselViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.productsViewModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProductCarouselCell.identifier,
                                                                             forIndexPath: indexPath)
            guard let carouselCell = cell as? ProductCarouselCell else { return UICollectionViewCell() }
            guard let product = viewModel.productAtIndex(indexPath.row) else { return carouselCell }
            carouselCell.backgroundColor = StyleHelper.productCellImageBgColor
            carouselCell.configureCellWithProduct(product)
            carouselCell.delegate = self
            prefetchImages(indexPath.row)
            prefetchNeighborsImages(indexPath.row)
//            configureWithProduct(viewModel.viewModelForProduct(product))
//            viewModel.moveToProductAtIndex(indexPath.row, delegate: self)
//            refreshOverlayElements()
            return carouselCell
    }
}


// MARK: > Image PreCaching

extension ProductCarouselViewController {
    func prefetchNeighborsImages(index: Int) {
        var imagesToPrefetch: [NSURL] = []
        if let prevProduct = viewModel.productAtIndex(index - 1), let imageUrl = prevProduct.images.first?.fileURL {
            imagesToPrefetch.append(imageUrl)
        }
        if let nextProduct = viewModel.productAtIndex(index + 1), let imageUrl = nextProduct.images.first?.fileURL {
            imagesToPrefetch.append(imageUrl)
        }
        SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs(imagesToPrefetch)
    }
    
    func prefetchImages(index: Int) {
        guard let product = viewModel.productAtIndex(index) else { return }
        let urls = product.images.flatMap({$0.fileURL})
        SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs(urls)
    }
}


// MARK: > Product View Model Delegate

extension ProductCarouselViewController: ProductViewModelDelegate {
    func vmShowNativeShare(message: String) {
        presentNativeShareWith(shareText: message, delegate: self)
    }
    
    func vmOpenEditProduct(editProductVM: EditSellProductViewModel) {
        let vc = EditSellProductViewController(viewModel: editProductVM, updateDelegate: viewModel.currentProductViewModel)
        let navCtl = UINavigationController(rootViewController: vc)
        navigationController?.presentViewController(navCtl, animated: true, completion: nil)
    }
    
    func vmOpenMainSignUp(signUpVM: SignUpViewModel, afterLoginAction: () -> ()) {
        let mainSignUpVC = MainSignUpViewController(viewModel: signUpVM)
        mainSignUpVC.afterLoginAction = afterLoginAction
        
        let navCtl = UINavigationController(rootViewController: mainSignUpVC)
        navCtl.view.backgroundColor = UIColor.whiteColor()
        presentViewController(navCtl, animated: true, completion: nil)
    }
    
    func vmOpenUser(userVM: UserViewModel) {
        let vc = UserViewController(viewModel: userVM)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func vmOpenChat(chatVM: ChatViewModel) {
        let chatVC = ChatViewController(viewModel: chatVM)
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func vmOpenOffer(offerVC: MakeAnOfferViewController) {
        navigationController?.pushViewController(offerVC, animated: true)
    }
    
    func vmOpenPromoteProduct(promoteVM: PromoteProductViewModel) {
//        let promoteProductVC = PromoteProductViewController(viewModel: promoteVM)
//        promoteProductVC.delegate = self
//        navigationController?.presentViewController(promoteProductVC, animated: true, completion: nil)
    }
    
    func vmOpenCommercialDisplay(displayVM: CommercialDisplayViewModel) {
        let commercialDisplayVC = CommercialDisplayViewController(viewModel: displayVM)
        navigationController?.presentViewController(commercialDisplayVC, animated: true, completion: nil)
    }
}


// MARK: > Native Share Delegate

extension ProductCarouselViewController: NativeShareDelegate {
    
    func nativeShareInFacebook() {
        viewModel.currentProductViewModel?.shareInFacebook(.Top)
        viewModel.currentProductViewModel?.shareInFBCompleted()
    }
    
    func nativeShareInTwitter() {
        viewModel.currentProductViewModel?.shareInTwitterActivity()
    }
    
    func nativeShareInEmail() {
        viewModel.currentProductViewModel?.shareInEmail(.Top)
    }
    
    func nativeShareInWhatsApp() {
        viewModel.currentProductViewModel?.shareInWhatsappActivity()
    }
}

