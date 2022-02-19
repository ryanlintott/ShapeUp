//
//  RectAnchor+extensions+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-03.
//

import SwiftUI

public extension Array where Element == RectAnchor {
    /// Creates an array of points corresponding to the locations of the anchors.
    /// - Parameter rect: Rectangle where anchors are positioned.
    /// - Returns: An array of points where the anchors are located.
    func points(in rect: CGRect) -> [CGPoint] {
        map { $0.point(in: rect) }
    }
}
