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
    
    /// A boolean check that determines if a corner array is flat.
    ///
    /// If there are any corners using relative values or nested corner styles, this value will be false.
    var isFlat: Bool {
        self.contains(where: { $0.style.isFlat })
    }
    
    #warning("This function should reference Corner.Dimensions version instead.")
    /// An array of corners that's a flattened representation of the current array.
    ///
    /// This array will not include relative values or corner styles with nested corner styles that are not .point. This function runs multiple passes to flatten corners with nested styles and so that relative values are relative to corners at the same level.
    var flattened: [Corner] {
        var corners: [Corner]
        var newCorners = self
        while !newCorners.isFlat {
            corners = newCorners
            newCorners = []
            for (i, corner) in corners.enumerated() {
                let previousCorner = i == 0 ? corners.last! : corners[i - 1]
                let nextCorner = i == corners.count - 1 ? corners.first! : corners[i + 1]
                newCorners += corner.flatten(previousCorner: previousCorner, nextCorner: nextCorner)
            }
        }
        
        return newCorners
    }
    
    func inset(_ insetAmount: CGFloat, previousPoint: CGPoint, nextPoint: CGPoint, allowNegativeRadius: Bool? = nil) -> [Corner] {
        if self.count < 2 || insetAmount == 0 { return self }
        
        return self
            .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
            .corners(inset: insetAmount, allowNegativeRadius: allowNegativeRadius)
    }

    /// Creates an array of corners that represent an inset version of the current shape.
    ///
    /// Corner array will be flattened so it may contain more corners than before. The inset assumes a clockwise shape order and a closed path where the start point is also the end point. Do not include a duplicate of the start point at the end of the array.
    /// - Parameter insetAmount: Amount corners will be inset.
    /// - Returns: An array of inset corners.
    func inset(by insetAmount: CGFloat, allowNegativeRadius: Bool? = nil) -> [Corner] {
        if self.isEmpty { return self }
        
        return inset(insetAmount, previousPoint: self.last!.point, nextPoint: self.first!.point, allowNegativeRadius: allowNegativeRadius)
    }
    
    /// Creates a path with a closed shape defined by this array of corners.
    ///
    /// The start point is also the end point. Do not include a duplicate of the start point at the end of the array.
    /// - Returns: A path with a closed shape defined by this array of corners.
    func path() -> Path {
        var path = Path()
        self.dimensions().addClosedCornerShape(to: &path)
//        path.addClosedCornerShape(self)
        return path
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
