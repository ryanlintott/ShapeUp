//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Path {
    /// Either moves to a point or adds a line to a point based on the supplied boolean
    /// - Parameters:
    ///   - p: Point to move or add a line towards
    ///   - isMove: Boolean determines whether a point is moved to or a line is drawn to it.
    fileprivate mutating func moveOrAddLine(to p: CGPoint, isMove: Bool) {
        isMove ? move(to: p) : addLine(to: p)
    }
    #warning("Test with 0, 1 or 2 corners with and without before and after")
    /// Adds an open corner shape to the current path. This function is recursive and will draw all nested corner styles.
    ///
    /// The path is drawn including the corner styles of both ends using the beforeCorner and afterCorner locations to describe the angle. If beforeCorner or afterCorner are not supplied, the last and first corners are used repectively.
    /// - Parameters:
    ///   - corners: An array of corners that will define what is drawn to this path.
    ///   - beforeCorner: The previous corner used when drawing the first corner style. The default is the last corner. A line will only be drawn from this corner if moveToStart is false.
    ///   - afterCorner: The target corner used for drawing the last corner style. The default will be the first corner. A line will not be drawn to this point.
    ///   - moveToStart: A boolean representing if the first action should be to move to the first corner. Default is true. If this is false, a line will be drawn from the current point to the first corner.
    fileprivate mutating func oldAddOpenCornerShape(_ corners: [Corner], between beforeCorner: Corner? = nil, and afterCorner: Corner? = nil, moveToStart: Bool = true) {


        corners.enumerated().forEach { i, corner in
            let previousCorner: Corner
            let nextCorner: Corner

            if i == 0 {
                // If it's the first corner, use the beforeCorner or if nil, grab the last corner.
                previousCorner = beforeCorner ?? corners[corners.count - 1]
            } else {
                // If it's not the first corner, use the previous corner.
                previousCorner = corners[i - 1]
            }

            if i == corners.count - 1 {
                // If it's the last corner, use the afterCorner or if nil, grab the first corner.
                nextCorner = afterCorner ?? corners[0]
            } else {
                // If it's not the last corner, use the next corner.
                nextCorner = corners[i + 1]
            }

            // Angle of the corner
            let angle = Angle.threePoint(nextCorner, corner, previousCorner)
            // Half of the angle used by the rounded curve of the corner
            let halvedRadiusAngle = angle.nonReflexCoterminal.supplementary.halved

            // Vector from the corner to the previous corner
            let previousVector = previousCorner.vector - corner.vector
            // Vector from the corner to the next corner
            let nextVector = nextCorner.vector - corner.vector

            // The maximum cut length from the corner. Any further and it would go beyond the next or previous corner.
            let maxCutLength = min(previousVector.magnitude, nextVector.magnitude)

            // The maximum radius that results from using the maximum cut length.
            let maxRadius = (maxCutLength / CGFloat(tan(halvedRadiusAngle.radians))).magnitude
            // Absolute value of corner radius relative to maximum radius.
            let cornerRadius = corner.radius.value(using: maxRadius)
            // Cut length based on corner radius
            let cutLength = cornerRadius * maxCutLength / maxRadius

            // The start point of the corner
            let cornerStart = corner.vector + (previousVector.normalized * cutLength)

            // The end point of the corner
            let cornerEnd = corner.vector + (nextVector.normalized * cutLength)

            // If it's the first corner and moveToStart is active, the first point will be a move.
            let isMove = i == 0 && moveToStart

            // Draw the corner based on the style.
            switch corner.style {
            case .point:
                // Move or draw a line to the corner.
                moveOrAddLine(to: corner.point, isMove: isMove)
            case .rounded:
                // Move or draw a line to the corner start point.
                moveOrAddLine(to: cornerStart.point, isMove: isMove)
                // Draw a rounded arc from the cornerStart to cornerEnd
                addArc(tangent1End: corner.point, tangent2End: cornerEnd.point, radius: cornerRadius)
            case .concave(radius: _, radiusOffset: nil):
                // Move or draw a line to the corner start point.
                moveOrAddLine(to: cornerStart.point, isMove: isMove)
                // Set the cutout corner as a mirrored version of the corner
                let cutoutCorner = corner.flipped(mirrorLineStart: cornerStart, mirrorLineEnd: cornerEnd)
                // Draw a concave arc from the cornerStart to cornerEnd
                addArc(tangent1End: cutoutCorner.point, tangent2End: cornerEnd.point, radius: cornerRadius)
            case let .concave(_, radiusOffset):
                // Move or draw a line to the corner start point.
                moveOrAddLine(to: cornerStart.point, isMove: isMove)
                // Set the cutout corner as a mirrored version of the corner
                let cutoutCorner = corner.flipped(mirrorLineStart: cornerStart, mirrorLineEnd: cornerEnd)
                // Draw a concave arc from the cornerStart to cornerEnd
                addArc(tangent1End: cutoutCorner.point, tangent2End: cornerEnd.point, radius: cornerRadius + (radiusOffset ?? 0))
                // Draw an additional line in case the arc doesn't get to the corner end point.
                addLine(to: cornerEnd.point)
            case let .straight(_, cornerStyles):
                if cornerStyles.allSatisfy({ $0 == .point }) {
                    // If all corner styles are simple points:
                    // Move or draw a line to the corner start point.
                    moveOrAddLine(to: cornerStart.point, isMove: isMove)
                    // Draw a line to the corner end point.
                    addLine(to: cornerEnd.point)
                } else {
                    // If non-point corner styles are used
                    // Create an array of corners used in this corner
                    let corners = [cornerStart, cornerEnd].corners(cornerStyles)
                    // Add a corner shape with these corners (only move to the start if isMove is active)
                    oldAddOpenCornerShape(corners, between: previousCorner, and: nextCorner, moveToStart: isMove)
                }
            case let .cutout(_, cornerStyles):
                // Determine the cutout point
                let cutout = cornerStart + (nextVector.normalized * cutLength)
                if cornerStyles.allSatisfy({ $0 == .point }) {
                    // If all corner styles are simple points:
                    // Move or draw a line to the corner start point.
                    moveOrAddLine(to: cornerStart.point, isMove: isMove)
                    // Draw a line to the corner cut point.
                    addLine(to: cutout.point)
                    // Draw a line to the corner end point.
                    addLine(to: cornerEnd.point)
                } else {
                    // If non-point corner styles are used
                    // Create an array of corners used in this corner
                    let corners = [cornerStart, cutout, cornerEnd].corners(cornerStyles)
                    // Add a corner shape with these corners (only move to the start if isMove is active)
                    oldAddOpenCornerShape(corners, between: previousCorner, and: nextCorner, moveToStart: isMove)
                }
            }
        }
    }
    
    /// Adds a closed corner shape to the current path. This function is recursive and will draw all nested corner styles.
    ///
    /// Once the last corner has been drawn the subpath is closed from the end of the last corner to the start of the first corner. Do not duplicate the first corner at the end.
    /// - Parameters:
    ///   - corners: An array of corners that will define what is drawn to this path.
    fileprivate mutating func oldAddClosedCornerShape(_ corners: [Corner]) {
        oldAddOpenCornerShape(corners)
        closeSubpath()
    }
}
