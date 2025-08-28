//
//  CornerCustom.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

/**
A custom open or closed insettable shape built out of corners, aligned inside the frame of the view containing it.

This shape can either be used in a SwiftUI View like any other `InsettableShape`

    CornerCustom { rect in
        [
            Corner(x: rect.midX, y: rect.minY),
            Corner(.rounded(radius: 5), x: rect.maxX, y: rect.maxY),
            Corner(.rounded(radius: 5), x: rect.minX, y: rect.maxY)
        ]
    }
    .fill()
 
    CornerCustom { rect in
        rect
            .points(.top, .bottomRight, .left)
            .corners(.rounded(radius: .relative(0.1)))
    }
    .strokeBorder(lineWidth: 10)
*/
public struct CornerCustom: CornerShape {
    public var closed: Bool
    public var insetAmount: CGFloat = 0
    
    public var animatableData: CGFloat {
        get { insetAmount }
        set { insetAmount = newValue }
    }
    
    internal var corners: @Sendable (CGRect) -> [Corner]
    
    /// Creates a custom insettable shape out of corners.
    /// - Parameters:
    ///  - closed: A boolean determining if the shape should be closed. Default is true.
    ///  - corners: Closure used to draw corners in a defined frame.
    public init(closed: Bool = true, @CornerArrayBuilder _ corners: @Sendable @escaping (CGRect) -> [Corner]) {
        self.closed = closed
        self.corners = corners
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        corners(rect)
    }
}

extension CornerCustom: CornerStylable {
    public func applyingStyle(_ newStyle: CornerStyle) -> Self {
        transformCorners { rect, corners in
            corners.applyingStyle(newStyle)
        }
    }
    
    public func changingRadius(to newRadius: RelatableValue) -> Self {
        transformCorners { rect, corners in
            corners.changingRadius(to: newRadius)
        }
    }
}

public extension CornerCustom {
    func closed(_ isClosed: Bool) -> Self {
        var copy = self
        copy.closed = isClosed
        return copy
    }
    
    internal func transformCorners(_ transform: @Sendable @escaping (CGRect, [Corner]) -> [Corner]) -> Self {
        var copy = self
        copy.corners = { rect in
            transform(rect, corners(rect))
        }
        return copy
    }
    
    public func applyingStyles(_ newStyles: [CornerStyle]) -> Self {
        transformCorners { rect, corners in
            corners.applyingStyles(newStyles)
        }
    }
}

@available(iOS 17, tvOS 17, macOS 14, watchOS 10, *)
#Preview {
    @Previewable @State var bottomOffset = 0.2
    
    VStack {
        CornerCustom { rect in
            Corner(x: rect.minX, y: rect.minY)
            Corner(x: rect.maxX, y: rect.minY)
            Corner(x: rect.minX + rect.width * bottomOffset, y: rect.maxY)
        }
        .applyingStyle(.rounded(radius: .relative(0.2)))
        
        CornerCustom { rect in
            rect[.topLeft]
            rect[.topRight]
            rect[bottomOffset, 1.0]
        }
        .applyingStyle(.rounded(radius: .relative(0.2)))
        
        Slider(value: $bottomOffset, in: 0...1)
            .padding()
    }
}
