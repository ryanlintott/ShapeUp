//
//  CornerCutRectangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

public struct CornerCutRectangle: InsettableCornerShape {
    public var insetAmount: CGFloat = 0
    
    let topLeft: CornerStyle?
    let topRight: CornerStyle?
    let bottomLeft: CornerStyle?
    let bottomRight: CornerStyle?
    
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

    public func path(in rect: CGRect) -> Path {
        let path = rect
            .corners([
                topLeft,
                topRight,
                bottomRight,
                bottomLeft
            ])
            .inset(by: insetAmount)
            .path()
        
        return path
    }
}
