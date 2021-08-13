//
//  Notch.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

public struct Notch {
    let style: NotchStyle
    let position: RelatableValue
    let length: RelatableValue
    let depth: RelatableValue
    
    public init(_ style: NotchStyle, position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue) {
        self.style = style
        self.position = position ?? .relative(0.5)
        self.length = length ?? depth
        self.depth = depth
    }
}
