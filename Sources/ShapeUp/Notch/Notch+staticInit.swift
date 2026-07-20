//
//  Notch+staticInit.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-09.
//

import SwiftUI

public extension Notch {
    /// Creates a triangular shaped notch with specified position, length, depth, and corner style.
    /// - Parameters:
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    ///   - cornerStyle: Corner style used for all corners in the notch. Default is a .point style.
    /// - Returns: A triangular shaped notch with specified position, length, depth, and corner styles.
    @available(*, deprecated, message: "Use `Notch(.triangle, depth: 20).defaultCornerStyle(.rounded(radius: 10))` instead.")
    static func triangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyle: CornerStyle? = nil) -> Notch {
        Notch(.triangle(cornerStyle: cornerStyle), position: position, length: length, depth: depth)
    }
    
    /// Creates a triangular shaped notch with specified position, length, depth, and corner styles.
    /// - Parameters:
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    ///   - cornerStyles: Corner styles used for each corner in the notch. Nil values use an automatic style that renders as a point when no default style is supplied.
    /// - Returns: A triangular shaped notch with specified position, length, depth, and corner styles.
    @available(*, deprecated, message: "Use `Notch(.triangle, depth: 20).cornerStyles([nil, nil, .rounded(radius: 10)])` instead.")
    static func triangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyles: [CornerStyle?]) -> Notch {
        Notch(.triangle(cornerStyles: cornerStyles), position: position, length: length, depth: depth)
    }
    
    /// Creates a rectangular shaped notch with specified position, length, depth, and corner styles.
    /// - Parameters:
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    ///   - cornerStyle: Corner style used for all corners in the notch. Default is a .point style.
    /// - Returns: A rectangular shaped notch with specified position, length, depth, and corner styles.
    @available(*, deprecated, message: "Use `Notch(depth: 20).defaultCornerStyle(.rounded(radius: 10))` instead.")
    static func rectangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyle: CornerStyle? = nil) -> Notch {
        Notch(.rectangle(cornerStyle: cornerStyle), position: position, length: length, depth: depth)
    }
    
    /// Creates a rectangular shaped notch with specified position, length, depth, and corner styles.
    /// - Parameters:
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    ///   - cornerStyles: Corner styles used for each corner in the notch. Nil values use an automatic style that renders as a point when no default style is supplied.
    /// - Returns: A rectangular shaped notch with specified position, length, depth, and corner styles.
    @available(*, deprecated, message: "Use `Notch(depth: 20).cornerStyles([nil, nil, .rounded(radius: 10), nil])` instead.")
    static func rectangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyles: [CornerStyle?]) -> Notch {
        Notch(.rectangle(cornerStyles: cornerStyles), position: position, length: length, depth: depth)
    }
    
    /// Creates a custom notch with specified position, length, depth, and corner styles.
    /// 
    /// - Warning: Some custom notches may no longer draw correctly.
    /// - Parameters:
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    ///   - corners: A closure used to create corners in a rectangle defined by the length and depth of the notch. Start and end points are at the top left and top right of the rectangle and do not need to be included.
    /// - Returns: A custom notch with specified position, length, depth, and corners.
    @available(*, deprecated, message: "Use `Notch(depth: 20) { }` instead. Notch has been redesigned to work with animation and can no longer support a closure property. The new custom notch based on relative corners should handle most cases where corners are positioned relative to the notch length and depth but if not you may need to switch to manually drawing the corners without using a notch.")
    static func custom(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, corners: @Sendable @escaping (CGRect) -> [Corner]) -> Notch {
        Notch(.custom(corners: corners), position: position, length: length, depth: depth)
    }
}
