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
        style = .automatic
    }
    
    public func repositioned(to point: some Vector2Representable) -> Corner {
        Corner(style, point: point)
    }
}

public extension Corner {
    /// Converts this object to one that is relative to the specified frame.
    /// - Parameter frame: Frame used for relative position.
    /// - Returns: A relative version of this object anchored to the specified frame.
    func relative(to frame: some CGFrameRepresentable) -> RelativeCorner {
        point.relative(to: frame).relativeCorner.cornerStyle(style)
    }
    
    /// Creates a set of saved dimensions based on the corner style and provided previous and next points.
    ///
    /// Used for creating paths, insetting, flattening, etc.
    /// - Parameters:
    ///   - previousPoint: Point before the corner.
    ///   - nextPoint: Point after the corner.
    /// - Returns: A set of saved dimensions based on the corner style and provided previous and next points.
    internal func dimensions(previousPoint: CGPoint, nextPoint: CGPoint) -> Self.Dimensions {
        .init(corner: self, previousPoint: previousPoint, nextPoint: nextPoint)
    }
    
    @available(*, deprecated, renamed: "cornerStyle(_:)")
    func applyingStyle(_ newStyle: CornerStyle) -> Self {
        cornerStyle(newStyle)
    }
}
