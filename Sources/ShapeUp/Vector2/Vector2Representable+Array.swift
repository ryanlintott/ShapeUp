//
//  Vector2Representable+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public extension Collection where Element: Vector2Representable {
    /// A bounding frame containing all the points in the array.
    ///
    /// This frame only takes into account the points and not any corner shapes so the shape itself might be inset in the frame.
    var bounds: CGRect {
        guard !isEmpty else {
            return .zero
        }
        
        let xArray = self.map { $0.vector.dx }
        let yArray = self.map { $0.vector.dy }
        let minX = xArray.min() ?? .zero
        let minY = yArray.min() ?? .zero
        let maxX = xArray.max() ?? .zero
        let maxY = yArray.max() ?? .zero

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

public extension Array where Element: Vector2Representable {
    /// A Vector2 array.
    var vectors: [Vector2] {
        map { $0.vector }
    }
    
    /// A CGPoint array.
    var points: [CGPoint] {
        map { $0.point }
    }
    
    /// Creates a point in the location of an anchor on the bounds.
    /// - Parameter anchor: Bounds anchor where the point is located.
    /// - Returns: The point where the bounds anchor is located.
    @available(*, deprecated: 100000, renamed: "bounds.subscript(_:)", message: "Use bounds[anchor] instead.")
    func anchorPoint(_ anchor: RectAnchor) -> CGPoint {
        bounds[anchor]
    }
    
    /// Center point of the bounds rectangle containing all points in the array.
    @available(*, deprecated: 100000, renamed: "bounds.center", message: "Use bounds[anchor] instead.")
    var center: CGPoint {
        bounds[.center]
    }
    
    /// An array of angles occuring at each point assuming points are connected in a closed shape.
    var angles: [Angle] {
        guard self.count >= 3 else {
            return []
        }

        return self
            .enumerated()
            .map {
                let previousPoint = $0.offset == 0 ? self.last! : self[$0.offset - 1]
                let nextPoint = $0.offset == self.count - 1 ? self.first! : self[$0.offset + 1]
                return Angle.threePoint(nextPoint, $0.element, previousPoint)
            }
    }
}
