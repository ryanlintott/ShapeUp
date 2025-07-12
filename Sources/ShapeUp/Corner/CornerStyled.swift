//
//  CornerStyled.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-23.
//

import Foundation

public protocol CornerStyled {
    var style: CornerStyle { get set }
    func applyingStyle(_ newStyle: CornerStyle) -> Self
}

public extension CornerStyled {
    /// Radius of corner based on the style.
    var radius: RelatableValue {
        get {
            style.radius
        }
        set {
            style.radius = newValue
        }
    }
    
    /// Creates a corner with the same style at the same position but with a new supplied radius.
    /// - Parameter newRadius: Radius to apply to the corner.
    /// - Returns: A corner with the same style at the same position but with a new supplied radius.
    func changingRadius(to newRadius: RelatableValue) -> Self {
        if style.radius == newRadius { return self }
        return applyingStyle(style.changingRadius(to: newRadius))
    }
    
    // MARK: - Applying styles
    
    /// Applies a rounded corner style to this corner.
    /// - Parameter radius: Radius of the rounded corner.
    /// - Returns: A corner with a rounded style applied.
    func rounded(radius: RelatableValue) -> Self {
        applyingStyle(.rounded(radius: radius))
    }
    
    /// Applies a concave corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the concave corner.
    ///   - radiusOffset: Offset for the radius. Default is 0.
    /// - Returns: A corner with a concave style applied.
    func concave(radius: RelatableValue, radiusOffset: CGFloat = 0) -> Self {
        applyingStyle(.concave(radius: radius, radiusOffset: radiusOffset))
    }
    
    /// Applies a straight chamfer corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the straight corner.
    ///   - cornerStyles: Corner styles for the two resulting corners of the chamfer.
    /// - Returns: A corner with a straight style applied.
    func straight(radius: RelatableValue, cornerStyles: [CornerStyle] = []) -> Self {
        applyingStyle(.straight(radius: radius, cornerStyles: cornerStyles))
    }
    
    /// Applies a straight chamfer corner style to this corner with a single nested style.
    /// - Parameters:
    ///   - radius: Radius of the straight corner.
    ///   - cornerStyle: Corner style for the two resulting corners of the chamfer.
    /// - Returns: A corner with a straight style applied.
    func straight(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        applyingStyle(.straight(radius: radius, cornerStyle: cornerStyle))
    }
    
    /// Applies a cutout corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the cutout corner.
    ///   - cornerStyles: Corner styles for the three resulting corners of the cutout.
    /// - Returns: A corner with a cutout style applied.
    func cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = []) -> Self {
        applyingStyle(.cutout(radius: radius, cornerStyles: cornerStyles))
    }
    
    /// Applies a cutout corner style to this corner with a single nested style.
    /// - Parameters:
    ///   - radius: Radius of the cutout corner.
    ///   - cornerStyle: Corner style for the three resulting corners of the cutout.
    /// - Returns: A corner with a cutout style applied.
    func cutout(radius: RelatableValue, cornerStyle: CornerStyle) -> Self {
        applyingStyle(.cutout(radius: radius, cornerStyle: cornerStyle))
    }
    
    /// Applies a custom corner style to this corner.
    /// - Parameters:
    ///   - radius: Radius of the custom corner.
    ///   - relativeCorners: Relative corners that define the corner shape.
    /// - Returns: A corner with a custom style applied.
    func custom(radius: RelatableValue, relativeCorners: [RelativeCorner]) -> Self {
        applyingStyle(.custom(radius: radius, relativeCorners: relativeCorners))
    }
}

public extension Array where Element: CornerStyled {
    /// Array of corner styles used on each corner respectively.
    var cornerStyles: [CornerStyle] {
        get {
            map(\.style)
        }
        set {
            self = self
                .applyingStyle(.point)
                .applyingStyles(newValue)
        }
    }
    
    /// Applies new styles to this array of corners.
    /// - Parameter styles: An array of styles that will be applied to each corner respecitvely. Nil values will keep current style.
    mutating func applyStyles(_ newStyles: [CornerStyle?]) {
        self = self.applyingStyles(newStyles)
    }
    
    /// Applies a new style to all corners in the array.
    /// - Parameter newStyle: A style that will be applied to every corner.
    mutating func applyStyle(_ newStyle: CornerStyle) {
        self = self.applyingStyle(newStyle)
    }
}

public extension BidirectionalCollection where Element: CornerStyled, Index == Int {
    /// Creates an array of corners with the same positions and specified styles.
    /// - Parameter newStyles: An array of styles that will be applied to each corner respecitvely. Nil values will keep current style.
    /// - Returns: An array of corners with the same positions and specified styles.
    func applyingStyles(_ newStyles: [CornerStyle?]) -> [Element] {
        /// If newStyles only contains nil values return self
        if newStyles.compactMap(\.self).isEmpty { return Array(self) }
        
        /// Create an array of styles equal in length to the array of corners.
        let newStylesMatchingCount = newStyles + Array<CornerStyle?>(repeating: nil, count: Swift.max(count - newStyles.count, 0))
        
        return zip(self, newStylesMatchingCount)
            .map { corner, newStyle in
                // Apply a style if one is provided, otherwise use the current style.
                corner.applyingStyle(newStyle ?? corner.style)
            }
    }
    
    /// Creates an array of corners with the same positions and a new specified style.
    /// - Parameter newStyle: A style that will be applied to every corner.
    /// - Returns: An array of corners with the same positions and a new specified style.
    func applyingStyle(_ newStyle: CornerStyle) -> [Element] {
        map { $0.applyingStyle(newStyle) }
    }
    
    /// Creates an array of corners with the same positions and a new specified style applied to specified corners.
    /// - Parameters:
    ///   - newStyle: A style that will be applied to specified corners.
    ///   - indices: Indices of the corners with which to apply the new style.
    /// - Returns: An array of corners with the same positions and a new specified style applied to specified corners.
    func applyingStyle(_ newStyle: CornerStyle, corners indices: [Self.Index]) -> [Element] {
        enumerated()
            .map { index, corner in
                indices.contains(index) ? corner.applyingStyle(newStyle) : corner
            }
    }
    
    /// Creates an array of corners with the same positions and a new specified style applied to a specified corner.
    /// - Parameters:
    ///   - newStyle: A style that will be applied to a specified corner.
    ///   - index: Index of the corner with which to apply the new style.
    /// - Returns: An array of corners with the same positions and a new specified style applied to a specified corner.
    func applyingStyle(_ newStyle: CornerStyle, corner index: Self.Index) -> [Element] {
        applyingStyle(newStyle, corners: [index])
    }
}
