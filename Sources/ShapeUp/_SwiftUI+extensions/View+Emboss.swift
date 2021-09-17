//
//  SwiftUIView.swift
//  
//
//  Created by Ryan Lintott on 2021-09-16.
//

import SwiftUI

public extension View {
    func emboss<S>(using shape: S, size: CGFloat, angle: Angle? = nil, opacity: Double? = nil) -> some View where S : InsettableShape {
        self
            .overlay(
                shape
                    .embossEdges(size: size, angle: angle, opacity: opacity)
            )
    }
    
    func deboss<S>(using shape: S, size: CGFloat, angle: Angle? = nil, opacity: Double? = nil) -> some View where S : InsettableShape {
        self
            .overlay(
                shape
                    .embossEdges(size: size, angle: (angle ?? .degrees(45)) + .degrees(180), opacity: opacity)
            )
    }
    
    func emboss(baseColor: Color? = nil, amount: CGFloat, blur: CGFloat? = nil, angle: Angle? = nil, opacity: Double? = nil) -> some View {
        self.modifier(embossViewModifier(baseColor: baseColor, amount: amount, blur: blur, angle: angle, opacity: opacity))
    }
    
    func deboss(baseColor: Color? = nil, amount: CGFloat, blur: CGFloat? = nil, angle: Angle? = nil, opacity: Double? = nil) -> some View {
        self.modifier(embossViewModifier(baseColor: baseColor, amount: amount, blur: blur, angle: (angle ?? .degrees(45)) + .degrees(180), opacity: opacity))
    }
}
