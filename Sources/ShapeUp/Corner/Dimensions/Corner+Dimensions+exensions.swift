//
//  File.swift
//  
//
//  Created by Ryan Lintott on 2022-03-03.
//

import SwiftUI

public extension Corner.Dimensions {
    /// An array of corners created from nested corner styles. Point, rounded and concave corners will return empty arrays. Straight will return an array of 2 points (corner start and corner end), and cutout will return an array of 3 points (corner start, cutout, corner end)
    var subCorners: [Corner] {
        switch corner.style {
        case .point, .rounded, .concave:
            return []
        case let .straight(_, cornerStyles):
            return [cornerStart, cornerEnd].corners(cornerStyles)
        case let .cutout(_, cornerStyles):
            return [cornerStart, cutoutPoint, cornerEnd].corners(cornerStyles)
        }
    }
}
