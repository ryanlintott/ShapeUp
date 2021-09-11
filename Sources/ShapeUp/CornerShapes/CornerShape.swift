//
//  CornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

public protocol CornerShape: InsettableShape {
    var insetAmount: CGFloat { get set }
    
    func corners(in rect: CGRect) -> [Corner]
}

public extension CornerShape {
    func insetCorners(in rect: CGRect) -> [Corner] {
        corners(in: rect)
            .inset(by: insetAmount)
    }
    
    var cornerShape: CSCustom {
        CSCustom { rect in
            insetCorners(in: rect)
                .inset(by: insetAmount)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        insetCorners(in: rect)
            .path()
    }
    
    func inset(by amount: CGFloat) -> Self {
        var cornerShape = self
        cornerShape.insetAmount = amount
        return cornerShape
    }
}
