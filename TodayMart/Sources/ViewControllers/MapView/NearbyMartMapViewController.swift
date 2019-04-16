//
//  NearbyMartMapViewController.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 8..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import GoogleMaps
import PanModal
import Floaty
import SnapKit

class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var userData: [String: Any]
    
    init(position: CLLocationCoordinate2D, name: String, userData: [String: Any]) {
        self.position = position
        self.name = name
        self.userData = userData
    }
}

// Cluster
let kClusterItemCount = 10000
var kCameraLatitude = -33.8
var kCameraLongitude = 151.2

class NearbyMartMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    // Cluster
    private var clusterManager: GMUClusterManager!
    
    var martArray: [Mart]?
    var currentLocation: CLLocation?
    var firstActive: Bool = false
    
    lazy var locationManager: CLLocationManager = {
        let locationManager: CLLocationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    var zoomLevel: Float = 13.0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPermission {
            self.mapView.clear()
            self.getMartData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()
        settingObserver()
        setFloatyButton()
        setup()
    }
}

// MARK: - Observer
extension NearbyMartMapViewController {
    
    func settingObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterBankground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func enterForeground() {
        checkPermission {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    @objc func enterBankground() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
}

// MARK: - Setup
extension NearbyMartMapViewController {
    
    func setFloatyButton() {
        let floaty = Floaty()
        floaty.buttonColor = .white
        floaty.addItem("내 위치로", icon: #imageLiteral(resourceName: "MapIcon")) { _ in
            if let location = self.currentLocation {
                self.move(at: location.coordinate)
            }
        }
        floaty.addItem("즐겨찾기", icon: #imageLiteral(resourceName: "FavoriteIcon")) { _ in
            let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
            let favoriteViewController = storyboard.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
            favoriteViewController.title = "즐겨찾기"
            self.present(UINavigationController(rootViewController: favoriteViewController), animated: true, completion: nil)
        }
        floaty.addItem("설정", icon: #imageLiteral(resourceName: "SettingIcon")) { _ in
            let storyboard = UIStoryboard(name: "Setting", bundle: nil)
            let settingViewController = storyboard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
            settingViewController.title = "설정"
            self.present(UINavigationController(rootViewController: settingViewController), animated: true, completion: nil)
        }
        view.addSubview(floaty)
        floaty.snp.makeConstraints {
            $0.trailing.equalTo(view.snp.trailing).offset(-16)
            $0.bottom.equalTo(view.snp.bottom).offset(-16)
            $0.height.width.equalTo(56)
        }
    }
    
    func setup() {
        navigationController?.navigationBar.isHidden = true
        
        // location
        DispatchQueue.main.async {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.mapView.isMyLocationEnabled = true
            self.mapView.setMinZoom(8, maxZoom: 15)
            self.getMartData()
        }
    }
    
    func move(at coordinate: CLLocationCoordinate2D) {
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withTarget: coordinate, zoom: self.zoomLevel)
        self.mapView.camera = camera
    }
}

// MARK: - CLLocationManagerDelegate
extension NearbyMartMapViewController: CLLocationManagerDelegate {
    
    // Permission check
    func checkPermission(permitHandler: (() -> ())? = nil) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            let alert = UIAlertController(title: "GPS 권한 승인 필요", message: "허용하지 않을시 일부 기능이\n동작하지 않습니다.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "설정메뉴로가기", style: .default, handler: { (UIAlertAction) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            })
            let cancel = UIAlertAction(title: "취소", style: .default, handler: nil)
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: false, completion: nil)
        case .authorizedAlways, .authorizedWhenInUse:
            permitHandler?()
        }
    }
    
    // update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.first else { return }
        
        self.currentLocation = location
        
        if !firstActive {
            move(at: location.coordinate)
            firstActive = !firstActive
        }
    }
}

// MARK: - GMUClusterRendererDelegate
extension NearbyMartMapViewController: GMUClusterRendererDelegate {
    
    // Marker Custom Icon
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let data = marker.userData as? POIItem {
            let userData = data.userData
            let mart = userData["mart"] as! Mart
            marker.icon = mart.favorite == 0 ? #imageLiteral(resourceName: "Pin_Blue") : #imageLiteral(resourceName: "Pin_Yellow")
        }
    }
}

// MARK: - GMSMapViewDelegate, GMUClusterManagerDelegate, InfomationDelegate
extension NearbyMartMapViewController: GMSMapViewDelegate, GMUClusterManagerDelegate, InfomationDelegate {
    
    // Add MarkerView (Cluster)
    func setMarker(marts: [Mart]) {
        DispatchQueue.main.async {
            
            // Set up the cluster manager with default icon generator and renderer.
            let iconGenerator = GMUDefaultClusterIconGenerator()
            let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
            let renderer = GMUDefaultClusterRenderer(mapView: self.mapView, clusterIconGenerator: iconGenerator)
            renderer.delegate = self
            self.clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm, renderer: renderer)
            
            for (index,mart) in marts.enumerated() {
                var markerData = [String: Any]()
                markerData.updateValue(mart, forKey: "mart")
                markerData.updateValue(index, forKey: "index")
                
                kCameraLatitude = Double(mart.latitude)!
                kCameraLongitude = Double(mart.longitude)!
                
                let position = CLLocationCoordinate2DMake(kCameraLatitude, kCameraLongitude)
                let item = POIItem(position: position, name: index.description, userData: markerData)
                self.clusterManager.add(item)
            }
            
            // Call cluster() after items have been added to perform the clustering and rendering on map.
            self.clusterManager.cluster()
            
            // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
            self.clusterManager.setDelegate(self, mapDelegate: self)
        }
    }
    
    // Marker Tap
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if let poiItem = marker.userData as? POIItem {
            let userData = poiItem.userData
            let mart = userData["mart"] as! Mart
            
            do {
                let db = try SQLiteManager()
                
                try db.executeSelect(name: mart.name) {(mart: Mart) in
                    let storyboard = UIStoryboard.init(name: "NearbyMartMap", bundle: nil)
                    let infoViewController = storyboard.instantiateViewController(withIdentifier: "InfomationViewController") as! InfomationViewController
                    infoViewController.title = "마트"
                    infoViewController.mart = mart
                    infoViewController.delegate = self
                    self.presentPanModal(infoViewController)
                    DispatchQueue.main.async {
                        marker.icon = #imageLiteral(resourceName: "Pin_Red")
                    }
                }
            } catch {
                dbOpenErrorAlert()
            }
        }
        return false
    }
    
    // Cluster Tap
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
                                                 zoom: mapView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
        return false
    }
    
    func completeDismiss() {
        self.mapView.clear()
        self.getMartData()
    }
}

// MARK: - Database
extension NearbyMartMapViewController {
    
    func getMartData() {
        self.indicator.startAnimating()
        do {
            let db = try SQLiteManager()
            try db.executeAll() { (marts: [Mart]) in
                self.indicator.stopAnimating()
                self.martArray = marts
                if let mart = self.martArray {
                    self.setMarker(marts: mart)
                }
            }
        } catch {
            self.indicator.stopAnimating()
            self.dbOpenErrorAlert()
        }
    }
    
    func dbOpenErrorAlert() {
        let alert = UIAlertController(title: "DB 불러오기 실패", message: "잠시후에 다시 실행해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        DispatchQueue.main.async {
            if let topController = UIApplication.topViewController() {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }
}
