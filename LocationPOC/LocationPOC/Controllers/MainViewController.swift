//
//  MainViewController.swift
//  LocationPOC
//
//  Created by Mike Lee on 8/25/18.
//  Copyright © 2018 slickdeals.net. All rights reserved.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var locationTextView: UITextView!
    
    var locationUpdating = false
    var currentLocation: CLLocation?
    
    private var subscribedEvents: [LocationEvents]! = [LocationEvents]()
    private var isLocationUpdatesEnabled = true
    
    
    @IBAction func updateLocationTapped(_ sender: Any) {
        locationTextView.text = ""
        isLocationUpdatesEnabled = true
        sharedLocationManager.startUpdatingLocation()
        locationUpdating = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        sharedLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        
        sharedLocationManager.subscribe(to: LocationEvents.locationsUpdated, subscriber: self) { [weak self] event, info in
            self?.updateLocationHandler(event: event, eventInfo: info)
        }
        subscribedEvents.append(LocationEvents.locationsUpdated)
        
        sharedLocationManager.subscribe(to: LocationEvents.authorizationChanged, subscriber: self) { [weak self] event, info in
            guard !(self?.locationUpdating ?? false) else { return }
            self?.locationUpdating = true
            if (status == .authorizedAlways || status == .authorizedWhenInUse) {
                self?.isLocationUpdatesEnabled = true
                sharedLocationManager.startUpdatingLocation()
                self?.view.backgroundColor = .green
                self?.locationUpdating = true
            }
        }
        subscribedEvents.append(LocationEvents.authorizationChanged)
                
        if (status == .authorizedAlways || status == .authorizedWhenInUse) && !locationUpdating {
            sharedLocationManager.startUpdatingLocation()
            view.backgroundColor = .blue
            locationUpdating = true
            return
        }
        
        sharedLocationManager.requestAlwaysAuthorization()
    }

}

extension MainViewController {
    
    func updateLocationHandler(event: String, eventInfo: [AnyHashable : Any]) {
        guard isLocationUpdatesEnabled else { return }
        guard event == LocationEvents.locationsUpdated.rawValue else { return }
        guard let locations: [CLLocation] = eventInfo["locations"] as? [CLLocation] else { return }
        
        
        for location in locations {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            print("***location updated with lat: \(lat) | long: \(long)")
            print("   altitude: \(location.altitude)")
            print("   accuracy: horizontal - \(location.horizontalAccuracy) | vertical - \(location.verticalAccuracy)")
            
            locationTextView.text = "Updating location..."
            if location.horizontalAccuracy <= 25.0 {
                updateCurrentLocation(with: location)
                sharedLocationManager.stopUpdatingLocation()
                isLocationUpdatesEnabled = false
                print("### func current location")
                currentLocation = location
                
                locationTextView.text = "Location determined within required accuracy\n\nLatitude: \(lat)\nLongitude: \(long)\naltitude:\(location.altitude)M\naccuracy: horizontal - \(location.horizontalAccuracy)M | vertical - \(location.verticalAccuracy)M"

                let geocoder = CLGeocoder()
                
                geocoder.reverseGeocodeLocation(location,
                                                completionHandler: { (placemarks, error) in
                                                    if error == nil {
                                                        guard let placemarks = placemarks else {
                                                            self.locationTextView.text = "Location determined within required accuracy\n\nLatitude: \(lat)\nLongitude: \(long)\naltitude:\(location.altitude)M\naccuracy: horizontal - \(location.horizontalAccuracy)M | vertical - \(location.verticalAccuracy)M"
                                                            return

                                                        }
                                                        guard !placemarks.isEmpty else {
                                                             self.locationTextView.text = "Location determined within required accuracy\n\nLatitude: \(lat)\nLongitude: \(long)\naltitude:\(location.altitude)M\naccuracy: horizontal - \(location.horizontalAccuracy)M | vertical - \(location.verticalAccuracy)M\n\n**No Placemarks Available"
                                                            return
                                                        }
                                                        print("*** placemakrs count = \(placemarks.count)")
                                                        let placemark = placemarks[0]
                                                        var string = "Location determined within required accuracy\n\nLatitude: \(lat)\nLongitude: \(long)\naltitude:\(location.altitude)M\naccuracy: horizontal - \(location.horizontalAccuracy)M | vertical - \(location.verticalAccuracy)M"
                                                        string = string + "\n\nName: \(placemark.name ?? "Unknown")"
                                                        string = string + "\npostalCode: \(placemark.postalCode ?? "Unknown")"
                                                        self.locationTextView.text = string

                                                   }
                                                    else {
                                                        var string = "Location determined within required accuracy\n\nLatitude: \(lat) | Longitude: \(long)\naltitude:\(location.altitude)M\naccuracy: horizontal - \(location.horizontalAccuracy)M | vertical - \(location.verticalAccuracy)M"
                                                        string = string + "\n\n*** error in reverse geocoding"
                                                    }
                })

                break
            }
        }
    }
    
    private func updateCurrentLocation(with location: CLLocation) {
        currentLocation = location
    }
}

