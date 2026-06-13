//
//  Notch+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

extension Notch: CornerStylable {
    public func cornerStyle(_ newStyle: CornerStyle) -> Notch {
        notchShape(style.cornerStyle(newStyle))
    }
    
    /// Creates a copy of this notch with new styles applied to its corners.
    /// - Parameter newStyles: Styles to apply to each corner respectively. Nil values keep the current style.
    /// - Returns: A notch with the supplied corner styles.
    public func cornerStyles(_ newStyles: [CornerStyle?]) -> Notch {
        notchShape(style.cornerStyles(newStyles))
    }
    
    public func changingRadius(to newRadius: RelatableValue) -> Notch {
        notchShape(style.changingRadius(to: newRadius))
    }
}

public extension Notch {
    /// Creates an array of corners describing a notch between two points.
    ///
    /// Although any `Vector2Representable` object can be passed in, the output is always an array of corners as notch styles can contain corner styles.
    /// - Parameters:
    ///  - start: Start point of the line where a notch is added.
    ///  - end: End point of the line where a notch is added.
    /// - Returns: An array of corners describing a notch between two points.
    func between(start: some Vector2Representable, end: some Vector2Representable) -> [Corner] {
        let vector = end.vector - start.vector
        
        // Check if vector has a direction. If not then a notch can't be created between these two points.
        guard let direction = vector.direction else {
            return []
        }
        
        let totalLength = vector.magnitude
        let normalizedVector = vector.normalized
        let notchPosition = position.value(using: totalLength)
        let notchLength = length.value(using: totalLength)
        let notchDepth = depth.value(using: totalLength)
        let notchStartPoint = start.vector + normalizedVector * (notchPosition - (notchLength / 2))
        
        let rect = CGRect(x: 0, y: 0, width: notchLength, height: abs(notchDepth))
        
        let notchCorners = style.corners(in: rect)
        let signedNotchCorners: [Corner]
        if notchDepth < 0 {
            signedNotchCorners = notchCorners.flippedVertically(across: 0)
        } else {
            signedNotchCorners = notchCorners
        }
        
        return signedNotchCorners
            .rotated(direction)
            .moved(notchStartPoint)
    }
}
