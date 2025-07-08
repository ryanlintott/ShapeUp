//
//  CornerExampleShapeView.swift
//  ShapeUpExample
//
//  Created by Ryan Lintott on 2025-06-12.
//

import ShapeUp
import SwiftUI

#if swift(>=6.2)
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
    
    static var allCases: [ShapeStyle] {
        if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *) {
            [.regular, .glass]
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
                .applyingStyle(adjustedStyle)
        case .triangle:
            CornerTriangle()
                .applyingStyle(adjustedStyle)
        case .pentagon:
            CornerPentagon(pointHeight: .relative(0.3), bottomTaper: .relative(0.2))
                .applyingStyle(adjustedStyle)
        case .custom:
            CustomCornerShapeExample(style: adjustedStyle)
        }
    }
    
    #if swift(>=6.2)
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
    var glass: Glass {
        .regular.tint(.accentColor).interactive()
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
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *),
               shapeStyle == .glass {
                #if swift(>=6.2)
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
                #else
                solidShape
                    .padding()
                #endif
            } else {
                solidShape
                    .padding()
            }
        }
        .accentColor(.suPink)
    }
}

#Preview {
    CornerExampleShapeView(shape: .rectangle, adjustedStyle: .rounded(15), inset: 0, shapeStyle: .regular)
}
