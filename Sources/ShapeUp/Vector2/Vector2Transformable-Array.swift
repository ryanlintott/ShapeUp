//
//  Vector2Transformable-Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public extension Array where Element: Vector2Transformable {
    var bounds: CGRect {
        let xArray = self.map { $0.dx }
        let yArray = self.map { $0.dy }
        let minX = xArray.min() ?? .zero
        let minY = yArray.min() ?? .zero
        let maxX = xArray.max() ?? .zero
        let maxY = yArray.max() ?? .zero

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var center: Element {
        let bounds = self.bounds
        return Element(dx: bounds.midX, dy: bounds.midY)
    }

    var angles: [Angle] {
        guard self.count >= 3 else {
            return []
        }

        return self
            .enumerated()
            .map {
                let previousPoint = $0.offset == 0 ? self.last! : self[$0.offset - 1]
                let nextPoint = $0.offset == self.count - 1 ? self.first! : self[$0.offset + 1]
                return Angle(previousPoint, $0.element, nextPoint)
            }
    }

    func rotated<T: Vector2Representable>(_ angle: Angle, anchor: T) -> Self {
        self.map({ $0.rotated(angle, anchor: anchor) })
    }
    #warning("Assumed rotation around zero, not center")
    func rotated(_ angle: Angle) -> [Element] {
        rotated(angle, anchor: Vector2.zero)
    }

    func rotatedAroundCenter(_ angle: Angle) -> Self {
        rotated(angle, anchor: center)
    }

    func mirrored<T: Vector2Representable, U: Vector2Representable>(mirrorLineStart: T, mirrorLineEnd: U) -> [Element] {
        self.map({ $0.mirrored(mirrorLineStart: mirrorLineStart, mirrorLineEnd: mirrorLineEnd) })
    }
    #warning("Assumed flip across center, not zero")
    func flipHorizontal(around x: CGFloat? = nil) -> Self {
        let mirrorX = x ?? center.dx
        return mirrored(mirrorLineStart: Element(dx: mirrorX, dy: .zero), mirrorLineEnd: Element(dx: mirrorX, dy: 1))
    }

    func flipVertical(around y: CGFloat? = nil) -> Self {
        let mirrorY = y ?? center.dy
        return mirrored(mirrorLineStart: Element(dx: 0, dy: mirrorY), mirrorLineEnd: Element(dx: 1, dy: mirrorY))
    }

    // Works for shapes drawn clockwise without a duplicate point at the end
    func inset(by insetAmount: CGFloat) -> Self {
        guard self.count >= 3 else {
            return []
        }
        var insetPoints = Self()

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
}
