//
//  AnimatablePack.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-08-02.
//

/// Crashes only with release build possibly due to writing past the end of a function local array
/// https://stackoverflow.com/questions/186237/program-only-crashes-as-release-build-how-to-debug
/// Waiting for iterable parameter pack feature to be added to swift as it may fix this issue
/// https://forums.swift.org/t/pitch-enable-pack-iteration/66168
/// Pack Iteration merged in Swift 6.0
/// https://github.com/swiftlang/swift-evolution/blob/main/proposals/0408-pack-iteration.md

#if compiler(>=6.0)
import SwiftUI

/// No longer needed with pack iteration
//fileprivate extension VectorArithmetic {
//    func addingMagnitudeSquared(to value: inout Double) {
//        value += magnitudeSquared
//    }
//}

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
public struct AnimatablePack<each Item: VectorArithmetic>: VectorArithmetic {
    /// Pack of items that conform to `VectorArithmetic`
    public var item: (repeat each Item)
    
    /// Creates an `Animatable` pack of items
    /// - Parameter item: Pack of items that conform to `VectorArithmetic`
    public init(_ item: repeat each Item) {
        self.item = (repeat each item)
    }
    
    public func callAsFunction() -> (repeat each Item) {
        item
    }
}

@available(iOS 17, macOS 14, watchOS 10, tvOS 17, *)
extension AnimatablePack: Sendable where (repeat each Item): Sendable { }


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
//        _ = (repeat (each item).addingMagnitudeSquared(to: &value))
        for i in repeat each item {
            value += i.magnitudeSquared
        }
        return value
    }
}
#endif
