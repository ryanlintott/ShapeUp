//
//  RelativeCornerShape.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-05-26.
//

import SwiftUI

/// An animatable corner shape defined by relative corners.
public struct RelativeCornerCustom: CornerShape {
    public var closed: Bool = true
    public var insetAmount: CGFloat = 0
    
    /// The array of relative corners that define this shape.
    public var relativeCorners: [RelativeCorner]
    
    public typealias AnimatableData =
    AnimatablePair<
        CGFloat,
        AnimatableArray<RelativeCorner.AnimatableData>
    >
    
    public var animatableData: AnimatableData {
        get {
            .init(
                insetAmount,
                relativeCorners.elementAnimatableData
            )
        }
        set {
            insetAmount = newValue.first
            relativeCorners.elementAnimatableData = newValue.second
        }
    }
    
    /// Creates a closed relative corner shape from variadic relative corners.
    ///
    /// - Note: To create an open corner shape add `.closed(false)`
    /// - Parameter relativeCorners: An array of relative corners that define the shape.
    public init(_ relativeCorners: [RelativeCorner]) {
        self.relativeCorners = relativeCorners
    }
    
    /// Creates a closed relative corner shape from variadic relative corners.
    ///
    /// - Note: To create an open corner shape add `.closed(false)`
    /// - Parameter relativeCorners: The relative corners that define the shape.
    public init(_ relativeCorners: RelativeCorner...) {
        self.relativeCorners = relativeCorners
    }
    
    /// Creates a closed relative corner shape using a result builder.
    ///
    /// - Note: To create an open corner shape add `.closed(false)`.
    /// - Parameter relativeCorners: A closure that builds the relative corners defining the shape.
    public init(@RelativeCornerArrayBuilder _ relativeCorners: () -> [RelativeCorner]) {
        self.relativeCorners = relativeCorners()
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        relativeCorners.corners(in: rect)
    }
}

public extension RelativeCornerCustom {
    /// Creates a copy of this shape with the specified closed state.
    /// - Parameter isClosed: Whether the returned shape should be closed.
    /// - Returns: A copy of this shape with the specified closed state.
    func closed(_ isClosed: Bool) -> Self {
        if closed == isClosed { return self }
        var copy = self
        copy.closed = isClosed
        return copy
    }
    
    internal func transformRelativeCorners(_ transform: ([RelativeCorner]) -> [RelativeCorner]) -> Self {
        var copy = self
        copy.relativeCorners = transform(relativeCorners)
        return copy
    }
}

extension RelativeCornerCustom: CornerStylable {
    public func cornerStyle(_ newStyle: CornerStyle) -> Self {
        transformRelativeCorners {
            $0.cornerStyle(newStyle)
        }
    }
    
    public func changingRadius(to newRadius: RelatableValue) -> Self {
        transformRelativeCorners {
            $0.changingRadius(to: newRadius)
        }
    }
}

@available(iOS 17, tvOS 17, macOS 14, watchOS 10, *)
#Preview {
    @Previewable @State var bottomOffset = 0.2
    
    VStack {
        RelativeCornerCustom {
            RelativeCorner.topLeft
                .moved(dx: 10)
                .rounded(radius: 20)
                
            RelativeCorner.right
            
            RelativeCorner(x: 0.7, y: 1.0)
                .cutout(radius: .relative(0.4))
        }
        
        RelativeCornerCustom(.topLeft, .topRight, .relative(x: bottomOffset, y: 1.0))
            .cornerStyle(.rounded(radius: .relative(0.2)))
        
        RelativeCornerCustom {
            RelativeCorners {
                RelativeCorner.topLeft
                    .concave(radius: .relative(0.2))
                
                RelativeCorner.topRight
                    .rounded(radius: .relative(0.3))
                
                RelativeCorner(x: bottomOffset, y: 1.0)
                    .straight(radius: 20)
            }
            .moved(dx: 0.1)
            .flippedVertically(across: 0.5)
        }
        
        Slider(value: $bottomOffset, in: 0...1)
            .padding()
    }
}
