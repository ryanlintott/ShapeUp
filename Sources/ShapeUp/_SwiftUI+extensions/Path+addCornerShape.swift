//
//  Path+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-25.
//

import SwiftUI

public extension Path {
    mutating func addOpenCornerShape(_ corners: [Corner], previousPoint: CGPoint? = nil, nextPoint: CGPoint? = nil, moveToStart: Bool = true) {
        corners
            .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
            .addOpenCornerShape(to: &self, moveToStart: moveToStart)
    }
    
    mutating func addClosedCornerShape(_ corners: [Corner]) {
        addOpenCornerShape(corners, moveToStart: true)
    }
}
