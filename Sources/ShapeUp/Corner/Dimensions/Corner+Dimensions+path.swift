//
//  Corner+Dimensions+path.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Corner.Dimensions {
    /// Either moves or adds a line to a provided point.
    /// - Parameters:
    ///   - path: Path that will be modified.
    ///   - point: Point that will either be moved to or have a line added towards.
    ///   - moveToStart: A boolean value determining if the point should be moved to. If this value is false a line will be added from wherever the path currrently is to the point.
    internal func startCornerShape(on path: inout Path, at point: CGPoint? = nil, moveToStart: Bool) {
        let point = point ?? cornerStart
        moveToStart ? path.move(to: point) : path.addLine(to: point)
    }
    
    /// Adds a corner shape to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currrently is to the first corner.
    public func addCornerShape(to path: inout Path, moveToStart: Bool) {
        guard absoluteRadius > 0 else {
            // If the radius is negative the corner style doesn't matter.
            startCornerShape(on: &path, at: corner.point, moveToStart: moveToStart)
            return
        }
        
        // Draw the corner based on the style.
        switch corner.style {
        case .point:
            // Start drawing this corner shape
            startCornerShape(on: &path, moveToStart: moveToStart)
            
        case .rounded:
            // Start drawing this corner shape
            startCornerShape(on: &path, moveToStart: moveToStart)
            // Draw a rounded arc from the cornerStart to cornerEnd
            path.addArc(
                tangent1End: corner.point,
                tangent2End: cornerEnd,
                radius: absoluteRadius
            )
            
        case .concave:
            // Start drawing this corner shape
            startCornerShape(on: &path, moveToStart: moveToStart)
            // If one value is nil, both are nil
            if let concaveStart = concaveStart, let concaveEnd = concaveEnd {
                if (concaveStart.vector - cornerStart.vector).magnitude < abs(cutLength) {
                    // Draw a line to concave start
                    path.addLine(to: concaveStart)
                    // Draw a concave arc from the concave start to concave end
                    path.addArc(
                        tangent1End: cutoutPoint,
                        tangent2End: concaveEnd,
                        radius: concaveRadius
                    )
                } else {
                    // Just draw a line to the cutout point
                    path.addLine(to: cutoutPoint)
                }
                // Draw a line to corner end.
                path.addLine(to: cornerEnd)
            } else {
                // Draw a concave arc from the cornerStart to cornerEnd
                path.addArc(
                    tangent1End: cutoutPoint,
                    tangent2End: cornerEnd,
                    radius: concaveRadius
                )
            }
            
        case let .straight(_, cornerStyles):
            if cornerStyles == [] || cornerStyles.allSatisfy({ $0 == .point }) {
                // If all corner styles are simple points:
                // Start drawing this corner shape
                startCornerShape(on: &path, moveToStart: moveToStart)
                // Draw a line to the corner end point.
                path.addLine(to: cornerEnd)
            } else {
                // If non-point corner styles are used
                subCorners
                    .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                    .addOpenCornerShape(to: &path, moveToStart: moveToStart)
            }
            
        case let .cutout(_, cornerStyles):
            if cornerStyles == [] || cornerStyles.allSatisfy({ $0 == .point }) {
                // If all corner styles are simple points:
                // Start drawing this corner shape
                startCornerShape(on: &path, moveToStart: moveToStart)
                // Draw a line to the corner cut point.
                path.addLine(to: cutoutPoint)
                // Draw a line to the corner end point.
                path.addLine(to: cornerEnd)
            } else {
                // If non-point corner styles are used
                subCorners
                    .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                    .addOpenCornerShape(to: &path, moveToStart: moveToStart)
            }
        }
    }
}
