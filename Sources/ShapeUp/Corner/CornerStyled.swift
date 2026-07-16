//
//  CornerStyled.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-23.
//

import Foundation

/// An object that has a single corner style that can be changed
public protocol CornerStyled: CornerStylable {
    /// The corner style applied to this object.
    var style: CornerStyle { get set }
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
    
    func transformCornerStyles(_ transform: @escaping @Sendable (CornerStyle) -> CornerStyle) -> Self {
        var copy = self
        copy.style = transform(style)
        return copy
    }
}

public extension Array where Element: CornerStyled {
    /// Array of corner styles used on each corner respectively.
    ///
    /// When setting this property, corners without a matching style use ``CornerStyle/automatic``.
    var cornerStyles: [CornerStyle] {
        get {
            map(\.style)
        }
        set {
            self = self
                .cornerStyle(.automatic)
                .cornerStyles(newValue)
        }
    }
    
    /// Creates an array of corners with the same positions and specified styles.
    /// - Parameter newStyles: An array of styles that will be applied to each corner respectively. Nil values will keep current style.
    /// - Returns: An array of corners with the same positions and specified styles.
    func cornerStyles(_ newStyles: [CornerStyle?]) -> [Element] {
        /// If newStyles only contains nil values return self
        if newStyles.compactMap(\.self).isEmpty { return Array(self) }
        
        /// Create an array of styles equal in length to the array of corners.
        let newStylesMatchingCount = newStyles + Array<CornerStyle?>(repeating: nil, count: Swift.max(count - newStyles.count, 0))
        
        return zip(self, newStylesMatchingCount)
            .map { corner, newStyle in
                // Apply a style if one is provided, otherwise use the current style.
                corner.cornerStyle(newStyle ?? corner.style)
            }
    }
    
    @available(*, deprecated, renamed: "cornerStyles(_:)")
    func applyingStyles(_ newStyles: [CornerStyle?]) -> [Element] {
        cornerStyles(newStyles)
    }
    
    /// Applies new styles to this array of corners.
    /// - Parameter newStyles: An array of styles that will be applied to each corner respectively. Nil values will keep current style.
    mutating func cornerStyles(_ newStyles: [CornerStyle?]) {
        self = self.cornerStyles(newStyles)
    }
}
