//
//  NearbyMartMapViewController.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 8..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit
import GoogleMaps

class NearbyMartMapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var markerView = MarkerView(frame: CGRect(x: 0, y: 0, width: 250, height: 120))
    var tapMarker = GMSMarker()
    var martArray: [Mart]?
    
    var currentLocation: CLLocation?
    var cameraFirstMove: Bool = false
    var getMartDataBool: Bool = false
    
    lazy var locationManager: CLLocationManager = {
        let locationManager: CLLocationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    var zoomLevel: Float = 13.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocation()
        setup()
        settingObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let location = self.currentLocation {
            self.getMartData(location: location)
        }
    }
}

// MARK: - Button Action
extension NearbyMartMapViewController {
    
    @IBAction func refreshButton(_ sender: UIButton) {
        if let location = self.currentLocation {
            self.getMartData(location: location)
        }
    }
}

// MARK: - Observer
extension NearbyMartMapViewController {
    
    func settingObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enterBankground), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func enterForeground() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            if let location = self.currentLocation {
                self.cameraFirstMove = !self.cameraFirstMove
                self.getMartDataBool = !self.getMartDataBool
                self.foregroundMove(at: location.coordinate)
                self.getMartData(location: location)
            }
        }
    }
    
    @objc func enterBankground() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
}

// MARK: - Custom method
extension NearbyMartMapViewController {
    
    func setupLocation() {
        // location
        DispatchQueue.main.async {
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
            self.mapView.settings.myLocationButton = true
            self.mapView.isMyLocationEnabled = true
        }
    }
    
    func setup() {
        self.navigationController?.navigationBar.isHidden = true
        self.refreshButton.layer.masksToBounds = false
        self.refreshButton.layer.cornerRadius = self.refreshButton.bounds.width/2
    }
    
    func move(at coordinate: CLLocationCoordinate2D) {
        if !cameraFirstMove {
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withTarget: coordinate, zoom: self.zoomLevel)
            self.mapView.camera = camera
            self.cameraFirstMove = true
        }
    }
    
    func foregroundMove(at coordinate: CLLocationCoordinate2D) {
        move(at: coordinate)
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withTarget: coordinate, zoom: self.zoomLevel)
        self.mapView.camera = camera
    }
    
    func setMarker(marts: [Mart]) {
        DispatchQueue.main.async {
            self.mapView.clear()
            
            for (index,mart) in marts.enumerated() {
                if let x = mart.x, let y = mart.y {
                    let position = CLLocationCoordinate2D(latitude: Double(y)!, longitude: Double(x)!)
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
    }
    
    func closedDayYN (week: closedWeek, day: closedDay) -> Bool {
        
        if week[0] == 0 && day[0] == 8 || week[1] == 0 && day[1] == 8 {
            return false
        }
        
        let time: TimeZone = TimeZone.current
        let today = Date(timeIntervalSinceNow: TimeInterval(time.secondsFromGMT()))
        let calendar = Calendar.current
        
        // 기준점 = 오늘
        var centerDate = DateComponents(calendar: calendar)
        centerDate.month = calendar.component(.month, from: today)
        centerDate.weekday = calendar.component(.weekday, from: today)
        centerDate.weekdayOrdinal = calendar.component(.weekdayOrdinal, from: today)
        
        // 첫번째 휴무
        var firstWeekdate = DateComponents()
        firstWeekdate.month = calendar.component(.month, from: today)
        firstWeekdate.weekday = day[0]
        firstWeekdate.weekdayOrdinal = week[0]
        
        // 두번째 휴무
        var thirdWeekdate = DateComponents()
        thirdWeekdate.month = calendar.component(.month, from: today)
        thirdWeekdate.weekday = day[1]
        thirdWeekdate.weekdayOrdinal = week[1]
        
        if centerDate.weekdayOrdinal == firstWeekdate.weekdayOrdinal && centerDate.weekday == firstWeekdate.weekday {
            return true
        }
        
        if centerDate.weekdayOrdinal == thirdWeekdate.weekdayOrdinal && centerDate.weekday == thirdWeekdate.weekday {
            return true
        }
        return false
    }
    
    func openTime(time: String) -> Bool {
        
        let timeSplit = time.split(separator: "~")
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "HH:mm"
        
        let currentTime = dateFormatter.string(from: date)
        
        guard let startTime = dateFormatter.date(from: String(timeSplit[0])),
        let centerTime = dateFormatter.date(from: currentTime),
        let closeTime = dateFormatter.date(from: String(timeSplit[1])) else { return false }
        
        return startTime < centerTime && centerTime < closeTime
    }
    
    func closedDayDescription(week: closedWeek, day: closedDay, fixedDay: [Int]) -> String {
        
        enum Day: Int {
            case sunday = 1
            case monday = 2
            case tuesday = 3
            case wednesday = 4
            case thursday = 5
            case friday = 6
            case saturday = 7
        }
        
        func dayToString(day: Int) -> String {
            
            switch day {
            case Day.sunday.rawValue:
                return "일요일"
            case Day.monday.rawValue:
                return "월요일"
            case Day.tuesday.rawValue:
                return "화요일"
            case Day.wednesday.rawValue:
                return "수요일"
            case Day.thursday.rawValue:
                return "목요일"
            case Day.friday.rawValue:
                return "금요일"
            default:
                return "토요일"
            }
        }
        
        guard week.count == 2 && day.count == 2 else {
            return "휴무정보없음"
        }
        
        if week[0] == 0 && day[0] == 8 {
            if week[1] == 0 && day[1] == 8 {
                return "매달 \(fixedDay[0]),\(fixedDay[1])일"
            } else {
                return "매달 \(fixedDay[0])일, \(week[1])번째주 \(dayToString(day: day[1]))"
            }
        } else {
            if week[1] == 0 && day[1] == 8 {
                return "\(week[0])번째주 \(dayToString(day: day[0])), 매달 \(fixedDay[0])일"
            }
        }
        
        return "\(week[0])번째주 \(dayToString(day: day[0])), \(week[1])번째주 \(dayToString(day: day[1]))"
    }
}

// MARK: - CLLocationManagerDelegate
extension NearbyMartMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            let alert = UIAlertController(title: "GPS 권한 승인 필요", message: "허용하지 않을시 일부 기능이\n동작하지 않습니다.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "설정메뉴로가기", style: .default, handler: { (UIAlertAction) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
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
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.first else { return }
        
        if !Distance.shared.firstLocation.0 {
            Distance.shared.firstLocation.1 = location.coordinate
            Distance.shared.firstLocation.0 = true
        } else {
            let fL = Distance.shared.firstLocation.1
            
            
            let firstLocation = CLLocation(latitude: fL.latitude, longitude: fL.longitude)
            let currentLocation = CLLocation(latitude: location.coordinate.latitude,
                                             longitude: location.coordinate.longitude)
            
            if firstLocation.distance(from: currentLocation) > 500 {
                self.cameraFirstMove = !self.cameraFirstMove
                self.getMartDataBool = !self.getMartDataBool
                self.currentLocation = location
                move(at: location.coordinate)
                if !getMartDataBool {
                    getMartData(location: location)
                }
                return
            }
        }
        
        self.currentLocation = location
        move(at: location.coordinate)
        if !getMartDataBool {
            getMartData(location: location)
        }
    }
}

// MARK: - GMSMapViewDelegate
extension NearbyMartMapViewController: GMSMapViewDelegate {
    
    @objc func favorite(_ sender: UIButton) {
        
        if let marts = self.martArray {
            if let name = marts[sender.tag].placeName {
                var martData: Any?
                do {
                    let db = try SQLiteManager()
                    try db.execute(name: name) { (mart: MartTuple) in
                        martData = mart
                    }
                    
                    let updateDB = try SQLiteManager()
                    let data = martData as! MartTuple
                    do {
                        if data.3 == 0 {
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
        
        // Mart Name, ClosedWeek
        if let name = martData.placeName {
            self.markerView.placeName.text = name
            do {
                let db = try SQLiteManager()
                try db.execute(name: name) { (mart) in
                    
                    // 휴무정보
                    self.markerView.closedWeek.text = self.closedDayDescription(week: mart.1, day: mart.2, fixedDay: mart.5)
                    
                    // 영업유무
                    if self.closedDayYN(week: mart.1, day: mart.2) {
                        self.markerView.onSaleYN.textColor = .red
                        self.markerView.onSaleYN.text = "휴무"
                    } else {
                        if mart.1[0] == 0 && mart.2[0] == 8 || mart.1[1] == 0 && mart.2[1] == 8 {
                            self.markerView.onSaleYN.text = "영업정보없음"
                        } else {
                            self.markerView.onSaleYN.text = self.openTime(time: mart.4) ? "영업중" : "영업종료"
                        }
                    }
                    
                    // 즐겨찾기
                    if mart.3 == 0 {
                        self.markerView.favorite.setImage(#imageLiteral(resourceName: "FavoriteIcon"), for: .normal)
                    } else {
                        self.markerView.favorite.setImage(#imageLiteral(resourceName: "FavoriteIconSelect"), for: .normal)
                    }
                    
                    // 영업시간
                    self.markerView.workTime.text = mart.4
                }
            } catch {
                self.dbOpenErrorAlert()
            }
        }
        
        // 주소
        if let address = martData.addressName {
            self.markerView.address.text = address
        }
        
        self.markerView.center = mapView.projection.point(for: position)
        self.markerView.frame.origin.y -= 100
        self.markerView.layer.cornerRadius = 10
        self.markerView.layer.borderColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7)
        self.markerView.layer.borderWidth = 0.7
        self.view.addSubview(self.markerView)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let location = CLLocationCoordinate2D(latitude: self.tapMarker.position.latitude, longitude: self.tapMarker.position.longitude)
        self.markerView.center = mapView.projection.point(for: location)
        self.markerView.frame.origin.y -= 100
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.markerView.removeFromSuperview()
    }
}

extension NearbyMartMapViewController {
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

// MARK: - URLSession
extension NearbyMartMapViewController {
    func getMartData(location: CLLocation) {
        
        self.getMartDataBool = true
        
        let mylocationRange = "\(location.coordinate.longitude - 0.05),\(location.coordinate.latitude - 0.05)," +
        "\(location.coordinate.longitude + 0.05),\(location.coordinate.latitude + 0.05)"
        
        var parameters = [String : Any]()
        parameters.updateValue("MT1", forKey: "category_group_code")
        parameters.updateValue(mylocationRange, forKey: "rect")
        
        var headers = [String: String]()
        headers.updateValue(AppDelegate.kakaoAPIKEY, forKey: "Authorization")
        
        API.getRequest(url: "https://dapi.kakao.com/v2/local/search/category.json", parameters: parameters, headers: headers) { [weak self] (data, error) in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            
            do {
                let marts = try JSONDecoder().decode(Documents.self, from: data)
                
                let filteringMart = marts.documents.filter {
                    ($0.placeName?.hasPrefix("이마트"))! && ($0.categoryName?.contains("대형마트"))! ||
                        ($0.placeName?.hasPrefix("홈플러스"))! && ($0.categoryName?.contains("대형마트"))! && !($0.placeName?.contains("스페셜"))! ||
                        ($0.placeName?.hasPrefix("롯데마트"))! && ($0.categoryName?.contains("대형마트"))!
                }
                
                if filteringMart.count > 0 {
                    //for mart in filteringMart {
                    //print(mart.description)
                    //}
                    self?.martArray?.removeAll()
                    self?.martArray = filteringMart
                    self?.setMarker(marts: filteringMart)
                } else {
                    DispatchQueue.main.async {
                        GWToast(message: "주변에 마트가 없습니다.").setPosition(position: .Bottom).setDuration(duration: 2).show()
                    }
                }
            } catch {
                let alert = UIAlertController(title: "마트정보 불러오기 실패", message: "잠시후에 다시 실행해주세요.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "다시 불러오기", style: .default, handler: { action in
                    self?.getMartData(location: location)
                })
                let cancelAction = UIAlertAction(title: "취소", style: .default, handler: nil)
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                DispatchQueue.main.async {
                    self?.present(self!, animated: false, completion: nil)
                }
            }
        }
    }
}
