//
//  Corner+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

extension Corner: RelativeRepresentable {
    public func repositioned(to anchor: RectAnchor) -> RelativeCorner {
        anchor.relativeCorner(style)
    }
}

extension Corner: Vector2Transformable {
    public var vector: Vector2 {
        Vector2(dx: x, dy: y)
    }
    
    public init(vector: Vector2) {
        x = vector.dx
        y = vector.dy
        style = .point
    }
    
    public func repositioned(to point: some Vector2Representable) -> Corner {
        Corner(style, point: point)
    }
}

extension Corner {
    /// Creates a set of saved dimensions based on the corner style and provided previous and next points.
    ///
    /// Used for creating paths, insetting, flattening, etc.
    /// - Parameters:
    ///   - previousPoint: Point before the corner.
    ///   - nextPoint: Point after the corner.
    /// - Returns: A set of saved dimensions based on the corner style and provided previous and next points.
    public func dimensions(previousPoint: CGPoint, nextPoint: CGPoint) -> Self.Dimensions {
        .init(corner: self, previousPoint: previousPoint, nextPoint: nextPoint)
    }
}
