//
//  RectAnchor+extensions+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-03.
//

import SwiftUI

public extension Array where Element == RectAnchor {
    /// Creates an array of points corresponding to the locations of the anchors.
    /// - Parameter rect: Rectangle where anchors are positioned.
    /// - Returns: An array of points where the anchors are located.
    func points(in rect: CGRect) -> [CGPoint] {
        map { $0.point(in: rect) }
    }
    
    /// Creates an array of points corresponding to the locations of the anchors within a coordinate frame.
    /// - Parameter frame: Coordinate frame where anchors are positioned.
    /// - Returns: An array of points where the anchors are located.
    func points(in frame: CGFrame) -> [CGPoint] {
        map { $0.point(in: frame) }
    }
    
    static let vertices: Self = RectAnchor.vertices
    
    /// Returns an array of relative corners matching the positions of the anchors with an applied corner style.
    ///
    /// - Parameter style: Style applied to all corners. Default is nil which renders as ``CornerStyle.point``.
    /// - Returns: An array of relative corners matching the positions of the anchors with an applied corner style.
    func relativeCorners(_ style: CornerStyle? = nil) -> [RelativeCorner] {
        map { $0.relativeCorner(style) }
    }
    
    /// Returns an array of relative corners matching the positions of the anchors with the array of corner styles applied.
    ///
    /// Nil style values will use point style. Styles array can be smaller than the anchor array. If it's larger extra values will be ignored.
    /// - Parameter styles: Styles applied to each anchor in order.
    /// - Returns: An array of relative corners matching the positions of the anchors with the array of corner styles applied.
    func relativeCorners(_ styles: [CornerStyle?]) -> [RelativeCorner] {
        enumerated().map { index, anchor in
            let style = styles.indices.contains(index) ? (styles[index] ?? .point) : .point
            return anchor.relativeCorner(style)
        }
    }
    
    /// An array of relative corners matching the positions of the anchors with point style.
    var relativeCorners: [RelativeCorner] {
        map(\.relativeCorner)
    }
}
