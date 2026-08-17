//
//  Corner+Dimensions+exensions.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-03-03.
//

import SwiftUI

extension Corner.Dimensions {
    /// The angle the corner curve turns through, from the incoming tangent
    /// direction to the outgoing one.
    ///
    /// Zero at a straight corner and 180 degrees at a zero-degree corner. This
    /// is the same turn angle whether the corner is drawn as a circular arc,
    /// a continuous curve, or any other style.
    var turnAngle: Angle {
        halvedTurnAngle.doubled
    }

    /// The coordinate frame used to position nested corners.
    var frame: CGFrame {
        .init(
            origin: cornerStart,
            xAxis: startVector,
            yAxis: endVector
        )
    }
    
    /// Vector from the start point to the corner point
    var startVector: Vector2 {
        -previousVector.normalized * cutLength
    }
    
    /// Vector from the corner point to the end point
    var endVector: Vector2 {
        nextVector.normalized * cutLength
    }
    
    /// An array of corners created from nested corner styles. Point, rounded and concave corners will return empty arrays. Straight will return an array of 2 points (corner start and corner end), and cutout will return an array of 3 points (corner start, cutout, corner end)
    var subCorners: [Corner] {
        switch corner.style {
        case .automatic, .point, .rounded, .concave:
            []
        case let .straight(_, cornerStyles):
            [cornerStart, cornerEnd].corners(cornerStyles)
        case let .cutout(_, cornerStyles):
            [cornerStart, cutoutPoint, cornerEnd].corners(cornerStyles)
        case let .custom(_, relativeCorners):
            relativeCorners.corners(in: frame)
        }
    }
}
