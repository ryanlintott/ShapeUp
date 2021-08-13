//
//  SketchyLines.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2020-10-28.
//

import SwiftUI

public struct SketchyLines: Shape {
    public var animatableData: CGFloat {
        get { drawAmount }
        set { self.drawAmount = newValue }
    }
    
    var lines: [SketchyLine]
    var drawAmount: CGFloat
    
    public init(lines: [SketchyLine], drawAmount: CGFloat = 1) {
        self.lines = lines
        self.drawAmount = drawAmount
    }
}

public extension SketchyLines {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        for line in lines {
            var drawnLine = line
            path.addPath(drawnLine.path(in: rect, drawAmount: drawAmount))
        }
        return path
    }
}
