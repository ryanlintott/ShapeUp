//
//  File.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-11.
//

import Foundation

extension RelativeCorner {
    // MARK: - Static properties for RectAnchor cases (default .point style)
    
    /// A relative corner at the center position with default .point style.
    public static let center = RelativeCorner(anchorPoint: .center)
    
    /// A relative corner at the top left position with default .point style.
    public static let topLeft = RelativeCorner(anchorPoint: .topLeft)
    
    /// A relative corner at the top position with default .point style.
    public static let top = RelativeCorner(anchorPoint: .top)
    
    /// A relative corner at the top right position with default .point style.
    public static let topRight = RelativeCorner(anchorPoint: .topRight)
    
    /// A relative corner at the right position with default .point style.
    public static let right = RelativeCorner(anchorPoint: .right)
    
    /// A relative corner at the bottom right position with default .point style.
    public static let bottomRight = RelativeCorner(anchorPoint: .bottomRight)
    
    /// A relative corner at the bottom position with default .point style.
    public static let bottom = RelativeCorner(anchorPoint: .bottom)
    
    /// A relative corner at the bottom left position with default .point style.
    public static let bottomLeft = RelativeCorner(anchorPoint: .bottomLeft)
    
    /// A relative corner at the left position with default .point style.
    public static let left = RelativeCorner(anchorPoint: .left)
    
    // MARK: - Static methods for RectAnchor cases
    
    /// Creates a relative corner at the center position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the center position with the specified style.
    public static func center(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .center, style)
    }
    
    /// Creates a relative corner at the top left position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the top left position with the specified style.
    public static func topLeft(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .topLeft, style)
    }
    
    /// Creates a relative corner at the top position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the top position with the specified style.
    public static func top(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .top, style)
    }
    
    /// Creates a relative corner at the top right position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the top right position with the specified style.
    public static func topRight(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .topRight, style)
    }
    
    /// Creates a relative corner at the right position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the right position with the specified style.
    public static func right(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .right, style)
    }
    
    /// Creates a relative corner at the bottom right position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the bottom right position with the specified style.
    public static func bottomRight(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .bottomRight, style)
    }
    
    /// Creates a relative corner at the bottom position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the bottom position with the specified style.
    public static func bottom(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .bottom, style)
    }
    
    /// Creates a relative corner at the bottom left position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the bottom left position with the specified style.
    public static func bottomLeft(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .bottomLeft, style)
    }
    
    /// Creates a relative corner at the left position.
    /// - Parameter style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the left position with the specified style.
    public static func left(_ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .left, style)
    }
    
    /// Creates a relative corner at a custom position.
    /// - Parameters:
    ///   - x: Relative x position (0.0 to 1.0).
    ///   - y: Relative y position (0.0 to 1.0).
    ///   - style: Corner style to apply. Default is .point.
    /// - Returns: A RelativeCorner at the specified relative position with the specified style.
    public static func relative(x: CGFloat, y: CGFloat, _ style: CornerStyle? = nil) -> RelativeCorner {
        RelativeCorner(anchorPoint: .relative(x: x, y: y), style)
    }
}