//
//  Vector2Representable+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public extension Array where Element: Vector2Representable {
    var vectors: [Vector2] {
        map({ $0.vector })
    }
    
    var points: [CGPoint] {
        map({ $0.point })
    }
    
    var bounds: CGRect {
        guard !isEmpty else {
            return .zero
        }
        
        let xArray = self.map { $0.vector.dx }
        let yArray = self.map { $0.vector.dy }
        let minX = xArray.min() ?? .zero
        let minY = yArray.min() ?? .zero
        let maxX = xArray.max() ?? .zero
        let maxY = yArray.max() ?? .zero

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    func anchorPoint(_ anchorPoint: RectAnchor) -> Element {
        Element(vector: bounds.anchorPoint(anchorPoint).vector)
    }

    var center: Element {
        anchorPoint(.center)
    }

    var angles: [Angle] {
        guard self.count >= 3 else {
            return []
        }

        return self
            .enumerated()
            .map {
                let previousPoint = $0.offset == 0 ? self.last! : self[$0.offset - 1]
                let nextPoint = $0.offset == self.count - 1 ? self.first! : self[$0.offset + 1]
                return Angle(previousPoint, $0.element, nextPoint)
            }
    }
}
