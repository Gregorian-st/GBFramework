//
//  GMapViewController.swift
//  GBFramework
//
//  Created by Grigory Stolyarov on 18.08.2021.
//

import UIKit
import GoogleMaps
import RxSwift
import MobileCoreServices

class GMapViewController: UIViewController {
    
    private let locationManager = LocationManager.instance
    private let disposeBag = DisposeBag()
    private var lastZoom = GMapConfig.defaultZoom
    private let speedLabel = UILabel()
    private let notificationCenter = NotificationCenter.default
    var avatarImage: UIImage?
    private var resizedAvatarImage: UIImage?
    private var avatarMarker = GMSMarker()
    
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
        
        if !locationManager.isLocationServiceEnabled {
            _ = locationManager.checkLocationStatus()
            return
        }
        if isTrackingPosition {
            stopRouteTracking(showRoute: true, saveRoute: true)
        } else {
            startRouteTracking()
        }
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
        resizedAvatarImage = prepareAvatarImage(sourceImage: avatarImage)
        if let image = resizedAvatarImage {
            avatarMarker.icon = image
        }
        prepareRecordingNotification()
        notificationCenter.addObserver(self,
                                       selector: #selector(stopRecording),
                                       name: Notification.Name("StopRecording"),
                                       object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        stopRouteTracking(showRoute: false, saveRoute: true)
    }

    // MARK: - App Logic
    
    private func configureLocationManager() {
        
        locationManager.userSpeed.subscribe(onNext: { speed in
            if self.isTrackingPosition {
                self.updateSpeed(speed: speed)
            }
        })
        .disposed(by: disposeBag)
        
        locationManager.userLocation.subscribe(onNext: { location in
            if self.isTrackingPosition {
                self.addRoutePathPoint(at: location.coordinate, centered: true)
                if self.addStartMarkFlag {
                    self.addMark(at: location.coordinate, colored: .systemGreen, centered: false)
                    self.addStartMarkFlag = false
                }
            }
            self.addAvatar(at: location.coordinate)
        })
        .disposed(by: disposeBag)
    }
    
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
    
    private func prepareAvatarImage(sourceImage: UIImage?) -> UIImage? {
        
        guard let image = sourceImage
        else {
            return nil
        }
        
        let avatarSize = CGSize(width: 50, height: 50)
        let resizedImage = scaleAndCropImage(image, toSize: avatarSize)
        if let roundedImage = roundImage(image: resizedImage) {
            return roundedImage
        }
        
        return nil
    }
    
    private func startRouteTracking() {
        
        mapView.clear()
        configureRoute(path: nil)
        addStartMarkFlag = true
        locationManager.startUpdatingLocation()
        NotificationConfig.instance.content.title = "Route is recording"
        isTrackingPosition = true
    }
    
    private func stopRouteTracking(showRoute: Bool, saveRoute: Bool) {
        
        if !isTrackingPosition {
            return
        }
        
        locationManager.stopUpdatingLocation()
        
        guard let count = routePath?.count()
        else { return }
        
        if showRoute {
            if count > 0 {
                if let lastCoordinate = routePath?.coordinate(at: count - 1) {
                    addMark(at: lastCoordinate, colored: .systemRed, centered: false)
                }
            }
            showFullRoute()
        }
        if saveRoute {
            dataService.savePath(stringPath: routePath?.encodedPath())
        }
        NotificationConfig.instance.content.title = ""
        isTrackingPosition = false
        avatarMarker.map = nil
    }
    
    @objc private func stopRecording() {
        
        stopRouteTracking(showRoute: true, saveRoute: true)
    }
    
    private func loadLastTrack() {
        
        if isTrackingPosition {
            let stopAlert = UIAlertController(title: "Confirm",
                                              message: "Current Track data will be lost! Continue?",
                                              preferredStyle: UIAlertController.Style.alert)
            
            let stopAlertYesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                self.stopRouteTracking(showRoute: false, saveRoute: false)
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
    
    private func addMark(at coordinate: CLLocationCoordinate2D, colored color: UIColor, centered: Bool) {
        
        let cameraPosition = GMSCameraPosition(target: coordinate, zoom: lastZoom)
        if centered {
            mapView.animate(to: cameraPosition)
        }
        let marker = GMSMarker(position: cameraPosition.target)
        marker.icon = GMSMarker.markerImage(with: color)
        marker.map = mapView
    }
    
    private func addAvatar(at coordinate: CLLocationCoordinate2D) {
        
        avatarMarker.map = nil
        
        guard let image = resizedAvatarImage
        else {
            return
        }
        avatarMarker = GMSMarker(position: coordinate)
        avatarMarker.icon = image
        avatarMarker.map = mapView
    }
    
    private func addRoutePathPoint(at coordinate: CLLocationCoordinate2D, centered: Bool) {
        
        let cameraPosition = GMSCameraPosition(target: coordinate, zoom: lastZoom)
        if centered {
            mapView.animate(to: cameraPosition)
        }
        routePath?.add(coordinate)
        route?.path = routePath
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
    
    private func updateSpeed(speed: Double) {
        
        let speedKMH = speed / 1000 * 3600
        speedLabel.text = "Speed: \(String(format: "%.2f", speedKMH)) km/h"
        speedLabel.isHidden = Int(speed) <= 0
    }
    
    private func prepareRecordingNotification() {
        
        let notificationConfig = NotificationConfig.instance
        let content = notificationConfig.content
        
        content.title = ""
        content.subtitle = "Do not forget to stop recording"
        content.body = "Location recording in the background dramatically reduces battery charge.\n\nPlease don't forget to stop recording!"
        content.sound = UNNotificationSound.default
        
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("notification.jpeg")
        
        if let image = UIImage(named: "googleMaps") {
            try? image.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
        }
        do {
            let options = [UNNotificationAttachmentOptionsTypeHintKey: kUTTypeJPEG]
            let mapImage = try UNNotificationAttachment(identifier: "mapImage", url: tempFileURL, options: options)
            content.attachments = [mapImage]
        } catch {
            print(error.localizedDescription)
        }
        
        let stopRecordingAction = UNNotificationAction(identifier: notificationConfig.stopRecordingActionId,
                                                       title: "Stop Recording",
                                                       options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: notificationConfig.cancelActionId,
                                                title: "Dismiss",
                                                options: [])
        let category = UNNotificationCategory(identifier: notificationConfig.categoryId,
                                              actions: [stopRecordingAction, cancelAction],
                                              intentIdentifiers: [],
                                              options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = notificationConfig.categoryId
    }
    
    func scaleAndCropImage(_ image:UIImage, toSize size: CGSize) -> UIImage {
        
        guard !image.size.equalTo(size)
        else {
            return image
        }

        let widthFactor = size.width / image.size.width
        let heightFactor = size.height / image.size.height
        var scaleFactor: CGFloat = 0.0

        scaleFactor = heightFactor

        if widthFactor > heightFactor {
            scaleFactor = widthFactor
        }

        var thumbnailOrigin = CGPoint.zero
        let scaledWidth  = image.size.width * scaleFactor
        let scaledHeight = image.size.height * scaleFactor

        if widthFactor > heightFactor {
            thumbnailOrigin.y = (size.height - scaledHeight) / 2.0
        } else if widthFactor < heightFactor {
            thumbnailOrigin.x = (size.width - scaledWidth) / 2.0
        }

        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailOrigin
        thumbnailRect.size.width  = scaledWidth
        thumbnailRect.size.height = scaledHeight

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: thumbnailRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return scaledImage
    }
    
    private func roundImage(image: UIImage?) -> UIImage? {
        
        guard let image = image
        else {
            return nil
        }
        let imageSize = image.size
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            
            let imageCenterX = imageSize.width/2;
            let imageCenterY = imageSize.height/2;
            let radius = imageSize.width/2;
            
            context.beginPath()
            context.addArc(center: CGPoint(x: imageCenterX, y: imageCenterY),
                           radius: radius,
                           startAngle: 0,
                           endAngle: 2 * CGFloat.pi,
                           clockwise: false)
            context.closePath()
            context.clip()
            
            let rect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            image.draw(in: rect)
            let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            return croppedImage
        }
        UIGraphicsEndImageContext()
        
        return nil
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
