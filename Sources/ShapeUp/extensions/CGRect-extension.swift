//
//  CGRect-extension.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

public extension CGRect {
    var points: [CGPoint] {
        [
            CGPoint(x: self.minX, y: self.minY),
            CGPoint(x: self.maxX, y: self.minY),
            CGPoint(x: self.maxX, y: self.maxY),
            CGPoint(x: self.minX, y: self.maxY)
        ]
    }
    
    func corners(_ style: CornerStyle = .point) -> [Corner] {
        points.map({ Corner(style, point: $0) })
    }
    
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        let points = self.points
        let cornerStyles = styles + Array<CornerStyle?>(repeating: nil, count: Swift.max(points.count - styles.count, 0))
        var corners = [Corner]()
        for (i, point) in points.enumerated() {
            corners.append(Corner(cornerStyles[i], point: point))
        }
        return corners
    }
}
