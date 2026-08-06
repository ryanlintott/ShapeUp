//
//  AnimatableByProperty.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-04.
//

import SwiftUI

/// A type whose animation data is synthesized from writable key paths.
///
/// Use ``animatableProperties`` for the properties stored directly in the animation data and
/// ``recursiveAnimatableProperties`` for values whose own direct fields should also animate.
/// Recursive fields contribute one additional level only.
///
/// ```swift
/// extension RecursiveCircle: AnimatableByProperty {
///     static var animatableProperties: some AnimatableProperty<Self> {
///         \.radius
///     }
///
///     static var recursiveAnimatableProperties: some AnimatableProperty<Self> {
///         \.circles
///     }
/// }
/// ```
public protocol AnimatableByProperty: Animatable
where AnimatableData == AnimatablePair<
    AnimatableProperties.AnimatableData,
    RecursiveAnimatableProperties.AnimatableData
> {
    /// The descriptor containing this type's direct animatable fields.
    associatedtype AnimatableProperties: AnimatableProperty<Self>

    /// The descriptor containing this type's recursive animatable fields. Any animatable fields of the properties in these fields will also be animated.
    associatedtype RecursiveAnimatableProperties: AnimatableProperty<Self>

    /// The direct fields included in this type's animation data.
    @AnimatablePropertiesBuilder<Self>
    static var animatableProperties: AnimatableProperties { get }

    /// Fields that may lead to recursion. Key paths to `AnimatableByProperty` values exclude their `recursiveAnimatableProperties` to prevent infinite recursion.
    @AnimatablePropertiesBuilder<Self>
    static var recursiveAnimatableProperties: RecursiveAnimatableProperties { get }
}

extension AnimatableByProperty {
    var animatablePropertiesData: AnimatableProperties.AnimatableData {
        get {
            Self.animatableProperties.animatableData(for: self)
        }
        set {
            Self.animatableProperties.applyAnimatableData(newValue, to: &self)
        }
    }
    
    var recursiveAnimatablePropertiesData: RecursiveAnimatableProperties.AnimatableData {
        get {
            Self.recursiveAnimatableProperties.animatableData(for: self)
        }
        set {
            Self.recursiveAnimatableProperties.applyAnimatableData(newValue, to: &self)
        }
    }
    
    public var animatableData: AnimatableData {
        get {
            .init(
                animatablePropertiesData,
                recursiveAnimatablePropertiesData
            )
        }
        set {
            animatablePropertiesData = newValue.first
            recursiveAnimatablePropertiesData = newValue.second
        }
    }
}

public extension AnimatableByProperty where RecursiveAnimatableProperties == AnimatablePropertiesBuilder<Self>.Empty {
    static var recursiveAnimatableProperties: RecursiveAnimatableProperties {
        .init()
    }
}

