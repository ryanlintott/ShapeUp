//
//  Notch+Methods.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension Notch {
    /// Creates an array of corners describing a notch between two points.
    ///
    /// Although any `Vector2Representable` object can be passed in, the output is always an array of corners as notch styles can contain corner styles.
    /// - Parameters:
    ///  - start: Start point of the line where a notch is added.
    ///  - end: End point of the line where a notch is added.
    /// - Returns: An array of corners describing a notch between two points.
    func between<T: Vector2Representable, U: Vector2Representable>(start: T, end: U) -> [Corner] {
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
