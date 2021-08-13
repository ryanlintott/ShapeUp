//
//  InsettableCornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-02-17.
//

import SwiftUI

public protocol InsettableCornerShape: InsettableShape {
    var insetAmount: CGFloat { get set }
    
    func inset(by amount: CGFloat) -> Self
}

public extension InsettableCornerShape {
    func inset(by amount: CGFloat) -> Self {
        var insetShape = self
        insetShape.insetAmount += amount
        return insetShape
    }
}
