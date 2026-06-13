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
    ///   - cornerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
    case triangle(cornerStyles: [CornerStyle?])
    
    /// A rectangular shaped notch.
    /// - Parameters:
    ///   - cornerStyles: Corner styles for each corner in the notch. Nil values will use a .point style.
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
                [RelativeCorner.topLeft, .bottom, .topRight]
                    .cornerStyles(cornerStyles)
                
            case let .rectangle(cornerStyles):
                [RelativeCorner.topLeft, .bottomLeft, .bottomRight, .topRight]
                    .cornerStyles(cornerStyles)
                
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

extension NotchStyle: CornerStylable {
    /// Sets the corner style of all notch corners.
    /// - Parameter newStyle: A style applied to all notch corners.
    /// - Returns: A notch where all corners match the new style.
    public func cornerStyle(_ newStyle: CornerStyle) -> NotchStyle {
        switch self {
        case .triangle: .triangle(cornerStyle: newStyle)
        case .rectangle: .rectangle(cornerStyle: newStyle)
        case .custom: .custom(relativeCorners: relativeCorners.cornerStyle(newStyle))
        }
    }
    
    public func changingRadius(to newRadius: RelatableValue) -> NotchStyle {
        cornerStyles(cornerStyles.map { $0?.changingRadius(to: newRadius) })
    }
    
    /// Updates the corner styles of all notch corners.
    /// - Parameter newStyles: An array of styles that will be applied to each corner respectively. Nil values will keep current style.
    /// - Returns: A notch style with updated corner styles.
    public func cornerStyles(_ newStyles: [CornerStyle?]) -> NotchStyle {
        let newRelativeCorners = relativeCorners.cornerStyles(newStyles)
        
        switch self {
        case .triangle: return .triangle(cornerStyles: newRelativeCorners.cornerStyles)
        case .rectangle: return .rectangle(cornerStyles: newRelativeCorners.cornerStyles)
        case .custom: return .custom(relativeCorners: newRelativeCorners)
        }
    }
}
