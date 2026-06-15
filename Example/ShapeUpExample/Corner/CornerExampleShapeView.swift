//
//  CornerExampleShapeView.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2025-06-12.
//

import ShapeUp
import SwiftUI

#if swift(>=6.2) && !os(visionOS)
@available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
extension Shape {
    func glass(_ style: Glass = .regular) -> some View {
        Color.clear.glassEffect(style, in: self)
    }
}
#endif

enum ShapeStyle: String, CaseIterable, Identifiable {
    case regular
    
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
    case glass
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
    case clearGlass
    
    static var allCases: [ShapeStyle] {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *) {
            [.regular, .glass, .clearGlass]
        } else {
            [.regular]
        }
    }
    
    var id: Self { self }
}

struct CornerExampleShapeView: View {
    let shape: CornerExample.ExampleShape
    let adjustedStyle: CornerStyle
    let inset: CGFloat
    let shapeStyle: ShapeStyle
    
    var baseShape: any InsettableShape {
        switch shape {
        case .rectangle:
            CornerRectangle()
                .cornerStyle(adjustedStyle)
        case .triangle:
            CornerTriangle()
                .cornerStyle(adjustedStyle)
        case .pentagon:
            CornerPentagon(pointHeight: .relative(0.3), bottomTaper: .relative(0.2))
                .cornerStyle(adjustedStyle)
        case .custom:
            CustomCornerShapeExample(style: adjustedStyle)
        }
    }
    
    #if swift(>=6.2) && !os(visionOS)
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
    var glass: Glass {
        switch shapeStyle {
        case .regular, .glass:
                .regular.tint(.accentColor).interactive()

        case .clearGlass:
                .clear.tint(.accentColor).interactive()
        }
    }
    
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
    @ViewBuilder
    var glassShape: some View {
        AnyShape(baseShape.inset(by: inset))
            .glass(glass)
    }
    #endif
    
    @ViewBuilder
    var solidShape: some View {
        AnyView(baseShape.inset(by: inset))
            .foregroundColor(.accentColor)
        
        AnyView(baseShape.stroke())
    }
    
    var body: some View {
        ZStack {
            #if swift(>=6.2) && !os(visionOS)
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *),
               shapeStyle != .regular {
                ZStack {
                    VStack {
                        ForEach(0...2, id: \.self) { _ in
                            Image(.shapeUpLogo)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    glassShape
                        .accentColor(.suPink.opacity(0.1))
                        .padding()
                }
            } else {
                solidShape
                    .padding()
            }
            #else
            solidShape
                .padding()
            #endif
        }
        .accentColor(.suPink)
    }
}

#Preview {
    CornerExampleShapeView(shape: .rectangle, adjustedStyle: .rounded(radius: 15), inset: 0, shapeStyle: .regular)
}
