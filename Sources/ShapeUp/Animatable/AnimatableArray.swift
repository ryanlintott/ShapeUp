//
//  AnimatableArray.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-18.
//

import SwiftUI

/// A wrapper around Array that provides animation capabilities for SwiftUI.
/// 
/// `AnimatableArray` allows arrays of types conforming to `VectorArithmetic` or `Animatable` to be smoothly animated by conforming to `VectorArithmetic`.
/// This enables element-wise interpolation between different array states during animations.
/// 
/// ## Usage Example for types conforming to `VectorArithmetic`
///
/// ```swift
/// struct AnimatedShape: Shape {
///     var points: [CGPoint]
///     
///     var animatableData: AnimatableArray<CGPoint> {
///         get { points.animatableData }
///         set { points.animatableData = newValue }
///     }
///     
///     func path(in rect: CGRect) -> Path {
///         // Create path using points
///     }
/// }
/// ```
/// 
/// ## Usage Example for types conforming to `Animatable`
///
/// ```swift
/// struct AnimatedCorners: Shape {
///     var corners: [Corner]
///     
///     var animatableData: AnimatableArray<Corner.AnimatableData> {
///         get { corners.elementAnimatableData }
///         set { corners.elementAnimatableData = newValue }
///     }
///     
///     func path(in rect: CGRect) -> Path {
///         // Create path using corners
///     }
/// }
/// 
@dynamicMemberLookup
public struct AnimatableArray<Element> {
    /// The underlying array being wrapped.
    public var wrappedValue: [Element]
    
    /// Creates an AnimatableArray wrapping the provided array.
    /// - Parameter wrappedValue: The array to wrap for animation.
    public init(_ wrappedValue: [Element]) {
        self.wrappedValue = wrappedValue
    }
    
    /// Provides dynamic member lookup to access array properties and methods.
    /// - Parameter keyPath: The key path to the array member.
    /// - Returns: The value at the specified key path.
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Array<Element>, V>) -> V {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
    
    /// The zero value for this type, represented as an empty array.
    public static var zero: Self {
        .init([])
    }
}

extension AnimatableArray: Sendable where Element: Sendable { }

extension AnimatableArray: Equatable where Element: Equatable {
    /// Determines equality by comparing the wrapped arrays.
    /// - Parameters:
    ///   - lhs: The left-hand side AnimatableArray.
    ///   - rhs: The right-hand side AnimatableArray.
    /// - Returns: `true` if the wrapped arrays are equal, `false` otherwise.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension AnimatableArray: AdditiveArithmetic where Element: AdditiveArithmetic {
    /// Adds two AnimatableArrays element-wise, padding shorter arrays with zero values.
    /// - Parameters:
    ///   - lhs: The left-hand side AnimatableArray.
    ///   - rhs: The right-hand side AnimatableArray.
    /// - Returns: A new AnimatableArray with element-wise addition results.
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
    
    /// Subtracts two AnimatableArrays element-wise, padding shorter arrays with zero values.
    /// - Parameters:
    ///   - lhs: The left-hand side AnimatableArray.
    ///   - rhs: The right-hand side AnimatableArray.
    /// - Returns: A new AnimatableArray with element-wise subtraction results.
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
    /// Scales all elements in the array by the specified factor.
    /// - Parameter rhs: The scaling factor.
    public mutating func scale(by rhs: Double) {
        wrappedValue = wrappedValue.map { $0.scaled(by: rhs) }
    }
    
    /// The sum of squared magnitudes of all elements in the array.
    public var magnitudeSquared: Double {
        wrappedValue.reduce(into: 0.0) { partialResult, element in
            partialResult += element.magnitudeSquared
        }
    }
}

extension AnimatableArray: ExpressibleByArrayLiteral {
    /// Creates an AnimatableArray from an array literal.
    /// - Parameter elements: The elements to include in the array.
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension Array where Element: VectorArithmetic {
    /// Provides animatable data for arrays of `VectorArithmetic` elements.
    ///
    /// This computed property allows arrays to be animated directly when their elements
    /// conform to VectorArithmetic.
    /// 
    /// - Note: Only existing elements are updated during animation; array size changes are not animated.
    public var animatableData: AnimatableArray<Element> {
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
    /// Provides animatable data for arrays of Animatable elements.
    /// 
    /// This computed property allows arrays to be animated by extracting and managing
    /// the animatable data of each element.
    /// 
    /// - Note: Only existing elements are updated during animation; array size changes are not animated.
    public var elementAnimatableData: AnimatableArray<Element.AnimatableData> {
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
