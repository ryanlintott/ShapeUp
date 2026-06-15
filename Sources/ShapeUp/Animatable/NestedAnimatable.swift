//
//  NestedAnimatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-08.
//

import SwiftUI

/// A type that can animate recursive properties to one level.
///
/// `NestedAnimatable` is useful when you have a custom type that contains properties of the same type and you want those nested types to animate as well. It's also helpful when you have one type that may reference another, then back to the first again. The `animatableData` property allows the recursion while the `nestedAnimatableData` property ends it.
///
/// ## Usage Example
/// A nested circle type that draws a circle with other nested circles within. Animating the outer circle would be simple but animating the inner circle requires a recursive option for defining `AnimatableData`
///
/// ```swift
/// struct NestedCircle: NestedAnimatable {
///     var radius: CGFloat
///     var nestedCircles: [NestedCircle]
///
///     // Only animates the radius - not the nested circles
///     typealias NestedAnimatableData = CGFloat
///     
///     var nestedAnimatableData: NestedAnimatableData {
///         get { radius }
///         set { radius = newValue }
///     }
///     
///     // Animates all properties including the nested circle using nestedAnimatableData
///     var animatableData: AnimatablePair<CGFloat, AnimatableArray<NestedCircle.NestedAnimatableData>> {
///         get { AnimatablePair(radius, nestedCircles.nestedAnimatableData) }
///         set {
///             radius = newValue.first
///             nestedCircles.nestedAnimatableData = newValue.second
///         }
///     }
/// }
/// 
/// // Usage in a shape
/// struct NestedCircleShape: Shape {
///     var rootCircle: NestedCircle
///     
///     var animatableData: NestedCircle.AnimatableData {
///         get { rootCircle.animatableData }
///         set { rootCircle.animatableData = newValue }
///     }
///     
///     func path(in rect: CGRect) -> Path {
///         var path = Path()
///         drawCircle(rootCircle, at: rect.center, in: &path)
///         return path
///     }
///     
///     private func drawCircle(_ circle: NestedCircle, at center: CGPoint, in path: inout Path) {
///         path.addEllipse(in: CGRect(
///             x: center.x - circle.radius,
///             y: center.y - circle.radius,
///             width: circle.radius * 2,
///             height: circle.radius * 2
///         ))
///         
///         for nested in circle.nestedCircles {
///             drawCircle(nested, at: center, in: &path)
///         }
///     }
/// }
/// 
protocol NestedAnimatable: Animatable {
    /// The type defining the nested data to animate.
    ///
    /// This type is intended to be used inside ``SwiftUICore.AnimatableData``. It cannot reference itself or another type that references itself.
    associatedtype NestedAnimatableData: VectorArithmetic

    /// The nested data to animate.
    var nestedAnimatableData: Self.NestedAnimatableData { get set }
}

extension Array where Element: NestedAnimatable {
    /// Provides access to the nested animatable data for arrays of `NestedAnimatable` elements.
    /// 
    /// This computed property allows arrays of `NestedAnimatable` types to be animated
    /// by extracting and managing the nested animatable data of each element.
    /// 
    /// - Note: Only existing elements are updated during animation; array size changes are not animated.
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

extension Dictionary where Key: Hashable, Value: NestedAnimatable {
    /// Provides animatable data for dictionaries of Animatable values.
    ///
    /// This computed property allows dictionaries to be animated by extracting and managing
    /// the animatable data of each value.
    ///
    /// - Note: Only existing keys are updated during animation; new keys are not added.
    var nestedAnimatableData: AnimatableDictionary<Key, Value.NestedAnimatableData> {
        get {
            .init(mapValues(\.nestedAnimatableData))
        }
        set {
            newValue.wrappedValue.forEach { (key, nestedAnimatableData) in
                self[key]?.nestedAnimatableData = nestedAnimatableData
            }
        }
    }
}
