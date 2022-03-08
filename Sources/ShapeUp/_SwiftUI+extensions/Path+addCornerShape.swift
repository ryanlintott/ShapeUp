//
//  Path+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-25.
//

import SwiftUI

public extension Path {
    /// Adds the shape described by an array of corners to a path.
    /// - Parameters:
    ///   - corners: Array of corners that define the shape to add.
    ///   - previousPoint: Previous point in the path used to determine the look of the first corner. Default is the last corner point.
    ///   - nextPoint: Next point in the path used to determine the look of the last corner. Default is the first corner point.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currrently is to the first corner.
    mutating func addOpenCornerShape(_ corners: [Corner], previousPoint: CGPoint? = nil, nextPoint: CGPoint? = nil, moveToStart: Bool = true) {
        corners
            .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
            .addOpenCornerShape(to: &self, moveToStart: moveToStart)
    }
    
    /// Adds a closed shape descrived by an array of corners to a path.
    ///
    /// Moves to the start of the shape and then draws to the end
    /// - Parameters:
    ///  - corners: Array of corners that define the shape to add.
    mutating func addClosedCornerShape(_ corners: [Corner]) {
        corners.addCornerShape(to: &self)
    }
}
