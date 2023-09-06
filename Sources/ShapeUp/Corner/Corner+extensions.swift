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
    /// Radius of corner based on the style.
    public var radius: RelatableValue {
        style.radius
    }
    
    /// Creates a corner at the same position but with the supplied style.
    /// - Parameter style: Corner style to apply.
    /// - Returns: A corner at the same position but with the supplied style.
    public func applyingStyle(_ style: CornerStyle) -> Corner {
        if style == self.style {
            return self
        }
        return Corner(style, point: point)
    }
    
    /// Creates a corner with the same style at the same position but with a new supplied radius.
    /// - Parameter radius: Radius to apply to the corner.
    /// - Returns: A corner with the same style at the same position but with a new supplied radius.
    public func changingRadius(to radius: RelatableValue) -> Corner {
        if radius == self.radius {
            return self
        }
        return applyingStyle(style.changingRadius(to: radius))
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
    
    func rescaled(from source: CGRect, to destination: CGRect) -> Self {
        .init(style, point: rescaledPoint(from: source, to: destination))
    }
}
