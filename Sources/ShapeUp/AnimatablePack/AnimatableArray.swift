//
//  AnimatableArray.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-18.
//

import SwiftUI

@dynamicMemberLookup
public struct AnimatableArray<Element> {
    public var wrappedValue: [Element]
    
    public init(_ wrappedValue: [Element]) {
        self.wrappedValue = wrappedValue
    }
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Array<Element>, V>) -> V {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
    
    public static var zero: Self {
        .init([])
    }
}

extension AnimatableArray: Sendable where Element: Sendable { }

extension AnimatableArray: Equatable where Element: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension AnimatableArray: AdditiveArithmetic where Element: AdditiveArithmetic {
    public static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            (0..<Swift.max(lhs.wrappedValue.count, rhs.wrappedValue.count))
                .map {
                    (lhs.wrappedValue.indices.contains($0) ? lhs.wrappedValue[$0] : .zero)
                    +
                    (rhs.wrappedValue.indices.contains($0) ? rhs.wrappedValue[$0] : .zero)
                }
        )
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        .init(
            (0..<Swift.max(lhs.wrappedValue.count, rhs.wrappedValue.count))
                .map {
                    (lhs.wrappedValue.indices.contains($0) ? lhs.wrappedValue[$0] : .zero)
                    -
                    (rhs.wrappedValue.indices.contains($0) ? rhs.wrappedValue[$0] : .zero)
                }
        )
    }
}

extension AnimatableArray: VectorArithmetic where Element: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        wrappedValue = wrappedValue.map { $0.scaled(by: rhs) }
    }
    
    public var magnitudeSquared: Double {
        wrappedValue.reduce(into: 0.0) { partialResult, element in
            partialResult += element.magnitudeSquared
        }
    }
}

extension AnimatableArray: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension Array where Element: VectorArithmetic {
    var animatableData: AnimatableArray<Element> {
        get {
            AnimatableArray(self)
        }
        set {
            let count = Swift.min(count, newValue.wrappedValue.count)
            for i in 0..<count {
                self[i] = newValue.wrappedValue[i]
            }
        }
    }
}

extension Array where Element: Animatable {
    var animatableData: AnimatableArray<Element.AnimatableData> {
        get {
            .init(map(\.animatableData))
        }
        set {
            let count = Swift.min(count, newValue.wrappedValue.count)
            for i in 0..<count {
                self[i].animatableData = newValue.wrappedValue[i]
            }
        }
    }
}

extension Array where Element: NestedAnimatable {
    var nestedAnimatableData: AnimatableArray<Element.NestedAnimatableData> {
        get {
            AnimatableArray(map(\.nestedAnimatableData))
        }
        set {
            let count = Swift.min(count, newValue.wrappedValue.count)
            for i in 0..<count {
                self[i].nestedAnimatableData = newValue.wrappedValue[i]
            }
        }
    }
}

protocol NestedAnimatable: Animatable {
    /// The type defining the data to animate.
    associatedtype NestedAnimatableData: VectorArithmetic

    /// The data to animate.
    var nestedAnimatableData: Self.NestedAnimatableData { get set }
}










//@dynamicMemberLookup
//@propertyWrapper
//public struct AnimatableArray<Element: Animatable>: Animatable {
//    public var wrappedValue: [Element]
//
//    public init(_ wrappedValue: [Element]) {
//        self.wrappedValue = wrappedValue
//    }
//    
//    public var animatableData: AnimatableArray<Element.AnimatableData> {
//        get {
//            .init(wrappedValue.map(\.animatableData))
//        }
//        set {
//            wrappedValue = wrappedValue.enumerated().map { (index, element) in
//                var newElement = element
//                if newValue.wrappedValue.indices.contains(index) {
//                    newElement.animatableData = newValue.wrappedValue[index]
//                }
//                return newElement
//            }
//        }
//    }
//    
//    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Array<Element>, V>) -> V {
//        get { wrappedValue[keyPath: keyPath] }
//        set { wrappedValue[keyPath: keyPath] = newValue }
//    }
//}
//
//extension AnimatableArray: Sendable where Element: Sendable { }



