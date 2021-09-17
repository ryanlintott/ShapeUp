//
//  EmbossViewModifier.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-19.
//

import SwiftUI

struct embossViewModifier: ViewModifier {
    let baseColor: Color?
    let blur: CGFloat
    let opacity: Double
    let offsetX: CGFloat
    let offsetY: CGFloat
    
    init(baseColor: Color? = nil, amount: CGFloat, blur: CGFloat? = nil, angle: Angle? = nil, opacity: Double? = nil) {
        self.baseColor = baseColor
        self.blur = blur ?? amount
        self.opacity = opacity ?? 1.0
        let angle = angle ?? .degrees(45)
        self.offsetX = amount * 1.5 * CGFloat(cos(angle.radians))
        self.offsetY = amount * 1.5 * CGFloat(sin(angle.radians))
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(baseColor == nil ? 1 : 0)
            .overlay(
                ZStack {
                    if let baseColor = baseColor {
                        baseColor
                    }
                    
                    Color.white
                        .mask(
                            Color.white
                                .overlay(
                                    Color.black
                                        .mask(
                                            content
                                                .offset(x: offsetX, y: offsetY)
                                        )
                                )
                                .blur(radius: blur)
                                .drawingGroup()
                                .luminanceToAlpha()
                        )
                        .opacity(opacity)
                    
                    Color.black
                        .mask(
                            Color.white
                                .overlay(
                                    Color.black
                                        .mask(
                                            content
                                                .offset(x: -offsetX, y: -offsetY)
                                        )
                                )
                                .blur(radius: blur)
                                .drawingGroup()
                                .luminanceToAlpha()
                        )
                        .opacity(opacity)
                }
            )
            .mask(content)
    }
}


