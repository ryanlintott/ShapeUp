//
//  RelatableValue+Arithmatic.swift
//  
//
//  Created by Ryan Lintott on 2022-03-24.
//

import SwiftUI

public extension RelatableValue {
    static func + (lhs: Self, rhs: Self) -> Self {
        switch (lhs, rhs) {
        case let (.absolute(lhsValue), .absolute(rhsValue)):
            return .absolute(lhsValue + rhsValue)
            
        case let (.relative(lhsValue), .relative(rhsValue)):
            return .relative(lhsValue + rhsValue)
            
        case let (.mixed(lhsAbsolute, lhsRelative), .mixed(rhsAbsolute, rhsRelative)):
            return .mixed(absolute: lhsAbsolute + rhsAbsolute, relative: lhsRelative + rhsRelative)
            
        case (.absolute, .relative), (.relative, .absolute), (.absolute, .mixed), (.mixed, .absolute), (.relative, .mixed), (.mixed, .relative):
            return lhs.mixed + rhs.mixed
        }
    }
    
    static prefix func - (x: Self) -> Self {
        switch x {
        case let .absolute(value):
            return .absolute(-value)
        case let .relative(value):
            return .relative(-value)
        case let .mixed(absolute, relative):
            return .mixed(absolute: -absolute, relative: -relative)
        }
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        lhs + -rhs
    }
    
    /// RelatableValue addition assignment
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    /// RelatableValue subtraction assignment
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    static func * (lhs: RelatableValue, rhs: CGFloat) -> RelatableValue {
        switch lhs {
        case let .absolute(lhsValue):
            return .absolute(lhsValue * rhs)

        case let .relative(lhsValue):
            return .relative(lhsValue * rhs)

        case let .mixed(lhsAbsolute, lhsRelative):
            return .mixed(absolute: lhsAbsolute * rhs, relative: lhsRelative * rhs)
        }
    }
    
    static func / (lhs: RelatableValue, rhs: CGFloat) -> RelatableValue {
        lhs * (1 / rhs)
    }
    
    /// RelatableValue multiplication assignment
    static func *= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
    /// RelatableValue division assignment
    static func /= (lhs: inout Self, rhs: CGFloat) {
        lhs = lhs / rhs
    }
}
