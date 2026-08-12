//
//  SketchyLine.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

/// An animatable line shape with ends that can extend and a position that can offset perpendicular to its direction.
public struct SketchyLine: Shape {
    /// Edges where the line can be drawn
    public enum SketchyEdge: Hashable, Codable, Sendable {
        case top, bottom, leading, trailing
    }
    
    /// Drawing direction
    public enum DrawDirection: Hashable, Codable, Sendable {
        /// Drawing will start at the top or leading end and draw to the bottom or trailing end.
        case toBottomTrailing
        /// Drawing will start at the bottom or trailing end and draw to the top or leading end.
        case toTopLeading
        
        /// The default drawing direction `.toBottomTrailing`
        public static let `default`: DrawDirection = .toBottomTrailing
    }
    
    /// The edge on which the line is drawn.
    public let edge: SketchyEdge
    /// The amount the start extends beyond the start point.
    public var startExtension: RelatableValue
    /// The amount the end extends beyond the end point.
    public var endExtension: RelatableValue
    /// The perpendicular offset from the edge.
    public var offset: RelatableValue
    /// The proportion of the line to draw.
    public var drawAmount: CGFloat
    /// The direction in which the line is drawn.
    public let drawDirection: DrawDirection
    
    /// Creates a sketchy line shape.
    /// - Parameters:
    ///   - edge: Edge on which to draw the line.
    ///   - startExtension: Amount the line start extends relative to the length of the line. Default is zero. Animatable.
    ///   - endExtension: Amount the line end extends relative to the length of the line. Default is zero. Animatable.
    ///   - offset: Perpendicular displacement from the selected edge. Relative values use the frame width for leading and trailing edges, and the frame height for top and bottom edges. Default is zero. Animatable.
    ///   - drawAmount: Amount of the line to draw measured as a percent of the length including extensions. Default is 1 for the entire line. Animatable.
    ///   - drawDirection: Direction to draw the line. Default is .toBottomTrailing.
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
        return switch edge {
        case .top:
            CGPoint(x: rect.minX - startExtension.value(using: rect.width), y: rect.minY)
        case .bottom:
            CGPoint(x: rect.minX - startExtension.value(using: rect.width), y: rect.maxY)
        case .leading:
            CGPoint(x: rect.minX, y: rect.minY - startExtension.value(using: rect.height))
        case .trailing:
            CGPoint(x: rect.maxX, y: rect.minY - startExtension.value(using: rect.height))
        }
    }
    
    /// Determines the end point of the line before offset.
    /// - Parameter rect: Rectangle in which the line is drawn.
    /// - Returns: Point where the line ends in the given rectangle.
    func endPoint(in rect: CGRect) -> CGPoint {
        return switch edge {
        case .top:
            CGPoint(x: rect.maxX + endExtension.value(using: rect.width), y: rect.minY)
        case .bottom:
            CGPoint(x: rect.maxX + endExtension.value(using: rect.width), y: rect.maxY)
        case .leading:
            CGPoint(x: rect.minX, y: rect.maxY + endExtension.value(using: rect.height))
        default:
            CGPoint(x: rect.maxX, y: rect.maxY + endExtension.value(using: rect.height))
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
        
        return switch edge {
        case .leading, .trailing:
            path.offsetBy(dx: offset.value(using: rect.width), dy: 0)
        default:
            path.offsetBy(dx: 0, dy: offset.value(using: rect.height))
        }
    }
    
    /// Creates the line path using a specified draw amount.
    /// - Parameters:
    ///   - rect: The rectangle in which to draw the line.
    ///   - drawAmount: The proportion of the line to draw.
    /// - Returns: The resulting line path.
    @available(*, deprecated, message: "Adjust the draw amount manually and then use path(in:) instead.")
    func path(in rect: CGRect, drawAmount: CGFloat) -> Path {
        var copy = self
        copy.drawAmount = drawAmount
        return copy.path(in: rect)
    }
}

extension SketchyLine: AnimatableProperties {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.startExtension
        \.endExtension
        \.offset
        \.drawAmount
    }
}
