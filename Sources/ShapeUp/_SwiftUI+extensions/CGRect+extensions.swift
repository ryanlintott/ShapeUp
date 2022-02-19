//
//  CGRect+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

public extension CGRect {
    /// Creates an array of points from the 4 corners of the rectangle starting with the top left and going clockwise.
    var points: [CGPoint] {
        RectAnchor.vertexAnchors.points(in: self)
    }
    
    /// Creates a point in the location of an anchor.
    /// - Parameter anchor: Anchor where the point is located
    /// - Returns: The point where the anchor is located.
    func anchorPoint(_ anchor: RectAnchor) -> CGPoint {
        anchor.point(in: self)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Achors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func anchorPoints(_ anchors: RectAnchor...) -> [CGPoint] {
        anchors.points(in: self)
    }
    
    /// Creates an array of corners from the rectangle.
    /// - Parameter style: Corner style used for all corners.
    /// - Returns: An array of 4 corners, with the provided style, starting with the top left and going clockwise.
    func corners(_ style: CornerStyle = .point) -> [Corner] {
        points.corners(style)
    }
    
    /// Creates an array of corners from the rectangle.
    /// - Parameter styles: Array of corner styles starting with the top left and going clockwise. Nil values will use "point"
    /// - Returns: An array of 4 corners, with the provided styles, starting with the top left and going clockwise.
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        points.corners(styles)
    }
}
