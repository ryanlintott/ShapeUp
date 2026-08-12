//
//  Shape+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-11.
//

import SwiftUI

public extension Shape {
    /// Scales a shape to fit a specified aspect ratio inside a specified frame.
    /// - Parameters:
    ///   - frame: Frame to fit.
    ///   - aspectRatio: Aspect ratio of the shape.
    /// - Returns: A shape scaled to fit a specified aspect ratio inside a specified frame.
    /// - Deprecated: Use SwiftUI's `aspectRatio(_:contentMode:)` modifier with
    ///   `.fit` instead. This method will be removed in ShapeUp 1.0.0.
    @available(
        *,
        deprecated,
        message: "This was a very old method I haven't used in a long time. If you need this functionality use SwiftUI Shape's scale modifier and check the code for this method. This will be removed in the next major version."
    )
    func scaleToFit(_ frame: CGSize, aspectRatio: CGFloat) -> some Shape {
        let frameRatio = frame.width / frame.height
        
        return self
            .scale(
                x: aspectRatio > frameRatio ? 1 : aspectRatio / frameRatio,
                y: aspectRatio > frameRatio ? frameRatio / aspectRatio : 1,
                anchor: .center
            )
    }
}
