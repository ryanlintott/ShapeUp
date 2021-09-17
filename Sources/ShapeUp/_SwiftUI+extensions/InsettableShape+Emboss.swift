//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2021-09-16.
//

import SwiftUI

public extension InsettableShape {
    func embossEdges(size: CGFloat, angle: Angle? = nil, opacity: Double? = nil) -> some View {
        let opacity = opacity ?? 1.0
        let angle = angle ?? .degrees(45)
        let offsetX = size * 1.5 * CGFloat(cos(angle.radians))
        let offsetY = size * 1.5 * CGFloat(sin(angle.radians))
        
        // Using Color.clear will not render shadows
        let almostClearBlack = Color.black.opacity(0.000001)
        let almostClearWhite = Color.white.opacity(0.000001)
        
        return self
            .fill(Color.clear)
            .overlay(
                ZStack {
                    self
                        .inset(by: -max(1, size * 1.5))
                        .strokeBorder(almostClearBlack, lineWidth: max(1, size))
                        .shadow(color: Color.black.opacity(opacity), radius: size, x: -offsetX, y: -offsetY)

                    self
                        .inset(by: -max(1, size * 1.5))
                        .strokeBorder(almostClearWhite, lineWidth: max(1, size))
                        .shadow(color: Color.white.opacity(opacity), radius: size, x: offsetX, y: offsetY)
                }
                .clipShape(self)
                .blendMode(.overlay)
            )
    }
    
    func debossEdges(size: CGFloat, angle: Angle? = nil, opacity: Double? = nil) -> some View {
        embossEdges(size: size, angle: (angle ?? .degrees(45)) + .degrees(180), opacity: opacity)
    }
}
