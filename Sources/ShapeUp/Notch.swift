//
//  Notch.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

enum NotchStyle {
    case triangle(cornerStyles: [CornerStyle?])
    case rectangle(cornerStyles: [CornerStyle?])
    case custom(corners: (_ in: CGRect) -> [Corner])
    
    static let triangle = NotchStyle.triangle(cornerStyles: [])
    static let rectangle = NotchStyle.rectangle(cornerStyles: [])
    
    static func triangle(cornerStyle: CornerStyle? = nil) -> NotchStyle {
        .triangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 3))
    }
    static func rectangle(cornerStyle: CornerStyle? = nil) -> NotchStyle {
        .rectangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 4))
    }
    
    var cornerStyles: [CornerStyle?] {
        switch self {
        case let .triangle(cornerStyles):
            return cornerStyles
        case let .rectangle(cornerStyles):
            return cornerStyles
        case let .custom(corners):
            return corners(.zero).cornerStyles
        }
    }
}

struct Notch {
    let style: NotchStyle
    let position: RelatableValue
    let length: RelatableValue
    let depth: RelatableValue
    
    init(_ style: NotchStyle, position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue) {
        
        self.style = style
        self.position = position ?? .relative(0.5)
        self.length = length ?? depth
        self.depth = depth
    }
    
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

extension Array where Element == CGPoint {
    mutating func addNotches(_ notches: [Notch?]) {
        self = self.addingNotches(notches)
    }
    
    func addingNotches(_ notches: [Notch?]) -> [CGPoint] {
        guard self.count >= 2 else {
            return self
        }
        // Pad notches with nil values to match point count
        let notches = notches + Array<Notch?>(repeating: nil, count: Swift.max(0, self.count - notches.count))
        var notchedPoints = [CGPoint]()
        for (i, point) in self.enumerated() {
            notchedPoints += [point]
            let nextPoint = i == self.count - 1 ? self.first! : self[i + 1]
            if let notch = notches[i] {
                notchedPoints += notch.between(start: point, end: nextPoint)
            }
        }
        return notchedPoints
    }
}
