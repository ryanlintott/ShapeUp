//
//  NotchStyle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

/// The style of a notch defined by different shape types.
public enum NotchStyle: Sendable {
    /// A triangular shaped notch.
    /// - Parameters:
    ///   - conerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
    case triangle(cornerStyles: [CornerStyle?])
    
    /// A rectangular shaped notch.
    /// - Parameters:
    ///   - conerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
    case rectangle(cornerStyles: [CornerStyle?])
    
    /// A custom shaped notch defined by relative corners.
    /// - Parameter relativeCorners: Relative corners that define the notch shape.
    case custom(relativeCorners: [RelativeCorner])
}

public extension NotchStyle {
    /// Relative corners for all corners of the notch.
    internal(set) var relativeCorners: [RelativeCorner] {
        get {
            switch self {
            case let .triangle(cornerStyles):
                [RectAnchor.topLeft, .bottom, .topRight]
                    .relativeCorners(cornerStyles)
                
            case let .rectangle(cornerStyles):
                [RectAnchor.topLeft, .bottomLeft, .bottomRight, .topRight]
                    .relativeCorners(cornerStyles)
                
            case let .custom(relativeCorners):
                relativeCorners
            }
        }
        set {
            // Setting is only used by animatableData
            switch self {
            case .triangle:
                self = .triangle(cornerStyles: newValue.cornerStyles)
            case .rectangle:
                self = .rectangle(cornerStyles: newValue.cornerStyles)
            case .custom:
                self = .custom(relativeCorners: newValue)
            }
        }
    }
    
    /// Corner styles for all corners of the notch.
    var cornerStyles: [CornerStyle?] {
        relativeCorners.cornerStyles
    }
    
    /// Creates corners for the notch in the specified rectangle.
    /// - Parameter rect: The rectangle in which to create the corners.
    /// - Returns: An array of corners positioned within the rectangle.
    func corners(in rect: CGRect) -> [Corner] {
        relativeCorners.corners(in: rect)
    }
}
