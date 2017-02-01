//
//  ProductCarouselMoreInfoView.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import MapKit
import LGCoreKit
import RxSwift
import LGCollapsibleLabel

enum MoreInfoState {
    case hidden
    case moving
    case shown
}

protocol ProductCarouselMoreInfoDelegate: class {
    func didEndScrolling(_ topOverScroll: CGFloat, bottomOverScroll: CGFloat)
    func requestFocus()
    func viewControllerToShowShareOptions() -> UIViewController
}

extension MKMapView {
    // Create a unique isntance of MKMapView due to: http://stackoverflow.com/questions/36417350/mkmapview-using-a-lot-of-memory-each-time-i-load-its-view
    @nonobjc static let sharedInstance = MKMapView()
}

class ProductCarouselMoreInfoView: UIView {

    fileprivate static let relatedItemsHeight: CGFloat = 80
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var autoTitleLabel: UILabel!
    @IBOutlet weak var transTitleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewContent: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var visualEffectViewBottom: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: LGCollapsibleLabel!
    @IBOutlet weak var statsContainerView: UIView!
    @IBOutlet weak var statsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var statsContainerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dragView: UIView!
    @IBOutlet weak var dragViewTitle: UILabel!
    @IBOutlet weak var dragViewImage: UIImageView!

    fileprivate let mapView: MKMapView = MKMapView.sharedInstance
    fileprivate var vmRegion: MKCoordinateRegion? = nil
    @IBOutlet weak var mapViewContainer: UIView!
    fileprivate var mapViewContainerExpandable: UIView? = nil
    fileprivate var mapViewTapGesture: UITapGestureRecognizer? = nil
    
    @IBOutlet weak var socialShareContainer: UIView!
    @IBOutlet weak var socialShareTitleLabel: UILabel!
    @IBOutlet weak var socialShareView: SocialShareView!

    fileprivate let disposeBag = DisposeBag()
    fileprivate var currentVmDisposeBag = DisposeBag()
    fileprivate var viewModel: ProductViewModel?
    fileprivate var locationZone: MKOverlay?
    fileprivate let bigMapMargin: CGFloat = 65.0
    fileprivate let bigMapBottomMargin: CGFloat = 210
    fileprivate(set) var mapExpanded: Bool = false
    fileprivate var mapZoomBlocker: MapZoomBlocker?
    fileprivate var statsView: ProductStatsView?

    fileprivate let statsContainerViewHeight: CGFloat = 24
    fileprivate let statsContainerViewTop: CGFloat = 26
    fileprivate var initialDragYposition: CGFloat = 0
    fileprivate var scrollBottomInset: CGFloat {
        guard let status = viewModel?.status.value else { return 0 }
        // Needed to avoid drawing content below the chat button
        switch status {
        case .pending, .otherSold, .notAvailable, .otherSoldFree:
            // No buttons in the bottom
            return 0
        case .pendingAndCommercializable, .available, .sold, .otherAvailable, .availableAndCommercializable, .availableFree, .otherAvailableFree, .soldFree:
            // Has a button in the bottom
            return 80
        }
    }

    weak var delegate: ProductCarouselMoreInfoDelegate?

    static func moreInfoView() -> ProductCarouselMoreInfoView {
        return moreInfoView(FeatureFlags.sharedInstance)
    }

    static func moreInfoView(_ featureFlags: FeatureFlaggeable) -> ProductCarouselMoreInfoView {
        guard let view = Bundle.main.loadNibNamed("ProductCarouselMoreInfoView", owner: self, options: nil)?.first
            as? ProductCarouselMoreInfoView else { return ProductCarouselMoreInfoView() }
        view.setupUI(featureFlags)
        view.setupStatsView()
        view.setAccessibilityIds()
        view.addGestures()
        return view
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setViewModel(_ viewModel: ProductViewModel) {
        self.viewModel = viewModel
        currentVmDisposeBag = DisposeBag()
        configureContent(currentVmDisposeBag)
        configureMapView(with: viewModel)
        configureStatsRx(currentVmDisposeBag)
        configureBottomPanel()
    }

    func viewWillShow() {
        setupMapViewIfNeeded()
    }

    func dismissed() {
        scrollView.contentOffset = CGPoint.zero
        descriptionLabel.collapsed = true
    }
    
    deinit {
        // MapView is a shared instance and all references must be removed
        cleanMapView()
    }
}


// MARK: - Gesture Intections 

extension ProductCarouselMoreInfoView {
    func addGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(compressMap))
        visualEffectView.addGestureRecognizer(tap)
    }
}


// MARK: - MapView stuff

extension ProductCarouselMoreInfoView: MKMapViewDelegate {

    func setupMapViewIfNeeded() {
        let container = mapExpanded ? mapViewContainerExpandable : mapViewContainer
        guard let theContainer = container, mapView.superview != theContainer else { return }
        setupMapView(inside: theContainer)
        guard let coordinate = viewModel?.productLocation.value else { return }
        addRegion(with: coordinate, zoomBlocker: true)
    }
    
    func setupMapView(inside container: UIView) {
        layoutMapView(inside: container)
        addMapGestures()
    }
    
    private func layoutMapView(inside container: UIView) {
        if mapView.superview != nil {
            mapView.removeFromSuperview()
        }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(mapView)
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .left, relatedBy: .equal,
            toItem: container, attribute: .left, multiplier: 1, constant: 0))
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .right, relatedBy: .equal,
            toItem: container, attribute: .right, multiplier: 1, constant: 0))
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal,
            toItem: container, attribute: .top, multiplier: 1, constant: 0))
        container.addConstraint(NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal,
            toItem: container, attribute: .bottom, multiplier: 1, constant: 8))
    }
    
    private func addMapGestures() {
        removeMapGestures()
        mapViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap))
        guard let mapViewTapGesture = mapViewTapGesture else { return }
        mapView.addGestureRecognizer(mapViewTapGesture)
    }
    
    private func removeMapGestures() {
        mapView.gestureRecognizers?.forEach { mapView.removeGestureRecognizer($0) }
    }
    
    fileprivate func cleanMapView() {
        // Clean only references related to current More Info View
        mapZoomBlocker?.mapView = nil
        if let mapViewTapGesture = mapViewTapGesture, let gestures = mapView.gestureRecognizers, gestures.contains(mapViewTapGesture) {
                mapView.removeGestureRecognizer(mapViewTapGesture)
        }
        if mapView.superview == mapViewContainer || mapView.superview == mapViewContainerExpandable {
            mapView.removeFromSuperview()
        }
    }
    
    dynamic func didTapMap() {
        mapExpanded ? compressMap() : expandMap()
    }

    func setupMapExpanded(_ enabled: Bool) {
        mapExpanded = enabled
        mapView.isZoomEnabled = enabled
        mapView.isScrollEnabled = enabled
        mapView.isPitchEnabled = enabled
    }

    func configureMapView(with viewModel: ProductViewModel?) {
        guard let coordinate = viewModel?.productLocation.value else { return }
        addRegion(with: coordinate, zoomBlocker: true)
        setupMapExpanded(false)
        locationZone = MKCircle(center:coordinate.coordinates2DfromLocation(),
                                radius: Constants.accurateRegionRadius)
    }
    
    func addRegion(with coordinate: LGLocationCoordinates2D, zoomBlocker: Bool) {
        let clCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        vmRegion = MKCoordinateRegionMakeWithDistance(clCoordinate, Constants.accurateRegionRadius*2, Constants.accurateRegionRadius*2)
        guard let region = vmRegion else { return }
        mapView.setRegion(region, animated: false)
        
        if zoomBlocker {
            mapZoomBlocker = MapZoomBlocker(mapView: mapView, minLatDelta: region.span.latitudeDelta,
                                            minLonDelta: region.span.longitudeDelta)
            mapZoomBlocker?.delegate = self
        }
    }
    
    func expandMap() {
        guard !mapExpanded else { return }
        if mapViewContainerExpandable == nil {
            mapViewContainerExpandable = UIView()
        }
        guard let mapViewContainerExpandable = mapViewContainerExpandable else { return }
        addSubview(mapViewContainerExpandable)
        mapViewContainerExpandable.frame = convert(mapViewContainer.frame, from: scrollViewContent)
        layoutMapView(inside: mapViewContainerExpandable)
        
        if let locationZone = self.locationZone {
            mapView.add(locationZone)
        }
        
        self.delegate?.requestFocus()
        var expandedFrame = mapViewContainerExpandable.frame
        expandedFrame.origin.y = bigMapMargin
        expandedFrame.size.height = height - bigMapBottomMargin
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapViewContainerExpandable?.frame = expandedFrame
            self?.mapViewContainerExpandable?.layoutIfNeeded()
            }, completion: { [weak self] completed in
                self?.setupMapExpanded(true)
        })
    }
    
    func compressMap() {
        guard mapExpanded else { return }
        
        let compressedFrame = convert(mapViewContainer.frame, from: scrollViewContent)
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.mapViewContainerExpandable?.frame = compressedFrame
            self?.mapViewContainerExpandable?.layoutIfNeeded()
            }, completion: { [weak self] completed in
                guard let strongSelf = self else { return }
                strongSelf.setupMapExpanded(false)
                if let locationZone = strongSelf.locationZone {
                    strongSelf.mapView.remove(locationZone)
                }
                strongSelf.layoutMapView(inside: strongSelf.mapViewContainer)
                strongSelf.mapViewContainerExpandable?.removeFromSuperview()
                strongSelf.mapZoomBlocker?.stop()
                if let region = strongSelf.vmRegion {
                    strongSelf.mapView.setRegion(region, animated: true)
                }
        })
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
            return renderer
        }
        return MKCircleRenderer()
    }
}

extension ProductCarouselMoreInfoView: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        initialDragYposition = min(max(scrollView.contentOffset.y, 0), bottomScrollLimit)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomOverScroll = max(scrollView.contentOffset.y - bottomScrollLimit, 0)
        visualEffectViewBottom.constant = -bottomOverScroll
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let topOverScroll = abs(min(0, scrollView.contentOffset.y))
        let bottomOverScroll = max(scrollView.contentOffset.y - bottomScrollLimit, 0)
        delegate?.didEndScrolling(topOverScroll, bottomOverScroll: bottomOverScroll)
    }

    var bottomScrollLimit: CGFloat {
        return max(0, scrollView.contentSize.height - scrollView.height + scrollView.contentInset.bottom)
    }
}


// MARK: - Private

fileprivate extension ProductCarouselMoreInfoView {
    func setupUI(_ featureFlags: FeatureFlaggeable) {
        
        setupMapView(inside: mapViewContainer)
        mapView.layer.cornerRadius = LGUIKitConstants.mapCornerRadius
        mapView.clipsToBounds = true
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: scrollBottomInset, right: 0)
        
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.productTitleFont
        
        priceLabel.textColor = UIColor.white
        priceLabel.font = UIFont.productPriceFont
        
        autoTitleLabel.textColor = UIColor.white
        autoTitleLabel.font = UIFont.productTitleDisclaimersFont
        autoTitleLabel.alpha = 0.5
        
        transTitleLabel.textColor = UIColor.white
        transTitleLabel.font = UIFont.productTitleDisclaimersFont
        transTitleLabel.alpha = 0.5
        
        addressLabel.textColor = UIColor.white
        addressLabel.font = UIFont.productAddresFont
        
        distanceLabel.textColor = UIColor.white
        distanceLabel.font = UIFont.productDistanceFont

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescriptionState))
        descriptionLabel.textColor = UIColor.grayLight
        descriptionLabel.addGestureRecognizer(tapGesture)
        descriptionLabel.expandText = LGLocalizedString.commonExpand.uppercase
        descriptionLabel.collapseText = LGLocalizedString.commonCollapse.uppercase
        descriptionLabel.gradientColor = UIColor.clear
        descriptionLabel.expandTextColor = UIColor.white

        setupSocialShareView()

        dragView.rounded = true
        dragView.layer.borderColor = UIColor.white.cgColor
        dragView.layer.borderWidth = 1
        dragView.backgroundColor = UIColor.clear
        
        dragViewTitle.text = LGLocalizedString.productMoreInfoOpenButton
        dragViewTitle.textColor = UIColor.white
        dragViewTitle.font = UIFont.systemSemiBoldFont(size: 13)
        
        [dragView, dragViewTitle, dragViewImage].forEach { view in
            view?.layer.shadowColor = UIColor.black.cgColor
            view?.layer.shadowOpacity = 0.5
            view?.layer.shadowRadius = 1
            view?.layer.shadowOffset = CGSize.zero
            view?.layer.masksToBounds = false
        }
        
        scrollView.delegate = self
    }

    func setupStatsView() {
        statsContainerViewHeightConstraint.constant = 0.0
        statsContainerViewTopConstraint.constant = 0.0

        guard let statsView = ProductStatsView.productStatsView() else { return }
        self.statsView = statsView
        statsContainerView.addSubview(statsView)

        statsView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: statsView, attribute: .top, relatedBy: .equal, toItem: statsContainerView,
                                     attribute: .top, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: statsView, attribute: .trailing, relatedBy: .equal, toItem: statsContainerView,
                                       attribute: .trailing, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint(item: statsView, attribute: .leading, relatedBy: .equal, toItem: statsContainerView,
                                       attribute: .leading, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: statsView, attribute: .bottom, relatedBy: .equal, toItem: statsContainerView,
                                     attribute: .bottom, multiplier: 1, constant: 0)
        statsContainerView.addConstraints([top, right, left, bottom])
    }

    func setupSocialShareView() {
        socialShareTitleLabel.textColor = UIColor.white
        socialShareTitleLabel.font = UIFont.productSocialShareTitleFont
        socialShareTitleLabel.text = LGLocalizedString.productShareTitleLabel

        socialShareView.delegate = self
        socialShareView.style = .grid
        socialShareView.gridColumns = 5
        switch DeviceFamily.current {
        case .iPhone4, .iPhone5:
            socialShareView.buttonsSide = 50
        default: break
        }
    }


    // MARK: > Configuration (each view model)

    func configureContent(_ disposeBag: DisposeBag) {
        guard let viewModel = viewModel else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: scrollBottomInset, right: 0)

        titleLabel.text = viewModel.productTitle.value
        priceLabel.text = viewModel.productPrice.value
        autoTitleLabel.text = viewModel.productTitleAutogenerated.value ?
            LGLocalizedString.productAutoGeneratedTitleLabel : nil
        transTitleLabel.text = viewModel.productTitleAutoTranslated.value ?
            LGLocalizedString.productAutoGeneratedTranslatedTitleLabel : nil

        addressLabel.text = viewModel.productAddress.value
        distanceLabel.text = viewModel.productDistance.value

        viewModel.productDescription.asObservable().bindTo(descriptionLabel.rx.optionalMainText)
            .addDisposableTo(disposeBag)
    }

    func configureStatsRx(_ disposeBag: DisposeBag) {
        guard let viewModel = viewModel else { return }
        viewModel.statsViewVisible.asObservable().distinctUntilChanged().bindNext { [weak self] visible in
            self?.statsContainerViewHeightConstraint.constant = visible ? self?.statsContainerViewHeight ?? 0 : 0
            self?.statsContainerViewTopConstraint.constant = visible ? self?.statsContainerViewTop ?? 0 : 0
        }.addDisposableTo(disposeBag)

        let infos = Observable.combineLatest(viewModel.viewsCount.asObservable(), viewModel.favouritesCount.asObservable(),
                                             viewModel.productCreationDate.asObservable()) { $0 }
        infos.subscribeNext { [weak self] (views, favorites, date) in
                guard let statsView = self?.statsView else { return }
                statsView.updateStatsWithInfo(views, favouritesCount: favorites, postedDate: date)
        }.addDisposableTo(disposeBag)
    }

    func configureBottomPanel() {
        guard let viewModel = viewModel else { return }

        socialShareView.socialMessage = viewModel.socialMessage.value
        socialShareView.socialSharer = viewModel.socialSharer
    }
}


// MARK: - LGCollapsibleLabel

extension ProductCarouselMoreInfoView {
    func toggleDescriptionState() {
        UIView.animate(withDuration: 0.25, animations: {
            self.descriptionLabel.toggleState()
            self.layoutIfNeeded()
        }) 
    }
}


// MARK: - SocialShareViewDelegate

extension ProductCarouselMoreInfoView: SocialShareViewDelegate {
    func viewController() -> UIViewController? {
        return delegate?.viewControllerToShowShareOptions()
    }
}


// MARK: - Accessibility ids

extension ProductCarouselMoreInfoView {
    fileprivate func setAccessibilityIds() {
        scrollView.accessibilityId = .productCarouselMoreInfoScrollView
        titleLabel.accessibilityId = .productCarouselMoreInfoTitleLabel
        transTitleLabel.accessibilityId = .productCarouselMoreInfoTransTitleLabel
        addressLabel.accessibilityId = .productCarouselMoreInfoAddressLabel
        distanceLabel.accessibilityId = .productCarouselMoreInfoDistanceLabel
        mapView.accessibilityId = .productCarouselMoreInfoMapView
        socialShareTitleLabel.accessibilityId = .productCarouselMoreInfoSocialShareTitleLabel
        socialShareView.accessibilityId = .productCarouselMoreInfoSocialShareView
        descriptionLabel.accessibilityId = .productCarouselMoreInfoDescriptionLabel
    }
}
