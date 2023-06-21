//
//  CGPoint+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-09-22.
//

import SwiftUI

extension CGPoint: Vector2Transformable {
    /// Vector pointing from zero to this point.
    public var vector: Vector2 {
        Vector2(dx: x, dy: y)
    }
    
    /// Creates a point based on the supplied vector.
    /// - Parameter vector: Vector placed at zero and used to determine point location.
    public init(vector: Vector2) {
        self = vector.point
    }
    
    public func repositioned(to point: some Vector2Representable) -> CGPoint {
        /// This function is required for Vector2Transformable conformance. Other types (like Corner) have to pass on their other properties but CGPoint only has point information.
        point.point
    }
}

