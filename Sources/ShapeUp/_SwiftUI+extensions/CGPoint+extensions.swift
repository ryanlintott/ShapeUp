//
//  CGPoint+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-09-22.
//

import SwiftUI

extension CGPoint: Vector2Representable {
    public var vector: Vector2 {
        Vector2(dx: x, dy: y)
    }
}

public extension CGPoint {
    func corner(_ style: CornerStyle? = nil) -> Corner {
        Corner(style ?? .point, point: self)
    }
}


