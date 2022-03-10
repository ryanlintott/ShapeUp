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
    public var closed = true
    public var insetAmount: CGFloat = 0
    
    /// An enumeration to indicate the three corners of a pentagon.
    public enum ShapeCorner: CaseIterable {
        case topLeft
        case top
        case topRight
        case bottomRight
        case bottomLeft
    }
    
    public var pointHeight: RelatableValue
    public var topTaper: RelatableValue
    public var bottomTaper: RelatableValue
    public var styles: [ShapeCorner: CornerStyle?]
    
    /// Creates a 2d pentagon shape with corners that can be styled.
    /// - Parameters:
    ///   - pointHeight: The vertical distance from the central point to the two points on either side.
    ///   - topTaper: The horizontal inset of the two points closest to the top.
    ///   - bottomTaper: The horizontal inset of the bottom two points.
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
            .bottomLeft: rect.point(.bottomLeft).moved(dx: bottomInset),
            .bottomRight: rect.point(.bottomRight).moved(dx: -bottomInset),
            .topLeft: rect.point(.topLeft).moved(dx: topInset, dy: pointHeight),
            .topRight: rect.point(.topRight).moved(dx: -topInset, dy: pointHeight),
            .top: rect.point(.top)
        ]
    }
}
