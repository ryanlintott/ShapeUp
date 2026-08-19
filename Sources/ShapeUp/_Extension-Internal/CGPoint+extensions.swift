//
//  CGPoint+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-06-11.
//

import Foundation

extension CGPoint {
    func relative(to frame: some CGFrameRepresentable) -> RectAnchor {
        /// Vector from origin to the point.
        let relativeVector = vector - frame.origin.vector
        
        let denominator = frame.xAxis.crossProduct(with: frame.yAxis)
        let axisMagnitudeSquared = frame.xAxis.magnitudeSquared + frame.yAxis.magnitudeSquared
        guard axisMagnitudeSquared > 0 else { return .topLeft }

        let rankTolerance = axisMagnitudeSquared * .ulpOfOne * 16
        let x: CGFloat
        let y: CGFloat

        if abs(denominator) > rankTolerance {
            x = relativeVector.crossProduct(with: frame.yAxis) / denominator
            y = frame.xAxis.crossProduct(with: relativeVector) / denominator
        } else {
            // Use the minimum-norm solution when the axes describe a line.
            x = frame.xAxis.dotProduct(with: relativeVector) / axisMagnitudeSquared
            y = frame.yAxis.dotProduct(with: relativeVector) / axisMagnitudeSquared
        }
        
        return .relative(x: x, y: y)
    }
}
