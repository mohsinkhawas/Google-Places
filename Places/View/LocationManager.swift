//
//  LocationManager.swift
//  Places
//
//  Created by Mohsin Khawas on 3/11/18.
//  Copyright © 2018 Mohsin Khawas. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

public protocol LocationInterfaceDelegate: class {
    func foundCurrentLocation()
    func locationFailedWithError(_ error: Error)
    func locationFailedWithAuthorizationError()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationInterfaceDelegate?
    let locationManager = CLLocationManager()
    
    var currentCoordinate: CLLocationCoordinate2D{
        get{
            return (self.locationManager.location!.coordinate)
            }
    }
    
    func getUserLocation(){
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    
        self.delegate?.foundCurrentLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.startUpdatingLocation()
        case .restricted, .denied:
            self.delegate?.locationFailedWithAuthorizationError()
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.locationFailedWithError(error)
    }
}
