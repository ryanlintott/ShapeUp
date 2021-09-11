//
//  CSRectangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

public struct CSRectangle: CornerShape {
    public var insetAmount: CGFloat = 0
    
    public var topLeft: CornerStyle?
    public var topRight: CornerStyle?
    public var bottomLeft: CornerStyle?
    public var bottomRight: CornerStyle?
    
    public init(topLeft: CornerStyle? = nil, topRight: CornerStyle? = nil, bottomLeft: CornerStyle? = nil, bottomRight: CornerStyle? = nil) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    public init(_ style: CornerStyle, corners: [RectCorner] = RectCorner.allCases) {
        self.topLeft = corners.contains(.topLeft) ? style : nil
        self.topRight = corners.contains(.topRight) ? style : nil
        self.bottomLeft = corners.contains(.bottomLeft) ? style : nil
        self.bottomRight = corners.contains(.bottomRight) ? style : nil
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        rect
            .corners([
                topLeft,
                topRight,
                bottomRight,
                bottomLeft
            ])
    }
}
