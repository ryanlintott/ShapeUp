//
//  Corner+Dimensions+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Array where Element == Corner.Dimensions {
    /// The corners represented by these dimensions.
    var corners: [Corner] {
        map { $0.corner }
    }
    
    /// Creates corners inset by the specified amount.
    /// - Parameter inset: The amount to inset each corner.
    /// - Returns: The inset corners.
    func corners(inset: CGFloat) -> [Corner] {
        inset == 0 ? corners : map { $0.corner(inset: inset) }
    }
    
    /// Adds an open corner shape defined by this array of corners to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currently is to the first corner.
    func addOpenCornerShape(to path: inout Path, moveToStart: Bool) {
        self.enumerated().forEach { i, dims in
            // If it's the first corner and moveToStart is active, the first point will be a move.
            dims.addCornerShape(to: &path, moveToStart: i == 0 && moveToStart)
        }
    }
    
    /// Adds a closed corner shape defined by this array of corner dimensions to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - closed: Boolean determining if the path is closed. Default is true.
    func addCornerShape(to path: inout Path, closed: Bool = true) {
        addOpenCornerShape(to: &path, moveToStart: true)
        if closed {
            path.closeSubpath()
        }
    }
}
