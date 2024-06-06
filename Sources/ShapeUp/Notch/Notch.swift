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
    public let style: NotchStyle
    
    /// Center position of the notch relative to the length of the line and measured from the start.
    public let position: RelatableValue
    
    /// Length of the notch relative to the length of the line.
    public let length: RelatableValue
    
    /// Depth of the notch relative to the length of the line.
    public let depth: RelatableValue
    
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
}
