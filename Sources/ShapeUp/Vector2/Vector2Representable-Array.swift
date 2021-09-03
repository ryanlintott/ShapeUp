//
//  Vector2Representable-Array.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2021-09-03.
//

import SwiftUI

public extension Array where Element: Vector2Representable {
    var vectors: [Vector2] {
        map({ $0.vector })
    }
    
    var points: [CGPoint] {
        map({ $0.vector.point })
    }
}
