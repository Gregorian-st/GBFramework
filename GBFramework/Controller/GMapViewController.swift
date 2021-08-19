//
//  GMapViewController.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 18.08.2021.
//

import UIKit
import GoogleMaps

class GMapViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var lastZoom = GMapConfig.defaultZoom
    private var lastSpeed: Double = 0
    private let speedLabel = UILabel()
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupNavigationBar()
        configureGMap()
        configureLocationManager()
        setupUI()
    }

    // MARK: - App Logic
    
    private func setupNavigationBar() {
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.hidesBarsOnSwipe = true
        navigationItem.backButtonTitle = ""
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private func setupUI() {
        
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.text = ""
        speedLabel.textColor = UIColor.label
        speedLabel.textAlignment = .right
        speedLabel.font = UIFont.systemFont(ofSize: 14.0)
        speedLabel.isHidden = true
        
        mapView.addSubview(speedLabel)
        
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height ?? 0
        let statusBarHeight = UIApplication.shared.windows.last?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0
        let topHeight = navigationBarHeight + statusBarHeight
        NSLayoutConstraint.activate([
            speedLabel.rightAnchor.constraint(equalTo: mapView.rightAnchor, constant: -10),
            speedLabel.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 10),
            speedLabel.topAnchor.constraint(equalTo: mapView.topAnchor, constant: topHeight)
        ])
    }
    
    private func configureGMap() {
        
        let cameraPosition = GMSCameraPosition.camera(withTarget: GMapConfig.myCoordinate, zoom: lastZoom)
        mapView.mapType = .normal
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        do {
            if traitCollection.userInterfaceStyle == .light {
                mapView.mapStyle = try GMSMapStyle(jsonString: GMapConfig.lightMapStyle)
            } else {
                mapView.mapStyle = try GMSMapStyle(jsonString: GMapConfig.darkMapStyle)
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        mapView.camera = cameraPosition
        mapView.delegate = self
        speedLabel.isHidden = true
    }
    
    private func configureLocationManager() {
        
        checkLocationStatus()
        locationManager.delegate = self
    }
    
    private func checkLocationStatus() {
        
        let locationStatus = locationManager.authorizationStatus
        switch locationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Access to location services is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    private func addMark(at location: CLLocation, centered: Bool) {
        
        let cameraPosition = GMSCameraPosition(target: location.coordinate, zoom: lastZoom)
        if centered {
            mapView.animate(to: cameraPosition)
        }
        let marker = GMSMarker(position: cameraPosition.target)
        marker.map = mapView
    }
    
    private func updateSpeed(speed: Double) {
        let speedKMH = speed / 1000 * 3600
        speedLabel.text = "Speed: \(String(format: "%.2f", speedKMH)) km/h"
        speedLabel.isHidden = Int(speed) <= 0
    }
}

// MARK: - CLLocationManagerDelegate

extension GMapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkLocationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last
        else {
            return
        }
        addMark(at: location, centered: true)
        lastSpeed = location.speed
        updateSpeed(speed: lastSpeed)
    }
}

// MARK: - GMSMapViewDelegate

extension GMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if lastZoom != position.zoom {
            lastZoom = position.zoom
        }
        updateSpeed(speed: lastSpeed)
    }
}

