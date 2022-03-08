//
//  InsettableShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-16.
//

import SwiftUI

public extension InsettableShape {
    /// Returns a view with embossed edges that matches the parent shape.
    ///
    /// Using a light angle between 180 and 360 degrees will likely look debossed.
    /// - Parameters:
    ///   - size: Size of the embossed effect.
    ///   - angle: Light angle. Default is 45 degrees (down and to the right).
    ///   - opacity: Opacity of the embossed effect.
    ///   - backgroundColor: Color of the base shape. Default is clear.
    /// - Returns: A view with an embossed effect.
    func embossEdges(size: CGFloat, angle: Angle? = nil, opacity: Double? = nil, backgroundColor: Color = .clear) -> some View {
        let opacity = opacity ?? 1.0
        let angle = angle ?? .degrees(45)
        let offsetX = size * 1.5 * CGFloat(cos(angle.radians))
        let offsetY = size * 1.5 * CGFloat(sin(angle.radians))
        
        // Using Color.clear will not render shadows
        let almostClearBlack = Color.black.opacity(0.000001)
        let almostClearWhite = Color.white.opacity(0.000001)
        
        var inset: CGFloat {
            -max(1, size * 1.5)
        }
        
        var lineWidth: CGFloat {
            max(1, size)
        }
        
        return self
            .fill(backgroundColor)
            .overlay(
                ZStack {
                    self
                        .inset(by: inset)
                        .strokeBorder(almostClearBlack, lineWidth: lineWidth)
                        .shadow(color: Color.black.opacity(opacity), radius: size, x: -offsetX, y: -offsetY)

                    self
                        .inset(by: inset)
                        .strokeBorder(almostClearWhite, lineWidth: lineWidth)
                        .shadow(color: Color.white.opacity(opacity), radius: size, x: offsetX, y: offsetY)
                }
                .clipShape(self)
                .blendMode(.overlay)
            )
    }
    
    /// Returns a view with debossed edges that matches the parent shape.
    ///
    /// Deboss is simply an emboss effect with the light turned 180 degrees. Using a light angle between 180 and 360 degrees will likely look embossed.
    /// - Parameters:
    ///   - size: Size of the debossed effect.
    ///   - angle: Light angle. Default is 45 degrees (down and to the right).
    ///   - opacity: Opacity of the debossed effect.
    ///   - backgroundColor: Color of the base shape. Default is clear.
    /// - Returns: A view with a debossed effect.
    func debossEdges(size: CGFloat, angle: Angle? = nil, opacity: Double? = nil, backgroundColor: Color = .clear) -> some View {
        embossEdges(size: size, angle: (angle ?? .degrees(45)) + .degrees(180), opacity: opacity, backgroundColor: backgroundColor)
    }
}
