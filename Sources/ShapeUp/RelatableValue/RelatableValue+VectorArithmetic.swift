//
//  RelatableValue+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-19.
//

import SwiftUI

extension RelatableValue: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        switch self {
        case let .absolute(absolute):
            self = .absolute(absolute * rhs)
        case let .relative(relative):
            self = .relative(relative * rhs)
        case let .mixed(absolute, relative):
            self = .mixed(absolute: absolute * rhs, relative: relative * rhs)
        }
    }

    public var magnitudeSquared: Double {
        switch self {
        case let .absolute(absolute):
            return absolute * absolute
        case let .relative(relative):
            return relative * relative
        case let .mixed(absolute, relative):
            return absolute * absolute + relative * relative
        }
    }
}
