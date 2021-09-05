//
//  ShapeLibrary.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-05.
//

import SwiftUI

public enum ShapeLibrary {
    case pentagon(pointHeight: RelatableValue, topTaper: RelatableValue, bottomTaper: RelatableValue)
    
    public func corners(in rect: CGRect) -> [Corner] {
        switch self {
        case let .pentagon(pointHeight, topTaper, bottomTaper):
            let sidePoints = [
                Corner(x: rect.minX + bottomTaper.value(using: rect.width / 2), y: rect.maxY),
                Corner(x: rect.minX + topTaper.value(using: rect.width / 2), y: rect.minY + pointHeight.value(using: rect.height))
            ]
            return sidePoints
                + [Corner(x: rect.midX, y: rect.minY)]
                + sidePoints.flipHorizontal(around: rect.midX).reversed()
        }
    }
    
    public var cornerShape: CornerShape {
        CornerShape(self)
    }
}

