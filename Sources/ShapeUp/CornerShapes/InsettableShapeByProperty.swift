//
//  InsettableShapeByProperty.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-16.
//

import SwiftUI

public protocol InsettableShapeByProperty: InsettableShape {
    var insetAmount: CGFloat { get set }
}

public extension InsettableShapeByProperty {
    func inset(by amount: CGFloat) -> Self {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
