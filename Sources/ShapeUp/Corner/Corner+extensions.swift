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
    
    public func repositioned<T: Vector2Representable>(to point: T) -> Corner {
        Corner(style, point: point)
    }
}

public extension Corner {
    var radius: RelatableValue {
        style.radius
    }
    
    func applyingStyle(_ style: CornerStyle) -> Corner {
        Corner(style, point: self.point)
    }
    
    func inset(_ insetAmount: CGFloat, previousCorner: Corner, nextCorner: Corner) -> Corner {
        guard insetAmount != 0 else {
            return self
        }
        let corner = self
        
        let angle = Angle.threePoint(previousCorner, corner, nextCorner)
        let halvedAngle = angle.interior.halved
        
        let concaveConvexMultiplier: CGFloat = angle.radians > .pi ? 1 : -1

        let vector1 = (corner.vector - previousCorner.vector)
        let vector2 = (corner.vector - nextCorner.vector)
        
        let maxVectorLength = min(vector1.magnitude, vector2.magnitude)
        let maxRadius = maxVectorLength * CGFloat(tan(halvedAngle.radians))
        let cornerRadius = corner.radius.value(using: maxRadius)
        let removedLength = maxVectorLength * cornerRadius / maxRadius
        
        let cornerCutPoint1 = corner.vector - vector1.normalized * removedLength
        
        let insetLength = insetAmount * maxVectorLength / maxRadius
        let insetRadius = cornerRadius + insetAmount * concaveConvexMultiplier
        
        let insetVector = vector1.normalized * insetLength + vector1.normalized.rotated(.degrees(90)) * insetAmount * concaveConvexMultiplier
        let insetPoint = corner.vector + insetVector * concaveConvexMultiplier
        
        switch corner.style {
        case .point:
            return Corner(corner.style, point: insetPoint)
        case .rounded:
            return Corner(.rounded(radius: .absolute(Swift.max(0, insetRadius))), point: insetPoint)
        case let .concave(_, oldRadiusOffset):
            let radiusPoint = cornerCutPoint1 + vector2.normalized.rotated(.degrees(90)) * cornerRadius
            let insetRadiusPoint = radiusPoint + (insetPoint - radiusPoint).normalized * (oldRadiusOffset ?? 0)
            
            
            let x = CGFloat(sin(halvedAngle.radians)) * (insetPoint - radiusPoint).magnitude
            let insetAngleAdjustment = Angle.radians(Double(asin(x / insetRadius)))
            let insetCornerCutPoint1 = insetRadiusPoint - vector1.normalized.rotated(insetAngleAdjustment) * insetRadius
            
            
            return Corner(.concave(radius: .absolute(insetRadius), radiusOffset: oldRadiusOffset), point: insetCornerCutPoint1)
        case .straight:
            let halvedCornerCutAngle = Angle.degrees((90 + halvedAngle.degrees) *  Double(-concaveConvexMultiplier) / 2)
            let straightCornerCutInsetVector1 = -vector1.normalized.rotated(-halvedCornerCutAngle) * (insetAmount / CGFloat(sin(halvedCornerCutAngle.radians)))
            let straightCornerCutInsetPoint1 = cornerCutPoint1 + straightCornerCutInsetVector1
            let straightInsetRadius = (straightCornerCutInsetPoint1 - insetPoint).magnitude * cornerRadius / removedLength
            
            return Corner(.straight(radius: .absolute(Swift.max(0, straightInsetRadius))), point: insetPoint)
        case .cutout:
            let cutoutCornerCutInsetPoint1 = cornerCutPoint1 + vector1.normalized * insetAmount * concaveConvexMultiplier + vector1.normalized.rotated(.degrees(90)) * insetAmount
            let cutoutInsetRadius = (cutoutCornerCutInsetPoint1 - insetPoint).magnitude * cornerRadius / removedLength
            
            return Corner(.cutout(radius: .absolute(Swift.max(0, cutoutInsetRadius))), point: insetPoint)
        }
    }
    
    func absolute(previousCorner: Corner, nextCorner: Corner) -> Corner {
        let corner = self
        
        let angle = Angle.threePoint(previousCorner, corner, nextCorner)
        let halvedAngle = angle.interior.halved
        
        let vector1 = (corner.vector - previousCorner.vector)
        let vector2 = (corner.vector - nextCorner.vector)
        
        let maxVectorLength = min(vector1.magnitude, vector2.magnitude)
        let maxRadius = maxVectorLength * CGFloat(tan(halvedAngle.radians))
        let cornerRadius = RelatableValue.absolute(corner.radius.value(using: maxRadius))

        switch corner.style {
        case .point:
            return corner
        case .rounded:
            return corner.applyingStyle(.rounded(radius: cornerRadius))
        case let .concave(_, radiusOffset):
            return corner.applyingStyle(.concave(radius: cornerRadius, radiusOffset: radiusOffset))
        case let .straight(_, cornerStyles):
            return corner.applyingStyle(.straight(radius: cornerRadius, cornerStyles: cornerStyles))
        case let .cutout(_, cornerStyles):
            return corner.applyingStyle(.straight(radius: cornerRadius, cornerStyles: cornerStyles))
        }
    }
    
    func flattened(previousCorner: Corner, nextCorner: Corner) -> [Corner] {
        guard self.style.isFlattenable else {
            return [self]
        }
        
        let corner = self
        
        let angle = Angle.threePoint(previousCorner, corner, nextCorner)
        let halvedAngle = angle.interior.halved
        
        let vector1 = (corner.vector - previousCorner.vector)
        let vector2 = (corner.vector - nextCorner.vector)
        
        let maxVectorLength = min(vector1.magnitude, vector2.magnitude)
        let maxRadius = maxVectorLength * CGFloat(tan(halvedAngle.radians))
        let cornerRadius = corner.radius.value(using: maxRadius)
        let removedLength = maxVectorLength * cornerRadius / maxRadius
    
        let cornerCutPoint1 = corner.vector - vector1.normalized * removedLength
        let cornerCutPoint2 = corner.vector - vector2.normalized * removedLength
        let cornerStyles = corner.style.cornerStyles

        switch corner.style {
        case .point:
            return [corner]
        case .rounded:
            return [corner.applyingStyle(.rounded(radius: .absolute(cornerRadius)))]
        case let .concave(_, radiusOffset):
            return [corner.applyingStyle(.concave(radius: .absolute(cornerRadius), radiusOffset: radiusOffset))]
        case .straight:
            return [
                cornerCutPoint1.point,
                cornerCutPoint2.point
            ]
            .corners(cornerStyles)
            .applyingStyle(.point)
        case .cutout:
            return [
                cornerCutPoint1.point,
                (cornerCutPoint1 + vector1.normalized.rotated(.degrees(90)) * cornerRadius).point,
                cornerCutPoint2.point
            ]
            .corners(cornerStyles)
        }
    }
}
