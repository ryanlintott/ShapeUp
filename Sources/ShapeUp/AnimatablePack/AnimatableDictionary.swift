//
//  AnimatableDictionary.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-18.
//

import SwiftUI

@dynamicMemberLookup
public struct AnimatableDictionary<Key: Hashable, Value> {
    public var wrappedValue: [Key: Value] = [:]
    
    public init(_ wrappedValue: [Key: Value]) {
        self.wrappedValue = wrappedValue
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Dictionary<Key,Value>, V>) -> V {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
    
    public static var zero: Self {
        .init([:])
    }
}

extension AnimatableDictionary: Sendable where Key: Sendable, Value: Sendable { }

extension AnimatableDictionary: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension AnimatableDictionary: AdditiveArithmetic where Value: AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs.wrappedValue
        rhs.wrappedValue.forEach { (key, value) in
            result[key, default: .zero] += value
        }
        return .init(result)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        var result = lhs.wrappedValue
        rhs.wrappedValue.forEach { (key, value) in
            result[key, default: .zero] -= value
        }
        return .init(result)
    }
}

extension AnimatableDictionary: VectorArithmetic where Value: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        wrappedValue = wrappedValue.mapValues {
            $0.scaled(by: rhs)
        }
    }

    public var magnitudeSquared: Double {
        wrappedValue.values.reduce(into: 0.0) { partialResult, value in
            partialResult += value.magnitudeSquared
        }
    }
}

extension Dictionary where Key: Hashable, Value: VectorArithmetic {
    var animatableData: AnimatableDictionary<Key, Value> {
        get {
            AnimatableDictionary(self)
        }
        set {
            newValue.wrappedValue.forEach { (key, animatableData) in
                self[key] = animatableData
            }
        }
    }
}

extension Dictionary where Key: Hashable, Value: Animatable {
    var animatableData: AnimatableDictionary<Key, Value.AnimatableData> {
        get {
            .init(mapValues(\.animatableData))
        }
        set {
            newValue.wrappedValue.forEach { (key, animatableData) in
                self[key]?.animatableData = animatableData
            }
        }
    }
}
