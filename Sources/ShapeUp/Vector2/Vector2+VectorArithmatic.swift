//
//  Vector2+VectorArithmatic.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2023-05-20.
//

import SwiftUI

extension Vector2: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        dx *= rhs
        dy *= rhs
    }
}
