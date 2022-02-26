//
//  CornerStyle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

/// An enum describing a corner style including subproperties.
public enum CornerStyle: Equatable {
    /// A simple point corner with no additional styling. This is the default style if none has been provided.
    case point
    
    /// A rounded corner style with a specified radius.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to round this corner.
    case rounded(radius: RelatableValue)
    
    /// A concave corner style with a specified radius.
    ///
    /// With zero radius offset, this corner style looks like a rounded corner flipped, but with the same start and end points. The radius offset is used to compensate for shape insetting. By default the center point of the circle describing the radius can be found by flipping the center point of the rounded corner circle across the line described by the arc endpoints. When a shape is inset, this point needs to remain in the same location leading to a non-zero radius offset.
    ///  - Parameters:
    ///   - radius: Radius of the circle used to cutout this corner.
    ///   - radiusOffset: Added to radius to create concave curve radius. Default is zero.
    case concave(radius: RelatableValue, radiusOffset: CGFloat = 0)
    
    /// A straight chamfer corner style with a specified radius. Additional cornerstyles can be used on the two resulting corners of the chamfer.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to determine the start and end points of the chamfer.
    ///   - cornerStyles: Corner styles for the two resulting corners of the chamfer.
    case straight(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    
    /// A cutout corner style with a specified radius. Additional cornerstyles can be used on the two corners of the chamfer.
    ///
    /// The cutout point is located at the center of the circle used to determine the radius.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start, cutout, and end corners of the cutout.
    ///   - cornerStyles: Corner styles for the three resulting corners of the cutout.
    case cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    
    /// A custom corner style with a specified radius. Additional corners are used to determine the shape.
    ///
    /// Additional corners are drawn based on a rectangular shape that will be scaled and skewed to fit the corner. The top left anchor is positioned on the corner point, the bottom left and top right on the start and end of the corner as determined by the radius and the bottom right anchor ma
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start, and end corners of the custom shape.
    ///   - corners: A closure used to create corners in a rectangle that will be stretched and skewed to fit the corner. Start and end points are at the bottom left and top right and do not need to be included.
//    case custom(radius: RelatableValue, corners: (CGRect) -> [Corner])
}

public extension CornerStyle {
    /// Radius of the corner.
    ///
    /// A circle with this radius determines the start and end points of any corner shape except concave that may be effected by radius offset.
    var radius: RelatableValue {
        switch self {
        case .point:
            return .zero
        case let .rounded(radius):
            return radius
        case let .concave(radius, _):
            return radius
        case let .straight(radius, _):
            return radius
        case let .cutout(radius, _):
            return radius
        }
    }
    
    /// Corner styles of any corners one level inside this corner.
    ///
    /// Some corners styles have no nested corners, others may have several and this nesting can continue to multiple levels.
    var cornerStyles: [CornerStyle] {
        switch self {
        case .point, .rounded, .concave:
            return []
        case let .straight(_, cornerStyles):
            return cornerStyles
        case let .cutout(_, cornerStyles):
            return cornerStyles
        }
    }
    
    /// A boolean check that determines if a corner style is flat.
    ///
    /// Flat corners are either point, rounded, or concave with absolute values. If a corner uses relative values or has nested corner styles, this value will be false.
    var isFlat: Bool {
        switch self {
        case .point:
            return true
        case .rounded, .concave:
            switch radius {
            case .absolute:
                return true
            case .relative:
                return false
            }
        case .straight, .cutout:
            return false
        }
    }
    
    /// Creates a corner style matching this style but with a new radius.
    /// - Parameter radius: Radius of the new cornerstyle.
    /// - Returns: A corner style matching this style but with a new radius.
    func changingRadius(to radius: RelatableValue) -> CornerStyle {
        switch self {
        case .point:
            return self
        case .rounded:
            return .rounded(radius: radius)
        case let .concave(_, radiusOffset):
            return .concave(radius: radius, radiusOffset: radiusOffset)
        case let .straight(_, cornerStyles):
            return .straight(radius: radius, cornerStyles: cornerStyles)
        case let .cutout(_, cornerStyles):
            return .cutout(radius: radius, cornerStyles: cornerStyles)
        }
    }
    
    /// Create a corner style matching this style but with an absolute value radius.
    ///
    /// All relative values will be changed to absolute based on the supplied total.
    /// - Parameter total: Relative values will use this total to determine their absolute values.
    /// - Returns: A corner style matching this style but with an absolute value radius.
    func absolute(using maxRadius: CGFloat) -> Self {
        changingRadius(to: .absolute(radius.value(using: maxRadius)))
    }
}
