//
//  CSNotchedRectangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

public struct CSNotchedRectangle: CornerShape {
    public var insetAmount: CGFloat = 0
    
    public var top: Notch?
    public var bottom: Notch?
    public var left: Notch?
    public var right: Notch?
    public var cornerStyles: [CornerStyle?]
    
    public init(top: Notch? = nil, bottom: Notch? = nil, left: Notch? = nil, right: Notch? = nil, cornerStyles: [CornerStyle?] = []) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
        self.cornerStyles = cornerStyles
    }
    
    public init(_ notch: Notch, edges: Set<RectEdge>, cornerStyles: [CornerStyle?] = []) {
        self.top = edges.contains(.top) ? notch : nil
        self.bottom = edges.contains(.bottom) ? notch : nil
        self.left = edges.contains(.left) ? notch : nil
        self.right = edges.contains(.right) ? notch : nil
        self.cornerStyles = cornerStyles
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        rect
            .corners(cornerStyles)
            .addingNotches([top, right, bottom, left])
    }
}

