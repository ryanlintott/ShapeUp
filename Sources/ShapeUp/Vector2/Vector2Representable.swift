//
//  Vector2Representable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public protocol Vector2Representable {
    var vector: Vector2 { get }
    
    init(vector: Vector2)
}

public extension Vector2Representable {
    var point: CGPoint {
        CGPoint(x: vector.dx, y: vector.dy)
    }
}
