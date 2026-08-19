//
//  CornerArrayBuilder.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-08-19.
//

import SwiftUI
import Foundation

/// Builds an array of corners from ``Corner``, `CGPoint`, and ``Notch`` values.
///
/// A notch is expanded between the nearest corners before and after it. Corner lookup is
/// cyclic, so a notch before the first corner or after the last corner is added between
/// the last and first corners. Consecutive notches share the same surrounding corners.
@resultBuilder
public enum CornerArrayBuilder { }

public extension CornerArrayBuilder {
    /// An opaque intermediate value used while building an array of corners.
    struct Component: Sendable {
        fileprivate enum Element: Sendable {
            case corner(Corner)
            case notch(Notch)
        }

        fileprivate var elements: [Element]

        fileprivate init(_ elements: [Element]) {
            self.elements = elements
        }

        fileprivate var corners: [Corner] {
            let explicitCorners = elements.compactMap { element in
                if case let .corner(corner) = element {
                    corner
                } else {
                    nil
                }
            }

            guard
                explicitCorners.count >= 2,
                let firstCorner = explicitCorners.first,
                let lastCorner = explicitCorners.last
            else {
                return explicitCorners
            }

            var previousCorners = Array(repeating: lastCorner, count: elements.count)
            var previousCorner = lastCorner
            for index in elements.indices {
                previousCorners[index] = previousCorner
                if case let .corner(corner) = elements[index] {
                    previousCorner = corner
                }
            }

            var nextCorners = Array(repeating: firstCorner, count: elements.count)
            var nextCorner = firstCorner
            for index in elements.indices.reversed() {
                nextCorners[index] = nextCorner
                if case let .corner(corner) = elements[index] {
                    nextCorner = corner
                }
            }

            return elements.indices.flatMap { index in
                switch elements[index] {
                case let .corner(corner):
                    [corner]
                case let .notch(notch):
                    notch.between(start: previousCorners[index], end: nextCorners[index])
                }
            }
        }
    }

    static func buildEither(first component: Component) -> Component {
        component
    }

    static func buildEither(second component: Component) -> Component {
        component
    }

    static func buildOptional(_ component: Component?) -> Component {
        component ?? Component([])
    }

    static func buildExpression(_ expression: CGPoint) -> Component {
        Component([.corner(expression.corner)])
    }

    static func buildExpression(_ expression: Corner) -> Component {
        Component([.corner(expression)])
    }

    static func buildExpression(_ expression: [Corner]) -> Component {
        Component(expression.map { .corner($0) })
    }

    static func buildExpression(_ expression: [CGPoint]) -> Component {
        Component(expression.map { .corner($0.corner) })
    }

    static func buildExpression(_ expression: Notch) -> Component {
        Component([.notch(expression)])
    }

    static func buildBlock(_ components: Component...) -> Component {
        Component(components.flatMap(\.elements))
    }

    static func buildFinalResult(_ component: Component) -> [Corner] {
        component.corners
    }

    @available(*, unavailable, message: "RelativeCorner is not compatible with CornerArrayBuilder.")
    static func buildExpression(_ expression: RelativeCorner) -> Component {
        fatalError()
    }
    
    @available(*, unavailable, message: "RelativeCorner is not compatible with CornerArrayBuilder.")
    static func buildExpression(_ expression: [RelativeCorner]) -> Component {
        fatalError()
    }
}

/// An array of ``Corner`` values.
public typealias Corners = [Corner]

extension Corners {
    /// Builds an array of corners from a trailing closure.
    /// - Parameter corners: A closure that builds the corners.
    public init(@CornerArrayBuilder _ corners: () -> [Corner]) {
        self = corners()
    }
}

struct CornerArrayBuilderShapeExample: CornerShape {
    var insetAmount: CGFloat = .zero
    var closed = true
    var radius: CGFloat
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
   
    func corners(in rect: CGRect) -> [Corner] {
        Corners {
            rect[.topLeft]
            
            rect[.topRight]
        }
        .defaultCornerStyle(.rounded(radius: .absolute(radius)))
        
        rect[.bottomRight]
        
        rect[.bottomRight]
            .moved(dx: -radius, dy: -radius)
            .rounded(radius: .absolute(radius))
        
        rect[.bottomLeft]
            .moved(dy: -radius)
            .rounded(radius: .absolute(radius))
    }
}

#if !os(tvOS)
@available(iOS 17, watchOS 10, macOS 14, tvOS 17, *)
#Preview {
    @Previewable @State var radius = 20.0
    
    VStack {
        CornerArrayBuilderShapeExample(radius: radius)
            .frame(maxWidth: 200, maxHeight: 200)
            .animation(.default, value: radius)
        
        Stepper("Radius", value: $radius, in: 0...50, step: 5)
        Slider(value: $radius, in: 0...50)
    }
}
#endif
