//
//  CornerStyle+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension Optional<CornerStyle> {
    public var animatableData: AnimatablePair<RelatableValue, CGFloat> {
        get {
            switch self {
            case .none: CornerStyle.point.animatableData
            case let .some(value): value.animatableData
            }
        }
        set {
            self?.animatableData = newValue
        }
    }
}

extension CornerStyle: Animatable {
    public var animatableData: AnimatablePair<RelatableValue, CGFloat> {
        get {
            switch self {
            case .point, .rounded, .straight, .cutout, .symmetrical:
                .init(radius, .zero)
            case let .concave(radius, radiusOffset):
                .init(radius, radiusOffset)
            }
        }
        set {
            switch self {
            case .point, .rounded, .straight, .cutout, .symmetrical:
                self = self.changingRadius(to: newValue.first)
            case .concave:
                self = .concave(newValue.first, radiusOffset: newValue.second)
            }
        }
    }
}
