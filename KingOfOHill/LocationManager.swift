//
//  LocationManager.swift
//  KingOfOHill
//
//  Created by Dylan Hellems on 4/17/16.
//  Copyright © 2016 Dylan Hellems. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : CLLocationManagerDelegate {
    let _locManager = CLLocationManager()
    
    override func viewDidLoad() {
        run()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var loc = locations[0] as CLLocation
        println(loc)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println(status)
        if (status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            _locManager.startUpdatingLocation()
        }
    }
    
    func run() {
        if (CLLocationManager.locationServicesEnabled()) {
            var authorizationStatus = CLLocationManager.authorizationStatus()
            _locManager.delegate = self
            _locManager.distanceFilter = kCLDistanceFilterNone
            _locManager.desiredAccuracy = kCLLocationAccuracyBest
            _locManager.requestAlwaysAuthorization()
            
        }
    }
}