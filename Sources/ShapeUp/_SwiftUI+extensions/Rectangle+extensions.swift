//
//  Rectangle+extensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-09.
//

import SwiftUI

public extension Rectangle {
    /// Creates a CornerRectangle applying the provided style to specified corners.
    /// - Parameters:
    ///   - style: Style to apply to specified shape corners.
    ///   - shapeCorners: Shape corners on which to apply the specified style. Missing values will keep current style.
    /// - Returns: A copy of this shape changing the style of specified corners to the provided style.
    func applyingStyle(_ style: CornerStyle, shapeCorners: Set<CornerRectangle.ShapeCorner> = Set(CornerRectangle.ShapeCorner.allCases)) -> CornerRectangle {
        CornerRectangle()
            .applyingStyle(style, shapeCorners: shapeCorners)
    }
    
    /// Creates a CornerRectangle applying the styles of specified corners.
    /// - Parameters:
    ///   - styles: Styles to apply to each specified shape corner. Nil or missing values will keep current style.
    /// - Returns: A copy of this shape changing the styles of specified corners.
    func applyingStyles(_ styles: [CornerRectangle.ShapeCorner: CornerStyle?]) -> CornerRectangle {
        CornerRectangle()
            .applyingStyles(styles)
    }
}
