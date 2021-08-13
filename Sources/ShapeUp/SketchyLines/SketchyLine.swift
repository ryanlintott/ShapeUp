//
//  SketchyLine.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public struct SketchyLine: Shape {
    public enum SketchyEdge {
        case top, bottom, leading, trailing
        case textBaseline(font: UIFont)
        case textCapHeight(font: UIFont)
    }
    
    public enum DrawDirection: CGFloat {
        case toBottomTrailing
        case toTopLeading
        
        public static let `default`: DrawDirection = .toBottomTrailing
    }
    
    public var animatableData: CGFloat {
        get { drawAmount }
        set { self.drawAmount = newValue }
    }
    
    let edge: SketchyEdge
    let startExtension: RelatableValue
    let endExtension: RelatableValue
    let offset: RelatableValue
    var drawAmount: CGFloat
    let drawDirection: DrawDirection
    
    public init(edge: SketchyEdge, startExtension: RelatableValue = .zero, endExtension: RelatableValue = .zero, offset: RelatableValue = .zero, drawAmount: CGFloat = 1, drawDirection: DrawDirection = .default) {
        self.edge = edge
        self.startExtension = startExtension
        self.endExtension = endExtension
        self.offset = offset
        self.drawAmount = drawAmount
        self.drawDirection = drawDirection
    }
}

public extension SketchyLine {
    var fontOffset: CGFloat {
        switch edge {
        case let .textBaseline(font):
            return font.descender
        case let .textCapHeight(font):
            return font.ascender - font.capHeight
        default:
            return 0
        }
    }
    
    func startPoint(in rect: CGRect) -> CGPoint {
        switch edge {
        case .top, .textCapHeight:
            return CGPoint(x: rect.minX - startExtension.value(using: rect.width), y: rect.minY)
        case .bottom, .textBaseline:
            return CGPoint(x: rect.minX - startExtension.value(using: rect.width), y: rect.maxY)
        case .leading:
            return CGPoint(x: rect.minX, y: rect.minY - startExtension.value(using: rect.height))
        case .trailing:
            return CGPoint(x: rect.maxX, y: rect.minY - startExtension.value(using: rect.height))
        }
    }
    
    func endPoint(in rect: CGRect) -> CGPoint {
        switch edge {
        case .top, .textCapHeight:
            return CGPoint(x: rect.maxX + endExtension.value(using: rect.width), y: rect.minY)
        case .bottom, .textBaseline:
            return CGPoint(x: rect.maxX + endExtension.value(using: rect.width), y: rect.maxY)
        case .leading:
            return CGPoint(x: rect.minX, y: rect.maxY + endExtension.value(using: rect.height))
        default:
            return CGPoint(x: rect.maxX, y: rect.maxY + endExtension.value(using: rect.height))
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var points = [startPoint(in: rect), endPoint(in: rect)]
        if drawDirection == .toTopLeading {
            points.reverse()
        }
        switch edge {
        case .top, .bottom, .textBaseline, .textCapHeight:
            points[1].x = points[0].x + (points[1].x - points[0].x) * max(0,drawAmount)
        default:
            points[1].y = points[0].y + (points[1].y - points[0].y) * max(0,drawAmount)
        }
        var path = Path()
        path.addLines(points)
        
        switch edge {
        case .leading, .trailing:
            return path.offsetBy(dx: offset.value(using: rect.width), dy: 0)
        default:
            return path.offsetBy(dx: 0, dy: offset.value(using: rect.height) + fontOffset)
        }
    }
    
    mutating func path(in rect: CGRect, drawAmount: CGFloat) -> Path {
        self.drawAmount = drawAmount
        return path(in: rect)
    }
}
