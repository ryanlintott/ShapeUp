//
//  CGRect+PublicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

public extension CGRect {
    // MARK: - Subscripts for creating points, corners and anchors

    /// Creates a point in the location of an anchor.
    /// - Parameters:
    ///   - anchor: Anchor where the point is located.
    /// - Returns: A point where the anchor is located.
    subscript (_ anchor: RectAnchor) -> CGPoint {
        anchor.point(in: self)
    }
    
    /// Transforms a relative corner into a corner.
    ///
    /// - Note: The additional style parameter makes this subscript act as a disfavoured overload to the subscript that outputs a `CGPoint`.
    ///
    /// - Parameters:
    ///   - anchor: Anchor where the point is located.
    ///   - style: The corner style to apply. (default is .point)
    /// - Returns: A corner based on the relative corner.
    subscript (_ anchor: RectAnchor, _ style: CornerStyle = .point) -> Corner {
        self[anchor].corner(style)
    }
    
    /// Returns the relative anchor for a given point within the frame.
    /// - Parameter point: The point to convert to an anchor.
    /// - Returns: The relative anchor representing the point's position in the frame.
    subscript (_ point: CGPoint) -> RectAnchor {
        let relativePosition = point.vector - origin.vector
        let x = width == 0 ? 0 : relativePosition.dx / width
        let y = height == 0 ? 0 : relativePosition.dy / height
        return .relative(x: x, y: y)
    }
    
    /// Creates a point at the relative coordinates inside this rectangle.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the rectangle.
    /// - Parameters:
    ///   - x: Relative x coordinate.
    ///   - y: Relative y coordinate.
    /// - Returns: A point at the relative location inside this CGRect.
    subscript (x: CGFloat, y: CGFloat) -> CGPoint {
        self[.relative(x: x, y: y)]
    }
    
    /// Creates a point at the relative coordinates inside this rectangle.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the rectangle.
    /// - Parameters:
    ///   - x: Relative x coordinate.
    ///   - y: Relative y coordinate.
    ///   - style: The corner style to apply. (default is .point)
    /// - Returns: A corner at the relative location inside this CGRect with the applied style.
    subscript (x: CGFloat, y: CGFloat, _ style: CornerStyle = .point) -> Corner {
        self[.relative(x: x, y: y)].corner(style)
    }
    
    // MARK: - Points from anchors and relative coordinates
    
    /// Creates an array of points from the 4 corners of the rectangle starting with the top left and going clockwise.
    var points: [CGPoint] {
        points(.vertices)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func points(_ anchors: [RectAnchor]) -> [CGPoint] {
        anchors.map { self[$0] }
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func points(_ anchors: RectAnchor...) -> [CGPoint] {
        points(anchors)
    }
    
    /// Creates an array of points at relative coordinates in the rectangle.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the rectangle.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: The points at the relative coordinates.
    func points(relativeLocations: [(x: CGFloat, y: CGFloat)]) -> [CGPoint] {
        relativeLocations.map { self[$0.x, $0.y] }
    }
    
    /// Creates an array of points at the relative coordinates in the rectangle.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the rectangle.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: The points at the relative coordinates.
    func points(relativeLocations: (x: CGFloat, y: CGFloat)...) -> [CGPoint] {
        points(relativeLocations: relativeLocations)
    }
    
    // MARK: - Corners
    
    /// Creates an array of corners from the 4 corners of the rectangle starting with the top left and going clockwise with the `.point` style applied.
    var corners: [Corner] {
        points.corners
    }
    
    /// Creates an array of corners from the rectangle.
    /// - Parameter style: Corner style used for all corners.
    /// - Returns: An array of 4 corners, with the provided style, starting with the top left and going clockwise.
    func corners(_ style: CornerStyle = .point) -> [Corner] {
        points(.vertices).corners(style)
    }
    
    /// Creates an array of corners from the rectangle.
    /// - Parameter styles: Array of corner styles starting with the top left and going clockwise. Nil values will use `.point`
    /// - Returns: An array of 4 corners, with the provided styles, starting with the top left and going clockwise.
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        points(.vertices).corners(styles)
    }
    
    func corners(_ relativeCorners: RelativeCorner...) -> [Corner] {
        relativeCorners.map { self[$0.anchor, $0.style] }
    }

    // MARK: - Transformations

    /// Repositions the origin.
    /// - Parameter point: A vector representing the new origin.
    /// - Returns: A rectangle of the same size, repositioned to the new origin.
    func repositioned(to point: some Vector2Representable) -> Self {
        .init(origin: point.point, size: size)
    }
    
    /// Moves the origin.
    /// - Parameter distance: A vector representing the movement.
    /// - Returns: A rectangle of the same size, moved by the provided distance.
    func moved(_ distance: some Vector2Representable) -> Self {
        let vector = origin.vector + distance.vector
        return repositioned(to: vector)
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
        let vector = location.vector - self[anchor].vector
        return repositioned(to: vector)
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
        self[anchor].rect(size: size.scaled(scale), anchor: anchor)
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

    // MARK: - Deprecated
    
    /// Creates a point in the location of an anchor.
    /// - Parameter anchor: Anchor where the point is located
    /// - Returns: A point where the anchor is located.
    @available(*, deprecated: 100000, renamed: "subscript(_:)", message: "Use `rect[anchor]` instead.")
    func point(_ anchor: RectAnchor) -> CGPoint {
        self[anchor]
    }
    
    /// Creates a point at the relative location inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocation: A tuple with relative x and y coordinates respectively.
    /// - Returns: A point at the relative location inside this CGRect.
    @available(*, deprecated: 100000, renamed: "subscript(_:_:)", message: "Use `rect[x, y]` instead.")
    func point(relativeLocation: (CGFloat, CGFloat)) -> CGPoint {
        self[relativeLocation.0, relativeLocation.1]
    }
}
