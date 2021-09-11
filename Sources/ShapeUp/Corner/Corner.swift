//
//  Corner.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

public struct Corner {
    public var x: CGFloat
    public var y: CGFloat
    public var style: CornerStyle
    
    public init(_ style: CornerStyle? = nil, x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
        self.style = style ?? .point
    }
    
    public init<T: Vector2Representable>(_ style: CornerStyle? = nil, point: T) {
        x = point.vector.dx
        y = point.vector.dy
        self.style = style ?? .point
    }
}
