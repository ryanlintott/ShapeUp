//
//  CGRect+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

extension CGRect: CGFrameRepresentable {
    public var xAxis: Vector2 {
        CGFrame(self).xAxis
    }
    
    public var yAxis: Vector2 {
        CGFrame(self).yAxis
    }
}

public extension CGRect {
    /// Creates an array of points from the 4 corners of the rectangle starting with the top left and going clockwise.
    var points: [CGPoint] {
        points(.vertices)
    }
    
    /// Moves the origin.
    /// - Parameter distance: A vector representing the movement.
    /// - Returns: A rectangle of the same size, moved by the provided distance.
    func moved(_ distance: some Vector2Representable) -> Self {
        .init(
            origin: origin.moved(distance),
            size: size
        )
    }
    
    /// Moves the origin.
    /// - Parameters:
    ///   - dx: Delta x
    ///   - dy: Delta y
    /// - Returns: A rectangle of the same size, moved by the provided distance.
    func moved(dx: CGFloat = .zero, dy: CGFloat = .zero) -> Self {
        moved(Vector2(dx: dx, dy: dy))
    }
    
    /// Moves the rectangle from one relative position to a new location.
    /// - Parameters:
    ///   - anchor: Start location of anchor point.
    ///   - location: End location.
    /// - Returns: A rectangle of the same size and a new origin determined by moving an anchor point from one location to another.
    func moved(_ anchor: RectAnchor = .topLeft, to location: some Vector2Representable) -> Self {
        moved(location.vector - self[anchor].vector)
    }
    
    /// Moves the rectangle from one relative position to another
    /// - Parameters:
    ///   - anchor: Start location of anchor point.
    ///   - location: End location of anchor point.
    /// - Returns: A rectangle of the same size and a new origin determined by moving an anchor point from one location to another.
    func moved(_ anchor: RectAnchor = .topLeft, to location: RectAnchor) -> Self {
        moved(anchor, to: self[location])
    }
    
    /// Scales the rectangle by a specified size using a specified anchor point.
    /// - Parameters:
    ///   - scale: Scale amount.
    ///   - anchor: Anchor point for scale. Default is .topLeft
    /// - Returns: A rectangle scaled by a specified size using a specified anchor point.
    func scaled(_ scale: CGSize, anchor: RectAnchor = .topLeft) -> Self {
        .init(
            origin: origin.scaledPosition(scale, anchor: self[anchor]),
            size: size.scaled(scale)
        )
    }
    
    /// Scales the rectangle by a specified x and y amount using a specified anchor point.
    /// - Parameters:
    ///   - x: X scale amount
    ///   - y: Y scale amount
    ///   - anchor: Anchor point for scale. Default is .topLeft
    /// - Returns: A rectangle scaled by a specified x and y amount using a specified anchor point.
    func scaled(x: CGFloat, y: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        scaled(CGSize(width: x, height: y), anchor: anchor)
    }
    
    /// Scales the rectangle by a specified amount using a specified anchor point.
    /// - Parameters:
    ///   - scale: Scale amount
    ///   - anchor: Anchor point for scale. Default is .topLeft
    /// - Returns: A rectangle scaled by a specified amount using a specified anchor point.
    func scaled(_ scale: CGFloat, anchor: RectAnchor = .topLeft) -> Self {
        scaled(CGSize(width: scale, height: scale), anchor: anchor)
    }
}
