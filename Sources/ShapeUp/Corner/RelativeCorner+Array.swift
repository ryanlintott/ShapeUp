//
//  RelativeCorner+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-08.
//

import Foundation

public extension Collection<RelativeCorner> {
    /// Converts the relative corners to corners positioned in a coordinate frame.
    /// - Parameter frame: The coordinate frame used to position the relative corners.
    /// - Returns: Corners positioned in the specified coordinate frame.
    func corners(in frame: some CGFrameRepresentable) -> [Corner] {
        map { $0.corner(in: frame) }
    }
}
