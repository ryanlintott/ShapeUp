//
//  CornerStyle+AnimatableData.swift
//  
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension CornerStyle: Animatable {
    public var animatableData: AnimatablePair<RelatableValue.AnimatableData, CGFloat> {
        get {
            switch self {
            case .point:
                return .init(.zero, .zero)
            case let .rounded(radius):
                return .init(radius.animatableData, .zero)
            case let .concave(radius, radiusOffset):
                return .init(radius.animatableData, radiusOffset)
            case let .straight(radius, _):
                return .init(radius.animatableData, .zero)
            case let .cutout(radius, _):
                return .init(radius.animatableData, .zero)
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
        case .point:
            break
        case var .rounded(radius):
            radius.update(with: newValue.first)
            self = self.changingRadius(to: radius)
        case var .concave(radius, _):
            radius.update(with: newValue.first)
            self = .concave(radius: radius, radiusOffset: newValue.second)
        case var .straight(radius, _):
            radius.update(with: newValue.first)
            self = self.changingRadius(to: radius)
        case var .cutout(radius, _):
            radius.update(with: newValue.first)
            self = self.changingRadius(to: radius)
        }
    }
}
