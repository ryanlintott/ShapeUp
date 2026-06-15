//
//  CGPoint+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-09-22.
//

import SwiftUI

extension CGPoint: Vector2Transformable {
    public var vector: Vector2 {
        Vector2(dx: x, dy: y)
    }
    
    /// Creates a point based on the supplied vector.
    /// - Parameter vector: Vector placed at zero and used to determine point location.
    public init(vector: Vector2) {
        self = vector.point
    }
    
    public func repositioned(to point: some Vector2Representable) -> Self {
        /// This function is required for Vector2Transformable conformance. Other types (like Corner) have to pass on their other properties but CGPoint only has point information.
        point.vector.point
    }
}

extension CGPoint: RelativeRepresentable {
    public func relative(to frame: some CGFrameRepresentable) -> RectAnchor {
        /// Vector from origin to the point.
        let relativeVector = vector - frame.origin.vector
        
        let denominator = frame.xAxis.crossProduct(with: frame.yAxis)
        let axisMagnitudeSquared = frame.xAxis.magnitudeSquared + frame.yAxis.magnitudeSquared
        guard axisMagnitudeSquared > 0 else { return .topLeft }

        let rankTolerance = axisMagnitudeSquared * .ulpOfOne * 16
        let x: CGFloat
        let y: CGFloat

        if abs(denominator) > rankTolerance {
            x = relativeVector.crossProduct(with: frame.yAxis) / denominator
            y = frame.xAxis.crossProduct(with: relativeVector) / denominator
        } else {
            // Use the minimum-norm solution when the axes describe a line.
            x = frame.xAxis.dotProduct(with: relativeVector) / axisMagnitudeSquared
            y = frame.yAxis.dotProduct(with: relativeVector) / axisMagnitudeSquared
        }
        
        return .relative(x: x, y: y)
    }
}

extension Array where Element == CGPoint {
    /// Creates a path defined by this array of points. Closed by default.
    /// - Parameters:
    ///   - closed: Boolean determining if the path is closed. Default is true.
    /// - Returns: A path defined by this array of points. Closed by default.
    public func path(closed: Bool = true) -> Path {
        // Creates corners which have a default .point type and returns their path
        corners.path(closed: closed)
    }
}
