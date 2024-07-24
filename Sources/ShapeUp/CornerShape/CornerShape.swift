//
//  CornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/// An 2D insettable shape that you can use when drawing a view or as an array of corners to use as a starting point for a more complex shape.
///
/// You can define an insetAmount of zero as this property is mainly used if the shape is later inset. Use the closed property to define if your shape should be closed or left open. Write a function that returns an array of corners.
///
///     public struct MyShape: CornerShape {
///         public var insetAmount: CGFloat = .zero
///         public let closed = true
///
///         public func corners(in rect: CGRect) -> [Corner] {
///             [
///                 Corner(x: rect.midX, y: rect.minY),
///                 Corner(.rounded(radius: 5), x: rect.maxX, y: rect.maxY),
///                 Corner(.rounded(radius: 5), x: rect.minX, y: rect.maxY)
///             ]
///         }
///     }
///
/// The path function is already implemented and will use this array to create a single path, applying any inset, and closing it if the closed parameter is true.
///
/// A `CornerShape` is an `InsettableShape` so it can be used in SwiftUI Views in the same way as `RoundedRectangle` or similar.
///
///     MyShape()
///         .fill()
///
/// Or the corners can be accessed directly for use in a more complex shape
///
///     public func corners(in rect: CGRect) -> [Corner] {
///         MyShape()
///             .corners(in: rect)
///             .inset(by: 10)
///             .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
///     }
///
public protocol CornerShape: InsettableShapeByProperty {
    /// Creates an array of corners that will form a single closed shape with zero inset.
    ///
    /// Do not apply any inset amount in this function as it is automatically applied before creating the path.
    /// - Parameter rect: Frame in which the corners are defined.
    /// - Returns: An array of corners defining the shape with zero inset.
    nonisolated func corners(in rect: CGRect) -> [Corner]
    
    /// A boolean determining if the shape is closed or open.
    var closed: Bool { get }
}

public extension CornerShape {
    /// Creates an array of corners inset by the insetAmount property.
    /// - Parameter rect: Frame in which the corners are defined.
    /// - Returns: An array of corners inset by the insetAmount property.
    func insetCorners(in rect: CGRect) -> [Corner] {
        corners(in: rect)
            .inset(by: insetAmount)
    }
    
    /// Creates a path from the array of inset corners.
    /// - Parameter rect: Frame in which the path is drawn.
    /// - Returns: Path that describes this corner shape.
    func path(in rect: CGRect) -> Path {
        insetCorners(in: rect)
            .path(closed: closed)
    }
}
