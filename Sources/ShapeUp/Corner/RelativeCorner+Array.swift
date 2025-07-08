//
//  RelativeCorner+Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-07-08.
//

import Foundation

public extension Collection<RelativeCorner> {
    func corners(in rect: CGRect) -> [Corner] {
        map { $0.corner(in: rect) }
    }
    
    func corners(in frame: CGFrame) -> [Corner] {
        map { $0.corner(in: frame) }
    }
}
