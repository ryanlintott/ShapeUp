//
//  Corner.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

public struct Corner {
    let style: CornerStyle
    let point: CGPoint
    
    var radius: RelatableValue {
        style.radius
    }
    
    var x: CGFloat { point.x }
    var y: CGFloat { point.y }
    
    public init<T: Vector2Representable>(_ style: CornerStyle? = nil, point: T) {
        self.point = point.vector.point
        self.style = style ?? .point
    }

    public init(_ style: CornerStyle? = nil, x: CGFloat, y: CGFloat) {
        self.init(style, point: CGPoint(x: x, y: y))
    }
    
    public func applyingStyle(_ style: CornerStyle) -> Corner {
        Corner(style, point: self.point)
    }
}

extension Corner: Vector2Representable {
    public var vector: Vector2 {
        Vector2(point: point)
    }
}




