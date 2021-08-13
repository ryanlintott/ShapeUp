//
//  CornerStyle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public enum CornerStyle: Equatable {
    case point
    case rounded(radius: RelatableValue)
    case concave(radius: RelatableValue, radiusOffset: CGFloat? = nil)
    case straight(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
    case cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = [])
//    case custom(radius: RelatableValue, corners: (CGRect) -> [Corner])

    var radius: RelatableValue {
        switch self {
        case .point:
            return .zero
        case let .rounded(radius):
            return radius
        case let .concave(radius, _):
            return radius
        case let .straight(radius, _):
            return radius
        case let .cutout(radius, _):
            return radius
        }
    }
    
    var cornerStyles: [CornerStyle] {
        switch self {
        case .point, .rounded, .concave:
            return []
        case let .straight(_, cornerStyles):
            return cornerStyles
        case let .cutout(_, cornerStyles):
            return cornerStyles
        }
    }
    
    var isFlattenable: Bool {
        switch self {
        case .point:
            return false
        case .rounded, .concave:
            switch radius {
            case .absolute:
                return false
            case .relative:
                return true
            }
        case .straight, .cutout:
            if cornerStyles == [] || cornerStyles.allSatisfy({ $0 == .point }) {
                return false
            } else {
                return true
            }
        }
    }
}
