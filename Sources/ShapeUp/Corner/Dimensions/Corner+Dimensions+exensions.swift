//
//  Corner+Dimensions+exensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-03.
//

import SwiftUI

public extension Corner.Dimensions {
    /// Vector from the start point to the corner point
    var startVector: Vector2 {
        -previousVector.normalized * cutLength
    }
    
    /// Vector from the corner point to the end point
    var endVector: Vector2 {
        nextVector.normalized * cutLength
    }
    
    func position(of anchor: RectAnchor) -> CGPoint {
        cornerStart
            .moved(startVector * anchor.relativePoint.x)
            .moved(endVector * anchor.relativePoint.y)
    }
    
    /// An array of corners created from nested corner styles. Point, rounded and concave corners will return empty arrays. Straight will return an array of 2 points (corner start and corner end), and cutout will return an array of 3 points (corner start, cutout, corner end)
    var subCorners: [Corner] {
        switch corner.style {
        case .point, .rounded, .concave:
            return []
        case let .straight(_, cornerStyles):
            return [cornerStart, cornerEnd].corners(cornerStyles)
        case let .cutout(_, cornerStyles):
            return [cornerStart, cutoutPoint, cornerEnd].corners(cornerStyles)
        case let .symmetrical(_, relativeCorners):
            let corners = relativeCorners(in: self)
            var mirroredCorners = corners
                .reversed()
                .flipped(
                    mirrorLineStart: RectAnchor.bottomLeft(in: self),
                    mirrorLineEnd: RectAnchor.topRight(in: self)
                )
            
            /// If the last corner is right on the mirror line, don't include it in the mirrored corners.
            if let last = corners.last,
               let first = mirroredCorners.first,
               last.point == first.point {
                return corners + mirroredCorners.dropFirst()
            } else {
                return corners + mirroredCorners
            }
        }
    }
}
