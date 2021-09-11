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
    
    func anchorPoint(_ anchorPoint: RectAnchor) -> CGPoint {
        switch anchorPoint {
        case .topLeft:
            return CGPoint(x: minX, y: minY)
        case .top:
            return CGPoint(x: midX, y: minY)
        case .topRight:
            return CGPoint(x: maxX, y: minY)
        case .left:
            return CGPoint(x: minX, y: midY)
        case .center:
            return CGPoint(x: midX, y: midY)
        case .right:
            return CGPoint(x: maxX, y: midY)
        case .bottomLeft:
            return CGPoint(x: minX, y: maxY)
        case .bottom:
            return CGPoint(x: midX, y: maxY)
        case .bottomRight:
            return CGPoint(x: maxX, y: maxY)
        }
    }
    
    func corners(_ style: CornerStyle = .point) -> [Corner] {
        points.map({ Corner(style, point: $0) })
    }
    
    func corners(_ styles: [CornerStyle?]) -> [Corner] {
        let points = self.points
        
        ///Ensures cornerStyles array is long enough to cover all corners
        let cornerStyles = styles + Array<CornerStyle?>(repeating: nil, count: Swift.max(points.count - styles.count, 0))
        var corners = [Corner]()
        for (i, point) in points.enumerated() {
            #warning("Add error checking here in case cornerStyles[i] doesn't exist")
            corners.append(Corner(cornerStyles[i], point: point))
        }
        return corners
    }
}
