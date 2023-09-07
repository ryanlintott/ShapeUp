//
//  NotchStyle+staticInit.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-09.
//

import Foundation

public extension NotchStyle {
    /// A triangular shaped notch with default corner styles.
    static let triangle = NotchStyle.triangle(cornerStyles: [])
    /// A rectangular shaped notch with default corner styles.
    static let rectangle = NotchStyle.rectangle(cornerStyles: [])
    
    /// Creates a triangular shaped notch with a specified corner style for all 3 corners.
    /// - Parameter cornerStyle: Corner style to apply to all 3 corners.
    /// - Returns: A triangular notch with styled corners.
    static func triangle(cornerStyle: CornerStyle? = nil) -> NotchStyle {
        .triangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 3))
    }
    
    /// Creates a rectangular shaped notch with a specified corner style for all 4 corners.
    /// - Parameter cornerStyle: Corner style to apply to all 4 corners.
    /// - Returns: A rectangular notch with styled corners.
    static func rectangle(cornerStyle: CornerStyle? = nil) -> NotchStyle {
        .rectangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 4))
    }
}
