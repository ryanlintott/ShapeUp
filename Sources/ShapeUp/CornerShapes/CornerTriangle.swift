//
//  CornerTriangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-08.
//

import SwiftUI

/// A triangular shape with an adjustable top point and individually stylable corners, aligned inside the frame of the view containing it.
///
/// This shape can either be used in a SwiftUI View directly (similar to `RoundedRectangle`)
///
///     CornerTriangle(topPoint: .relative(0.3), style: .straight(radius: 20), corners: [.bottomRight, .bottomLeft])
///         .fill()
///
/// Or the corners can be accessed directly for use in a more complex shape
///
///     public func corners(in rect: CGRect) -> [Corner] {
///         CornerTriangle(top: .rounded(radius: 10))
///             .corners(in: rect)
///             .inset(by: 10)
///             .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
///     }
///
public struct CornerTriangle: CornerShape {
    public var closed = true
    public var insetAmount: CGFloat = 0
    
    /// An enumeration to indicate the three corners of a triangle.
    public enum ShapeCorner: CaseIterable {
        case top
        case bottomRight
        case bottomLeft
    }
    
    /// An enumeration to indicate the three edges of a triangle.
    public enum ShapeEdge: CaseIterable {
        case left
        case right
        case bottom
    }
    
    
    public var topPoint: RelatableValue
    public var top: CornerStyle?
    public var bottomRight: CornerStyle?
    public var bottomLeft: CornerStyle?
    
    /// Creates a 2d triangular shape with specified top point and styles for each corner.
    /// - Parameters:
    ///   - topPoint: Position of the top point from the top left corner of the frame. Relative values are relative to width.
    ///   - bottomRight: Style applied to the bottom right corner.
    ///   - bottomLeft: Style applied to the bottom left corner.
    public init(topPoint: RelatableValue = .relative(0.5), top: CornerStyle? = nil, bottomRight: CornerStyle? = nil, bottomLeft: CornerStyle? = nil) {
        self.topPoint = topPoint
        self.top = top
        self.bottomRight = bottomRight
        self.bottomLeft = bottomLeft
    }
    
    /// Creates a 2d triangular shape with specified top point and a style applied to specified corners.
    /// - Parameters:
    ///   - topPoint: Position of the top point from the top left corner of the frame. Relative values are relative to width.
    ///   - style: Style to apply to specified corners.
    ///   - corners: Corners to be styled. All others will have nil style (which defaults to "point").
    public init(topPoint: RelatableValue = .relative(0.5), style: CornerStyle, corners: Set<ShapeCorner> = Set(ShapeCorner.allCases)) {
        self.topPoint = topPoint
        self.top = corners.contains(.top) ? style : nil
        self.bottomRight = corners.contains(.bottomRight) ? style : nil
        self.bottomLeft = corners.contains(.bottomLeft) ? style : nil
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        [
            rect.anchorPoint(.topLeft).moved(dx: topPoint.value(using: rect.width)),
            rect.anchorPoint(.bottomRight),
            rect.anchorPoint(.bottomLeft)
        ]
            .corners([
                top,
                bottomRight,
                bottomLeft
            ])
    }
}
