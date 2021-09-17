//
//  CornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

public protocol CornerShape: InsettableShapeByProperty {
    func corners(in rect: CGRect) -> [Corner]
}

public extension CornerShape {
    func insetCorners(in rect: CGRect) -> [Corner] {
        corners(in: rect)
            .inset(by: insetAmount)
    }
    
    func path(in rect: CGRect) -> Path {
        insetCorners(in: rect)
            .path()
    }
}
