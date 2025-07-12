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
    
    /// Creates a relative corner at a custom position with default .point style.
    /// - Parameters:
    ///   - x: Relative x position (0.0 to 1.0).
    ///   - y: Relative y position (0.0 to 1.0).
    /// - Returns: A RelativeCorner at the specified relative position with the default .point style.
    public static func relative(x: CGFloat, y: CGFloat) -> RelativeCorner {
        RelativeCorner(anchorPoint: .relative(x: x, y: y))
    }
}
