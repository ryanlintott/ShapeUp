//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Corner.Dimensions {
    func startCornerShape(on path: inout Path, moveToStart: Bool) {
        moveToStart ? path.move(to: cornerStart) : path.addLine(to: cornerStart)
    }
    
    func addCornerShape(to path: inout Path, moveToStart: Bool) {
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
                radius: abs(absoluteRadius)
            )
        case let .concave(_, radiusOffset):
            // Start drawing this corner shape
            startCornerShape(on: &path, moveToStart: moveToStart)
            // Draw a concave arc from the cornerStart to cornerEnd
            #warning("Draw the arc using center point and angles instead.")
            path.addArc(
                tangent1End: cutoutPoint,
                tangent2End: cornerEnd,
                radius: absoluteRadius + (radiusOffset ?? 0)
            )
            // Draw an additional line in case the arc doesn't get to the corner end point. Once the bug is fixed with drawing offset arcs this shouldn't be needed.
            if radiusOffset != 0 {
                path.addLine(to: cornerEnd)
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
