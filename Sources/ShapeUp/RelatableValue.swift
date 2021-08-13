//
//  RelatableValue.swift
//  Wordhord
//
//  Created by Ryan Lintott on 2021-01-22.
//

import SwiftUI

public enum RelatableValue: Equatable {
    case absolute(_ value: CGFloat)
    case relative(_ value: CGFloat)
    
    static let zero = RelatableValue.absolute(0)
    
    func value(using total: CGFloat) -> CGFloat {
        switch self {
        case .absolute(let value):
            return value
        case .relative(let value):
            return value * total
        }
    }
}
