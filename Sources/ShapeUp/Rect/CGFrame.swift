//
//  CGFrame.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-12.
//

import SwiftUI

/// A coordinate space or rhombus defined only by an origin and a vector for each axis.
public struct CGFrame {
    /// The origin point of the coordinate frame.
    public var origin: CGPoint
    /// The vector defining the x-axis direction and magnitude.
    public var xAxis: Vector2
    /// The vector defining the y-axis direction and magnitude.
    public var yAxis: Vector2
}

public extension CGFrame {
    // MARK: - Inits
    
    /// Creates a coordinate frame with the specified origin, size, anchor, and rotation.
    /// - Parameters:
    ///   - origin: The origin point of the frame.
    ///   - size: The size of the frame.
    ///   - anchor: The anchor point for positioning (default: .topLeft).
    ///   - rotation: The rotation angle of the frame (default: .zero).
    init(
        origin: CGPoint,
        size: CGSize,
        anchor: RectAnchor = .topLeft,
        rotation: Angle = .zero
    ) {
        self.origin = origin
        self.xAxis = Vector2(magnitude: size.width, direction: rotation)
        self.yAxis = Vector2(magnitude: size.width, direction: rotation + Angle.degrees(90))
    }
    
    /// Creates a coordinate frame equivalent for a CGRect.
    /// - Parameter rect: The rectangle to convert to a coordinate frame.
    init(_ rect: CGRect) {
        self.init(origin: rect.origin, size: rect.size)
    }
    
    // MARK: - Points from anchor points
    
    /// Returns the point at the specified anchor location within the frame.
    /// - Parameter anchor: The anchor defining the point location.
    /// - Returns: The point at the anchor location.
    subscript (_ anchor: RectAnchor) -> CGPoint {
        origin
            .moved(xAxis * anchor.relativePoint.x)
            .moved(yAxis * anchor.relativePoint.y)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    subscript (_ anchors: [RectAnchor]) -> [CGPoint] {
        anchors.map { self[$0] }
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    subscript (_ anchors: RectAnchor...) -> [CGPoint] {
        self[anchors]
    }
    
    // MARK: - Points from relative coordinates

    /// Creates a point at the specified relative coordinates in the frame.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the frame.
    /// - Parameters:
    ///   - x: Relative x coordinate.
    ///   - y: Relative y coordinate.
    /// - Returns: The point at the relative coordinates.
    subscript (_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        self[.relative(x, y)]
    }
    
    /// Creates an array of points at relative coordinates in the frame.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the frame.
    /// - Parameter relativePoints: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: The points at the relative coordinates.
    subscript (_ relativePoints: [(x: CGFloat, y: CGFloat)]) -> [CGPoint] {
        relativePoints.map { self[$0.x, $0.y] }
    }
    
    /// Creates an array of points at the relative coordinates in the frame.
    ///
    /// Values outside the 0.0 to 1.0 range will project to relative coordinates outside the frame.
    /// - Parameter relativePoints: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: The points at the relative coordinates.
    subscript (_ relativePoints: (x: CGFloat, y: CGFloat)...) -> [CGPoint] {
        relativePoints.map { self[$0.x, $0.y] }
    }

    // MARK: - Anchor points from points
    
    /// Returns the relative anchor for a given point within the frame.
    /// - Parameter point: The point to convert to an anchor.
    /// - Returns: The relative anchor representing the point's position in the frame.
    subscript (_ point: CGPoint) -> RectAnchor {
        /// Vector from origin to the point.
        let relativeVector = point.vector - origin.vector
        
        let denominator = xAxis.crossProduct(with: yAxis)
        guard abs(denominator) > 1e-8 else { return .topLeft }
        
        let x = relativeVector.crossProduct(with: yAxis) / denominator
        let y = xAxis.crossProduct(with: relativeVector) / denominator
        
        return .relative(x, y)
    }
    
    /// Converts an array of points to their corresponding anchors within the frame.
    /// - Parameter points: The points to convert to anchors.
    /// - Returns: An array of anchors representing the points' positions in the frame.
    subscript (_ points: [CGPoint]) -> [RectAnchor] {
        points.map { self[$0] }
    }
    
    /// Converts points to their corresponding anchors within the frame.
    /// - Parameter points: The points to convert to anchors.
    /// - Returns: An array of anchors representing the points' positions in the frame.
    subscript (_ points: CGPoint...) -> [RectAnchor] {
        self[points]
    }
}
