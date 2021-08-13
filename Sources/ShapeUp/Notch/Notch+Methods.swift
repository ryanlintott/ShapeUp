//
//  Notch+Methods.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public extension Notch {
    func between(start: CGPoint, end: CGPoint) -> [CGPoint] {
        let vector = end - start
        let totalLength = vector.magnitude
        let normalizedVector = vector.normalized
        let notchLength = length.value(using: totalLength)
        let notchPosition = position.value(using: totalLength)
        let notchDepth = depth.value(using: totalLength)
        
        let notchStartPoint = start + normalizedVector * notchPosition - normalizedVector * (notchLength / 2)
        let notchEndPoint = notchStartPoint + normalizedVector * notchLength
        
        var points = [CGPoint]()
        
        switch style {
        case .triangle:
            points += [
                notchStartPoint,
                notchStartPoint + (normalizedVector * (notchLength / 2)) + (normalizedVector.rotated(.degrees(90)) * notchDepth),
                notchEndPoint
            ]
        case .rectangle:
            points += [
                notchStartPoint,
                notchStartPoint + (normalizedVector.rotated(.degrees(90)) * notchDepth),
                notchEndPoint + (normalizedVector.rotated(.degrees(90)) * notchDepth),
                notchEndPoint
            ]
        case let .custom(corners):
            let rect = CGRect(x: 0, y: 0, width: notchLength, height: notchDepth)
            let angle = Angle(start, end)
            points += corners(rect).points.map({ $0.rotated(angle).moved(notchStartPoint)})
        }

        return points
    }
    // TODO: add corner styles
    func between(start: Corner, end: Corner) -> [Corner] {
        let points = between(start: start.point, end: end.point)
        let styleCornerStyles = style.cornerStyles
        let cornerStyles = styleCornerStyles + Array<CornerStyle?>(repeating: nil, count: Swift.max(points.count - styleCornerStyles.count, 0))
        
        return between(start: start.point, end: end.point).corners(cornerStyles)
    }
    
    static func triangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyle: CornerStyle? = nil) -> Notch {
        Notch(.triangle(cornerStyle: cornerStyle), position: position, length: length, depth: depth)
    }
    
    static func triangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyles: [CornerStyle?]) -> Notch {
        Notch(.triangle(cornerStyles: cornerStyles), position: position, length: length, depth: depth)
    }
    
    static func rectangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyle: CornerStyle? = nil) -> Notch {
        Notch(.rectangle(cornerStyle: cornerStyle), position: position, length: length, depth: depth)
    }
    
    static func rectangle(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, cornerStyles: [CornerStyle?]) -> Notch {
        Notch(.rectangle(cornerStyles: cornerStyles), position: position, length: length, depth: depth)
    }
    
    static func custom(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, corners: @escaping (CGRect) -> [Corner]) -> Notch {
        Notch(.custom(corners: corners), position: position, length: length, depth: depth)
    }
}
