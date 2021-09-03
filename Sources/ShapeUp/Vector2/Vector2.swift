//
//  Vector2.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public struct Vector2 {
    public let dx: CGFloat
    public let dy: CGFloat
    
    public init(dx: CGFloat, dy: CGFloat) {
        self.dx = dx
        self.dy = dy
    }
}

public extension Vector2 {
    // Zero
    static var zero: Self { Self.init(dx: 0, dy: 0) }

    var point: CGPoint { CGPoint(x: dx, y: dy) }
    var size: CGSize { CGSize(width: dx, height: dy) }
    var rect: CGRect { CGRect(x: 0, y: 0, width: dx, height: dy) }
    
    init(point: CGPoint) {
        self = Vector2(dx: point.x, dy: point.y)
    }
}

extension Vector2: Vector2Transformable { }
