//
//  CGFrame.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-12.
//

import SwiftUI

/// A type that represents a coordinate frame using an origin and two axis vectors.
public protocol CGFrameRepresentable {
    /// The origin point of the coordinate frame.
    var origin: CGPoint { get }
    /// The vector defining the x-axis direction and magnitude.
    var xAxis: Vector2 { get }
    /// The vector defining the y-axis direction and magnitude.
    var yAxis: Vector2 { get }
    
    /// Creates a point in the location of an anchor.
    /// - Parameters:
    ///   - anchor: Anchor where the point is located.
    /// - Returns: A point where the anchor is located.
    subscript (_ anchor: RectAnchor) -> CGPoint { get }
}

public extension CGFrameRepresentable {
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
    
    /// Creates a point at the specified relative coordinates in the frame.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the frame.
    /// - Parameters:
    ///   - x: Relative x coordinate.
    ///   - y: Relative y coordinate.
    /// - Returns: The point at the relative coordinates.
    subscript (x: CGFloat, y: CGFloat) -> CGPoint {
        self[.relative(x: x, y: y)]
    }
    
    /// Creates a corner at the specified relative coordinates in the frame.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the frame.
    /// - Parameters:
    ///   - x: Relative x coordinate.
    ///   - y: Relative y coordinate.
    ///   - style: The corner style to apply. (default is .point)
    /// - Returns: A corner at the relative coordinates with the applied style.
    subscript (x: CGFloat, y: CGFloat, _ style: CornerStyle = .point) -> Corner {
        self[.relative(x: x, y: y)].corner(style)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func points(_ anchors: [RectAnchor]) -> [CGPoint] {
        anchors.map { self[$0] }
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func points(_ anchors: RectAnchor...) -> [CGPoint] {
        points(anchors)
    }
    
    /// Creates an array of points in the locations supplied by a result builder.
    /// - Parameter anchors: A closure that builds the anchors defining the point locations.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func points(@RectAnchorArrayBuilder _ anchors: () -> [RectAnchor]) -> [CGPoint] {
        points(anchors())
    }
    
    /// Creates an array of corners from the four vertices of the frame, starting with the top left and going clockwise with the `.point` style applied.
    var corners: [Corner] {
        corners()
    }
    
    /// Creates an array of corners from the frame vertices.
    /// - Parameter style: Corner style used for all corners.
    /// - Returns: An array of 4 corners, with the provided style, starting with the top left and going clockwise.
    func corners(_ style: CornerStyle = .point) -> [Corner] {
        points(.vertices).corners(style)
    }
    
    /// Creates an array of corners from the frame vertices.
    /// - Parameter styles: Array of corner styles starting with the top left and going clockwise. Nil values will use `.point`
    /// - Returns: An array of 4 corners, with the provided styles, starting with the top left and going clockwise.
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        points(.vertices).corners(styles)
    }
    
    /// Creates corners from relative corners supplied by a result builder.
    /// - Parameter relativeCorners: A closure that builds the relative corners.
    /// - Returns: Corners positioned in this coordinate frame.
    func corners(@RelativeCornerArrayBuilder _ relativeCorners: () -> [RelativeCorner]) -> [Corner] {
        relativeCorners().map { $0.corner(in: self) }
    }
}


/// A coordinate frame defined by an origin and a vector for each axis.
public struct CGFrame {
    /// The origin point of the coordinate frame.
    public var origin: CGPoint
    /// The vector defining the x-axis direction and magnitude.
    public var xAxis: Vector2
    /// The vector defining the y-axis direction and magnitude.
    public var yAxis: Vector2
}

extension CGFrame: CGFrameRepresentable {
    public subscript (_ anchor: RectAnchor) -> CGPoint {
        origin
            .moved(xAxis * anchor.relativePoint.x)
            .moved(yAxis * anchor.relativePoint.y)
    }
}

public extension CGFrame {
    // MARK: - Inits
    
    /// Creates a coordinate frame with the specified origin, size, and rotation.
    /// - Parameters:
    ///   - origin: The origin point of the frame.
    ///   - size: The size of the frame.
    ///   - rotation: The rotation angle of the frame (default: .zero).
    init(
        origin: CGPoint,
        size: CGSize,
        rotation: Angle = .zero
    ) {
        self.origin = origin
        self.xAxis = Vector2(magnitude: size.width, direction: rotation)
        self.yAxis = Vector2(magnitude: size.height, direction: rotation + Angle.degrees(90))
    }
    
    /// Creates a coordinate frame equivalent to a CGRect.
    /// - Parameter rect: The rectangle to convert to a coordinate frame.
    init(_ rect: CGRect) {
        self.init(origin: rect.origin, size: rect.size)
    }
}
