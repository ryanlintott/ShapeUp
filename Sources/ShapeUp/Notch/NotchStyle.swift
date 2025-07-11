//
//  NotchStyle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

/// The style of a notch defined by relative corners.
public struct NotchStyle: Hashable, Codable, Sendable {
    /// Relative corners that define the notch shape.
    public var relativeCorners: [RelativeCorner]
    
    /// Creates a notch style with the specified relative corners.
    /// - Parameter relativeCorners: Relative corners that define the notch shape.
    public init(relativeCorners: [RelativeCorner]) {
        self.relativeCorners = relativeCorners
    }
}

public extension NotchStyle {
    /// Creates a notch style with the specified anchor points and corner styles.
    /// - Parameters:
    ///   - anchorPoints: Anchor points that define the positions of the corners.
    ///   - cornerStyles: Corner styles for each corner. Nil values will use a .point style.
    init(anchorPoints: [RectAnchor], cornerStyles: [CornerStyle?]) {
        self.relativeCorners = anchorPoints.enumerated().map { index, anchor in
            let style = cornerStyles.indices.contains(index) ? (cornerStyles[index] ?? .point) : .point
            return RelativeCorner(anchor, style)
        }
    }
    
    /// Creates a notch style with the specified anchor points and a single corner style applied to all corners.
    /// - Parameters:
    ///   - anchorPoints: Anchor points that define the positions of the corners.
    ///   - cornerStyle: Corner style to apply to all corners. Default is nil which renders as .point.
    init(anchorPoints: [RectAnchor], cornerStyle: CornerStyle? = nil) {
        self.relativeCorners = anchorPoints.relativeCorners(cornerStyle)
    }
    
    /// Creates corners for the notch in the specified rectangle.
    /// - Parameter rect: The rectangle in which to create the corners.
    /// - Returns: An array of corners positioned within the rectangle.
    func corners(in rect: CGRect) -> [Corner] {
        relativeCorners.corners(in: rect)
    }
}
