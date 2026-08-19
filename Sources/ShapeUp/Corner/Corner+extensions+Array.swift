//
//  Corner+extensions+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension Array where Element == Corner {
    /// An array of corner dimensions used for drawing, insetting, and modifying points of a closed shape.
    internal var dimensions: [Corner.Dimensions] {
        dimensions()
    }
    
    /// Creates an array of corner dimensions used for drawing, insetting, and modifying points of an open shape.
    /// - Parameters:
    ///   - previousPoint: Previous corner point. Default is the last point.
    ///   - nextPoint: Next corner point. Default is the first point.
    /// - Returns: An array of corner dimensions used for drawing, insetting, and modifying points.
    internal func dimensions(previousPoint: CGPoint? = nil, nextPoint: CGPoint? = nil) -> [Corner.Dimensions] {
        guard
            let beforeFirst = previousPoint ?? last?.point,
            let afterLast = nextPoint ?? first?.point
        else {
            return []
        }
        
        return enumerated().map { i, corner in
            let previousPoint = i == 0 ? beforeFirst : self[i - 1].point
            let nextPoint = i == self.count - 1 ? afterLast : self[i + 1].point
            return corner.dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
        }
    }
    
    /// Creates a path defined by this array of corners. Closed by default.
    /// - Parameters:
    ///   - closed: Boolean determining if the path is closed. Default is true.
    /// - Returns: A path defined by this array of corners. Closed by default.
    func path(closed: Bool = true) -> Path {
        var path = Path()
        dimensions.addCornerShape(to: &path, closed: closed)
        return path
    }
    
    /// Adds an open corner shape defined by this array of corners to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currently is to the first corner.
    func addOpenCornerShape(to path: inout Path, moveToStart: Bool) {
        dimensions.addOpenCornerShape(to: &path, moveToStart: moveToStart)
    }
    
    /// Adds a closed corner shape defined by this array of corners to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - closed: Boolean determining if the path is closed. Default is true.
    func addCornerShape(to path: inout Path, closed: Bool = true) {
        dimensions.addCornerShape(to: &path, closed: closed)
    }
    
    /// Returns an array of corners inset from this array but the specified amount.
    ///
    /// A clockwise ordering of corners is expected.
    /// - Parameters:
    ///   - insetAmount: Amount to inset the corners.
    ///   - previousPoint: A point used for determining the angle of the first corner. Default is last point.
    ///   - nextPoint: A point used for determining the angle of the last corner. Default is first point.
    /// - Returns: An array of corners inset from this array but the specified amount.
    func inset(by insetAmount: CGFloat, previousPoint: CGPoint? = nil, nextPoint: CGPoint? = nil) -> [Corner] {
        if self.count < 2 || insetAmount == 0 { return self }
        
        return self
            .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
            .corners(inset: insetAmount)
    }
    
    /// Creates a copy of the corner array with additional corners based on the specified notches.
    ///
    /// The first notch will create corners between the first and second corner, the next will create corners between the second and third corners, etc. Nil values will create no additional corners.
    /// - Parameter notches: Notches that define additional corners to add in the gaps between each corner. Nil values will skip a gap and add no corners.
    /// - Returns: A copy of the corner array with additional corners based on the specified notches.
    func addingNotches(_ notches: [Notch?]) -> [Corner] {
        guard self.count >= 2 else {
            return self
        }
        
        // Pad notches with nil values to match point count
        let notches = notches + Array<Notch?>(repeating: nil, count: Swift.max(self.count - notches.count, 0))
        var newCorners = [Corner]()
        for (i, corner) in self.enumerated() {
            let nextCorner = i == self.count - 1 ? self.first! : self[i + 1]
            newCorners.append(corner)
            if let notch = notches[i] {
                newCorners += notch.between(start: corner, end: nextCorner)
            }
        }
        return newCorners
    }
    
    /// Creates a copy of the corner array with additional corners based on the specified notch after the specified index.
    /// - Parameters:
    ///   - notch: Notch that define additional corners to add after the specified index.
    ///   - cornerIndex: Index after which the corners will be added. Default is 0
    func addingNotch(_ notch: Notch, afterCornerIndex cornerIndex: Int = 0) -> [Corner] {
        self.addingNotches(Array<Notch?>(repeating: nil, count: cornerIndex) + [notch])
    }
    
    /// Creates a copy of the corner array appending additional corners based on the specified notch and corner.
    ///
    /// If array is empty, no corners are added.
    /// - Parameters:
    ///   - notch: Notch that define additional corners to add between the last corner and the specified corner.
    ///   - corner: Corner to add at the end of the array.
    /// - Returns: A copy of the corner array with additional corners based on the specified notch and corner.
    func addingSegment(notch: Notch? = nil, to corner: Corner) -> [Corner] {
        guard let lastCorner = self.last else {
            return self
        }
        
        return self + (notch?.between(start: lastCorner, end: corner) ?? []) + [corner]
    }
}
