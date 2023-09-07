//
//  CGRect+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

extension CGRect {
    /// A unit rectangle with origin at zero and size of 1
    static let one = CGRect(x: 0, y: 0, width: 1, height: 1)
}

public extension CGRect {
    /// Creates an array of points from the 4 corners of the rectangle starting with the top left and going clockwise.
    var points: [CGPoint] {
        RectAnchor.vertexAnchors.points(in: self)
    }
    
    /// Creates a point in the location of an anchor.
    /// - Parameter anchor: Anchor where the point is located
    /// - Returns: A point where the anchor is located.
    func point(_ anchor: RectAnchor) -> CGPoint {
        anchor.point(in: self)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func points(_ anchors: [RectAnchor]) -> [CGPoint] {
        anchors.points(in: self)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    func points(_ anchors: RectAnchor...) -> [CGPoint] {
        points(anchors)
    }
    
    /// Returns a point at the relative location inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocation: A tuple with relative x and y coordinates respectively.
    /// - Returns: A point at the relative location inside this CGRect.
    func point(relativeLocation: (CGFloat, CGFloat)) -> CGPoint {
        CGPoint(x: minX + (relativeLocation.0 * width), y: minY + (relativeLocation.1 * height))
    }
    
    /// Returns an array of points at the relative locations inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: A an array of points at the relative locations inside this CGRect.
    func points(relativeLocations: [(CGFloat, CGFloat)]) -> [CGPoint] {
        relativeLocations.map { point(relativeLocation: $0) }
    }
    
    /// Returns an array of points at the relative locations inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: A an array of points at the relative locations inside this CGRect.
    func points(relativeLocations: (CGFloat, CGFloat)...) -> [CGPoint] {
        points(relativeLocations: relativeLocations)
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
