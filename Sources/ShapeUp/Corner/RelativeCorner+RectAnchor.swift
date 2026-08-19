//
//  RelativeCorner+RectAnchor.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-11.
//

import Foundation

extension RelativeCorner {
    /// A relative corner at the center position with default .point style.
    public static let center = RelativeCorner(anchor: .center)
    
    /// A relative corner at the top left position with default .point style.
    public static let topLeft = RelativeCorner(anchor: .topLeft)
    
    /// A relative corner at the top position with default .point style.
    public static let top = RelativeCorner(anchor: .top)
    
    /// A relative corner at the top right position with default .point style.
    public static let topRight = RelativeCorner(anchor: .topRight)
    
    /// A relative corner at the right position with default .point style.
    public static let right = RelativeCorner(anchor: .right)
    
    /// A relative corner at the bottom right position with default .point style.
    public static let bottomRight = RelativeCorner(anchor: .bottomRight)
    
    /// A relative corner at the bottom position with default .point style.
    public static let bottom = RelativeCorner(anchor: .bottom)
    
    /// A relative corner at the bottom left position with default .point style.
    public static let bottomLeft = RelativeCorner(anchor: .bottomLeft)
    
    /// A relative corner at the left position with default .point style.
    public static let left = RelativeCorner(anchor: .left)
    
    /// Creates a relative corner at a custom position with default .point style.
    /// - Parameters:
    ///   - x: Relative x position (0.0 to 1.0).
    ///   - y: Relative y position (0.0 to 1.0).
    /// - Returns: A RelativeCorner at the specified relative position with the default .point style.
    public static func relative(x: CGFloat, y: CGFloat) -> RelativeCorner {
        RelativeCorner(anchor: .relative(x: x, y: y))
    }
}
