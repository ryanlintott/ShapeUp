//
//  GeoMath.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-28.
//

import SwiftUI

internal enum GeoMath {
    /// Returns any intersection points between a line and a circle.
    /// - Parameters:
    ///   - line: A line defined by two points.
    ///   - circle: A circle defined by a center point and a radius.
    /// - Returns: An array of intersection points between the line and the circle. May be 0, 1, or 2 points.
    static func intersectionPoints(line: (point1: some Vector2Representable, point2: some Vector2Representable), circle: (center: some Vector2Representable, radius: CGFloat)) -> [CGPoint] {
        let deltaLine = line.point2.vector - line.point1.vector
        let centerToP1 = line.point1.vector - circle.center.vector
        
        let a = pow(deltaLine.dx,2) + pow(deltaLine.dy,2)
        let b = 2 * (deltaLine.dx * centerToP1.dx + deltaLine.dy * centerToP1.dy)
        let c = pow(centerToP1.dx, 2) + pow(centerToP1.dy, 2) - pow(circle.radius, 2)
        
        let det = b * b - 4 * a * c
        var detRoot = [CGFloat]()
        if a <= 0.000001 || det < 0 {
            // No real solutions
            return []
        } else if det == 0 {
            // One solution
            detRoot += [0]
        } else {
            let root = sqrt(det)
            // Two solutions
            detRoot += [root, -root]
        }
        return detRoot
            .map { (-b + $0) / (2.0 * a) }
            .map { (line.point1.vector + ($0 * deltaLine)).point }
    }
}
