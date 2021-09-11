//
//  Vector2Transformable+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public extension Array where Element: Vector2Transformable {
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
        let mirrorX = x ?? center.vector.dx
        return mirrored(mirrorLineStart: Vector2(dx: mirrorX, dy: .zero), mirrorLineEnd: Vector2(dx: mirrorX, dy: 1))
    }

    func flipVertical(around y: CGFloat? = nil) -> Self {
        let mirrorY = y ?? center.vector.dy
        return mirrored(mirrorLineStart: Vector2(dx: 0, dy: mirrorY), mirrorLineEnd: Vector2(dx: 1, dy: mirrorY))
    }
}
