//
//  LocationManager.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 05.09.2021.
//

import Foundation
import CoreLocation
import RxSwift

final class LocationManager: NSObject {
    
    static let instance = LocationManager()
    let locationManager = CLLocationManager()
    var isLocationServiceEnabled = false
    let userLocation = PublishSubject<CLLocation>()
    let userSpeed = PublishSubject<Double>()
    
    private override init() {
        
        super.init()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        
        isLocationServiceEnabled = checkLocationStatus()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func startUpdatingLocation() {
        
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        
        locationManager.stopUpdatingLocation()
    }
    
    func checkLocationStatus() -> Bool {
        
        let locationStatus = locationManager.authorizationStatus
        switch locationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("Access to location services is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            break
        }
        return false
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        isLocationServiceEnabled = checkLocationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            userLocation.onNext(location)
            userSpeed.onNext(location.speed)
        }
    }
}
