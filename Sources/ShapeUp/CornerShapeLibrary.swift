//
//  CornerShapeLibrary.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-27.
//

import SwiftUI

extension CGRect {
    func pentagon(pointHeight: RelatableValue, topTaper: RelatableValue = .zero, bottomTaper: RelatableValue = .zero) -> [CGPoint] {
        let rect = self
        let sidePoints = [
            CGPoint(x: rect.minX + bottomTaper.value(using: rect.width / 2), y: rect.maxY),
            CGPoint(x: rect.minX + topTaper.value(using: rect.width / 2), y: rect.minY + pointHeight.value(using: rect.height))
        ]

        return sidePoints
                    + [CGPoint(x: rect.midX, y: rect.minY)]
                    + sidePoints.flipHorizontal(around: rect.midX).reversed()
    }
}
