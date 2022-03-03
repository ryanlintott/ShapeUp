//
//  Corner+Dimensions+Array.swift
//  
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Array where Element == Corner.Dimensions {
    public var corners: [Corner] {
        map { $0.corner }
    }
    
    public func corners(inset: CGFloat) -> [Corner] {
        inset == 0 ? corners : map { $0.corner(inset: inset) }
    }
    
    /// Creates a path with a closed shape defined by this array of corner dimensions.
    /// - Returns: A path with a closed shape defined by this array of corners.
    public func path() -> Path {
        var path = Path()
        addClosedCornerShape(to: &path)
        return path
    }
    
    /// Adds an open corner shape defined by this array of corners to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currrently is to the first corner.
    func addOpenCornerShape(to path: inout Path, moveToStart: Bool) {
        self.enumerated().forEach { i, dims in
            // If it's the first corner and moveToStart is active, the first point will be a move.
            dims.addCornerShape(to: &path, moveToStart: i == 0 && moveToStart)
        }
    }
    
    /// Adds a closed corner shape defined by this array of corner dimensions to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    func addClosedCornerShape(to path: inout Path) {
        addOpenCornerShape(to: &path, moveToStart: true)
        path.closeSubpath()
    }
    
    /// An flattened array of corners based on these corner dimensions.
    ///
    /// All corners will have their radius changed to absolute values and corners with nested styles will change to an array of corners with those styles. This process is recursive leaving no corners with nested corner styles or relative radius values.
    internal var flattened: [Corner] {
        flatMap { $0.flattened }
    }
    
    /// Returns an array of corners based on these corner dimensions flattened by the number of levels provided.
    ///
    /// All corners on this level will have their radius changed to absolute values and corners with nested styles will change to an array of corners with those styles. For each level higher than one this process will be repeated for those new nested corners.
    /// - Parameter levels: Number of levels to flatten.
    /// - Returns: An array of corners based on these corner dimensions flattened by the number of levels provided.
    internal func flattened(levels: Int) -> [Corner] {
        flatMap { $0.flattened(levels: levels)}
    }
}
