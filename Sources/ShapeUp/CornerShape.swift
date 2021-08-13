//
//  CornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

public struct CornerShape: InsettableShape {
    public typealias InsetShape = Self
    var insetAmount: CGFloat = 0
    
    let corners: (CGRect) -> [Corner]
    
    public init(_ corners: @escaping (CGRect) -> [Corner]) {
        self.corners = corners
    }
    
    public func path(in rect: CGRect) -> Path {
        let path = corners(rect)
            .inset(by: insetAmount)
            .path()
        
        return path
    }
    
    public func inset(by amount: CGFloat) -> InsetShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
