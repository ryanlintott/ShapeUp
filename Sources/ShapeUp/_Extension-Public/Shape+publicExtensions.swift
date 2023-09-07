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
    func scaleToFit(_ frame: CGSize, aspectRatio: CGFloat) -> some Shape {
        let frameRatio = frame.width / frame.height
        
        return self
            .scale(x: aspectRatio > frameRatio ? 1 : frameRatio * aspectRatio, y: aspectRatio > frameRatio ? frameRatio / aspectRatio : 1, anchor: .center)
    }
}
