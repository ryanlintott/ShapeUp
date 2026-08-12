//
//  RectAnchor+extensions+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-03.
//

import SwiftUI

public extension Array where Element == RectAnchor {
    /// Creates an array of points corresponding to the locations of the anchors within a coordinate frame.
    /// - Parameter frame: Coordinate frame where anchors are positioned.
    /// - Returns: An array of points where the anchors are located.
    func points(in frame: some CGFrameRepresentable) -> [CGPoint] {
        map { $0.point(in: frame) }
    }
    
    /// The four vertex anchors clockwise starting from the top left.
    static let vertices: Self = RectAnchor.vertices
    
    /// An array of relative corners matching the anchors with a default corner style.
    var relativeCorners: [RelativeCorner] {
        map { $0.relativeCorner }
    }
}
