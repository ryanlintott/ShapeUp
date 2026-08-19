//
//  AnimatableDictionary.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-18.
//

import SwiftUI

/// A wrapper around Dictionary that provides animation capabilities for SwiftUI.
///
/// `AnimatableDictionary` allows dictionaries whose values conform to `VectorArithmetic` or `Animatable` to be smoothly animated by conforming to `VectorArithmetic`.
/// This enables key-based interpolation between values with matching keys during animations.
///
/// ## Usage Example for values conforming to `VectorArithmetic`
///
/// ```swift
/// struct AnimatedShape: Shape {
///     var vectors: [Int: Vector2]
///
///     var animatableData: AnimatableDictionary<Int, Vector2> {
///         get { vectors.animatableDictionary }
///         set { vectors.animatableDictionary = newValue }
///     }
///
///     func path(in rect: CGRect) -> Path {
///         Path()
///     }
/// }
/// ```
///
/// ## Usage Example for values conforming to `Animatable`
///
/// ```swift
/// struct AnimatedCorners: Shape {
///     var corners: [Int: Corner]
///
///     var animatableData: AnimatableDictionary<Int, Corner.AnimatableData> {
///         get { corners.animatableValueDictionary }
///         set { corners.animatableValueDictionary = newValue }
///     }
///
///     func path(in rect: CGRect) -> Path {
///         Path()
///     }
/// }
/// ```
/// - Note: Setting this property updates matching existing keys. It does not add or remove keys.
/// - Note: Use ``AnimatableProperties``or the `@Animatable` macro to more easily conform to `Animatable` unless you require custom logic inside `animatableData`.
@dynamicMemberLookup
public struct AnimatableDictionary<Key: Hashable, Value> {
    /// The underlying dictionary being wrapped.
    public var wrappedValue: [Key: Value] = [:]
    
    /// Creates an AnimatableDictionary wrapping the provided dictionary.
    /// - Parameter wrappedValue: The dictionary to wrap for animation.
    public init(_ wrappedValue: [Key: Value]) {
        self.wrappedValue = wrappedValue
    }
    
    /// Provides dynamic member lookup to access dictionary properties and methods.
    /// - Parameter keyPath: The key path to the dictionary member.
    /// - Returns: The value at the specified key path.
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Dictionary<Key,Value>, V>) -> V {
        get { wrappedValue[keyPath: keyPath] }
        set { wrappedValue[keyPath: keyPath] = newValue }
    }
    
    /// The zero value for this type, represented as an empty dictionary.
    public static var zero: Self {
        .init([:])
    }
}

extension AnimatableDictionary: Sendable where Key: Sendable, Value: Sendable { }

extension AnimatableDictionary: Equatable where Value: Equatable {
    /// Determines equality by comparing the wrapped dictionaries.
    /// - Parameters:
    ///   - lhs: The left-hand side AnimatableDictionary.
    ///   - rhs: The right-hand side AnimatableDictionary.
    /// - Returns: `true` if the wrapped dictionaries are equal, `false` otherwise.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension AnimatableDictionary: AdditiveArithmetic where Value: AdditiveArithmetic {
    /// Adds two AnimatableDictionaries key-wise, using zero values for missing keys.
    /// - Parameters:
    ///   - lhs: The left-hand side AnimatableDictionary.
    ///   - rhs: The right-hand side AnimatableDictionary.
    /// - Returns: A new AnimatableDictionary with key-wise addition results.
    /// - Note: Keys present in either dictionary will be included in the result.
    public static func + (lhs: Self, rhs: Self) -> Self {
        var result = lhs.wrappedValue
        rhs.wrappedValue.forEach { (key, value) in
            result[key, default: .zero] += value
        }
        return .init(result)
    }
    
    /// Subtracts two AnimatableDictionaries key-wise, using zero values for missing keys.
    /// - Parameters:
    ///   - lhs: The left-hand side AnimatableDictionary.
    ///   - rhs: The right-hand side AnimatableDictionary.
    /// - Returns: A new AnimatableDictionary with key-wise subtraction results.
    /// - Note: Keys present in either dictionary will be included in the result.
    public static func - (lhs: Self, rhs: Self) -> Self {
        var result = lhs.wrappedValue
        rhs.wrappedValue.forEach { (key, value) in
            result[key, default: .zero] -= value
        }
        return .init(result)
    }
}

extension AnimatableDictionary: VectorArithmetic where Value: VectorArithmetic {
    /// Scales all values in the dictionary by the specified factor.
    /// - Parameter rhs: The scaling factor.
    public mutating func scale(by rhs: Double) {
        wrappedValue = wrappedValue.mapValues {
            $0.scaled(by: rhs)
        }
    }

    /// The sum of squared magnitudes of all values in the dictionary.
    public var magnitudeSquared: Double {
        wrappedValue.values.reduce(into: 0.0) { partialResult, value in
            partialResult += value.magnitudeSquared
        }
    }
}

extension Dictionary where Key: Hashable, Value: VectorArithmetic {
    /// Provides animatable data for dictionaries of VectorArithmetic values.
    /// 
    /// This computed property allows dictionaries to be animated directly when their values
    /// conform to VectorArithmetic.
    /// 
    /// - Note: Setting this property updates matching existing keys. It does not add or remove keys.
    /// - Note: Use ``AnimatableProperties``or the `@Animatable` macro to more easily conform to `Animatable` unless you require custom logic inside `animatableData`.
    public var animatableDictionary: AnimatableDictionary<Key, Value> {
        get {
            .init(self)
        }
        set {
            newValue.wrappedValue.forEach { (key, animatableData) in
                if index(forKey: key) != nil {
                    self[key] = animatableData
                }
            }
        }
    }
}

extension Dictionary where Key: Hashable, Value: Animatable {
    /// Provides animatable data for dictionaries of Animatable values.
    /// 
    /// This computed property allows dictionaries to be animated by extracting and managing
    /// the animatable data of each value.
    /// 
    /// - Note: Setting this property updates matching existing keys. It does not add or remove keys.
    /// - Note: Use ``AnimatableProperties``or the `@Animatable` macro to more easily conform to `Animatable` unless you require custom logic inside `animatableData`.
    public var animatableValueDictionary: AnimatableDictionary<Key, Value.AnimatableData> {
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
