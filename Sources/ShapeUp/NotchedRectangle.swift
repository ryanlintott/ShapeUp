//
//  NotchedRectangle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

public struct NotchedRectangle: InsettableShape {
    public typealias InsetShape = Self
    var insetAmount: CGFloat = 0
    
    let top: Notch?
    let bottom: Notch?
    let left: Notch?
    let right: Notch?
    let cornerStyles: [CornerStyle?]
    
    public init(top: Notch? = nil, bottom: Notch? = nil, left: Notch? = nil, right: Notch? = nil, cornerStyles: [CornerStyle?] = []) {
        self.top = top
        self.bottom = bottom
        self.left = left
        self.right = right
        self.cornerStyles = cornerStyles
    }
    
    #if canImport(UIKit)
    public init(_ notch: Notch, edges: [UIRectEdge], cornerStyles: [CornerStyle?] = []) {
        self.top = edges.contains(.top) ? notch : nil
        self.bottom = edges.contains(.bottom) ? notch : nil
        self.left = edges.contains(.left) ? notch : nil
        self.right = edges.contains(.right) ? notch : nil
        self.cornerStyles = cornerStyles
    }
    #endif
}

public extension NotchedRectangle {
    func path(in rect: CGRect) -> Path {
        let path = rect
            .corners(cornerStyles)
            .addingNotches([top, right, bottom, left])
            .inset(by: insetAmount)
            .path()
        
        return path
    }
    
    func inset(by amount: CGFloat) -> InsetShape {
        var insetShape = self
        insetShape.insetAmount += amount
        return insetShape
    }
}

public extension View {
    func notchEdges(top: Notch? = nil, bottom: Notch? = nil, left: Notch? = nil, right: Notch? = nil) -> some View {
        clipShape(NotchedRectangle(top: top, bottom: bottom, left: left, right: right))
    }
    
    #if canImport(UIKit)
    func notchEdges(_ notch: Notch, edges: [UIRectEdge]) -> some View {
        clipShape(NotchedRectangle(notch, edges: edges))
    }
    #endif
}

