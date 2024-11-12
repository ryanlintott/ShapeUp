//
//  CornerStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension CornerStyle: Animatable {
    public var animatableData: AnimatablePair<RelatableValue, CGFloat> {
        get {
            switch self {
            case .point:
                return .init(.zero, .zero)
            case let .rounded(radius):
                return .init(radius, .zero)
            case let .concave(radius, radiusOffset):
                return .init(radius, radiusOffset)
            case let .straight(radius, _):
                return .init(radius, .zero)
            case let .cutout(radius, _):
                return .init(radius, .zero)
            }
        }
        set {
            self.update(with: newValue)
        }
    }
    
    /// Updates this value based on new animatable data
    /// - Parameter newValue: Animatable Data representing the new value.
    mutating func update(with newValue: AnimatableData) {
        switch self {
        case .point, .rounded, .straight, .cutout:
            self = self.changingRadius(to: newValue.first)
        case .concave:
            self = .concave(newValue.first, radiusOffset: newValue.second)
        }
    }
}
