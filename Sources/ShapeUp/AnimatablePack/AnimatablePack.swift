//
//  AnimatablePack.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-08-02.
//

/// AnimatablePack uses parameter pack iteration that is only available when using the Swift 6.0 compiler (Xcode 16+)
/// https://forums.swift.org/t/pitch-enable-pack-iteration/66168
#if compiler(>=6.0)
import SwiftUI

/**
 A parameter pack implementation of `AnimatablePair`
 
 Conforming to Animatable with AnimatablePair:

 ```swift
 struct MyShape: Animatable {
     var animatableData: AnimatablePair<CGFloat, AnimatablePair<RelatableValue, Double>> {
         get { AnimatablePair(insetAmount, AnimatablePair(cornerRadius, rotation)) }
         set {
             insetAmount = newValue.first
             cornerRadius = newValue.second.first
             rotation = newValue.second.second
         }
     }
 }
 ```
 
 Conforming to Animatable with AnimatablePack:
 ```swift
 struct MyShape: Animatable {
     var animatableData: AnimatablePack<CGFloat, RelatableValue, Double> {
         get { AnimatablePack(insetAmount, cornerRadius, rotation) }
         set { (insetAmount, cornerRadius, rotation) = newValue() }
     }
 }
 ```
 */
@available(iOS 17, macOS 14, watchOS 10, tvOS 17, *)
@dynamicMemberLookup
public struct AnimatablePack<each Item: VectorArithmetic>: VectorArithmetic {
    /// Pack of items that conform to ``VectorArithmetic``
    public var item: (repeat each Item)
    
    /// Creates an `Animatable` pack of items
    /// - Parameter item: Pack of items that conform to ``VectorArithmetic``
    public init(_ item: repeat each Item) {
        self.item = (repeat each item)
    }
    
    /// Access elements in the same was as a tuple using pack.1, pack.2, etc...
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<(repeat each Item), V>) -> V {
        get { item[keyPath: keyPath] }
        set { item[keyPath: keyPath] = newValue }
    }
    
    /// Call as function to easily return the item tuple.
    public func callAsFunction() -> (repeat each Item) {
        item
    }
}

@available(iOS 17, macOS 14, watchOS 10, tvOS 17, *)
extension AnimatablePack: Sendable where repeat each Item: Sendable { }


@available(iOS 17, macOS 14, watchOS 10, tvOS 17, *)
public extension AnimatablePack {
    static var zero: Self {
        .init(repeat (each Item).zero)
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(repeat (each lhs.item) + (each rhs.item))
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(repeat (each lhs.item) - (each rhs.item))
    }
    
    mutating func scale(by rhs: Double) {
        item = (repeat (each item).scaled(by: rhs))
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs - rhs).magnitudeSquared == .zero
    }
    
    var magnitudeSquared: Double {
        var value = 0.0
        for item in repeat each item {
            value += item.magnitudeSquared
        }
        return value
    }
}
#endif
