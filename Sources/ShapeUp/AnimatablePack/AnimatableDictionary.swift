//
//  AnimatableDictionary.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-18.
//

import SwiftUI

@dynamicMemberLookup
@propertyWrapper
public struct VectorDictionary<Key: Hashable, Value> {
    fileprivate var storage: [Key: Value] = [:]
    
    public var wrappedValue: [Key: Value] {
        get { storage }
        set { storage = newValue }
    }
    
    public init(_ wrappedValue: [Key: Value]) {
        self.storage = wrappedValue
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Dictionary<Key,Value>, V>) -> V {
        get { storage[keyPath: keyPath] }
        set { storage[keyPath: keyPath] = newValue }
    }
    
    public static var zero: Self {
        .init([:])
    }
}

extension VectorDictionary: Sendable where Key: Sendable, Value: Sendable { }

extension VectorDictionary: Equatable where Value: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension VectorDictionary: AdditiveArithmetic where Value: AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs.storage
        rhs.storage.forEach { (key, value) in
            result[key, default: .zero] += value
        }
        return .init(result)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        var result = lhs.storage
        rhs.storage.forEach { (key, value) in
            result[key, default: .zero] -= value
        }
        return .init(result)
    }
}

extension VectorDictionary: VectorArithmetic where Value: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        storage = storage.mapValues {
            $0.scaled(by: rhs)
        }
    }

    public var magnitudeSquared: Double {
        storage.values.reduce(into: 0.0) { partialResult, value in
            partialResult += value.magnitudeSquared
        }
    }
}

@dynamicMemberLookup
@propertyWrapper
public struct AnimatableDictionary<Key: Hashable, Value: Animatable>: Animatable {
    fileprivate var storage: [Key: Value]

    public var wrappedValue: [Key: Value] {
        get { storage }
        set { storage = newValue }
    }

    public init(_ wrappedValue: [Key: Value]) {
        self.storage = wrappedValue
    }
    
    public var animatableData: VectorDictionary<Key, Value.AnimatableData> {
        get {
            .init(storage.mapValues(\.animatableData))
        }
        set {
            newValue.storage.forEach { (key, animatableData) in
                storage[key]?.animatableData = animatableData
            }
        }
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Dictionary<Key,Value>, V>) -> V {
        get { storage[keyPath: keyPath] }
        set { storage[keyPath: keyPath] = newValue }
    }
}

extension AnimatableDictionary: Sendable where Key: Sendable, Value: Sendable { }
