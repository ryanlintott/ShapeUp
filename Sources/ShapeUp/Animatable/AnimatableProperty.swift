//
//  AnimatableProperty.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2026-08-04.
//

import SwiftUI

/// A typed description of animatable fields belonging to a root value.
public protocol AnimatableProperty<Root> {
    associatedtype Root
    associatedtype AnimatableData: VectorArithmetic

    func animatableData(for root: Root) -> AnimatableData
    func applyAnimatableData(_ animatableData: AnimatableData, to root: inout Root)
}
