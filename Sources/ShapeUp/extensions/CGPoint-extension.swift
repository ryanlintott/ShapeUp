//
//  CGPoint-extension.swift
//  FullscreenZoom
//
//  Created by Ryan Lintott on 2020-09-22.
//

import SwiftUI

extension CGPoint {
    // Vector negation
    static prefix func - (cgPoint: CGPoint) -> CGPoint {
        return CGPoint(x: -cgPoint.x, y: -cgPoint.y)
    }
    
    // Vector addition
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    // Vector subtraction
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return lhs + -rhs
    }
    
    // Vector addition assignment
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs + rhs
    }
    
    // Vector subtraction assignment
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs = lhs - rhs
    }
}

extension CGPoint {
    // Scalar-vector multiplication
    static func * (lhs: CGFloat, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        return rhs * lhs
    }
    
    // Vector-scalar division
    static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        guard rhs != 0 else { fatalError("Division by zero") }
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    // Vector-scalar division assignment
    static func /= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    
    // Scalar-vector multiplication assignment
    static func *= (lhs: inout CGPoint, rhs: CGFloat) {
        lhs = lhs * rhs
    }
}

extension CGPoint {
    // Vector magnitude (length)
    var magnitude: CGFloat {
        return sqrt(x * x + y * y)
    }
    
    // Vector normalization
    var normalized: CGPoint {
        return CGPoint(x: x / magnitude, y: y / magnitude)
    }
    
    func moved(_ vector: CGPoint) -> CGPoint {
        self + vector
    }
    
    func rotated(_ angle: Angle, anchor: CGPoint = .zero) -> CGPoint {
        let p = self - anchor
        let s = CGFloat(sin(angle.radians))
        let c = CGFloat(cos(angle.radians))
        let pRotated = CGPoint(x: p.x * c - p.y * s, y: p.x * s + p.y * c)
        return pRotated + anchor
    }
    
    func mirrored(mirrorLineStart: CGPoint, mirrorLineEnd: CGPoint) -> CGPoint {
        let vectorToPoint = self - mirrorLineStart
        let angle = Angle.radians(Angle(self, mirrorLineStart, mirrorLineEnd).radians * 2)
        return self - vectorToPoint + vectorToPoint.rotated(-angle)
    }
    
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        lhs.magnitude < rhs.magnitude
    }
}

extension CGPoint {
    var aspectRatio: CGFloat {
        x / y
    }
    
    init(cgSize: CGSize) {
        self = CGPoint(x: cgSize.width, y: cgSize.height)
    }
}

extension CGPoint {
    func corner(_ style: CornerStyle? = nil) -> Corner {
        Corner(style ?? .point, point: self)
    }
}
    
extension Array where Element == CGPoint {
    var angles: [Angle] {
        guard self.count >= 3 else {
            return []
        }

//        var angles = [Angle]()
//
//        for (i, point) in self.enumerated() {
//            let previousPoint = i == 0 ? self.last! : self[i - 1]
//            let nextPoint = i == self.count - 1 ? self.first! : self[i + 1]
//            angles.append(.init(previousPoint, point, nextPoint))
//        }

//        return angles
        return self
            .enumerated()
            .map {
                let previousPoint = $0.offset == 0 ? self.last! : self[$0.offset - 1]
                let nextPoint = $0.offset == self.count - 1 ? self.first! : self[$0.offset + 1]
                return Angle(previousPoint, $0.element, nextPoint)
            }
    }
    
    func rotated(_ angle: Angle, anchor: CGPoint = .zero) -> [CGPoint] {
        self.map({ $0.rotated(angle, anchor: anchor) })
    }
    
    func mirrored(mirrorLineStart: CGPoint, mirrorLineEnd: CGPoint) -> [CGPoint] {
        self.map({ $0.mirrored(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) })
    }
    
    var bounds: CGRect {
        let xArray = self.map { $0.x }
        let yArray = self.map { $0.y }
        let minX = xArray.min() ?? .zero
        let minY = yArray.min() ?? .zero
        let maxX = xArray.max() ?? .zero
        let maxY = yArray.max() ?? .zero
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    var center: CGPoint {
        let bounds = self.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    func flipHorizontal(around x: CGFloat? = nil) -> [CGPoint] {
        let mirrorX = x ?? center.x
        return mirrored(mirrorLineStart: CGPoint(x: mirrorX, y: 0), mirrorLineEnd: CGPoint(x: mirrorX, y: 1))
    }
    
    func flipVertical(around y: CGFloat? = nil) -> [CGPoint] {
        let mirrorY = y ?? center.y
        return mirrored(mirrorLineStart: CGPoint(x: 0, y: mirrorY), mirrorLineEnd: CGPoint(x: 1, y: mirrorY))
    }
    
    // Works for shapes drawn clockwise without a duplicate point at the end
    func inset(by insetAmount: CGFloat) -> [CGPoint] {
        guard self.count >= 3 else {
            return []
        }
        var insetPoints = [CGPoint]()
        
        for (i, point) in self.enumerated() {
            let previousPoint = i == 0 ? self.last! : self[i - 1]
            let nextPoint = i == self.count - 1 ? self.first! : self[i + 1]
            let halfAngle = Angle.degrees(Angle.threePoint(previousPoint, point, nextPoint).degrees / 2)
            let tangentOffsetDistance = insetAmount / CGFloat(tan(halfAngle.radians))
            let normalizedSegment = (nextPoint - point).normalized
            let insetVector = normalizedSegment * tangentOffsetDistance + normalizedSegment.rotated(.degrees(90)) * insetAmount
            insetPoints.append(point + insetVector)
        }
        return insetPoints
    }

    func corners(_ style: CornerStyle? = nil) -> [Corner] {
        self.map({ $0.corner(style) })
    }
    
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        let cornerStyles = styles + Array<CornerStyle?>(repeating: nil, count: Swift.max(self.count - styles.count, 0))
        var corners = [Corner]()
        for (i, point) in self.enumerated() {
            corners.append(point.corner(cornerStyles[i]))
        }
        return corners
    }
}


