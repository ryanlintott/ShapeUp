//
//  Vector2Transformable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public protocol Vector2Transformable: Vector2Representable {
    func repositioned<T: Vector2Representable>(to point: T) -> Self
}

public extension Vector2Transformable {
    func moved<T: Vector2Representable>(_ distance: T) -> Self {
        let vector = self.vector + distance.vector
        return repositioned(to: vector)
    }
    
    func rotated<T: Vector2Representable>(_ angle: Angle, anchor: T) -> Self {
        let p = self.vector - anchor.vector
        let s = CGFloat(sin(angle.radians))
        let c = CGFloat(cos(angle.radians))
        let pRotated = Vector2(dx: p.dx * c - p.dy * s, dy: p.dx * s + p.dy * c)
        return repositioned(to: pRotated + anchor.vector)
    }
    
    func rotated(_ angle: Angle) -> Self {
        rotated(angle, anchor: CGPoint.zero)
    }
    
    func mirrored<T: Vector2Representable, U: Vector2Representable>(mirrorLineStart: T, mirrorLineEnd: U) -> Self {
        let vector = self.vector
        let vectorToPoint = vector - mirrorLineStart.vector
        let angle = Angle.radians(Angle(self, mirrorLineStart, mirrorLineEnd).radians * 2)
        return repositioned(to: vector - vectorToPoint + vectorToPoint.rotated(-angle))
    }
}
