//
//  CornerStyle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

/// An enum describing a corner style including subproperties.
public enum CornerStyle: Hashable, Codable, Sendable {
    /// A simple point corner with no additional styling. This is the default style if none has been provided.
    case point
    
    /// A rounded corner style with a specified radius.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to round this corner. Relative values relate to the shortest of the two lines from this corner.
    case rounded(_ radius: RelatableValue)
    
    /// A concave corner style with a specified radius.
    ///
    /// With zero radius offset, this corner style looks like a rounded corner flipped, but with the same start and end points. The radius offset is used to compensate for shape insetting. By default the center point of the circle describing the radius can be found by flipping the center point of the rounded corner circle across the line described by the arc endpoints. When a shape is inset, this point needs to remain in the same location leading to a non-zero radius offset.
    ///  - Parameters:
    ///   - radius: Radius of the circle used to cutout this corner. Relative values relate to the shortest of the two lines from this corner.
    ///   - radiusOffset: Added to radius to create concave curve radius. Default is zero.
    case concave(_ radius: RelatableValue, radiusOffset: CGFloat = 0)
    
    /// A straight chamfer corner style with a specified radius. Additional corner styles can be used on the two resulting corners of the chamfer.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to determine the start and end points of the chamfer. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyles: Corner styles for the two resulting corners of the chamfer.
    case straight(_ radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    
    /// A cutout corner style with a specified radius. Additional corner styles can be used on the three resulting corners of the cut.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start and end points of the cutout. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyles: Corner styles for the three resulting corners of the cutout.
    case cutout(_ radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    
    /// A custom corner style with a specified radius. Additional anchor points with corner styles are used to determine the shape.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start, and end corners of the custom shape. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyles: An array of anchor points with corner styles that create corners in a rectangle that will be stretched and skewed to fit the corner starting at the bottom left and ending at the top right.
//    case custom(radius: RelatableValue, cornerStyles: [(RectAnchor, CornerStyle)])
}

public extension CornerStyle {
    /// A string with the name of this corner style.
    var name: String {
        switch self {
        case .point:
            return "point"
        case .rounded:
            return "rounded"
        case .concave:
            return "concave"
        case .straight:
            return "straight"
        case .cutout:
            return "cutout"
        }
    }
    
    @available(*, deprecated, renamed: "rounded(_:)")
    static func rounded(radius: RelatableValue) -> Self {
        .rounded(radius)
    }
    
    @available(*, deprecated, renamed: "concave(_:radiusOffset:)")
    static func concave(radius: RelatableValue, radiusOffset: CGFloat = 0) -> Self {
        .concave(radius, radiusOffset: radiusOffset)
    }
    
    @available(*, deprecated, renamed: "straight(_:cornerStyles:)")
    static func straight(radius: RelatableValue, cornerStyles: [CornerStyle] = []) -> Self {
        .straight(radius, cornerStyles: cornerStyles)
    }
    
    @available(*, deprecated, renamed: "cutout(_:cornerStyles:)")
    static func cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = []) -> Self {
        .cutout(radius, cornerStyles: cornerStyles)
    }
    
    /// A straight chamfer corner style with a specified radius and a nested corner style applied to the two resulting corners of the chamfer.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to determine the start and end points of the chamfer. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyle: Corner style for the two resulting corners of the chamfer.
    static func straight(_ radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        .straight(radius, cornerStyles: [cornerStyle, cornerStyle])
    }
    
    /// A straight chamfer corner style with a specified radius and a nested corner style applied to the two resulting corners of the chamfer.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to determine the start and end points of the chamfer. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyle: Corner style for the two resulting corners of the chamfer.
    @available(*, deprecated, renamed: "straight(_:cornerStyle:)")
    static func straight(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        .straight(radius, cornerStyle: cornerStyle)
    }
    
    /// A cutout corner style with a specified radius and a nested corner style applied to the three resulting corners of the cut.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start and end points of the cutout. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyle: Corner style for the three resulting corners of the cutout.
    static func cutout(_ radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        .cutout(radius, cornerStyles: [cornerStyle, cornerStyle, cornerStyle])
    }
    
    /// A cutout corner style with a specified radius and a nested corner style applied to the three resulting corners of the cut.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start and end points of the cutout. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyle: Corner style for the three resulting corners of the cutout.
    @available(*, deprecated, renamed: "cutout(_:cornerStyle:)")
    static func cutout(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        .cutout(radius, cornerStyle: cornerStyle)
    }
    
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
    
    /// A boolean check that determines if a corner style is flat. Flat corners are point, rounded, and concave with absolute radius values.
    ///
    /// If a corner uses relative radius values or allows nested corner styles, this value will be false.
    var isFlat: Bool {
        switch self {
        case .point:
            return true
        case .rounded, .concave:
            if case .absolute = radius {
                return true
            }
            return false
        case .straight, .cutout:
            return false
        }
    }
    
    /// Creates a corner style matching this style but with a new radius.
    /// - Parameter radius: Radius of the new corner style.
    /// - Returns: A corner style matching this style but with a new radius.
    func changingRadius(to radius: RelatableValue) -> CornerStyle {
        switch self {
        case .point:
            return self
        case .rounded:
            return .rounded(radius)
        case let .concave(_, radiusOffset):
            return .concave(radius, radiusOffset: radiusOffset)
        case let .straight(_, cornerStyles):
            return .straight(radius, cornerStyles: cornerStyles)
        case let .cutout(_, cornerStyles):
            return .cutout(radius, cornerStyles: cornerStyles)
        }
    }
    
    /// Create a corner style matching this style but with an absolute value radius.
    ///
    /// All relative values will be changed to absolute based on the supplied total.
    /// - Parameter maxRadius: Relative radius values will use this value to determine their absolute values.
    /// - Returns: A corner style matching this style but with an absolute value radius.
    func absolute(using maxRadius: CGFloat) -> Self {
        changingRadius(to: .absolute(radius.value(using: maxRadius)))
    }
}
