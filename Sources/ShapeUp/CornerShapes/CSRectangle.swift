//
//  CSRectangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

public struct CSRectangle: CornerShape {
    public var insetAmount: CGFloat = 0
    
    public let topLeft: CornerStyle?
    public let topRight: CornerStyle?
    public let bottomLeft: CornerStyle?
    public let bottomRight: CornerStyle?
    
    public init(topLeft: CornerStyle? = nil, topRight: CornerStyle? = nil, bottomLeft: CornerStyle? = nil, bottomRight: CornerStyle? = nil) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    #if canImport(UIKit)
    public init(_ style: CornerStyle, corners: [UIRectCorner] = [.allCorners]) {
        let all = corners.contains(.allCorners)
        self.topLeft = all || corners.contains(.topLeft) ? style : nil
        self.topRight = all || corners.contains(.topRight) ? style : nil
        self.bottomLeft = all || corners.contains(.bottomLeft) ? style : nil
        self.bottomRight = all || corners.contains(.bottomRight) ? style : nil
    }
    #endif
    
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
