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
        guard abs(denominator) > 1e-8 else { return .topLeft }
        
        let x = relativeVector.crossProduct(with: frame.yAxis) / denominator
        let y = frame.xAxis.crossProduct(with: relativeVector) / denominator
        
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
