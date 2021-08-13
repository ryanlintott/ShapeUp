//
//  Angle-extension.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-20.
//

import SwiftUI

extension Angle {
    init(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) {
        self = Angle.threePoint(a, b, c)
    }
    
    init(_ a: CGPoint, _ b: CGPoint) {
        self = Angle.twoPoint(a, b)
    }
    
    /// Three Point Angle
    /// - Parameters:
    ///   - a: Start Point
    ///   - b: Corner Point
    ///   - c: End Point
    /// - Returns: Angle between 3 points (always positive values)
    static func threePoint(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Angle {
        let theta1 = atan2(Double(a.y - b.y), Double(a.x - b.x))
        let theta2 = atan2(Double(c.y - b.y), Double(c.x - b.x))
        let positiveTheta1 = theta1 >= 0 ? theta1 : .pi * 2 + theta1
        let positiveTheta2 = theta2 >= 0 ? theta2 : .pi * 2 + theta2
        let result = positiveTheta1 - positiveTheta2
        return Angle.radians(result >= 0 ? result : .pi * 2 + result)
    }
    
    static func twoPoint(_ a: CGPoint, _ b: CGPoint) -> Angle {
        let theta1 = atan2(Double(b.y - a.y), Double(b.x - a.x))
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

