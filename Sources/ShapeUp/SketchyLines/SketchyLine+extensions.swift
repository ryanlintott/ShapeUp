//
//  SketchyLine+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension SketchyLine {
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
    
    static func textBaseline(
        font: UIFont,
        startExtension: RelatableValue = .zero,
        endExtension: RelatableValue = .zero,
        offset: RelatableValue = .zero,
        drawAmount: CGFloat = 1,
        drawDirection: DrawDirection = .default
    ) -> SketchyLine {
        SketchyLine(
            edge: .textBaseline(font: font),
            startExtension: startExtension,
            endExtension: endExtension,
            offset: offset,
            drawAmount: drawAmount,
            drawDirection: drawDirection
        )
    }
    
    static func textCapHeight(
        font: UIFont,
        startExtension: RelatableValue = .zero,
        endExtension: RelatableValue = .zero,
        offset: RelatableValue = .zero,
        drawAmount: CGFloat = 1,
        drawDirection: DrawDirection = .default
    ) -> SketchyLine {
        SketchyLine(
            edge: .textCapHeight(font: font),
            startExtension: startExtension,
            endExtension: endExtension,
            offset: offset,
            drawAmount: drawAmount,
            drawDirection: drawDirection
        )
    }
}
