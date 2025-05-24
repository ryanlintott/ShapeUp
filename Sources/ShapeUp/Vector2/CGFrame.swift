//
//  CGFrame.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-12.
//

import SwiftUI

/// A coordinate space or rhombus defined only by an origin and a vector for each axis.
public struct CGFrame {
    let origin: CGPoint
    let xAxis: Vector2
    let yAxis: Vector2
}

public extension CGFrame {
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
    
    init(_ rect: CGRect) {
        self.init(origin: rect.origin, size: rect.size)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    subscript (_ anchor: RectAnchor) -> CGPoint {
        origin
            .moved(xAxis * anchor.relativePoint.x)
            .moved(yAxis * anchor.relativePoint.y)
    }
    
    subscript (_ point: CGPoint) -> RectAnchor {
        /// Vector from origin to the point.
        let relativeVector = point.vector - origin.vector
        
        let denominator = xAxis.crossProduct(with: yAxis)
        guard abs(denominator) > 1e-8 else { return .topLeft }
        
        let x = relativeVector.crossProduct(with: yAxis) / denominator
        let y = xAxis.crossProduct(with: relativeVector) / denominator
        
        return .relative(x, y)
    }
    
    /// Creates a point in the location of an anchor.
    /// - Parameter anchor: Anchor where the point is located.
    /// - Returns: A point where the anchor is located.
    subscript (_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        self[.relative(x, y)]
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    subscript (_ anchors: [RectAnchor]) -> [CGPoint] {
        anchors.map { self[$0] }
    }
    
    subscript (_ anchors: RectAnchor...) -> [CGPoint] {
        self[anchors]
    }
    
    subscript (_ points: [CGPoint]) -> [RectAnchor] {
        points.map { self[$0] }
    }
    
    subscript (_ points: CGPoint...) -> [RectAnchor] {
        self[points]
    }
}
