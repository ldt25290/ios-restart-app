//
//  LocationManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 28/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result
import RxSwift

public enum LocationEvent {
    case locationUpdate
    case movedFarFromSavedManualLocation
    case changedPermissions
}

public protocol LocationManager {

    var locationEvents: Observable<LocationEvent> { get }

    var didAcceptPermissions: Bool { get }
    var isManualLocationEnabled: Bool { get }
    var manualLocationThreshold: Double { get }

    func initialize()
    
    // MARK: > Location
    
    /**
    Returns the current location with the following preference/fallback:

        1. User location if its type is manual
        2. Sensor
        3. User location
        4. Device location
        5. Inaccurate (IP, or worst case: regional)
    */
    var currentLocation: LGLocation? { get }

    /**
    Returns the best accurate automatic location.
    */
    var currentAutoLocation: LGLocation? { get }

    /**
    Sets the given location as manual.
    - parameter location: The location.
    - parameter postalAddress: The postal address.
    - parameter userUpdateCompletion: The `MyUser` update completion closure.
    */
    func setManualLocation(_ location: CLLocation, postalAddress: PostalAddress, completion: MyUserCompletion?)

    /**
    Sets the location as automatic.
    - parameter userUpdateCompletion: The `MyUser` update completion closure.
    */
    func setAutomaticLocation(_ userUpdateCompletion: MyUserCompletion?)

    /**
    Returns the current location service status.
    */
    var locationServiceStatus: LocationServiceStatus { get }


    // MARK: > Sensor location updates

    /**
    Starts updating sensor location.

    - returns: The location service status.
    */
    @discardableResult
    func startSensorLocationUpdates() -> LocationServiceStatus

    /**
    Stops updating location.
    */
    func stopSensorLocationUpdates()

    func shouldAskForLocationPermissions() -> Bool
}
