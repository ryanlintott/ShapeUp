//
//  NotchStyle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

/// An enumeration to indicate the style of a notch.
public enum NotchStyle {
    /// A triangular shaped notch.
    /// - Parameters:
    ///   - conerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
    case triangle(cornerStyles: [CornerStyle?])
    
    /// A rectangular shaped notch.
    /// - Parameters:
    ///   - conerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
    case rectangle(cornerStyles: [CornerStyle?])
    
    /// A custom shaped notch defined by corners in a reference frame equal to the notch's length and depth.
    /// - Parameters:
    ///   - coners: A closure used to create corners in a rectangle defined by the length and depth of the notch. Start and end points are at the top left and top right of the rectangle and do not need to be included.
    case custom(corners: @Sendable (_ in: CGRect) -> [Corner])
}

public extension NotchStyle {
    /// Corner styles for all corners of the notch.
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
    
    func corners(in rect: CGRect) -> [Corner] {
        switch self {
        case .triangle(let cornerStyles):
            return rect.points(
                .topLeft,
                .bottom,
                .topRight
            ).corners(cornerStyles)
        case .rectangle(let cornerStyles):
            return rect.points(
                .topLeft,
                .bottomLeft,
                .bottomRight,
                .topRight
            ).corners(cornerStyles)
        case .custom(let corners):
            return corners(rect)
        }
    }
}
