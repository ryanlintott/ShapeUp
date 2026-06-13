//
//  Corner+Dimensions+path.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Corner.Dimensions {
    /// Returns whether the corner angle is approximately straight.
    /// - Parameter tolerance: The maximum difference from 180 degrees in degrees.
    /// - Returns: `true` when the corner angle is within the tolerance of a straight angle.
    public func isApproximatelyStraight(tolerance: Double = 1e-12) -> Bool {
        180 - angle.nonReflexCoterminal.positive.degrees < tolerance
    }
    
    /// Either moves or adds a line to a provided point.
    /// - Parameters:
    ///   - path: Path that will be modified.
    ///   - point: Point that will either be moved to or have a line added towards.
    ///   - moveToStart: A boolean value determining if the point should be moved to. If this value is false a line will be added from wherever the path currently is to the point.
    internal func startCornerShape(on path: inout Path, at point: CGPoint, moveToStart: Bool) {
        moveToStart ? path.move(to: point) : path.addLine(to: point)
    }
    
    /// Adds a corner shape to the provided path.
    /// - Parameters:
    ///   - path: Path where corner shape is added.
    ///   - moveToStart: A boolean value determining if the first point should be moved to. If this value is false a line will be added from wherever the path currently is to the first corner.
    public func addCornerShape(to path: inout Path, moveToStart: Bool) {
        if absoluteRadius <= 0 || isApproximatelyStraight() {
            // If the radius is negative or the angle is straight, the corner style doesn't matter.
            startCornerShape(on: &path, at: corner.point, moveToStart: moveToStart)
            return
        }
        
        // Draw the corner based on the style.
        switch corner.style {
            // Custom corners with no subcorners should draw as points.
        case .point:
            // Start drawing this corner shape
            startCornerShape(on: &path, at: corner.point, moveToStart: moveToStart)
            
        case .rounded:
            // Start drawing this corner shape
            startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
            // Draw a rounded arc from the cornerStart to cornerEnd
            path.addArc(
                tangent1End: corner.point,
                tangent2End: cornerEnd,
                radius: absoluteRadius
            )
            
        case .concave:
            
            guard absoluteRadius > 1e-12 else {
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                return
            }
            
            if concaveRadius > absoluteRadius {
                guard let concaveStart, let concaveEnd else {
                    // Sometimes the inset sides of a corner shrink the concave curve to nothing. In that case, draw a point.
                    startCornerShape(on: &path, at: corner.point, moveToStart: moveToStart)
                    return
                }
                
                startCornerShape(on: &path, at: concaveStart, moveToStart: moveToStart)
                path.addArc(
                    center: concaveRadiusCenter,
                    radius: concaveRadius,
                    startAngle: (concaveStart.vector - concaveRadiusCenter.vector).direction ?? .zero,
                    endAngle: (concaveEnd.vector - concaveRadiusCenter.vector).direction ?? .zero,
                    clockwise: reflexMultiplier > 0
                )
                path.addLine(to: concaveEnd)
                
            } else {
                guard let concaveStart, let concaveEnd else {
                    // If an inset corner with a small radius has no concave start or end then it's likely the radius is zero and it should draw as a cutout point.
                    startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                    path.addLine(to: cutoutPoint)
                    path.addLine(to: cornerEnd)
                    return
                }
                
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
                path.addLine(to: concaveStart)
                path.addArc(tangent1End: cutoutPoint, tangent2End: concaveEnd, radius: concaveRadius)
                path.addLine(to: concaveEnd)
                path.addLine(to: cornerEnd)
            }
        case let .straight(_, cornerStyles):
            if cornerStyles == [] || cornerStyles.allSatisfy({ $0 == .point }) {
                // If all corner styles are simple points:
                // Start drawing this corner shape
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
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
                startCornerShape(on: &path, at: cornerStart, moveToStart: moveToStart)
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
            
        case .custom:
            (subCorners.isEmpty ? [RelativeCorner.topRight.corner(in: frame)] : subCorners)
                .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                .addOpenCornerShape(to: &path, moveToStart: moveToStart)
        }
    }
}
