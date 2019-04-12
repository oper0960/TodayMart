//
//  NearbyMartMapViewController.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 8..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import GoogleMaps
import PullUpController

class NearbyMartMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var markerView = MarkerView(frame: CGRect(x: 0, y: 0, width: 300, height: 120))
    var tapMarker = GMSMarker()
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
        checkPermission()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermission()
        settingObserver()
        setup()
    }
}

// MARK: - Button Action
extension NearbyMartMapViewController {
    @IBAction func refreshButton(_ sender: UIButton) {
        checkPermission {
            self.mapView.clear()
            self.getMartData()
        }
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
    
    private func addPullUpController() {
        guard let favoriteViewController: FavoriteViewController = UIStoryboard(name: "Favorite", bundle: nil)
            .instantiateInitialViewController() as? FavoriteViewController else { return }
        
        
        addPullUpController(favoriteViewController as! PullUpController, initialStickyPointOffset: 10, animated: true)
    }
    
    func setup() {
        navigationController?.navigationBar.isHidden = true
        refreshButton.layer.masksToBounds = false
        refreshButton.layer.cornerRadius = refreshButton.bounds.width/2
        getMartData()
        
        // location
        DispatchQueue.main.async {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
//            self.mapView.settings.myLocationButton = true
            self.mapView.isMyLocationEnabled = true
            self.mapView.setMinZoom(8, maxZoom: 15)
        }
    }
    
    func move(at coordinate: CLLocationCoordinate2D) {
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withTarget: coordinate, zoom: self.zoomLevel)
        self.mapView.camera = camera
    }
}

// MARK: - CLLocationManagerDelegate
extension NearbyMartMapViewController: CLLocationManagerDelegate {
    
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.first else { return }
        
        self.currentLocation = location
        
        if !firstActive {
            move(at: location.coordinate)
            firstActive = !firstActive
        }
    }
}


// MARK: - GMUClusterManagerDelegate, GMSMapViewDelegate
extension NearbyMartMapViewController: GMSMapViewDelegate {
    
    // Add MarkerView
    func setMarker(marts: [Mart]) {
        DispatchQueue.main.async {
            for (index,mart) in marts.enumerated() {
                let position = CLLocationCoordinate2D(latitude: Double(mart.latitude)!,
                                                      longitude: Double(mart.longitude)!)
                let marker = GMSMarker(position: position)
                marker.icon = UIImage(named: "Pin_Orange")
                marker.appearAnimation = GMSMarkerAnimation.none
                var markerData = [String: Any]()
                markerData.updateValue(mart, forKey: "mart")
                markerData.updateValue(index, forKey: "index")
                marker.userData = markerData
                marker.map = self.mapView
            }
        }
    }
    
    // Poi Touch
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let userData = marker.userData as! [String: Any]
        let martData = userData["mart"] as! Mart
        let index = userData["index"] as! Int
        
        let position = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
        self.tapMarker = marker
        self.markerView.removeFromSuperview()
        self.markerView = MarkerView.instanceFromNib()
        self.markerView.favorite.tag = index
        self.markerView.favorite.addTarget(self, action: #selector(favorite), for: .touchUpInside)
        
        // Mart Name
        self.markerView.placeName.text = martData.name
        
        // 휴무정보
        self.markerView.closedWeek.text = self.closedDayDescription(week: martData.closedWeek, day: martData.closedDay, fixedDay: martData.fixedClosedDay)
        
        // 영업유무
        if self.closedDayYN(week: martData.closedWeek, day: martData.closedDay) {
            self.markerView.onSaleYN.textColor = .red
            self.markerView.onSaleYN.text = "휴무"
        } else {
            if martData.closedWeek[0] == 0 && martData.closedDay[0] == 8 ||
                martData.closedWeek[1] == 0 && martData.closedDay[1] == 8 {
                self.markerView.onSaleYN.text = "영업정보없음"
            } else {
                self.markerView.onSaleYN.text = self.openTime(time: martData.openingHours) ? "영업중" : "영업종료"
            }
        }
        
        // 즐겨찾기
        if martData.favorite == 0 {
            self.markerView.favorite.setImage(#imageLiteral(resourceName: "FavoriteIcon"), for: .normal)
        } else {
            self.markerView.favorite.setImage(#imageLiteral(resourceName: "FavoriteIconSelect"), for: .normal)
        }
        
        // 영업시간
        self.markerView.workTime.text = martData.openingHours
        
        // 주소
        self.markerView.address.text = martData.address
        
        self.markerView.center = mapView.projection.point(for: position)
        self.markerView.frame.origin.y -= 100
        self.markerView.layer.cornerRadius = 10
        self.markerView.layer.borderColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7)
        self.markerView.layer.borderWidth = 0.7
        self.view.addSubview(self.markerView)
        
        return false
    }

    // Poi View position
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let location = CLLocationCoordinate2D(latitude: self.tapMarker.position.latitude, longitude: self.tapMarker.position.longitude)
        self.markerView.center = mapView.projection.point(for: location)
        self.markerView.frame.origin.y -= 100
    }
    
    // MapView Touch
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.markerView.removeFromSuperview()
    }
    
    // Favorite Button
    @objc func favorite(_ sender: UIButton) {
        if let marts = self.martArray {
            let name = marts[sender.tag].name
            var martData: Mart?
            do {
                let db = try SQLiteManager()
                
                try db.executeSelect(name: name) { (mart: Mart) in
                    martData = mart
                }
                
                let updateDB = try SQLiteManager()
                guard let data = martData else { return }
                do {
                    if data.favorite == 0 {
                        try updateDB.favoriteExecute(name: name, favorite: 1, doneHandler: {
                            sender.setImage(#imageLiteral(resourceName: "FavoriteIconSelect"), for: .normal)
                        })
                    } else {
                        try updateDB.favoriteExecute(name: name, favorite: 0, doneHandler: {
                            sender.setImage(#imageLiteral(resourceName: "FavoriteIcon"), for: .normal)
                        })
                    }
                } catch {
                    self.dbOpenErrorAlert()
                }
            } catch {
                self.dbOpenErrorAlert()
            }
        }
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
