//
//  SketchyLines.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-10-28.
//

import SwiftUI

/// Lines with ends that can extend and a position that can offset perpendicular to its direction.
///
/// All lines can be animated with a single draw amount. Each line's draw amount will be ignored.
@MainActor
public struct SketchyLines: Shape {
    nonisolated public var animatableData: CGFloat {
        get {
            MainActor.assumeIsolated {
                drawAmount
            }
        }
        set {
            MainActor.assumeIsolated {
                self.drawAmount = newValue
            }
        }
    }
    
    public var lines: [SketchyLine]
    public var drawAmount: CGFloat
    
    /// Creates a collection of sketchy lines.
    /// - Parameters:
    ///   - lines: Lines that will be drawn using hte drawAmount.
    ///   - drawAmount: Amount to draw. Defaults to 1 and overrides all lines.
    public init(lines: [SketchyLine], drawAmount: CGFloat = 1) {
        self.lines = lines
        self.drawAmount = drawAmount
    }
}

public extension SketchyLines {
    nonisolated func path(in rect: CGRect) -> Path {
        MainActor.assumeIsolated {
            var path = Path()
            
            for line in lines {
                var drawnLine = line
                path.addPath(drawnLine.path(in: rect, drawAmount: drawAmount))
            }
            return path
        }
    }
}
