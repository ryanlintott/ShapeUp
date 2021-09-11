//
//  CSPentagon.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-10.
//

import SwiftUI

public struct CSPentagon: CornerShape {    
    public var insetAmount: CGFloat = 0
    
    public let pointHeight: RelatableValue
    public let topTaper: RelatableValue
    public let bottomTaper: RelatableValue
    
    public init(pointHeight: RelatableValue, topTaper: RelatableValue, bottomTaper: RelatableValue) {
        self.pointHeight = pointHeight
        self.topTaper = topTaper
        self.bottomTaper = bottomTaper
    }
    
    public func corners(in rect: CGRect) -> [Corner] {
        let sidePoints = [
            Corner(x: rect.minX + bottomTaper.value(using: rect.width / 2), y: rect.maxY),
            Corner(x: rect.minX + topTaper.value(using: rect.width / 2), y: rect.minY + pointHeight.value(using: rect.height))
        ]
        return sidePoints
        + [Corner(x: rect.midX, y: rect.minY)]
        + sidePoints.flipHorizontal(around: rect.midX).reversed()
    }
}

