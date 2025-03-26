//
//  MTLocationManager.swift
//  MapTilerSDK
//

import CoreLocation

/// Enum representing MTLocationManager errors.
public enum MTLocationError: Error {
    case permissionDenied
}

@MainActor
/// Protocol requirements for location manager.
public protocol MTLocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
    func didFailWithError(_ error: Error)
}

/// Class responsible for location updates.
public class MTLocationManager: NSObject, @preconcurrency CLLocationManagerDelegate {
    private var notInitMessage = "Location manager not initialized."

    private var locationManager: CLLocationManager?
    private var accuracy: CLLocationAccuracy = kCLLocationAccuracyBest

    package weak var delegate: MTLocationManagerDelegate?

    public init(using manager: CLLocationManager? = nil, accuracy: CLLocationAccuracy? = nil) {
        super.init()

        if let manager {
            self.locationManager = manager
            self.locationManager?.desiredAccuracy = accuracy ?? manager.desiredAccuracy
        } else {
            self.locationManager = CLLocationManager()
            self.locationManager?.desiredAccuracy = accuracy ?? kCLLocationAccuracyBest
        }

        self.locationManager?.delegate = self
    }

    /// Starts the location updates.
    ///
    /// Updates are available in didUpdateLocations method.
    public func startLocationUpdates() {
        guard let locationManager else {
            MTLogger.log(notInitMessage, type: .warning)
            return
        }

        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
    }

    /// Requests location only once and calls didUpdateLocations delegate method.
    public func requestLocationOnce() {
        locationManager?.requestLocation()
    }

    /// Stops the location updates.
    public func stopLocationUpdates() {
        locationManager?.stopUpdatingLocation()
    }

    /// Requests whenInUse location permission.
    @MainActor public func requestLocationPermission() {
        guard let locationManager else {
            MTLogger.log(notInitMessage, type: .warning)
            return
        }

        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.didFailWithError(MTLocationError.permissionDenied)
        default:
            break
        }
    }

    /// Requests always location permission.
    ///
    /// Make sure whenInUse location permission is active first.
    @MainActor public func requestAlwaysLocationPermission() {
        guard let locationManager else {
            MTLogger.log(notInitMessage, type: .warning)
            return
        }

        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        } else {
            MTLogger.log("whenInUse location permission should be active first.", type: .warning)
        }
    }

    @MainActor public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            delegate?.didUpdateLocation(location)
        }
    }

    @MainActor public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailWithError(error)
    }
}
