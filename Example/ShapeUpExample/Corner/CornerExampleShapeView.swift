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

struct CornerExampleShapeView: View {
    let shape: CornerExample.ExampleShape
    let adjustedStyle: CornerStyle
    let inset: CGFloat
    
    #if swift(>=6.2)
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
    var glass: Glass {
        .regular.tint(.accentColor).interactive()
    }
    
    @available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *)
    @ViewBuilder
    var glassShape: some View {
        switch shape {
        case .rectangle:
            CornerRectangle()
                .applyingStyle(adjustedStyle)
                .inset(by: inset)
                .glass(glass)
        case .triangle:
            CornerTriangle()
                .applyingStyle(adjustedStyle)
                .inset(by: inset)
                .glass(glass)
        case .pentagon:
            CornerPentagon(pointHeight: .relative(0.3), bottomTaper: .relative(0.2))
                .applyingStyle(adjustedStyle)
                .inset(by: inset)
                .glass(glass)
        case .custom:
            CustomCornerShapeExample(style: adjustedStyle)
                .inset(by: inset)
                .glass(glass)
        }
    }
    #endif
    
    @ViewBuilder
    var solidShape: some View {
        switch shape {
        case .rectangle:
            CornerRectangle()
                .applyingStyle(adjustedStyle)
                .inset(by: inset)
                .foregroundColor(.accentColor)
            
            CornerRectangle()
                .applyingStyle(adjustedStyle)
                .stroke()
        case .triangle:
            CornerTriangle()
                .applyingStyle(adjustedStyle)
                .inset(by: inset)
                .foregroundColor(.accentColor)
            
            CornerTriangle()
                .applyingStyle(adjustedStyle)
                .stroke()
        case .pentagon:
            CornerPentagon(pointHeight: .relative(0.3), bottomTaper: .relative(0.2))
                .applyingStyle(adjustedStyle)
                .inset(by: inset)
                .foregroundColor(.accentColor)
            
            CornerPentagon(pointHeight: .relative(0.3), bottomTaper: .relative(0.2))
                .applyingStyle(adjustedStyle)
                .stroke()
        case .custom:
            CustomCornerShapeExample(style: adjustedStyle)
                .inset(by: inset)
                .foregroundColor(.accentColor)
            
            CustomCornerShapeExample(style: adjustedStyle)
                .stroke()
        }
    }
    
    var body: some View {
        ZStack {
            if #available(iOS 26, macOS 26, tvOS 26, watchOS 26, visionOS 26, *) {
                #if swift(>=6.2)
                glassShape
                #else
                solidShape
                #endif
            } else {
                solidShape
            }
        }
    }
}

#Preview {
    CornerExampleShapeView(shape: .rectangle, adjustedStyle: .rounded(15), inset: 0)
}
