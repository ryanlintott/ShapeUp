//
//  SketchyLines.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-10-28.
//

import SwiftUI

/// Lines with ends that can extend and a position that can offset perpendicular to its direction.
///
/// All animatable line properties can be animated individually and a single draw amount can be supplied to override the draw amount on all lines.
public struct SketchyLines: Shape {
    /// The lines included in this shape.
    public var lines: [SketchyLine]
    /// The proportion of each line to draw.
    public var drawAmount: CGFloat?
    
    /// Creates a collection of sketchy lines.
    /// - Parameters:
    ///   - lines: Lines that will be drawn using the drawAmount.
    ///   - drawAmount: Amount to draw that overrides all lines. Defaults to nil.
    public init(lines: [SketchyLine], drawAmount: CGFloat? = nil) {
        self.lines = lines
        self.drawAmount = drawAmount
    }
}

extension SketchyLines: AnimatableProperties {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.drawAmount
        \.lines
    }
}

public extension SketchyLines {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for var line in lines {
            if let drawAmount {
                line.drawAmount = drawAmount
            }
            path.addPath(line.path(in: rect))
        }
        return path
    }
}
