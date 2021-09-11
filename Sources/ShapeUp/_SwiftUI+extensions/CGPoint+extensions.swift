//
//  CGPoint+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-09-22.
//

import SwiftUI

extension CGPoint: Vector2Transformable {
    public var vector: Vector2 {
        Vector2(dx: x, dy: y)
    }
    
    public init(vector: Vector2) {
        self = vector.point
    }
    
    public func repositioned<T: Vector2Representable>(to point: T) -> CGPoint {
        point.point
    }
}

public extension CGPoint {
    func corner(_ style: CornerStyle? = nil) -> Corner {
        Corner(style ?? .point, point: self)
    }
}


