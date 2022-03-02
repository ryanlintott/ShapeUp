//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Corner.Dimensions {
    func startCornerShape(on path: inout Path, at point: CGPoint? = nil, moveToStart: Bool) {
        let point = point ?? cornerStart
        moveToStart ? path.move(to: point) : path.addLine(to: point)
    }
    
    func addCornerShape(to path: inout Path, moveToStart: Bool) {
        #warning("Comment this when finished debugging")
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
//            path.addLine(to: cornerEnd)
            // Draw a rounded arc from the cornerStart to cornerEnd
            path.addArc(
                tangent1End: corner.point,
                tangent2End: cornerEnd,
                radius: absoluteRadius
            )
        case .concave:
            let debug = false
            
            // Start drawing this corner shape
            startCornerShape(on: &path, moveToStart: moveToStart)
            
            if debug {
                if let concaveStart = concaveStart {
                    path.addLine(to: concaveStart)
                }
                // path.addLine(to: cutoutPoint)
                path.addLine(to: concaveRadiusCenter)
                // path.addLine(to: corner.point)
                if let concaveEnd = concaveEnd {
                    path.addLine(to: concaveEnd)
                }
                path.addLine(to: cornerEnd)
                break
            }
            
            // If one value is nil, both are nil
            if let concaveStart = concaveStart, let concaveEnd = concaveEnd {
                // Draw a line to concave start
                path.addLine(to: concaveStart)
                // Draw a concave arc from the concave start to concave end
                path.addArc(
                    tangent1End: cutoutPoint,
                    tangent2End: concaveEnd,
                    radius: concaveRadius
                )
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
                [cornerStart, cornerEnd]
                    .corners(cornerStyles)
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
                [cornerStart, cutoutPoint, cornerEnd]
                    .corners(cornerStyles)
                    .dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
                    .addOpenCornerShape(to: &path, moveToStart: moveToStart)
            }
        }
    }
}
