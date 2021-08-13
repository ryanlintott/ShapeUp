//
//  Corner.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

public enum CornerStyle: Equatable {
    case point
    case rounded(radius: RelatableValue)
    case concave(radius: RelatableValue, radiusOffset: CGFloat? = nil)
    case straight(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    case cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
//    case custom(radius: RelatableValue, corners: (CGRect) -> [Corner])

    var radius: RelatableValue {
        switch self {
        case .point:
            return .zero
        case let .rounded(radius):
            return radius
        case let .concave(radius, _):
            return radius
        case let .straight(radius, _):
            return radius
        case let .cutout(radius, _):
            return radius
        }
    }
    
    var cornerStyles: [CornerStyle] {
        switch self {
        case .point, .rounded, .concave:
            return []
        case let .straight(_, cornerStyles):
            return cornerStyles
        case let .cutout(_, cornerStyles):
            return cornerStyles
        }
    }
    
    var isFlattenable: Bool {
        switch self {
        case .point:
            return false
        case .rounded, .concave:
            switch radius {
            case .absolute:
                return false
            case .relative:
                return true
            }
        case .straight, .cutout:
            if cornerStyles == [] || cornerStyles.allSatisfy({ $0 == .point }) {
                return false
            } else {
                return true
            }
        }
    }
}

struct Corner {
    let style: CornerStyle
    let point: CGPoint
    
    var radius: RelatableValue {
        style.radius
    }
    
    var x: CGFloat { point.x }
    var y: CGFloat { point.y }
    
    init(_ style: CornerStyle? = nil, point: CGPoint) {
        self.point = point
        self.style = style ?? .point
    }

    init(_ style: CornerStyle? = nil, x: CGFloat, y: CGFloat) {
        self.init(style, point: CGPoint(x: x, y: y))
    }
    
    func applyingStyle(_ style: CornerStyle) -> Corner {
        Corner(style, point: self.point)
    }
}

extension Corner {
    func moved(_ vector: CGPoint) -> Corner {
        Corner(self.style, point: self.point.moved(vector))
    }
    
    func rotated(_ angle: Angle, anchor: CGPoint = .zero) -> Corner {
        Corner(self.style, point: self.point.rotated(angle, anchor: anchor))
    }
    
    func mirrored(mirrorLineStart: CGPoint, mirrorLineEnd: CGPoint) -> Corner {
        Corner(self.style, point: self.point.mirrored(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd))
    }
    
    func inset(_ insetAmount: CGFloat, previousCorner: Corner, nextCorner: Corner) -> Corner {
        guard insetAmount != 0 else {
            return self
        }
        let corner = self
        
        let angle = Angle.threePoint(previousCorner.point, corner.point, nextCorner.point)
        let halvedAngle = angle.interior.halved
        
        let concaveConvexMultiplier: CGFloat = angle.radians > .pi ? 1 : -1

        let vector1 = (corner.point - previousCorner.point)
        let vector2 = (corner.point - nextCorner.point)
        
        let maxVectorLength = min(vector1.magnitude, vector2.magnitude)
        let maxRadius = maxVectorLength * CGFloat(tan(halvedAngle.radians))
        let cornerRadius = corner.radius.value(using: maxRadius)
        let removedLength = maxVectorLength * cornerRadius / maxRadius
        
        let cornerCutPoint1 = corner.point - vector1.normalized * removedLength
        
        let insetLength = insetAmount * maxVectorLength / maxRadius
        let insetRadius = cornerRadius + insetAmount * concaveConvexMultiplier
        
        let insetVector = vector1.normalized * insetLength + vector1.normalized.rotated(.degrees(90)) * insetAmount * concaveConvexMultiplier
        let insetPoint = corner.point + insetVector * concaveConvexMultiplier
        
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
        
        let angle = Angle.threePoint(previousCorner.point, corner.point, nextCorner.point)
        let halvedAngle = angle.interior.halved
        
        let vector1 = (corner.point - previousCorner.point)
        let vector2 = (corner.point - nextCorner.point)
        
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
        
        let angle = Angle.threePoint(previousCorner.point, corner.point, nextCorner.point)
        let halvedAngle = angle.interior.halved
        
        let vector1 = (corner.point - previousCorner.point)
        let vector2 = (corner.point - nextCorner.point)
        
        let maxVectorLength = min(vector1.magnitude, vector2.magnitude)
        let maxRadius = maxVectorLength * CGFloat(tan(halvedAngle.radians))
        let cornerRadius = corner.radius.value(using: maxRadius)
        let removedLength = maxVectorLength * cornerRadius / maxRadius
    
        let cornerCutPoint1 = corner.point - vector1.normalized * removedLength
        let cornerCutPoint2 = corner.point - vector2.normalized * removedLength
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
                cornerCutPoint1,
                cornerCutPoint2
            ]
            .corners(cornerStyles)
            .applyingStyle(.point)
        case .cutout:
            return [
                cornerCutPoint1,
                cornerCutPoint1 + vector1.normalized.rotated(.degrees(90)) * cornerRadius,
                cornerCutPoint2
            ]
            .corners(cornerStyles)
        }
    }
    
    
}

extension Array where Element == Corner {
    var points: [CGPoint] {
        self.map({ $0.point })
    }
    
    var cornerStyles: [CornerStyle] {
        self.map({ $0.style })
    }
    
    var isFlattenable: Bool {
        self.contains(where: { $0.style.isFlattenable })
    }
    
    var flattened: [Corner] {
        var corners: [Corner]
        var newCorners = self
        while newCorners.isFlattenable {
            corners = newCorners
            newCorners = []
            for (i, corner) in corners.enumerated() {
                let previousCorner = i == 0 ? corners.last! : corners[i - 1]
                let nextCorner = i == corners.count - 1 ? corners.first! : corners[i + 1]
                newCorners += corner.flattened(previousCorner: previousCorner, nextCorner: nextCorner)
            }
        }
        
        return newCorners
    }
    
    func rotated(_ angle: Angle, anchor: CGPoint = .zero) -> [Corner] {
        self.map({ $0.rotated(angle, anchor: anchor) })
    }
    
    func mirrored(mirrorLineStart: CGPoint, mirrorLineEnd: CGPoint) -> [Corner] {
        self.map({ $0.mirrored(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) })
    }
    
    var bounds: CGRect {
        points.bounds
    }
    
    var center: CGPoint {
        points.center
    }
    
    func flipHorizontal(around x: CGFloat? = nil) -> [Corner] {
        let mirrorX = x ?? center.x
        return mirrored(mirrorLineStart: CGPoint(x: mirrorX, y: 0), mirrorLineEnd: CGPoint(x: mirrorX, y: 1))
    }
    
    func flipVertical(around y: CGFloat? = nil) -> [Corner] {
        let mirrorY = y ?? center.y
        return mirrored(mirrorLineStart: CGPoint(x: 0, y: mirrorY), mirrorLineEnd: CGPoint(x: 1, y: mirrorY))
    }
    // Works for shapes drawn clockwise without a duplicate point at the end
    func inset(by insetAmount: CGFloat) -> [Corner] {
        guard self.count >= 3 || insetAmount != 0 else {
            return self
        }
        
        let corners = self.flattened
        var insetCorners = [Corner]()
        for (i, corner) in corners.enumerated() {
            let previousCorner = i == 0 ? corners.last! : corners[i - 1]
            let nextCorner = i == corners.count - 1 ? corners.first! : corners[i + 1]
            insetCorners.append(corner.inset(insetAmount, previousCorner: previousCorner, nextCorner: nextCorner))
        }
        
        return insetCorners
    }
    
    
    func path() -> Path {
        var path = Path()
        path.addCornerShape(self)
        return path
    }
    
    mutating func applyStyles(_ styles: [CornerStyle?]) {
        self = self.applyingStyles(styles)
    }
    // nil values will keep old style
    func applyingStyles(_ styles: [CornerStyle?]) -> [Corner] {
        guard !styles.isEmpty else {
            return self
        }
        
        let styles = styles + Array<CornerStyle?>(repeating: nil, count: Swift.max(0, self.count - styles.count))
        
        var newCorners = [Corner]()
        for (i, corner) in self.enumerated() {
            newCorners.append(corner.applyingStyle(styles[i] ?? corner.style))
        }
        return newCorners
    }
    
    mutating func applyStyle(_ style: CornerStyle) {
        self = self.applyingStyle(style)
    }
    
    func applyingStyle(_ style: CornerStyle) -> [Corner] {
        self.map({$0.applyingStyle(style)})
    }
    
    mutating func addNotches(_ notches: [Notch?]) {
        self = self.addingNotches(notches)
    }
    
    func addingNotches(_ notches: [Notch?]) -> [Corner] {
        guard self.count >= 2 else {
            return self
        }
        
        // Pad notches with nil values to match point count
        let notches = notches + Array<Notch?>(repeating: nil, count: Swift.max(self.count - notches.count, 0))
        var newCorners = [Corner]()
        for (i, corner) in self.enumerated() {
            let nextCorner = i == self.count - 1 ? self.first! : self[i + 1]
            newCorners.append(corner)
            if let notch = notches[i] {
                newCorners += notch.between(start: corner, end: nextCorner)
            }
        }
        return newCorners
    }
    
    mutating func addNotch(_ notch: Notch, afterCornerIndex cornerIndex: Int) {
        self = self.addingNotch(notch, afterCornerIndex: cornerIndex)
    }
    
    func addingNotch(_ notch: Notch, afterCornerIndex cornerIndex: Int) -> [Corner] {
        self.addingNotches(Array<Notch?>(repeating: nil, count: cornerIndex) + [notch])
    }
    
    func addingSegment(notch: Notch? = nil, to corner: Corner) -> [Corner] {
        guard let lastCorner = self.last else {
            return self
        }
        
        return self + (notch?.between(start: lastCorner, end: corner) ?? []) + [corner]
    }
}
