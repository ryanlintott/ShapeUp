//
//  CGSize-extension.swift
//  FullscreenZoom
//
//  Created by Ryan Lintott on 2020-09-21.
//

import SwiftUI

extension CGSize {
    // Vector negation
    static prefix func - (cgSize: CGSize) -> CGSize {
        return CGSize(width: -cgSize.width, height: -cgSize.height)
    }
    
    // Vector addition
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    // Vector subtraction
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return lhs + -rhs
    }
    
    // Vector addition assignment
    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
    
    // Vector subtraction assignment
    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs - rhs
    }
}

extension CGSize {
    // Scalar-vector multiplication
    static func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
    }
    
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return rhs * lhs
    }
    
    // Vector-scalar division
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        guard rhs != 0 else { fatalError("Division by zero") }
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    // Vector-scalar division assignment
    static func /= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    
    // Scalar-vector multiplication assignment
    static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs * rhs
    }
}

extension CGSize: Comparable {
    var min: CGFloat {
        return Swift.min(width, height)
    }
    
    var max: CGFloat {
        return Swift.max(width, height)
    }
    
    // Vector magnitude (length)
    var magnitude: CGFloat {
        return sqrt(width * width + height * height)
    }
    
    // Vector normalization
    var normalized: CGSize {
        return CGSize(width: width / magnitude, height: height / magnitude)
    }
    
    public static func < (lhs: CGSize, rhs: CGSize) -> Bool {
        lhs.magnitude < rhs.magnitude
    }
}

extension CGSize {
    var aspectRatio: CGFloat {
        width / height
    }
    
    init(cgPoint: CGPoint) {
        self = CGSize(width: cgPoint.x, height: cgPoint.y)
    }
    
    init(cgRect: CGRect) {
        self = CGSize(width: cgRect.width, height: cgRect.height)
    }
}


