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
    ///   - style: Style of the notch. (default is .rectangle)
    ///   - position: Center position of the notch relative to the length of the line and measured from the start. Default is the midpoint of the line.
    ///   - length: Length of the notch relative to the length of the line. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    public init(_ style: NotchStyle = .rectangle, position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue) {
        self.style = style
        self.position = position ?? .relative(0.5)
        self.length = length ?? depth
        self.depth = depth
    }
    
    /// Creates a custom notch from relative corners.
    ///
    /// Notch depth assumes a clockwise order of points. Negative depth creates a tab.
    /// - Parameters:
    ///   - position: Center position of the notch measured from the start. Default is the midpoint.
    ///   - length: Length of the notch. Default is equal to the depth.
    ///   - depth: Depth of the notch relative to the length of the line.
    ///   - relativeCorners: A closure that builds the relative corners defining the notch.
    public init(position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue, @RelativeCornerArrayBuilder relativeCorners: () -> [RelativeCorner]) {
        self.position = position ?? .relative(0.5)
        self.length = length ?? depth
        self.depth = depth
        self.style = .custom(relativeCorners: relativeCorners())
    }
}
