//
//  NotchStyle+staticInit.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-09.
//

import Foundation

public extension NotchStyle {
    /// A triangular shaped notch with default corner styles.
    static let triangle = NotchStyle.triangle()
    
    /// Creates a triangular shaped notch with a specified corner style for all 3 corners.
    /// - Parameter cornerStyle: Corner style to apply to all 3 corners.
    /// - Returns: A triangular notch with styled corners.
    static func triangle(cornerStyle: CornerStyle?) -> NotchStyle {
        .triangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 3))
    }
    
    /// A triangular shaped notch.
    /// - Parameter cornerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
    /// - Returns: A NotchStyle configured as a triangle.
    static func triangle(_ cornerStyles: CornerStyle?...) -> NotchStyle {
        .triangle(cornerStyles: cornerStyles)
    }
    
    /// A rectangular shaped notch with default corner styles.
    static let rectangle = NotchStyle.rectangle()
    
    /// Creates a rectangular shaped notch with a specified corner style for all 4 corners.
    /// - Parameter cornerStyle: Corner style to apply to all 4 corners.
    /// - Returns: A rectangular notch with styled corners.
    static func rectangle(cornerStyle: CornerStyle?) -> NotchStyle {
        .rectangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 4))
    }
    
    /// A rectangular shaped notch.
    /// - Parameter cornerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
    /// - Returns: A NotchStyle configured as a rectangle.
    static func rectangle(_ cornerStyles: CornerStyle?...) -> NotchStyle {
        .rectangle(cornerStyles: cornerStyles)
    }
    
    /// A custom shaped notch defined by corners in a reference frame equal to the notch's length and depth.
    /// 
    /// - Warning: Some custom notches may no longer draw correctly.
    /// - Parameters:
    ///   - corners: A closure used to create corners in a rectangle defined by the length and depth of the notch. Start and end points are at the top left and top right of the rectangle and do not need to be included.
    /// - Returns: A NotchStyle with the custom shape defined by the closure.
    @available(*, deprecated, renamed: "custom(_:)", message: "NotchStyle has been redesigned to work with animation and can no longer support a closure property. The new custom notch based on relative corners should handle most cases where corners are positioned relative to the notch length and depth but if not you may need to switch to manually drawing the corners without using a notch.")
    static func custom(corners: @Sendable @escaping (_ in: CGRect) -> [Corner]) -> NotchStyle {
        // Convert the closure-based corners to relative corners using a reference frame
        let relativeCorners = corners(.one).relative(to: .one)
        return .custom(relativeCorners: relativeCorners)
    }
}
