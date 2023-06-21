//
//  Angle+AngleRepresentable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2022-02-08.
//

import SwiftUI

fileprivate struct _Angle: AngleRepresentable {
    let radians: Double
}

/// Extension is internal so that Swift Package users have the option of adding protocol conformance themselves.
internal extension Angle {
    fileprivate var _angle: _Angle {
        _Angle(radians: radians)
    }

    var type: AngleType {
        _angle.type
    }
    
    var positive: Angle {
        _angle.positive
    }
    
    var complementary: Angle {
        _angle.complementary
    }
    
    var supplementary: Angle {
        _angle.supplementary
    }
    
    var explementary: Angle {
        _angle.explementary
    }
    
    var minPositiveCoterminal: Angle {
        _angle.minPositiveCoterminal
    }
    
    func minRotation(from angle: Angle) -> Angle {
        _angle.minRotation(from: angle)
    }

    func maxRotation(from angle: Angle) -> Angle {
        _angle.maxRotation(from: angle)
    }
    
    var reflexCoterminal: Angle {
        _angle.reflexCoterminal
    }
    
    var nonReflexCoterminal: Angle {
        _angle.nonReflexCoterminal
    }
    
    var halved: Angle {
        _angle.halved
    }
    
    static func threePoint(_ initialPoint: some Vector2Representable, _ anchor: some Vector2Representable, _ terminalPoint: some Vector2Representable) -> Angle {
        _Angle.threePoint(initialPoint, anchor, terminalPoint)
    }
}
