//
//  CSCustom.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-23.
//

import SwiftUI

public struct CSCustom: CornerShape {
    public var insetAmount: CGFloat = 0
    
    public var corners: (CGRect) -> [Corner]
    
    public init(_ corners: @escaping (CGRect) -> [Corner]) {
        self.corners = corners
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        corners(rect)
    }
    
    
}
