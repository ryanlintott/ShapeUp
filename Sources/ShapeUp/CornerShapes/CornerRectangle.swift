//
//  CornerRectangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/// A rectangular shape with individually stylable corners, aligned inside the frame of the view containing it.
///
/// This shape can either be used in a SwiftUI View directly (similar to `RoundedRectangle`)
///
///     CornerRectangle(.straight(radius: 20), corners: [.bottomLeft, .bottomRight])
///         .fill()
///
/// Or the corners can be accessed directly for use in a more complex shape
///
///     public func corners(in rect: CGRect) -> [Corner] {
///         CornerRectangle(topLeft: .rounded(radius: 20))
///             .corners(in: rect)
///             .inset(by: 10)
///             .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
///     }
///
public struct CornerRectangle: CornerShape {
    public var closed = true
    public var insetAmount: CGFloat = 0
    
    /// An enumeration to indicate the four corners of a rectangle.
    public enum ShapeCorner: CaseIterable {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    /// An enumberation to indicate the four edges of a rectangle.
    public enum ShapeEdge: CaseIterable {
        case top
        case left
        case right
        case bottom
    }
    
    public var topLeft: CornerStyle?
    public var topRight: CornerStyle?
    public var bottomRight: CornerStyle?
    public var bottomLeft: CornerStyle?
    
    /// Creates a 2d rectangular shape with specified styles for each corner.
    /// - Parameters:
    ///   - topLeft: Style applied to the top left corner.
    ///   - topRight: Style applied to the top right corner.
    ///   - bottomRight: Style applied to the bottom right corner.
    ///   - bottomLeft: Style applied to the bottom left corner.
    public init(topLeft: CornerStyle? = nil, topRight: CornerStyle? = nil, bottomRight: CornerStyle? = nil, bottomLeft: CornerStyle? = nil) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }
    
    /// Creates a 2d rectangular shape with a style applied to specified corners.
    /// - Parameters:
    ///   - style: Style to apply to specified corners.
    ///   - corners: Corners to be styled. All others will have nil style (which defaults to "point").
    public init(_ style: CornerStyle, corners: Set<ShapeCorner> = Set(ShapeCorner.allCases)) {
        self.topLeft = corners.contains(.topLeft) ? style : nil
        self.topRight = corners.contains(.topRight) ? style : nil
        self.bottomRight = corners.contains(.bottomRight) ? style : nil
        self.bottomLeft = corners.contains(.bottomLeft) ? style : nil
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        rect
            .corners([
                topLeft,
                topRight,
                bottomRight,
                bottomLeft
            ])
    }
}
