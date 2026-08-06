//
//  AnimatableByProperty.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-04.
//

import SwiftUI

/// A type whose animation data is synthesized from writable key paths.
///
/// Every writable key path supplied by ``animatableProperties`` contributes to the synthesized
/// animation data.
///
/// ```swift
/// struct StyledRectangle: Shape, AnimatableByProperty {
///     var insetAmount: CGFloat
///     var cornerStyle: CornerStyle
///
///     static var animatableProperties: some AnimatableProperty<Self> {
///         \.insetAmount
///         \.cornerStyle
///     }
///
///     func path(in rect: CGRect) -> Path {
///         rect
///             .insetBy(dx: insetAmount, dy: insetAmount)
///             .corners(cornerStyle)
///             .path()
///     }
/// }
/// ```
public protocol AnimatableByProperty: Animatable {
    /// The descriptor containing this type's animatable fields.
    associatedtype AnimatableProperties: AnimatableProperty<Self>

    /// The properties included in this type's animation data.
    @AnimatablePropertiesBuilder<Self>
    static var animatableProperties: AnimatableProperties { get }
}

extension AnimatableByProperty {
    public var animatableData: AnimatableProperties.AnimatableData {
        get {
            Self.animatableProperties.animatableData(for: self)
        }
        set {
            Self.animatableProperties.applyAnimatableData(newValue, to: &self)
        }
    }
}
