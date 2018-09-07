import CoreLocation
import Result
import RxSwift

// MARK: - LocationManager

final class LGLocationManager: NSObject, CLLocationManagerDelegate, LocationManager {
    
    var didAcceptPermissions: Bool {
        switch locationRepository.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .restricted, .denied, .notDetermined:
            return false
        }
    }
    
    var locationEvents: Observable<LocationEvent> {
        return events
    }

    var lastEmergencyLocation: LGLocation? = nil
    var shouldAskForBackgroundLocationPermission: Bool = false

    // Repositories
    private let myUserRepository: InternalMyUserRepository
    private let locationRepository: LocationRepository

    // DAO
    private let dao: DeviceLocationDAO
    
    // Helpers
    private let countryHelper: CountryHelper
    
    // iVars
    private var lastNotifiedLocation: LGLocation?
    private let events = PublishSubject<LocationEvent>()
    
    private var sessionDisposeBag = DisposeBag()
    
    /**
     Returns if the manual location is enabled.
     */
    private(set) var isManualLocationEnabled: Bool
    
    /**
     When set if last manual location is saved, then if an auto location is received far from it according this
     threshold a `MovedFarFromSavedManualLocation` notification will be posted.
     */
    var manualLocationThreshold: Double
    
    
    // MARK: - Lifecycle
    
    init(myUserRepository: InternalMyUserRepository, locationRepository: LocationRepository,
         deviceLocationDAO: DeviceLocationDAO, countryHelper: CountryHelper) {
        self.myUserRepository = myUserRepository
        
        self.locationRepository = locationRepository
        
        self.dao = deviceLocationDAO
        
        self.countryHelper = countryHelper
        
        self.lastNotifiedLocation = nil
        self.isManualLocationEnabled = false
        
        self.manualLocationThreshold = LGCoreKitConstants.defaultManualLocationThreshold
        
        super.init()
        
        // Setup
        self.locationRepository.setLocationManagerDelegate(delegate: self)
        self.setup()
    }
    
    func initialize() {
        if let location = currentLocation, location.countryCode == nil {
            // we do this for older sessions with valid addresses.
            updateLocation(location)
        } else {
            retrieveInitialLocationIfNeeded()
        }
    }
    
    func observeSessionManager(_ sessionManager: SessionManager) {
        sessionDisposeBag = DisposeBag()
        sessionManager.sessionEvents.subscribeNext { [weak self] event in
            switch event {
            case .login:
                self?.setup()
                self?.checkUserLocationAndUpdate()
            case .logout:
                self?.isManualLocationEnabled = false
            }
            }.disposed(by: sessionDisposeBag)
    }
    
    
    // MARK: > Location
    
    /**
     Returns the current location with the following preference/fallback:
     
     1. User location if its type is manual
     2. Sensor
     3. User location
     4. Device location (IP, or worst case: regional)
     */
    var currentLocation: LGLocation? {
        if let userLocation = myUserRepository.myUser?.location, userLocation.type == .manual {
            return userLocation
        }
        if let deviceLocation = dao.deviceLocation?.location, deviceLocation.type == .sensor {
            return deviceLocation
        }
        if let userLocation = myUserRepository.myUser?.location { return userLocation }
        return  dao.deviceLocation?.location
        
    }
    
    /**
     Returns the best accurate automatic location.
     */
    var currentAutoLocation: LGLocation? {
        return dao.deviceLocation?.location
    }
    
    
    /**
     Sets the given location as manual.
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     - parameter userUpdateCompletion: The `MyUser` update completion closure.
     */
    func setManualLocation(_ location: CLLocation, postalAddress: PostalAddress,
                           completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let lgLocation = LGLocation(location: location, type: .manual, postalAddress: postalAddress) else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Invalid CLLocation")))
            return
        }
        isManualLocationEnabled = true
        
        updateLocation(lgLocation, userUpdateCompletion: completion)
    }
    
    /**
     Sets the location as automatic.
     - parameter userUpdateCompletion: The `MyUser` update completion closure.
     */
    func setAutomaticLocation(_ userUpdateCompletion: ((Result<MyUser, RepositoryError>) -> ())?) {
        isManualLocationEnabled = false
        
        guard let currentAutoLocation = currentAutoLocation else { return }
        updateLocation(currentAutoLocation, userUpdateCompletion: userUpdateCompletion)
    }
    
    /**
     Returns the current location service status.
     */
    var locationServiceStatus: LocationServiceStatus {
        return LocationServiceStatus(enabled: locationRepository.locationEnabled(),
                                     authStatus: locationRepository.authorizationStatus())
    }
    
    
    // MARK: > Sensor location updates
    
    /**
     Starts updating sensor location.
     
     - returns: The location service status.
     */
    func startSensorLocationUpdates() -> LocationServiceStatus {
        let enabled = locationRepository.locationEnabled()
        let authStatus = locationRepository.authorizationStatus()
        
        if enabled {
            // If not determined, ask authorization
            if shouldAskForWhenInUseLocationPermissions() {
                locationRepository.requestWhenInUseAuthorization()
            } else if shouldAskForAlwaysLocationPermission() {
                locationRepository.requestAlwaysAuthorization()
            } else {
                // Otherwise, start the location updates
                locationRepository.startUpdatingLocation()
            }
        }
        return LocationServiceStatus(enabled: enabled, authStatus: authStatus)
    }
    
    /**
     Stops updating location.
     */
    func stopSensorLocationUpdates() {
        locationRepository.stopUpdatingLocation()
    }
    
    
    // MARK: - CLLocationManagerDelegate

    func shouldAskForLocationPermissions() -> Bool {
        return shouldAskForAlwaysLocationPermission() || shouldAskForWhenInUseLocationPermissions()
    }

    func shouldAskForWhenInUseLocationPermissions() -> Bool {
        let status = locationRepository.authorizationStatus()
        return !shouldAskForBackgroundLocationPermission && status == .notDetermined
    }

    func shouldAskForAlwaysLocationPermission() -> Bool {
        let status = locationRepository.authorizationStatus()
        return shouldAskForBackgroundLocationPermission && (status == .notDetermined || status == .authorizedWhenInUse)
    }
    
    /*
     Warning, this method will be called on app launch because it's called when the CLLOcationManager it's initialized.
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        defer { dao.save(status) }
        
        if didAcceptPermissions {
            _ = startSensorLocationUpdates()
        }
        
        // Only notify if there really is a change in the auth status, not always
        guard let currentStatus = dao.locationStatus, currentStatus != status else { return }
        
        events.onNext(.changedPermissions)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        // there is no postalAddress at that point, it will update on updateLocation
        guard let newLocation = LGLocation(location: lastLocation, type: .sensor, postalAddress: nil) else { return }
        updateLocation(newLocation)
    }
    
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    /**
     Setup.
     */
    private func setup() {
        isManualLocationEnabled = myUserRepository.myUser?.location?.type == .manual
    }
    
    
    // MARK: > Innacurate location & address retrieval
    
    /**
     Requests the IP lookup location retrieval and, if fails it uses the regional.
     */
    private func retrieveInitialLocationIfNeeded() {
        if let currentLocationType = currentLocation?.type, currentLocationType > .ipLookup { return }
        locationRepository.retrieveIPLookupLocation { [weak self] (result: IPLookupLocationRepositoryResult) -> Void in
            if let strongSelf = self {
                if let currentLocationType = strongSelf.currentLocation?.type, currentLocationType > .ipLookup { return }
                // If there's no previous location or is with lower priority. it should update
                var newLocation: LGLocation? = nil
                if let coordinates = result.value {
                    newLocation = LGLocation(latitude: coordinates.latitude, longitude: coordinates.longitude,
                                             type: .ipLookup, postalAddress: nil)
                } else {
                    newLocation = LGLocation(coordinate: strongSelf.countryHelper.regionCoordinate, type: .regional, postalAddress: nil)
                }
                if let location = newLocation { strongSelf.updateLocation(location) }
            }
        }
    }
    
    
    /**
     Retrieves the postal address for the given location and updates my user & installation.
     - parameter location: The location to retrieve the postal address from.
     - parameter completion: The completion closure, what will be called on user update.
     */
    private func retrievePostalAddressAndUpdate(_ location: LGLocation,
                                                completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        locationRepository.retrievePostalAddress(location: location.location) { [weak self] result in
            let postalAddress = result.value?.postalAddress ?? PostalAddress.emptyAddress()
            let newLocation = location.updating(postalAddress: postalAddress)
            self?.updateLocation(newLocation, userUpdateCompletion: completion)
        }
    }
    
    
    // MARK: > Location update
    
    
    /**
     Updates location and postal address in my user & installation, and runs recursively if `postalAddress` is `nil`
     after retrieving it.
     - parameter location: The location.
     - parameter userUpdateCompletion: The completion closure for `MyUser` update.
     */
    private func updateLocation(_ location: LGLocation,
                                userUpdateCompletion: ((Result<MyUser, RepositoryError>) -> ())? = nil) {

        // If the emergency mode is active. Ignore all the checks and publish the new location.
        if locationRepository.emergencyIsActive {
            lastEmergencyLocation = location
            events.onNext(.emergencyLocationUpdate)
        }

        if let _ = location.postalAddress {
            let deviceLocationUpdated = updateDeviceLocation(location)
            let userLocationUpdated = updateUserLocation(location, completion: userUpdateCompletion)
            if deviceLocationUpdated || userLocationUpdated {
                handleLocationUpdate()
            }
        } else {
            retrievePostalAddressAndUpdate(location, completion: userUpdateCompletion)
        }
    }
    
    /**
     Updates location and postal address in `DeviceLocation`.
     - parameter location: The location.
     - returns:  If device location was updated or not.
     */
    private func updateDeviceLocation(_ location: LGLocation) -> Bool {
        var updatedDeviceLocation: DeviceLocation? = nil
        if let deviceLocation = dao.deviceLocation {
            if deviceLocation.shouldReplaceWithNewLocation(location) {
                updatedDeviceLocation = LGDeviceLocation(location: location)
            }
        } else {
            // If non-cached device location then create a new one
            updatedDeviceLocation = LGDeviceLocation(location: location)
        }
        if let updatedDeviceLocation = updatedDeviceLocation {
            dao.save(updatedDeviceLocation)
        }
        return updatedDeviceLocation != nil
    }
    
    /**
     Updates location and postal address in `MyUser`.
     - parameter location: The location.
     - parameter completion: The completion closure.
     - returns If userLocation will be updated or not
     */
    private func updateUserLocation(_ location: LGLocation,
                                    completion: ((Result<MyUser, RepositoryError>) -> ())? = nil) -> Bool {
        guard let myUser = myUserRepository.myUser else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
            return false
        }
        let willUpdateUserLocation: Bool
        checkFarAwayMovementAndNotify(myUser: myUser, location: location)
        
        if myUser.shouldReplaceWithNewLocation(location, manualLocationEnabled: isManualLocationEnabled) {
            willUpdateUserLocation = true
            let myCompletion: (Result<MyUser, RepositoryError>) -> () = { [weak self] result in
                self?.handleLocationUpdate()
                completion?(result)
            }
            myUserRepository.updateLocation(location, completion: myCompletion)
        } else {
            //We're not updating location but everything is ok
            completion?(Result<MyUser, RepositoryError>(value: myUser))
            willUpdateUserLocation = false
        }
        return willUpdateUserLocation
    }
    
    
    /**
     If the last saved location in myUser is manual, the new location is not manual and are far away enough
     then post a notification
     - parameter location: the new location
     */
    private func checkFarAwayMovementAndNotify(myUser: MyUser, location: LGLocation) {
        if let myUserLocation = myUser.location, myUserLocation.type == .manual && location.type != .manual &&
            myUserLocation.distanceFromLocation(location) > manualLocationThreshold {
            
            events.onNext(.movedFarFromSavedManualLocation)
        }
    }
    
    /**
     Handles a location update.
     */
    private func handleLocationUpdate() {
        guard let currentLocation = currentLocation, currentLocation != lastNotifiedLocation else { return }
        
        lastNotifiedLocation = currentLocation
        events.onNext(.locationUpdate)
    }
    
    
    /**
     Checks current user and updates user location if needed
     */
    private func checkUserLocationAndUpdate() {
        guard let myUser = myUserRepository.myUser else { return }
        
        guard let location = dao.deviceLocation?.location, let _ = dao.deviceLocation?.postalAddress else {
            return
        }
        if myUser.shouldReplaceWithNewLocation(location, manualLocationEnabled: isManualLocationEnabled) {
            myUserRepository.updateLocation(location, completion: nil)
        }
    }
}


// MARK: - MyUser

private extension MyUser {
    func shouldReplaceWithNewLocation(_ newLocation: LGLocation, manualLocationEnabled: Bool) -> Bool {
        guard let savedLocationType = location?.type else { return true }
        let newLocationType = newLocation.type
        
        switch savedLocationType {
        case .ipLookup:
            switch newLocationType {
            case .ipLookup, .manual, .sensor:
                return true
            case .regional:
                return false
            }
        case .manual:
            switch newLocationType {
            case .manual:
                return true
            case .ipLookup, .sensor, .regional:
                return !manualLocationEnabled
            }
        case .regional:
            switch newLocationType {
            case .ipLookup:
                return false
            case .regional, .manual, .sensor:
                return true
            }
        case .sensor:
            switch newLocationType {
            case .ipLookup, .regional:
                return false
            case .manual, .sensor:
                return true
            }
        }
    }
}


// MARK: - DeviceLocation

private extension DeviceLocation {
    func shouldReplaceWithNewLocation(_ newLocation: LGLocation) -> Bool {
        guard let savedLocationType = location?.type else { return true }
        let newLocationType = newLocation.type
        
        switch savedLocationType {
        case .ipLookup:
            switch newLocationType {
            case .ipLookup, .sensor:
                return true
            case .manual, .regional:
                return false
            }
        case .manual, .regional:
            switch newLocationType {
            case .ipLookup, .manual:
                return false
            case .regional, .sensor:
                return true
            }
        case .sensor:
            switch newLocationType {
            case .ipLookup, .regional, .manual:
                return false
            case .sensor:
                return true
            }
        }
    }
}

