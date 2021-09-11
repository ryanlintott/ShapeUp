//
//  Proportionable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public protocol Proportionable {
    var width: CGFloat { get }
    var height: CGFloat { get }
}

public enum AspectFormat: CaseIterable {
    case portrait, square, landscape
    
    public static func forRatio(_ aspectRatio: CGFloat) -> Self {
        switch aspectRatio {
        case 1:
            return .square
        case ..<1:
            return .portrait
        default:
            return .landscape
        }
    }
}

public extension Proportionable {
    var aspectFormat: AspectFormat {
        .forRatio(aspectRatio)
    }
    
    var aspectRatio: CGFloat {
        (width / height).magnitude
    }

    var minDimension: CGFloat {
        return Swift.min(width, height)
    }

    var maxDimension: CGFloat {
        return Swift.max(width, height)
    }
}
