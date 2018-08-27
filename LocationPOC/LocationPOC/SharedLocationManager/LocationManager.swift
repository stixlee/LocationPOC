//
//  LocationManager.swift
//  ZList
//
//  Created by Michael Lee on 7/9/18.
//  Copyright © 2018 Michael Lee. All rights reserved.
//

import UIKit
import CoreLocation

public let sharedLocationManager = LocationManager()

public class LocationManager: CLLocationManager {
    
    private var locationManagerDelegate = LocationManagerDelegate()
    
    public override init() {
        super.init()
        self.delegate = locationManagerDelegate
    }

}

//MARK - Subscribe/Unsubscribe to Location Manager events
public extension LocationManager {
    
    public func subscribe(to event: LocationEvents, subscriber: AnyHashable, with handler: @escaping EventHandler) {
        locationManagerDelegate.subscribe(to: event.rawValue , subscriber: subscriber, with: handler)
    }
    
    public func unsubscribe(to event: LocationEvents, subscriber: AnyHashable) {
        locationManagerDelegate.unsubscribe(to: event.rawValue, subscriber: subscriber)
    }
}
