//
//  Notch.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

/// A notch in a line.
public struct Notch: Sendable {
    /// Style of the notch.
    public var style: NotchStyle
    
    /// Center position of the notch relative to the length of the line and measured from the start.
    public var position: RelatableValue
    
    /// Length of the notch relative to the length of the line.
    public var length: RelatableValue
    
    /// Depth of the notch relative to the length of the line.
    public var depth: RelatableValue
    
    /// Creates a notch that will be drawn relative to a line segment between two points.
    ///
    /// Notch depth assumes a clockwise order of points.
    ///
    /// Negative depth will create a tab instead of a notch.
    /// - Parameters:
    ///   - style: Style of the notch.
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    public init(_ style: NotchStyle, position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue) {
        self.style = style
        self.position = position ?? .relative(0.5)
        self.length = length ?? depth
        self.depth = depth
    }
    
    /// Creates a notch that will be drawn relative to a line segment between two points using relative corners.
    ///
    /// Notch depth assumes a clockwise order of points.
    ///
    /// Negative depth will create a tab instead of a notch.
    /// - Parameters:
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    ///   - relativeCorners: Relative corners that define the notch shape.
    public init(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, relativeCorners: [RelativeCorner]) {
        self.style = NotchStyle(relativeCorners: relativeCorners)
        self.position = position ?? .relative(0.5)
        self.length = length ?? depth
        self.depth = depth
    }
}
