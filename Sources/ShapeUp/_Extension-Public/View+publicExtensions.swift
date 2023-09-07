//
//  View+publicExtensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-16.
//

import SwiftUI

public extension View {
    /// Returns the same view with an overlayed embossed effect using edges of a supplied shape.
    ///
    /// This works best when the view itself has the same clip shape applied.
    ///
    /// Using a light angle between 180 and 360 degrees will likely look debossed.
    /// - Parameters:
    ///   - shape: Shape edges will be used for embossed effect.
    ///   - size: Size of the embossed effect.
    ///   - angle: Light angle. Default is 45 degrees (down and to the right).
    ///   - opacity: Opacity of the embossed effect.
    /// - Returns: The same view with an overlayed embossed effect using edges of a supplied shape.
    func emboss<S>(using shape: S, size: CGFloat, angle: Angle? = nil, opacity: Double? = nil) -> some View where S : InsettableShape {
        self
            .overlay(
                shape
                    .embossEdges(size: size, angle: angle, opacity: opacity)
                    .allowsHitTesting(false)
            )
    }
    
    /// Returns the same view with an overlayed debossed effect using edges of a supplied shape.
    ///
    /// This works best when the view itself has the same clip shape applied.
    ///
    /// Deboss is simply an emboss effect with the light turned 180 degrees. Using a light angle between 180 and 360 degrees will likely look embossed.
    /// - Parameters:
    ///   - shape: Shape edges will be used for debossed effect.
    ///   - size: Size of the debossed effect.
    ///   - angle: Light angle. Default is 45 degrees (down and to the right).
    ///   - opacity: Opacity of the debossed effect.
    /// - Returns: The same view with an overlayed debossed effect using edges of a supplied shape.
    func deboss<S>(using shape: S, size: CGFloat, angle: Angle? = nil, opacity: Double? = nil) -> some View where S : InsettableShape {
        self
            .overlay(
                shape
                    .debossEdges(size: size, angle: angle, opacity: opacity)
                    .allowsHitTesting(false)
            )
    }
    
    /// Returns the same view with an overlayed embossed effect.
    ///
    /// Embossed effect is created by offsetting the view instead of insetting. Thin parts of a view may look strage with larger amount values.
    /// - Parameters:
    ///   - baseColor: Base colour applied to the whole view. Default is clear.
    ///   - amount: Amount of offset used in embossed effect.
    ///   - blur: Amount of blur used in embossed effect.
    ///   - angle: Light angle. Default is 45 degrees (down and to the right).
    ///   - opacity: Opacity of the embossed effect.
    /// - Returns: The same view with an overlayed embossed effect.
    func emboss(baseColor: Color? = nil, amount: CGFloat, blur: CGFloat? = nil, angle: Angle? = nil, opacity: Double? = nil) -> some View {
        self.modifier(EmbossViewModifier(baseColor: baseColor, amount: amount, blur: blur, angle: angle, opacity: opacity))
    }
    
    /// Returns the same view with an overlayed debossed effect.
    ///
    /// Debossed effect is created by offsetting the view instead of insetting. Thin parts of a view may look strage with larger amount values.
    /// - Parameters:
    ///   - baseColor: Base colour applied to the whole view. Default is clear.
    ///   - amount: Amount of offset used in debossed effect.
    ///   - blur: Amount of blur used in debossed effect.
    ///   - angle: Light angle. Default is 45 degrees (down and to the right).
    ///   - opacity: Opacity of the debossed effect.
    /// - Returns: The same view with an overlayed debossed effect.
    func deboss(baseColor: Color? = nil, amount: CGFloat, blur: CGFloat? = nil, angle: Angle? = nil, opacity: Double? = nil) -> some View {
        self.modifier(EmbossViewModifier(baseColor: baseColor, amount: amount, blur: blur, angle: angle, opacity: opacity, deboss: true))
    }
}
