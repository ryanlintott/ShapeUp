//
//  Path-extension.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-25.
//

import SwiftUI

public extension Path {
    mutating func addCornerShape(_ corners: [Corner]) {
        var corners = corners.flattened
        corners.append(corners.first!)
//        let lastCorner = corners.last!
//        self.move(to: lastCorner.point)
        
        // adjust first position
        

        for (i, corner) in corners.enumerated() {
//            let previousCorner = i == 0 ? corners.last! : corners[i - 1]
//            let nextCorner = i == corners.count - 1 ? corners.first! : corners[i + 1]
            // on the last or first corner, skip a corner as the ends are duplicates
            let previousCorner = i == 0 ? corners[corners.count - 2] : corners[i - 1]
            let nextCorner = i == corners.count - 1 ? corners[1] : corners[i + 1]
            
            let angle = Angle.threePoint(previousCorner.point, corner.point, nextCorner.point)
            
            if angle.radians == .pi || corner.radius.value(using: 1) == 0 || corner.style == .point {
                if i == 0 {
                    self.move(to: corner.point)
                } else {
                    self.addLine(to: corner.point)
                }
            } else {
                
                let halvedAngle = angle.interior.halved
                let concaveConvexMultiplier: CGFloat = angle.radians > .pi ? 1 : -1
                
                let vector1 = (corner.point - previousCorner.point)
                let vector2 = (corner.point - nextCorner.point)
                
                let maxVectorLength = min(vector1.magnitude, vector2.magnitude)
                let maxRadius = maxVectorLength * CGFloat(tan(halvedAngle.radians))
                let cornerRadius = corner.radius.value(using: maxRadius)
                let removedLength = maxVectorLength * cornerRadius / maxRadius
            
                let cornerCutPoint1 = corner.point - vector1.normalized * removedLength
                let cornerCutPoint2 = corner.point - vector2.normalized * removedLength
                
                // if first corner, just move to position
                if i == 0 {
                    switch corner.style {
                    case .point, .rounded:
                        self.move(to: corner.point)
                    case .concave, .straight, .cutout:
                        self.move(to: cornerCutPoint2)
                    }
                } else {
                    // any other corner, draw to the next one
                    switch corner.style {
                    case .point:
                        self.addLine(to: corner.point)
                    case .rounded:
                        self.addArc(tangent1End: corner.point, tangent2End: nextCorner.point, radius: cornerRadius)
                    case .concave(radius: _, radiusOffset: nil):
                        self.addLine(to: cornerCutPoint1)
                        self.addArc(tangent1End: cornerCutPoint1 - vector2.normalized * removedLength, tangent2End: cornerCutPoint2, radius: cornerRadius)
                        self.addLine(to: cornerCutPoint2)
                    case let .concave(_, radiusOffset):
    //                    let radiusPoint = corner.point + vector1.normalized.rotated(-halvedAngle) * radiusOffset
    //                    let insetAmount = CGFloat(sin(halvedAngle.radians)) * radiusOffset
    //                    let startAngle = Double(asin(insetAmount / cornerRadius))
                        
    //                    let radiusCutPoint1 = radiusPoint + vector1.normalized.rotated(halvedAngle) * cornerRadius
                        self.addLine(to: cornerCutPoint1)
    //                    self.addLine(to: insetCornerCutPoint1)
                        self.addArc(tangent1End: cornerCutPoint1 - vector2.normalized * removedLength, tangent2End: cornerCutPoint2, radius: cornerRadius + (radiusOffset ?? 0))
    //                    self.addLine(to: radiusPoint)
    //                    self.addLine(to: insetCornerCutPoint1)
    //                    self.addArc(center: radiusPoint, radius: cornerRadius, startAngle: Angle.radians(startAngle + halvedAngle.radians), endAngle: Angle(radiusPoint, cornerCutPoint2), clockwise: true)
    //                    self.addLine(to: cornerCutPoint1 - vector2.normalized * removedLength)
    //                    self.addArc(tangent1End: cornerCutPoint1 - vector2.normalized * removedLength, tangent2End: cornerCutPoint2, radius: cornerRadius)
    //                    self.addLine(to: cornerCutPoint1 - vector1.normalized.rotated(.degrees(90)) * cornerRadius * concaveConvexMultiplier)
                        self.addLine(to: cornerCutPoint2)
                    case .straight:
                        self.addLine(to: cornerCutPoint1)
                        self.addLine(to: cornerCutPoint2)
                    case .cutout:
                        self.addLine(to: cornerCutPoint1)
                        self.addLine(to: cornerCutPoint1 - vector1.normalized.rotated(.degrees(90)) * cornerRadius * concaveConvexMultiplier)
                        self.addLine(to: cornerCutPoint2)
                    }
                }
            }
        }
        self.closeSubpath()
    }
}
