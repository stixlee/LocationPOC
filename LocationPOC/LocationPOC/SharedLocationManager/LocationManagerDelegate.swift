//
//  LocationManagerDelegate.swift
//  ZList
//
//  Created by Michael Lee on 7/6/18.
//  Copyright © 2018 Michael Lee. All rights reserved.
//

import UIKit
import CoreLocation

public enum LocationEvents: String {
    case locationsUpdated = "locationsUpdated"
    case failedUpdatesWithError = "failedUpdatesWithError"
    case finishedDeferredUpdatesWithError = "finishedDeferredUpdatesWithError"
    case finishedDeferredUpdates = "finishedDeferredUpdates"
    case locationUpdatesPaused = "locationUpdatesPaused"
    case locationUpdatesResumed = "locationUpdatesResumed"
    case headingUpdated = "headingUpdated"
    case regionEntered = "regionEntered"
    case regionExit = "regionExit"
    case regionStateDetermined = "regionStateDetermined"
    case regionMonitoringFailed = "regionMonitoringFailed"
    case regionMonitoringStarted = "regionMonitoringStarted"
    case beaconsInRange = "beaconsInRange"
    case beaconRangingFailedWithError = "beaconRangingFailedWithError"
    case newVisit = "newVisit"
    case authorizationChanged = "authorizationChanged"
}

public class LocationManagerDelegate: NSObject, EventBroker {
    
    public var subscribedEvents: SubscribedEvents = SubscribedEvents()
    public var shouldShowCalibration = false
    
    public override init() { super.init() }
    
    public init(shouldShowCalibration: Bool) {
        super.init()
        self.shouldShowCalibration = shouldShowCalibration
    }

}

extension LocationManagerDelegate: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        let eventInfo = ["locations" : locations]
        publish(event: LocationEvents.locationsUpdated.rawValue, with: eventInfo)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didFailWithError error: Error) {
        let eventInfo = ["error" : error]
        publish(event: LocationEvents.failedUpdatesWithError.rawValue, with: eventInfo)
        
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            let eventInfo = ["error" : error]
            publish(event: LocationEvents.finishedDeferredUpdatesWithError.rawValue, with: eventInfo)
            return
        }
        publish(event: LocationEvents.finishedDeferredUpdates.rawValue, with: [AnyHashable: Any]() )
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        publish(event: LocationEvents.locationUpdatesPaused.rawValue, with: [AnyHashable: Any]() )
    }
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        publish(event: LocationEvents.locationUpdatesResumed.rawValue, with: [AnyHashable: Any]() )
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateHeading newHeading: CLHeading) {
        let eventInfo = ["newHeading" : newHeading]
        publish(event: LocationEvents.headingUpdated.rawValue, with: eventInfo)
    }
    
    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return shouldShowCalibration
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didEnterRegion region: CLRegion) {
        let eventInfo = ["region" : region]
        publish(event: LocationEvents.regionEntered.rawValue, with: eventInfo)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didExitRegion region: CLRegion) {
        let eventInfo = ["region" : region]
        publish(event: LocationEvents.regionExit.rawValue, with: eventInfo)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didDetermineState state: CLRegionState,
                                for region: CLRegion) {
        let eventInfo = ["region" : region, "state" : state] as [String : Any]
        publish(event: LocationEvents.regionStateDetermined.rawValue, with: eventInfo)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                monitoringDidFailFor region: CLRegion?,
                                withError error: Error) {
        var eventInfo = [String : Any]()
        if let region = region { eventInfo["region"] = region }
        eventInfo["error"] = error
        publish(event: LocationEvents.regionMonitoringFailed.rawValue, with: eventInfo)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didStartMonitoringFor region: CLRegion) {
        let eventInfo = ["region" : region]
        publish(event: LocationEvents.regionMonitoringStarted.rawValue, with: eventInfo )
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didRangeBeacons beacons: [CLBeacon],
                                in region: CLBeaconRegion) {
        let eventInfo = ["region" : region, "beacons" : beacons] as [String : Any]
        publish(event: LocationEvents.beaconsInRange.rawValue, with: eventInfo )
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                rangingBeaconsDidFailFor region: CLBeaconRegion,
                                withError error: Error) {
        let eventInfo = ["region" : region, "error" : error] as [String : Any]
        publish(event: LocationEvents.beaconRangingFailedWithError.rawValue, with: eventInfo )
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didVisit visit: CLVisit) {
        let eventInfo = ["newVisit" : visit]
        publish(event: LocationEvents.newVisit.rawValue, with: eventInfo )
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        let eventInfo = ["status" : status]
        publish(event: LocationEvents.authorizationChanged.rawValue, with: eventInfo )
    }
    
}
