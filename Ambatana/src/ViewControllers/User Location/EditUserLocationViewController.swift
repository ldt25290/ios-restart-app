//
//  EditUserLocationViewController.swift
//  LetGo
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import UIKit
import MapKit
import LGCoreKit
import RxSwift
import RxCocoa
import Result

class EditUserLocationViewController: BaseViewController, EditUserLocationViewModelDelegate, MKMapViewDelegate,
UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    // UI
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchField: LGTextField!
    
    @IBOutlet weak var approximateLocationSwitch: UISwitch!
    @IBOutlet weak var approximateLocationLabel: UILabel!

    @IBOutlet weak var gpsLocationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var setLocationButton: UIButton!
    @IBOutlet weak var setLocationLoading: UIActivityIndicatorView!

    @IBOutlet weak var suggestionsTableView : UITableView!

    @IBOutlet weak var aproxLocationArea: UIView!
    @IBOutlet weak var poiImage: UIImageView!
    @IBOutlet weak var poiInfoContainer: UIView!
    @IBOutlet weak var addressTopText: UILabel!
    @IBOutlet weak var addressBottomText: UILabel!


    var applyBarButton : UIBarButtonItem!

    let viewModel: EditUserLocationViewModel
    //Rx
    let disposeBag = DisposeBag()


    // MARK: - Lifecycle

    convenience init() {
        self.init(viewModel: EditUserLocationViewModel())
    }
    
    init(viewModel: EditUserLocationViewModel) {
        self.viewModel = EditUserLocationViewModel()
        super.init(viewModel: nil, nibName: "EditUserLocationViewController")
        self.viewModel.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setRxBindings()
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
////        approximateLocationSwitch.on = viewModel.approximateLocation
////        viewModel.showInitialUserLocation()
//    }

//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

    
    @IBAction func searchButtonPressed() {
        goToLocation(nil)
    }

    @IBAction func gpsLocationButtonPressed() {
        viewModel.showGPSUserLocation()
    }

    @IBAction func approximateLocationSwitchChanged() {
//        viewModel.approximateLocation = approximateLocationSwitch.on
//        viewModel.updateApproximateSwitchChanged()
    }

    func goToLocation(resultsIndex: Int?) {
        // Dismissing keyboard so that it doesn't show up after searching. If it fails we will show it programmaticaly
        searchField.resignFirstResponder()
        
        viewModel.goToLocation(resultsIndex)
    }

    func applyBarButtonPressed() {
        viewModel.applyLocation()
    }
    
    
    // MARK: - view model delegate methods
    
    func viewModelDidStartSearchingLocation(viewModel: EditUserLocationViewModel) {
        showLoadingMessageAlert()
    }

    func viewModel(viewModel: EditUserLocationViewModel, updateTextFieldWithString locationName: String) {
        self.searchField.text = locationName
    }

 
    func viewModel(viewModel: EditUserLocationViewModel, updateSearchTableWithResults results: [String]) {

        /*If searchfield is not first responder means user is not typing so doesn't make sense to show/update 
        suggestions table*/
        if !searchField.isFirstResponder() {
            return
        }
        
        let newHeight = CGFloat(results.count*44)
        suggestionsTableView.frame = CGRectMake(suggestionsTableView.frame.origin.x,
            suggestionsTableView.frame.origin.y, suggestionsTableView.frame.size.width, newHeight);
        suggestionsTableView.hidden = false
        suggestionsTableView.reloadData()
    }
    
    func viewModelDidFailFindingSuggestions(viewModel: EditUserLocationViewModel) {
        suggestionsTableView.hidden = true
    }

    
    func viewModel(viewModel: EditUserLocationViewModel,
        didFailToFindLocationWithResult result: SearchLocationSuggestionsServiceResult) {
        
            var completion: (() -> Void)? = nil
            
            switch (result) {
            case .Success:
                completion = { [weak self] in
                    self?.showAutoFadingOutMessageAlert(LGLocalizedString.changeLocationErrorSearchLocationMessage)
                }
                break
            case .Failure(let error):
                let message: String
                switch (error) {
                case .Network:
                    message = LGLocalizedString.changeLocationErrorSearchLocationMessage
                case .Internal:
                    message = LGLocalizedString.changeLocationErrorSearchLocationMessage
                case .NotFound:
                    message = LGLocalizedString.changeLocationErrorUnknownLocationMessage(searchField.text ?? "")
                }
                completion = { [weak self] in
                    self?.showAutoFadingOutMessageAlert(message)
                }
            }
            
            dismissLoadingMessageAlert(completion)
            
            // Showing keyboard again as the user must update the text
            searchField.becomeFirstResponder()
    }

    
    func viewModel(viewModel: EditUserLocationViewModel, centerMapInLocation location: CLLocationCoordinate2D,
        withPostalAddress postalAddress: PostalAddress?, approximate: Bool) {
            dismissLoadingMessageAlert()
//            centerMapInLocation(location, withPostalAddress: postalAddress, approximate: approximate)
            viewModel.goingToLocation = false
    }

    func viewModelDidStartApplyingLocation(viewModel: EditUserLocationViewModel) {
        showLoadingMessageAlert()
    }

    func viewModelDidApplyLocation(viewModel: EditUserLocationViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.popBackViewController()
        }
    }

    func viewModelDidFailApplyingLocation(viewModel: EditUserLocationViewModel) {
        dismissLoadingMessageAlert() { [weak self] in
            self?.showAutoFadingOutMessageAlert(LGLocalizedString.commonError)
        }
    }

    // MARK: - MapView methods
    
//    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        
//        let newAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationViewID")
//        let image = UIImage(named: "map_pin")
//        let imageHeight = image?.size.height ?? 0
//        newAnnotationView.image = image
////        newAnnotationView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.0)
//        newAnnotationView.centerOffset = CGPoint(x: 0, y: imageHeight / 2)
//        newAnnotationView.annotation = annotation
//        newAnnotationView.canShowCallout = true
//
//        return newAnnotationView
//    }

    
//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKCircle {
//            let renderer = MKCircleRenderer(overlay: overlay)
//            renderer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.10)
//            return renderer
//        }
//        return MKCircleRenderer();
//    }

    
    // MARK: - textFieldDelegate methods

    
    // "touchesBegan" used to hide the keyboard when touching outside the textField
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchField.resignFirstResponder()
        super.touchesBegan(touches, withEvent: event)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            if let tfText = textField.text {
                let searchText = (tfText as NSString).stringByReplacingCharactersInRange(range, withString: string)
                
                if searchText.isEmpty {
                    suggestionsTableView.hidden = true
                }
            }
            return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        suggestionsTableView.hidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if let textFieldText = textField.text {
            if textFieldText.characters.count < 1 { return true }

        }
        
        suggestionsTableView.hidden = true

        goToLocation(nil)
        
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        suggestionsTableView.hidden = true
        
        return true
    }
    
    
    // MARK: UITableViewDelegate Methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.predictiveResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) 
        
        cell.textLabel!.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        cell.selectionStyle = .None
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.searchField.text = viewModel.placeResumedDataAtPosition(indexPath.row)
        suggestionsTableView.hidden = true
        goToLocation(indexPath.row)
    }
    
    // MARK : - private methods
    
    private func setupUI() {
        
        searchField.insetX = 40
        searchField.placeholder = LGLocalizedString.changeLocationSearchFieldHint
        searchField.layer.cornerRadius = StyleHelper.defaultCornerRadius
        searchField.layer.borderColor = StyleHelper.lineColor.CGColor
        searchField.layer.borderWidth = StyleHelper.onePixelSize
        suggestionsTableView.layer.cornerRadius = StyleHelper.defaultCornerRadius
        suggestionsTableView.layer.borderColor = StyleHelper.lineColor.CGColor
        suggestionsTableView.layer.borderWidth = StyleHelper.onePixelSize
        setLocationButton.setPrimaryStyle()
        gpsLocationButton.layer.cornerRadius = 10
        aproxLocationArea.layer.cornerRadius = aproxLocationArea.width / 2
        poiInfoContainer.layer.cornerRadius = StyleHelper.defaultCornerRadius
        StyleHelper.applyDefaultShadow(poiInfoContainer.layer)
        poiInfoContainer.hidden = true
        poiImage.hidden = true
        aproxLocationArea.hidden = true

        // i18n
        approximateLocationLabel.text = LGLocalizedString.changeLocationApproximateLocationLabel

        self.setLetGoNavigationBarStyle(LGLocalizedString.changeLocationTitle)
        
        applyBarButton = UIBarButtonItem(title: LGLocalizedString.changeLocationApplyButton,
            style: UIBarButtonItemStyle.Plain, target: self, action: Selector("applyBarButtonPressed"))
        self.navigationItem.rightBarButtonItem = applyBarButton;

        suggestionsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func setRxBindings() {

        //Search
        searchField.rx_text.debounce(0.3, scheduler: MainScheduler.instance).subscribeNext{ [weak self] text in
            guard let searchField = self?.searchField where searchField.isFirstResponder() else { return }
            self?.viewModel.searchText.value = text
        }.addDisposableTo(disposeBag)
        viewModel.placeInfoText.asObservable().bindTo(searchField.rx_text).addDisposableTo(disposeBag)

        //Info
        viewModel.placeTitle.asObservable().bindTo(addressTopText.rx_text).addDisposableTo(disposeBag)
        viewModel.placeSubtitle.asObservable().bindTo(addressBottomText.rx_text).addDisposableTo(disposeBag)
        viewModel.approxLocation.asObservable().subscribeNext({ [weak self] approximate in
            self?.poiInfoContainer.hidden = approximate
            self?.poiImage.hidden = approximate
            self?.aproxLocationArea.hidden = !approximate
        }).addDisposableTo(disposeBag)

        //Approximate location switch
        approximateLocationSwitch.rx_value.bindTo(viewModel.approxLocation).addDisposableTo(disposeBag)
        viewModel.approxLocation.asObservable().bindTo(approximateLocationSwitch.rx_value).addDisposableTo(disposeBag)
        viewModel.approxLocation.asObservable().subscribeNext({ [weak self] approximate in
            guard let location = self?.viewModel.placeLocation.value else { return }
            self?.centerMapInLocation(location, approximate: approximate)
        }).addDisposableTo(disposeBag)

        //Location change
        viewModel.placeLocation.asObservable().subscribeNext({ [weak self] location in
            guard let strongSelf = self, location = location else { return }
            strongSelf.centerMapInLocation(location, approximate: strongSelf.viewModel.approxLocation.value)
        }).addDisposableTo(disposeBag)
    }

    private func centerMapInLocation(coordinate: CLLocationCoordinate2D, approximate: Bool) {
        let radius = approximate ? Constants.nonAccurateRegionRadius : Constants.accurateRegionRadius
        let region = MKCoordinateRegionMakeWithDistance(coordinate, radius, radius)
        mapView.setRegion(region, animated: true)
    }
}
