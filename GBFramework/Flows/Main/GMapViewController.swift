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
    private var isLocationServiceEnabled = false
    private var lastZoom = GMapConfig.defaultZoom
    private var lastSpeed: Double = 0
    private let speedLabel = UILabel()
    
    private var route: GMSPolyline?
    private var routePath: GMSMutablePath?
    private var addStartMarkFlag = false
    private var isTrackingPosition = false {
        didSet {
            if isTrackingPosition {
                startStopTrackButton.image = UIImage(systemName: "stop.circle")
                startStopTrackButton.tintColor = .systemRed
            } else {
                startStopTrackButton.image = UIImage(systemName: "play.circle")
                startStopTrackButton.tintColor = .systemGreen
                updateSpeed(speed: 0)
            }
        }
    }
    
    lazy var dataService = CoreDataService()
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var startStopTrackButton: UIBarButtonItem!
    @IBOutlet weak var loadLastTrackButton: UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func startStopTrackButtonTapped(_ sender: UIBarButtonItem) {
        
        if !isLocationServiceEnabled {
            isLocationServiceEnabled = checkLocationStatus()
            return
        }
        if isTrackingPosition {
            stopRouteTracking()
        } else {
            startRouteTracking()
        }
        isTrackingPosition.toggle()
    }
    
    @IBAction func loadLastTrackButtonTapped(_ sender: UIBarButtonItem) {
        
        loadLastTrack()
    }
    
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
        startStopTrackButton.image = UIImage(systemName: "play.circle")
        startStopTrackButton.tintColor = .systemGreen
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
    
    private func configureRoute (path: GMSMutablePath?) {
        
        if path == nil {
            routePath = GMSMutablePath()
        } else {
            routePath = path
        }
        route = GMSPolyline(path: routePath)
        route?.strokeColor = .systemBlue
        route?.strokeWidth = 3
        route?.map = mapView
    }
    
    private func startRouteTracking() {
        
        mapView.clear()
        configureRoute(path: nil)
        addStartMarkFlag = true
        locationManager.startUpdatingLocation()
    }
    
    private func stopRouteTracking() {
        
        locationManager.stopUpdatingLocation()
        guard let count = routePath?.count()
        else { return }
        if count > 0 {
            if let lastCoordinate = routePath?.coordinate(at: count - 1) {
                addMark(at: lastCoordinate, colored: .systemRed, centered: false)
            }
        }
        showFullRoute()
        dataService.savePath(stringPath: routePath?.encodedPath())
    }
    
    private func loadLastTrack() {
        
        if isTrackingPosition {
            let stopAlert = UIAlertController(title: "Confirm",
                                              message: "Current Track data will be lost! Continue?",
                                              preferredStyle: UIAlertController.Style.alert)
            
            let stopAlertYesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                self.locationManager.stopUpdatingLocation()
                self.isTrackingPosition = false
                if !self.showLastRoute() {
                    showAlert(alertMessage: "There is no Last Track saved!", viewController: self)
                }
            }
            let stopAlertNoAction = UIAlertAction(title: "No", style: .cancel) { _ in
                return
            }
            
            stopAlert.addAction(stopAlertYesAction)
            stopAlert.addAction(stopAlertNoAction)
            
            present(stopAlert, animated: true, completion: nil)
        } else {
            if !self.showLastRoute() {
                showAlert(alertMessage: "There is no Last Track saved!", viewController: self)
            }
        }
    }
    
    private func showFullRoute() {
        
        guard let path = routePath
        else {
            return
        }
        let bounds = GMSCoordinateBounds(path: path)
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
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
        
        isLocationServiceEnabled = checkLocationStatus()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    private func checkLocationStatus() -> Bool {
        
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
    
    private func addMark(at coordinate: CLLocationCoordinate2D, colored color: UIColor, centered: Bool) {
        
        let cameraPosition = GMSCameraPosition(target: coordinate, zoom: lastZoom)
        if centered {
            mapView.animate(to: cameraPosition)
        }
        let marker = GMSMarker(position: cameraPosition.target)
        marker.icon = GMSMarker.markerImage(with: color)
        marker.map = mapView
    }
    
    private func addRoutePathPoint(at coordinate: CLLocationCoordinate2D, centered: Bool) {
        
        let cameraPosition = GMSCameraPosition(target: coordinate, zoom: lastZoom)
        if centered {
            mapView.animate(to: cameraPosition)
        }
        routePath?.add(coordinate)
        route?.path = routePath
    }
    
    private func updateSpeed(speed: Double) {
        
        let speedKMH = speed / 1000 * 3600
        speedLabel.text = "Speed: \(String(format: "%.2f", speedKMH)) km/h"
        speedLabel.isHidden = Int(speed) <= 0
    }
    
    private func showLastRoute() -> Bool {
        
        guard let path = dataService.loadPath(),
              let encodedPath = GMSMutablePath(fromEncodedPath: path)
        else { return false }
        
        mapView.clear()
        configureRoute(path: encodedPath)
        guard let count = routePath?.count()
        else { return false }
        if count > 0 {
            if let firstCoordinate = routePath?.coordinate(at: 0) {
                addMark(at: firstCoordinate, colored: .systemGreen, centered: false)
            }
            if let lastCoordinate = routePath?.coordinate(at: count - 1) {
                addMark(at: lastCoordinate, colored: .systemRed, centered: false)
            }
        }
        showFullRoute()
        updateSpeed(speed: 0)
        return true
    }
}

// MARK: - CLLocationManagerDelegate

extension GMapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        isLocationServiceEnabled = checkLocationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last
        else {
            return
        }
        if isTrackingPosition {
            addRoutePathPoint(at: location.coordinate, centered: true)
            if addStartMarkFlag {
                addMark(at: location.coordinate, colored: .systemGreen, centered: false)
                addStartMarkFlag = false
            }
            lastSpeed = location.speed
            updateSpeed(speed: lastSpeed)
        }
    }
}

// MARK: - GMSMapViewDelegate

extension GMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if lastZoom != position.zoom {
            lastZoom = position.zoom
        }
    }
}

