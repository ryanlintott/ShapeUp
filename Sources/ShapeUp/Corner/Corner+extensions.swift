//
//  Corner+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

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
    /// Creates a corner at the same position but with the supplied style.
    /// - Parameter style: Corner style to apply.
    /// - Returns: A corner at the same position but with the supplied style.
    public func applyingStyle(_ style: CornerStyle) -> Corner {
        if style == self.style {
            return self
        }
        return Corner(style, point: point)
    }
    
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
    
    public func relative(to rect: CGRect) -> RelativeCorner {
        relative(to: CGFrame(rect))
    }
    
    public func relative(to frame: CGFrame) -> RelativeCorner {
        .init(anchorPoint: frame[point], style)
    }
}
