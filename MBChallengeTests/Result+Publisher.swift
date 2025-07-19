//
//  Result+Publisher.swift
//  MBChallengeTests
//
//  Created by Diego Iturrizaga on 18/07/25.
//

import Foundation
import Combine

extension Result: Publisher {
    public typealias Output = Success
    public typealias Failure = Failure
    
    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        switch self {
        case .success(let value):
            subscriber.receive(subscription: SingleSubscription())
            _ = subscriber.receive(value)
            subscriber.receive(completion: .finished)
        case .failure(let error):
            subscriber.receive(subscription: SingleSubscription())
            subscriber.receive(completion: .failure(error))
        }
    }
}

private struct SingleSubscription: Subscription {
    func request(_ demand: Subscribers.Demand) {}
    func cancel() {}
} 