//
//  CornerInset.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-02-17.
//

import SwiftUI

protocol InsettableCornerShape: InsettableShape {
    var insetAmount: CGFloat { get set }
    
    func inset(by amount: CGFloat) -> Self
}

extension InsettableCornerShape {
    func inset(by amount: CGFloat) -> Self {
        var insetShape = self
        insetShape.insetAmount += amount
        return insetShape
    }
}
