//
//  Corner+Dimensions+Array.swift
//  
//
//  Created by Ryan Lintott on 2022-02-18.
//

import SwiftUI

extension Array where Element == Corner {
    public var dimensions: [Corner.Dimensions] {
        dimensions()
    }
    
    public func dimensions(previousPoint: CGPoint? = nil, nextPoint: CGPoint? = nil) -> [Corner.Dimensions] {
        if self.isEmpty { return [] }
        
        let firstPoint = previousPoint ?? self.last!.point
        let lastPoint = nextPoint ?? self.first!.point
        
        return self.enumerated().map { i, corner in
            let previousPoint = i == 0 ? firstPoint : self[i - 1].point
            let nextPoint = i == self.count - 1 ? lastPoint : self[i + 1].point
            return corner.dimensions(previousPoint: previousPoint, nextPoint: nextPoint)
        }
    }
}

extension Array where Element == Corner.Dimensions {
    public var corners: [Corner] {
        corners()
    }
    
    public func corners(inset: CGFloat = .zero, allowNegativeRadius: Bool? = nil) -> [Corner] {
        map {
            $0.corner(inset: inset, allowNegativeRadius: allowNegativeRadius)
        }
    }
    
    public func path() -> Path {
        var path = Path()
        addOpenCornerShape(to: &path, moveToStart: true)
        return path
    }
    
    func addOpenCornerShape(to path: inout Path, moveToStart: Bool) {
        self.enumerated().forEach { i, dims in
            // If it's the first corner and moveToStart is active, the first point will be a move.
            dims.addCornerShape(to: &path, moveToStart: i == 0 && moveToStart)
        }
    }
    
    func addClosedCornerShape(to path: inout Path) {
        addOpenCornerShape(to: &path, moveToStart: true)
        path.closeSubpath()
    }
}
