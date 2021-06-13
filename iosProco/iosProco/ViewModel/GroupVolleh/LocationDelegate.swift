//
//  LocationDelegate.swift
//  proco
//
//  Created by 이은호 on 2020/12/27.
//

import Foundation
import MapKit
import CoreLocation
import Combine

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate{
    @Published var locationManager: CLLocationManager = CLLocationManager() // location manager
    @Published var currentLocation: CLLocation!
    @Published var region : MKCoordinateRegion = MKCoordinateRegion()

   //사용자가 입력한 주소
    @Published var input_location: String = ""
    //주소를 기반으로 찾은 위도, 경도값.
    @Published var coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D()
    func firstSetting(){
        self.currentLocation = locationManager.location
        locationManager.startUpdatingLocation()
    }
  
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationManager = manager
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
        }
    }
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        self.locationManager = manager
//
//        switch status {
//            case .notDetermined :
//                print("로케이션매니저 not detiermined")
//                manager.requestWhenInUseAuthorization()
//                break
//            case .authorizedWhenInUse:
//                print("로케이션매니저 in user")
//                self.firstSetting()
//                break
//            case .authorizedAlways:
//                print("로케이션매니저 항상허용")
//                self.firstSetting()
//                break
//            case .restricted :
//                print("로케이션매니저 restricted")
//                break
//            case .denied :
//                print("로케이션매니저 denied")
//                break
//            default:
//                print("로케이션매니저 default")
//                break
//            }
//      }
    
    //1.검색한 주소 기반으로 위도, 경도 찾기
    func get_coordinate(address: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address){(placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
            else {
                print("위도 경도 찾기 에러 발생 : \(String(describing: error))")
                // handle no location found
                return
            }
            self.coordinate = location.coordinate
            print("찾은 위도 값 : \(self.coordinate )")
        }
        }
    
    //2.검색한 위치로 이동 & marker 추가
    func setMapView(coordinate: CLLocationCoordinate2D, address: String){
        //주소를 바탕으로 위도, 경도값 찾는 메소드.
        self.get_coordinate(address: address)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta:0.01))
       //self.mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        //지도 위에 나타나는 주석
        annotation.title = address
       // self.mapView.addAnnotation(annotation)
        
        //self.findAddr(lat: coordinate.latitude, long: coordinate.longitude)
    }
    
    // 위도, 경도에 따른 주소 찾기
    func findAddr(lat: CLLocationDegrees, long: CLLocationDegrees){
        let findLocation = CLLocation(latitude: lat, longitude: long)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
            if let address: [CLPlacemark] = placemarks {
                var myAdd: String = ""
                if let area: String = address.last?.locality{
                    myAdd += area
                }
                if let name: String = address.last?.name {
                    myAdd += " "
                    myAdd += name
                }
            }
        })
    }

}
