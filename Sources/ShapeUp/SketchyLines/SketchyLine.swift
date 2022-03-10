//
//  SketchyLine.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

/// A animatable line Shape with ends that can extend and a position that can offset perpendicular to its direction.
public struct SketchyLine: Shape {
    /// Edges where the line can be drawn
    public enum SketchyEdge: Equatable, Hashable, Codable {
        case top, bottom, leading, trailing
    }
    
    /// Drawing direction
    public enum DrawDirection: CGFloat {
        /// Drawing will start at the top or leading end and draw to the bottom or trailing end.
        case toBottomTrailing
        /// Drawing will start at the bottom or trailing end and draw to the top or leading end.
        case toTopLeading
        
        public static let `default`: DrawDirection = .toBottomTrailing
    }
    
    public var animatableData: CGFloat {
        get { drawAmount }
        set { self.drawAmount = newValue }
    }
    
    public let edge: SketchyEdge
    public let startExtension: RelatableValue
    public let endExtension: RelatableValue
    public let offset: RelatableValue
    public var drawAmount: CGFloat
    public let drawDirection: DrawDirection
    
    /// Creates a sketchy line shape.
    /// - Parameters:
    ///   - edge: Edge to draw the line on. Text edges require an instance of the UIFont
    ///   - startExtension: Amount the line start extends relative to the length of the line. Default is zero.
    ///   - endExtension: Amount the line end extends relative to the length of the line. Default is zero.
    ///   - offset: Amount of the line to draw measured as a percent of the length including extensions. 1 is the entire line. Default is zero.
    ///   - drawAmount: Animatable. Amount of the line to draw measured as a percent of the length including extensions. Default is 1 for the entire line.
    ///   - drawDirection: Direction to draw the line. Default is .toBottomTrailling.
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
    /// Determines the start point of the line before offset.
    /// - Parameter rect: Rectangle in which the line is drawn.
    /// - Returns: Point where the line starts in the given rectangle.
    func startPoint(in rect: CGRect) -> CGPoint {
        switch edge {
        case .top:
            return CGPoint(x: rect.minX - startExtension.value(using: rect.width), y: rect.minY)
        case .bottom:
            return CGPoint(x: rect.minX - startExtension.value(using: rect.width), y: rect.maxY)
        case .leading:
            return CGPoint(x: rect.minX, y: rect.minY - startExtension.value(using: rect.height))
        case .trailing:
            return CGPoint(x: rect.maxX, y: rect.minY - startExtension.value(using: rect.height))
        }
    }
    
    /// Determines the end point of the line before offset.
    /// - Parameter rect: Rectangle in which the line is drawn.
    /// - Returns: Point where the line ends in the given rectangle.
    func endPoint(in rect: CGRect) -> CGPoint {
        switch edge {
        case .top:
            return CGPoint(x: rect.maxX + endExtension.value(using: rect.width), y: rect.minY)
        case .bottom:
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
        case .top, .bottom:
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
            return path.offsetBy(dx: 0, dy: offset.value(using: rect.height))
        }
    }
    
    mutating func path(in rect: CGRect, drawAmount: CGFloat) -> Path {
        self.drawAmount = drawAmount
        return path(in: rect)
    }
}
