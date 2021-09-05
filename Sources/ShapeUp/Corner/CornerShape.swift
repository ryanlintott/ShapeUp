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
    
    public func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.insetAmount += amount
        return shape
    }

    public func corners(in rect: CGRect) -> [Corner] {
        corners(rect)
            .inset(by: insetAmount)
    }
    
    public func path(in rect: CGRect) -> Path {
        corners(in: rect)
            .path()
    }
}

public extension CornerShape {
    init(_ shape: ShapeLibrary) {
        corners = shape.corners(in:)
    }
}
