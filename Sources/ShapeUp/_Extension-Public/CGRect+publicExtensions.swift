//
//  CGRect+PublicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

public extension CGRect {
    /// Creates an array of points from the 4 corners of the rectangle starting with the top left and going clockwise.
    @available(*, deprecated, renamed: "subscript(_:)", message: "Use subscript `[.vertices]` instead.")
    var points: [CGPoint] {
        self[.vertices]
    }
    
    /// Creates a point in the location of an anchor.
    /// - Parameter anchor: Anchor where the point is located
    /// - Returns: A point where the anchor is located.
    @available(*, deprecated, renamed: "subscript(_:)")
    func point(_ anchor: RectAnchor) -> CGPoint {
        self[anchor]
    }
    
    /// Creates a point in the location of an anchor.
    /// - Parameter anchor: Anchor where the point is located.
    /// - Returns: A point where the anchor is located.
    subscript (_ anchor: RectAnchor) -> CGPoint {
        anchor.point(in: self)
    }
    
    /// Returns a corner with the specified style at the specified anchor position inside this CGRect.
    /// - Parameters:
    ///   - anchor: Anchor where the corner is positioned.
    ///   - style: Style applied to the corner.
    /// - Returns: A corner with the specified style at the specified anchor position inside this CGRect.
    subscript (_ anchor: RectAnchor, _ style: CornerStyle) -> Corner {
        self[anchor].corner(style)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    @available(*, deprecated, renamed: "subscript(_:)")
    func points(_ anchors: [RectAnchor]) -> [CGPoint] {
        self[anchors]
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    subscript (_ anchors: [RectAnchor]) -> [CGPoint] {
        anchors.points(in: self)
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    @available(*, deprecated, renamed: "subscript(_:)")
    func points(_ anchors: RectAnchor...) -> [CGPoint] {
        self[anchors]
    }
    
    /// Creates an array of points in the locations of the supplied anchors.
    /// - Parameter anchors: Anchors defining point locations in order.
    /// - Returns: An array of points in the location and order of the supplied anchors.
    subscript (_ anchors: RectAnchor...) -> [CGPoint] {
        self[anchors]
    }
    
    /// Returns a point at the relative location inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocation: A tuple with relative x and y coordinates respectively.
    /// - Returns: A point at the relative location inside this CGRect.
    @available(*, deprecated, renamed: "subscript(_:_:)")
    func point(relativeLocation: (CGFloat, CGFloat)) -> CGPoint {
        self[relativeLocation.0, relativeLocation.1]
    }
    
    /// Returns a point at the relative location inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameters:
    ///   - x: Relative x position.
    ///   - y: Relative y position.
    /// - Returns: A point at the relative location inside this CGRect.
    subscript (_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        self[.relative(x, y)]
    }
    
    /// Returns an array of points at the relative locations inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: A an array of points at the relative locations inside this CGRect.
    @available(*, deprecated, renamed: "subscript(_:)")
    func points(relativeLocations: [(CGFloat, CGFloat)]) -> [CGPoint] {
        self[relativeLocations]
    }
    
    /// Returns an array of points at the relative locations inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativePoints: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: A an array of points at the relative locations inside this CGRect.
    subscript (_ relativePoints: [(x: CGFloat, y: CGFloat)]) -> [CGPoint] {
        relativePoints.map { self[$0.x, $0.y] }
    }
    
    /// Returns an array of points at the relative locations inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativeLocations: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: A an array of points at the relative locations inside this CGRect.
    @available(*, deprecated, renamed: "subscript(_:)")
    func points(relativeLocations: (CGFloat, CGFloat)...) -> [CGPoint] {
        self[relativeLocations]
    }
    
    /// Returns an array of points at the relative locations inside this CGRect.
    ///
    /// Relative x values are multiplied by the width and positioned that distance from minX.
    /// Relative y values are multiplied by the height and positioned that distance from minY.
    /// - Parameter relativePoints: An array of tuples with relative x and y coordinates respectively.
    /// - Returns: A an array of points at the relative locations inside this CGRect.
    subscript (_ relativePoints: (x: CGFloat, y: CGFloat)...) -> [CGPoint] {
        relativePoints.map { self[$0.x, $0.y] }
    }
    
    /// Creates an array of corners from the rectangle.
    /// - Parameter style: Corner style used for all corners.
    /// - Returns: An array of 4 corners, with the provided style, starting with the top left and going clockwise.
    func corners(_ style: CornerStyle = .point) -> [Corner] {
        self[.vertices].corners(style)
    }
    
    /// Creates an array of corners from the rectangle.
    /// - Parameter styles: Array of corner styles starting with the top left and going clockwise. Nil values will use "point"
    /// - Returns: An array of 4 corners, with the provided styles, starting with the top left and going clockwise.
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        self[.vertices].corners(styles)
    }
}
