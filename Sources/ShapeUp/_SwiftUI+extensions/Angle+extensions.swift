//
//  Angle-extension.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-20.
//

import SwiftUI

public extension Angle {
    init<T: Vector2Representable, U: Vector2Representable, V: Vector2Representable>(_ a: T, _ b: U, _ c: V) {
        self = Angle.threePoint(a, b, c)
    }
    
    init<T: Vector2Representable, U: Vector2Representable>(_ a: T, _ b: U) {
        self = Angle.twoPoint(a, b)
    }
    
    /// Three Point Angle
    /// - Parameters:
    ///   - a: Start Point
    ///   - b: Corner Point
    ///   - c: End Point
    /// - Returns: Angle between 3 points (always positive values)
    static func threePoint<T: Vector2Representable, U: Vector2Representable, V: Vector2Representable>(_ a: T, _ b: U, _ c: V) -> Angle {
        let theta1 = atan2(Double(a.vector.dy - b.vector.dy), Double(a.vector.dx - b.vector.dx))
        let theta2 = atan2(Double(c.vector.dy - b.vector.dy), Double(c.vector.dx - b.vector.dx))
        let positiveTheta1 = theta1 >= 0 ? theta1 : .pi * 2 + theta1
        let positiveTheta2 = theta2 >= 0 ? theta2 : .pi * 2 + theta2
        let result = positiveTheta1 - positiveTheta2
        return Angle.radians(result >= 0 ? result : .pi * 2 + result)
    }
    
    static func twoPoint<T: Vector2Representable, U: Vector2Representable>(_ a: T, _ b: U) -> Angle {
        let theta1 = atan2(Double(b.vector.dy - a.vector.dy), Double(b.vector.dx - a.vector.dx))
        let positiveTheta1 = theta1 >= 0 ? theta1 : .pi * 2 + theta1
        return Angle.radians(positiveTheta1)
    }
    
    var interior: Angle {
        let reduced = abs(self.radians.remainder(dividingBy: .pi * 2))
        return Angle.radians(reduced > .pi ? (2 * .pi) - reduced : reduced)
    }
    
    var halved: Angle {
        Angle.radians(self.radians / 2)
    }
}
