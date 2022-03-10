//
//  SketchyLine+staticInit.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension SketchyLine {
    /// Creates a sketchy line shape on the top edge.
    /// - Parameters:
    ///   - startExtension: Amount the line start extends relative to the length of the line. Default is zero.
    ///   - endExtension: Amount the line end extends relative to the length of the line. Default is zero.
    ///   - offset: Amount of the line to draw measured as a percent of the length including extensions. 1 is the entire line. Default is zero.
    ///   - drawAmount: Animatable. Amount of the line to draw measured as a percent of the length including extensions. Default is 1 for the entire line.
    ///   - drawDirection: Direction to draw the line. Default is .toBottomTrailling.
    static func top(
        startExtension: RelatableValue = .zero,
        endExtension: RelatableValue = .zero,
        offset: RelatableValue = .zero,
        drawAmount: CGFloat = 1,
        drawDirection: DrawDirection = .default
    ) -> SketchyLine {
        SketchyLine(
            edge: .top,
            startExtension: startExtension,
            endExtension: endExtension,
            offset: offset,
            drawAmount: drawAmount,
            drawDirection: drawDirection
        )
    }
    
    /// Creates a sketchy line shape on the bottom edge.
    /// - Parameters:
    ///   - startExtension: Amount the line start extends relative to the length of the line. Default is zero.
    ///   - endExtension: Amount the line end extends relative to the length of the line. Default is zero.
    ///   - offset: Amount of the line to draw measured as a percent of the length including extensions. 1 is the entire line. Default is zero.
    ///   - drawAmount: Animatable. Amount of the line to draw measured as a percent of the length including extensions. Default is 1 for the entire line.
    ///   - drawDirection: Direction to draw the line. Default is .toBottomTrailling.
    static func bottom(
        startExtension: RelatableValue = .zero,
        endExtension: RelatableValue = .zero,
        offset: RelatableValue = .zero,
        drawAmount: CGFloat = 1,
        drawDirection: DrawDirection = .default
    ) -> SketchyLine {
        SketchyLine(
            edge: .bottom,
            startExtension: startExtension,
            endExtension: endExtension,
            offset: offset,
            drawAmount: drawAmount,
            drawDirection: drawDirection
        )
    }
    
    /// Creates a sketchy line shape on the leading edge.
    /// - Parameters:
    ///   - startExtension: Amount the line start extends relative to the length of the line. Default is zero.
    ///   - endExtension: Amount the line end extends relative to the length of the line. Default is zero.
    ///   - offset: Amount of the line to draw measured as a percent of the length including extensions. 1 is the entire line. Default is zero.
    ///   - drawAmount: Animatable. Amount of the line to draw measured as a percent of the length including extensions. Default is 1 for the entire line.
    ///   - drawDirection: Direction to draw the line. Default is .toBottomTrailling.
    static func leading(
        startExtension: RelatableValue = .zero,
        endExtension: RelatableValue = .zero,
        offset: RelatableValue = .zero,
        drawAmount: CGFloat = 1,
        drawDirection: DrawDirection = .default
    ) -> SketchyLine {
        SketchyLine(
            edge: .leading,
            startExtension: startExtension,
            endExtension: endExtension,
            offset: offset,
            drawAmount: drawAmount,
            drawDirection: drawDirection
        )
    }
    
    /// Creates a sketchy line shape on the trailing edge.
    /// - Parameters:
    ///   - startExtension: Amount the line start extends relative to the length of the line. Default is zero.
    ///   - endExtension: Amount the line end extends relative to the length of the line. Default is zero.
    ///   - offset: Amount of the line to draw measured as a percent of the length including extensions. 1 is the entire line. Default is zero.
    ///   - drawAmount: Animatable. Amount of the line to draw measured as a percent of the length including extensions. Default is 1 for the entire line.
    ///   - drawDirection: Direction to draw the line. Default is .toBottomTrailling.
    static func trailing(
        startExtension: RelatableValue = .zero,
        endExtension: RelatableValue = .zero,
        offset: RelatableValue = .zero,
        drawAmount: CGFloat = 1,
        drawDirection: DrawDirection = .default
    ) -> SketchyLine {
        SketchyLine(
            edge: .trailing,
            startExtension: startExtension,
            endExtension: endExtension,
            offset: offset,
            drawAmount: drawAmount,
            drawDirection: drawDirection
        )
    }
}
