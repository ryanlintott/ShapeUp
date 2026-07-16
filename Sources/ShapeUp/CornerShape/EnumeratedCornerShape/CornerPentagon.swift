//
//  CornerPentagon.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

/**
A pentagon shape pointing upwards with individually stylable corners, aligned inside the frame of the view containing it.

This shape can either be used in a SwiftUI View like any other `InsettableShape`
 
    CornerPentagon(
        pointHeight: .relative(0.3),
        topTaper: .relative(0.1),
        bottomTaper: .relative(0.3),
        styles: [
            .topRight: .concave(radius: 30),
            .bottomLeft: .straight(radius: .relative(0.3))
        ]
    )
    .fill()

The corners can be accessed directly for use in a more complex shape

    public func corners(in rect: CGRect) -> [Corner] {
        CornerPentagon(pointHeight: .relative(0.2), topTaper: .relative(0.15), bottomTaper: .zero)
            .corners(in: rect)
            .inset(by: 10)
            .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
    }
*/
public struct CornerPentagon: EnumeratedCornerShape {
    public let closed = true
    public var insetAmount: CGFloat = 0
    
    /// An enumeration to indicate the corners of a pentagon.
    public enum ShapeCorner: EnumeratedCorner {
        case topLeft
        case top
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    /// The downward distance from the top vertex to the two shoulder vertices.
    ///
    /// Relative values use the full frame height. Values are not clamped.
    public var pointHeight: RelatableValue

    /// The horizontal inset of each shoulder vertex from its adjacent side.
    ///
    /// Relative values use half the frame width, so `0` leaves the vertices at the sides
    /// and `1` moves both vertices to the horizontal center. Values are not clamped.
    public var topTaper: RelatableValue

    /// The horizontal inset of each bottom vertex from its adjacent side.
    ///
    /// Relative values use half the frame width, so `0` leaves the vertices at the sides
    /// and `1` moves both vertices to the horizontal center. Values are not clamped.
    public var bottomTaper: RelatableValue
    
    public var styles: [ShapeCorner: CornerStyle]
    
    /// Creates a pentagon shape with corners that can be styled.
    /// - Parameters:
    ///   - pointHeight: Downward distance from the top vertex to the two shoulder vertices. Relative values use the full frame height and are not clamped.
    ///   - topTaper: Horizontal inset of each shoulder vertex from its adjacent side. Relative values use half the frame width and are not clamped.
    ///   - bottomTaper: Horizontal inset of each bottom vertex from its adjacent side. Relative values use half the frame width and are not clamped.
    ///   - styles: A dictionary of corner styles keyed to ``ShapeCorner``. Missing entries use ``CornerStyle/automatic``.
    public init(pointHeight: RelatableValue, topTaper: RelatableValue = .zero, bottomTaper: RelatableValue = .zero, styles: [ShapeCorner: CornerStyle] = [:]) {
        self.pointHeight = pointHeight
        self.topTaper = topTaper
        self.bottomTaper = bottomTaper
        self.styles = styles
    }
    
    public func points(in rect: CGRect) -> [ShapeCorner: CGPoint] {
        let bottomInset = bottomTaper.value(using: rect.width / 2)
        let topInset = topTaper.value(using: rect.width / 2)
        let pointHeight = pointHeight.value(using: rect.height)
        
        return [
            .bottomLeft: rect[.bottomLeft].moved(dx: bottomInset),
            .bottomRight: rect[.bottomRight].moved(dx: -bottomInset),
            .topLeft: rect[.topLeft].moved(dx: topInset, dy: pointHeight),
            .topRight: rect[.topRight].moved(dx: -topInset, dy: pointHeight),
            .top: rect[.top]
        ]
    }
}

/// Animatable Extension
extension CornerPentagon {
    public var animatableData: AnimatablePair<
        CGFloat,
        AnimatablePair<
            RelatableValue,
            AnimatablePair<
                RelatableValue,
                AnimatablePair<
                    RelatableValue,
                    AnimatableDictionary<ShapeCorner, CornerStyle.AnimatableData>
                >
            >
        >
    >
    {
        get {
            .init(
                insetAmount,
                .init(
                    pointHeight,
                    .init(
                        topTaper,
                        .init(
                            bottomTaper,
                            styles.valueAnimatableData
                        )
                    )
                )
            )
        }
        set {
            insetAmount = newValue.first
            pointHeight = newValue.second.first
            topTaper = newValue.second.second.first
            bottomTaper = newValue.second.second.second.first
            styles.valueAnimatableData = newValue.second.second.second.second
        }
    }
}
