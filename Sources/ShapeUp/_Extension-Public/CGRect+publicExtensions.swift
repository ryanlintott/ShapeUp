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
    
    public subscript (_ anchor: RectAnchor) -> CGPoint {
        anchor.point(in: self)
    }
}

public extension CGRect {
    /// Creates an array of points from the 4 corners of the rectangle starting with the top left and going clockwise.
    var points: [CGPoint] {
        points(.vertices)
    }
    
    /// Creates an array of points at relative coordinates in the rectangle.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the rectangle.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: The points at the relative coordinates.
    @available(*, deprecated, renamed: "points(_:)", message: "Use `points { }` instead.")
    func points(relativeLocations: [(x: CGFloat, y: CGFloat)]) -> [CGPoint] {
        relativeLocations.map { self[$0.x, $0.y] }
    }
    
    /// Creates an array of points at the relative coordinates in the rectangle.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the rectangle.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: The points at the relative coordinates.
    @available(*, deprecated, renamed: "points(_:)", message: "Use `points { }` instead.")
    func points(relativeLocations: (x: CGFloat, y: CGFloat)...) -> [CGPoint] {
        points(relativeLocations: relativeLocations)
    }
    
    /// Creates a point in the location of an anchor.
    /// - Parameter anchor: Anchor where the point is located
    /// - Returns: A point where the anchor is located.
    @available(*, deprecated, renamed: "subscript(_:)", message: "Use `rect[anchor]` instead.")
    func point(_ anchor: RectAnchor) -> CGPoint {
        self[anchor]
    }
    
    /// Creates a point at the relative location inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocation: A tuple with relative x and y coordinates respectively.
    /// - Returns: A point at the relative location inside this CGRect.
    @available(*, deprecated, renamed: "subscript(_:_:)", message: "Use `rect[x, y]` instead.")
    func point(relativeLocation: (CGFloat, CGFloat)) -> CGPoint {
        self[relativeLocation.0, relativeLocation.1]
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
