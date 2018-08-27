//
//  EventBroker.swift
//  EventBroker
//
//  Created by Michael Lee on 7/10/18.
//  Copyright © 2018 Michael Lee. All rights reserved.
//

import Foundation

public typealias EventHandler = (String, [AnyHashable : Any]) -> Void

public typealias SubscribedEvents = [String : [SubscriberAction]]

public struct SubscriberAction {
    public var subscriber: AnyHashable
    public var handler: EventHandler
}

public protocol EventBroker {
    
    var subscribedEvents: SubscribedEvents { get set }
    
    func publish(event: String, with eventInfo: [AnyHashable : Any])
    
    mutating func subscribe(to event: String, subscriber: AnyHashable, with handler: @escaping EventHandler)
    
    mutating func unsubscribe(to event: String, subscriber: AnyHashable)
}

public extension EventBroker {
    
    public func publish(event: String, with eventInfo: [AnyHashable : Any]) {
        guard let subscriberActions = subscribedEvents[event] else { return }
        for subscriberAction in subscriberActions {
            subscriberAction.handler(event, eventInfo)
        }
    }
    
    public mutating func subscribe(to event: String, subscriber: AnyHashable, with handler: @escaping EventHandler) {
        let subscriberAction = SubscriberAction(subscriber: subscriber, handler: handler)
        var subscriberActions: [SubscriberAction]
        if let _subscriberActions: [SubscriberAction] = subscribedEvents[event]  {
            subscriberActions = _subscriberActions
        } else {
            subscriberActions = [subscriberAction]
        }
        subscribedEvents[event] = subscriberActions
    }
    
    public mutating func unsubscribe(to event: String, subscriber: AnyHashable) {
        guard var subscriberActions = subscribedEvents[event] else { return }
        var index = 0
        for subscriberAction in subscriberActions {
            if subscriberAction.subscriber == subscriber {
                break
            }
            index = index + 1
        }
        subscriberActions.remove(at: index)
        subscribedEvents[event] = subscriberActions
    }
}
