//
//  Corner+extensions+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension Array where Element == Corner {
    /// Array of corner styles used on each corner respectively.
    var cornerStyles: [CornerStyle] {
        self.map({ $0.style })
    }
    
    /// Applies new styles to this array of corners.
    /// - Parameter styles: An array of styles that will be applied to each corner respecitvely. Nil values will keep current style.
    mutating func applyStyles(_ styles: [CornerStyle?]) {
        self = self.applyingStyles(styles)
    }
    
    /// Creates an array of corners with the same positions and specified styles.
    /// - Parameter styles: An array of styles that will be applied to each corner respecitvely. Nil values will keep current style.
    /// - Returns: An array of corners with the same positions and specified styles.
    func applyingStyles(_ styles: [CornerStyle?]) -> [Corner] {
        if styles.isEmpty { return self }
        // Create an array of styles equal in length to the array of corners.
        let styles = styles + Array<CornerStyle?>(repeating: nil, count: Swift.max(count - styles.count, 0))
        
        return zip(self, styles).map { corner, style in
            // Apply a style if one is provided, otherwise use the current style.
            corner.applyingStyle(style ?? corner.style)
        }
    }
    
    /// Applies a new style to all corners in the array.
    /// - Parameter style: A style that will be applied to every corner.
    mutating func applyStyle(_ style: CornerStyle) {
        self = self.applyingStyle(style)
    }
    
    /// Creates an array of corners with the same positions and a new specified style.
    /// - Parameter style: A style that will be applied to every corner.
    /// - Returns: An array of corners with the same positions and a new specified style.
    func applyingStyle(_ style: CornerStyle) -> [Corner] {
        self.map { $0.applyingStyle(style) }
    }
    
    /// Creates an array of corners with the same positions and a new specified style applied to specified corners.
    /// - Parameters:
    ///   - style: A style that will be applied to specified corners.
    ///   - indices: Indices of the corners with which to apply the new style.
    /// - Returns: An array of corners with the same positions and a new specified style applied to specified corners.
    func applyingStyle(_ style: CornerStyle, corners indices: [Self.Index]) -> [Corner] {
        self.enumerated().map({ indices.contains($0) ? $1.applyingStyle(style) : $1 })
    }
    
    /// Creates an array of corners with the same positions and a new specified style applied to a specified corner.
    /// - Parameters:
    ///   - style: A style that will be applied to a specified corner.
    ///   - indices: Index of the corner with which to apply the new style.
    /// - Returns: An array of corners with the same positions and a new specified style applied to a specified corner.
    func applyingStyle(_ style: CornerStyle, corner index: Self.Index) -> [Corner] {
        applyingStyle(style, corners: [index])
    }
    
    /// An array of corner dimensions used for drawing, insetting, and modifying points of a closed shape.
    var dimensions: [Corner.Dimensions] {
        dimensions()
    }
    
    /// Creates an array of corner dimensions used for drawing, insetting, and modifying points of an open shape.
    /// - Parameters:
    ///   - previousPoint: Previous corner point. Default is the last point.
    ///   - nextPoint: Next corner point. Default is the first point.
    /// - Returns: An array of corner dimensions used for drawing, insetting, and modifying points.
    func dimensions(previousPoint: CGPoint? = nil, nextPoint: CGPoint? = nil) -> [Corner.Dimensions] {
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
    
    /// Creates a path with a closed shape defined by this array of corners.
    /// - Returns: A path with a closed shape defined by this array of corners.
    func path() -> Path {
        dimensions.path()
    }
    
    /// Adds an open corner shape defined by this array of corners to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currrently is to the first corner.
    func addOpenCornerShape(to path: inout Path, moveToStart: Bool) {
        dimensions.addOpenCornerShape(to: &path, moveToStart: moveToStart)
    }
    
    /// Adds a closed corner shape defined by this array of corners to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    func addClosedCornerShape(to path: inout Path) {
        dimensions.addClosedCornerShape(to: &path)
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
    
    /// A boolean check that determines if a corner array is flat. Flat corners are point, rounded, and concave with absolute radius values.
    ///
    /// If any corner uses relative radius values or allows nested corner styles, this value will be false.
    internal var isFlat: Bool {
        self.contains(where: { !$0.style.isFlat })
    }
    
    /// An array of corners that's a flattened representation of the current array. Flat corners are point, rounded, and concave with absolute radius values.
    ///
    /// Relative radius values will be changed to absolute and corners with nested styles will change to an array of sub corners with those styles. This function is recursive and will flatten corners at all nested levels.
    internal var flattened: [Corner] {
        isFlat ? self : dimensions.flattened
    }
    
    /// Returns a copy of this array of corners flattened by the number of levels provided.
    ///
    /// All corners on this level will have their radius changed to absolute values and corners with nested styles will change to an array of corners with those styles. For each level higher than one this process will be repeated for those new nested corners.
    /// - Parameter levels: Number of levels to flatten.
    /// - Returns: A copy of this array of corners flattened by the number of levels provided.
    internal func flattened(levels: Int) -> [Corner] {
        isFlat ? self : dimensions.flattened(levels: levels)
    }
    
    /// Adds corners based on the specified notches.
    ///
    /// The first notch will create corners between the first and second corner, the next will create corners between the second and third corners, etc. Nil values will create no additional corners.
    /// - Parameter notches: Notches that define additional corners to add in the gaps between each corner. Nil values will skip a gap and add no corners.
    mutating func addNotches(_ notches: [Notch?]) {
        self = self.addingNotches(notches)
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
    
    /// Adds corners based on the specified notch after the specified index.
    /// - Parameters:
    ///   - notch: Notch that define additional corners to add after the specified index.
    ///   - cornerIndex: Index after which the corners will be added.
    mutating func addNotch(_ notch: Notch, afterCornerIndex cornerIndex: Int) {
        self = self.addingNotch(notch, afterCornerIndex: cornerIndex)
    }
    
    /// Creates a copy of the corner array with additional corners based on the specified notch after the specified index.
    /// - Parameters:
    ///   - notch: Notch that define additional corners to add after the specified index.
    ///   - cornerIndex: Index after which the corners will be added.
    func addingNotch(_ notch: Notch, afterCornerIndex cornerIndex: Int) -> [Corner] {
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
