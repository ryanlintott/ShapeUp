//
//  CornerShape.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

struct CornerShape: InsettableShape {
    typealias InsetShape = Self
    var insetAmount: CGFloat = 0
    
    let corners: (CGRect) -> [Corner]
    
    init(_ corners: @escaping (CGRect) -> [Corner]) {
        self.corners = corners
    }
    
    func path(in rect: CGRect) -> Path {
        let path = corners(rect)
            .inset(by: insetAmount)
            .path()
        
        return path
    }
    
    func inset(by amount: CGFloat) -> InsetShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}
