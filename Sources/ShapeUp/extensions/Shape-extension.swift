//
//  Shape-extension.swift
//  FullscreenZoom
//
//  Created by Ryan Lintott on 2021-01-11.
//

import SwiftUI

extension Shape {
    func scaleToFit(_ frame: CGSize, aspectRatio: CGFloat) -> some Shape {
        self
            .scale(x: aspectRatio > frame.aspectRatio ? 1 : frame.aspectRatio * aspectRatio, y: aspectRatio > frame.aspectRatio ? frame.aspectRatio / aspectRatio : 1, anchor: .center)
    }
}
