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
    case rounded(radius: RelatableValue)
    
    /// A concave corner style with a specified radius.
    ///
    /// With zero radius offset, this corner style looks like a rounded corner flipped, but with the same start and end points. The radius offset is used to compensate for shape insetting. By default the center point of the circle describing the radius can be found by flipping the center point of the rounded corner circle across the line described by the arc endpoints. When a shape is inset, this point needs to remain in the same location leading to a non-zero radius offset.
    ///  - Parameters:
    ///   - radius: Radius of the circle used to cutout this corner. Relative values relate to the shortest of the two lines from this corner.
    ///   - concaveInset: Inset for the concave radius. Default is 0. This value changes when insetting the corner.
    case concave(radius: RelatableValue, concaveInset: CGFloat = 0)
    
    /// A straight chamfer corner style with a specified radius. Additional corner styles can be used on the two resulting corners of the chamfer.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to determine the start and end points of the chamfer. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyles: Corner styles for the two resulting corners of the chamfer.
    case straight(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    
    /// A cutout corner style with a specified radius. Additional corner styles can be used on the three resulting corners of the cut.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start and end points of the cutout. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyles: Corner styles for the three resulting corners of the cutout.
    case cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    
    /// A custom corner style with a specified radius. Additional anchor points with corner styles are used to determine the corner shape.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start and end points of the custom shape. Relative values relate to the shortest of the two lines from this corner.
    ///   - corners: These corners define the corner shape. Their position is determined relative to a ``CGFrame`` defined by the radius.
    case custom(radius: RelatableValue, relativeCorners: [RelativeCorner])
}

public extension CornerStyle {
    /// A string with the name of this corner style.
    var name: String {
        switch self {
        case .point: "point"
        case .rounded: "rounded"
        case .concave: "concave"
        case .straight: "straight"
        case .cutout: "cutout"
        case .custom: "custom"
        }
    }
    
    /// A straight chamfer corner style with a specified radius and a nested corner style applied to the two resulting corners of the chamfer.
    ///  - Parameters:
    ///   - radius: Radius of a circle used to determine the start and end points of the chamfer. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyle: Corner style for the two resulting corners of the chamfer.
    static func straight(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        .straight(radius: radius, cornerStyles: [cornerStyle, cornerStyle])
    }
    
    /// A cutout corner style with a specified radius and a nested corner style applied to the three resulting corners of the cut.
    ///  - Parameters:
    ///   - radius: Radius of circle used to determine the start and end points of the cutout. Relative values relate to the shortest of the two lines from this corner.
    ///   - cornerStyle: Corner style for the three resulting corners of the cutout.
    static func cutout(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        .cutout(radius: radius, cornerStyles: [cornerStyle, cornerStyle, cornerStyle])
    }
    
    /// Radius of the corner.
    ///
    /// A circle with this radius determines the start and end points of any corner shape except concave that may be effected by radius offset.
    var radius: RelatableValue {
        get {
            switch self {
            case .point: .zero
            case let .rounded(radius): radius
            case let .concave(radius, _): radius
            case let .straight(radius, _): radius
            case let .cutout(radius, _): radius
            case let .custom(radius, _): radius
            }
        }
        set {
            self = self.changingRadius(to: newValue)
        }
    }
    
    /// Radius offset of the corner
    internal(set) var concaveInset: CGFloat {
        get {
            switch self {
            case .point, .rounded, .straight, .cutout, .custom:
                .zero
            case let .concave(_, concaveInset):
                concaveInset
            }
        }
        set {
            switch self {
            case .point, .rounded, .straight, .cutout, .custom:
                break
            case .concave:
                self = .concave(radius: radius, concaveInset: newValue)
            }
        }
    }
    
    /// Corner styles of any corners one level inside this corner.
    ///
    /// Some corners styles have no nested corners, others may have several and this nesting can continue to multiple levels.
    var cornerStyles: [CornerStyle] {
        switch self {
        case .point, .rounded, .concave: []
        case let .straight(_, cornerStyles): cornerStyles
        case let .cutout(_, cornerStyles): cornerStyles
        case .custom: relativeCorners.map(\.style)
        }
    }
    
    /// Relative corner setting is only used for animatableData
    internal var relativeCorners: [RelativeCorner] {
        get {
            switch self {
            case .point, .rounded, .concave:
                []
            case .straight:
                [.topLeft, .bottomRight].applyingStyles(cornerStyles)
            case .cutout:
                [.topLeft, .bottomLeft, .bottomRight].applyingStyles(cornerStyles)
            case let .custom(_, relativeCorners):
                relativeCorners
            }
        }
        set {
            switch self {
            case .point, .rounded, .concave:
                break
            case .straight:
                self = .straight(radius: radius, cornerStyles: newValue.cornerStyles)
            case .cutout:
                self = .cutout(radius: radius, cornerStyles: newValue.cornerStyles)
            case .custom:
                self = .custom(radius: radius, relativeCorners: newValue)
            }
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
        case .straight, .cutout, .custom:
            return false
        }
    }
    
    /// Creates a corner style matching this style but with a new radius.
    /// - Parameter radius: Radius of the new corner style.
    /// - Returns: A corner style matching this style but with a new radius.
    func changingRadius(to radius: RelatableValue) -> CornerStyle {
        switch self {
        case .point:
            self
        case .rounded:
                .rounded(radius: radius)
        case let .concave(_, concaveInset):
                .concave(radius: radius, concaveInset: concaveInset)
        case let .straight(_, cornerStyles):
                .straight(radius: radius, cornerStyles: cornerStyles)
        case let .cutout(_, cornerStyles):
                .cutout(radius: radius, cornerStyles: cornerStyles)
        case let .custom(_, relativeCorners):
                .custom(radius: radius, relativeCorners: relativeCorners)
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
