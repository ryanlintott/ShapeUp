//
//  AnimatableDictionary.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-18.
//

import SwiftUI

@dynamicMemberLookup
public struct VectorDictionary<Key: Hashable, Value> {
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

extension VectorDictionary: Sendable where Key: Sendable, Value: Sendable { }

extension VectorDictionary: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension VectorDictionary: AdditiveArithmetic where Value: AdditiveArithmetic {
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

extension VectorDictionary: VectorArithmetic where Value: VectorArithmetic {
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

@dynamicMemberLookup
public struct AnimatableDictionary<Key: Hashable, Value> {
    public var wrappedValue: [Key: Value]
    
    public init(_ wrappedValue: [Key: Value]) {
        self.wrappedValue = wrappedValue
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Dictionary<Key, Value>, V>) -> V {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
}

extension AnimatableDictionary: Sendable where Key: Sendable, Value: Sendable { }

extension AnimatableDictionary: Animatable where Value: Animatable {
    public typealias AnimatableData = VectorDictionary<Key, Value.AnimatableData>
    
    public var animatableData: AnimatableData {
        get {
            .init(wrappedValue.mapValues(\.animatableData))
        }
        set {
            newValue.wrappedValue.forEach { (key, animatableData) in
                wrappedValue[key]?.animatableData = animatableData
            }
        }
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Dictionary<Key, Value>, V>) -> V {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
}

extension Dictionary where Key: Hashable, Value: VectorArithmetic {
    var animatableData: VectorDictionary<Key, Value> {
        get {
            VectorDictionary(self)
        }
        set {
            newValue.wrappedValue.forEach { (key, animatableData) in
                self[key] = animatableData
            }
        }
    }
}

extension Dictionary where Key: Hashable, Value: Animatable {
    var animatableData: VectorDictionary<Key, Value.AnimatableData> {
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
