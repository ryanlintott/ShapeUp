//
//  AnimatableArray.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-18.
//

import SwiftUI

@dynamicMemberLookup
@propertyWrapper
public struct VectorArray<Element> {
    fileprivate var storage: [Element]
    
    public var wrappedValue: [Element] {
        get { storage }
        set { storage = newValue }
    }
    
    public init(_ wrappedValue: [Element]) {
        self.storage = wrappedValue
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Array<Element>, V>) -> V {
        get { storage[keyPath: keyPath] }
        set { storage[keyPath: keyPath] = newValue }
    }
    
    public static var zero: Self {
        .init([])
    }
}

extension VectorArray: Sendable where Element: Sendable { }

extension VectorArray: Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage == rhs.storage
    }
}

extension VectorArray: AdditiveArithmetic where Element: AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            (0..<Swift.max(lhs.storage.count, rhs.storage.count))
                .map {
                    (lhs.storage.indices.contains($0) ? lhs.storage[$0] : .zero)
                    +
                    (rhs.storage.indices.contains($0) ? rhs.storage[$0] : .zero)
                }
        )
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(
            (0..<Swift.max(lhs.storage.count, rhs.storage.count))
                .map {
                    (lhs.storage.indices.contains($0) ? lhs.storage[$0] : .zero)
                    -
                    (rhs.storage.indices.contains($0) ? rhs.storage[$0] : .zero)
                }
        )
    }
}

extension VectorArray: VectorArithmetic where Element: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        storage = storage.map { $0.scaled(by: rhs) }
    }
    
    public var magnitudeSquared: Double {
        storage.reduce(into: 0.0) { partialResult, element in
            partialResult += element.magnitudeSquared
        }
    }
}

extension VectorArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

@dynamicMemberLookup
@propertyWrapper
public struct AnimatableArray<Element: Animatable>: Animatable {
    fileprivate var storage: [Element]

    public var wrappedValue: [Element] {
        get { storage }
        set { storage = newValue }
    }

    public init(_ wrappedValue: [Element]) {
        self.storage = wrappedValue
    }
    
    public var animatableData: VectorArray<Element.AnimatableData> {
        get {
            .init(storage.map(\.animatableData))
        }
        set {
            storage = storage.enumerated().map { (index, element) in
                var newElement = element
                if newValue.storage.indices.contains(index) {
                    newElement.animatableData = newValue.storage[index]
                }
                return newElement
            }
        }
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Array<Element>, V>) -> V {
        get { storage[keyPath: keyPath] }
        set { storage[keyPath: keyPath] = newValue }
    }
}

extension AnimatableArray: Sendable where Element: Sendable { }



