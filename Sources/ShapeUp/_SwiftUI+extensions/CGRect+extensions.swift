//
//  CGRect+extensions.swift
//  ShapeUp
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
    
    func pentagon(pointHeight: RelatableValue, topTaper: RelatableValue = .zero, bottomTaper: RelatableValue = .zero) -> [CGPoint] {
        let rect = self
        let sidePoints = [
            Corner(x: rect.minX + bottomTaper.value(using: rect.width / 2), y: rect.maxY),
            Corner(x: rect.minX + topTaper.value(using: rect.width / 2), y: rect.minY + pointHeight.value(using: rect.height))
        ]
        let corners = sidePoints
                    + [Corner(x: rect.midX, y: rect.minY)]
                    + sidePoints.flipHorizontal(around: rect.midX).reversed()
        
        return corners.points
    }
}
