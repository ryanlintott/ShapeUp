//
//  EmbossViewModifier.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-19.
//

import SwiftUI

extension InsettableShape {
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

extension View {
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

struct EmbossViewModifier_Previews: PreviewProvider {
    static let color: Color = .blue
    static let size: CGFloat = 4
    static let angle: Angle = .degrees(45)
    static let opacity: Double = 1
    
    static var previews: some View {
        VStack(spacing: 40) {
            Circle()
                .fill(color)
                .emboss(using: Circle(), size: size, angle: angle, opacity: opacity)
            
            Image(systemName: "heart")
                .resizable()
                .scaledToFit()
                .deboss(baseColor: .red, amount: 3, blur: 2, angle: angle, opacity: 0.8)
            
            Text("Hello World")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.blue)
                .emboss(amount: 1, angle: angle + .degrees(180), opacity: 0.8)
                

            CSPentagon(pointHeight: .absolute(4), topTaper: .relative(0.5), bottomTaper: .relative(0.2))
                .embossEdges(size: size, angle: angle + .degrees(180), opacity: opacity)
        }
        .padding(50)
        .background(Color.gray)
    }
}
