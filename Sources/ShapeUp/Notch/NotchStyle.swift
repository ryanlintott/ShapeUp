//
//  NotchStyle.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-08-13.
//

import SwiftUI

public enum NotchStyle {
    case triangle(cornerStyles: [CornerStyle?])
    case rectangle(cornerStyles: [CornerStyle?])
    case custom(corners: (_ in: CGRect) -> [Corner])
}

public extension NotchStyle {
    static let triangle = NotchStyle.triangle(cornerStyles: [])
    static let rectangle = NotchStyle.rectangle(cornerStyles: [])
    
    static func triangle(cornerStyle: CornerStyle? = nil) -> NotchStyle {
        .triangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 3))
    }
    static func rectangle(cornerStyle: CornerStyle? = nil) -> NotchStyle {
        .rectangle(cornerStyles: Array<CornerStyle?>(repeating: cornerStyle, count: 4))
    }
    
    var cornerStyles: [CornerStyle?] {
        switch self {
        case let .triangle(cornerStyles):
            return cornerStyles
        case let .rectangle(cornerStyles):
            return cornerStyles
        case let .custom(corners):
            return corners(.zero).cornerStyles
        }
    }
}
