//
//  Notch.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-01-21.
//

import SwiftUI

public struct Notch {
    public let style: NotchStyle
    public let position: RelatableValue
    public let length: RelatableValue
    public let depth: RelatableValue
    
    public init(_ style: NotchStyle, position: RelatableValue? = nil, length: RelatableValue? = nil, depth: RelatableValue) {
        self.style = style
        self.position = position ?? .relative(0.5)
        self.length = length ?? depth
        self.depth = depth
    }
}
