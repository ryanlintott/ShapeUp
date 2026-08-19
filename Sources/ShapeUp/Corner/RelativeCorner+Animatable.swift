//
//  RelativeCorner+Animatable.swift
//  ShapeUp
//
//  Created by Ryan Lintott on 2025-06-12.
//

import SwiftUI

extension RelativeCorner: AnimatableProperties {
    public static var animatableProperties: some AnimatableProperty<Self> {
        \.anchor
        \.offset
        AnimatablePropertyGroup(id: \.style.name) {
            \.style.radius
            \.style.concaveInset
            \.style.relativeCorners.anchors
            \.style.relativeCorners.offsets
            AnimatablePropertyArray(\.style.relativeCorners.cornerStyles) {
                AnimatablePropertyGroup(id: \.name) {
                    \.radius
                    \.concaveInset
                }
            }
        }
    }
}

extension Array where Element == RelativeCorner {
    var anchors: [RectAnchor] {
        get {
            map(\.anchor)
        }
        set {
            update(with: newValue) { corner, anchor in
                corner.anchor = anchor
            }
        }
    }

    var offsets: [Vector2] {
        get {
            map(\.offset)
        }
        set {
            update(with: newValue) { corner, offset in
                corner.offset = offset
            }
        }
    }
}

/// Applies an animatable property descriptor to each existing element in an
/// array.
private struct AnimatablePropertyArray<
    Root,
    Element,
    Properties: AnimatableProperty<Element>
>: AnimatableProperty {
    typealias AnimatableData = AnimatableArray<Properties.AnimatableData>

    private let elements: WritableKeyPath<Root, [Element]>
    private let properties: Properties

    /// Creates an array property whose elements use the supplied animatable
    /// properties.
    ///
    /// Property data is read and applied independently at each existing array
    /// index. Array size changes are not animated.
    ///
    /// - Parameters:
    ///   - elements: A writable key path to the array containing the elements.
    ///   - properties: The properties to animate on every element.
    init(
        _ elements: WritableKeyPath<Root, [Element]>,
        @AnimatablePropertyBuilder<Element> properties: () -> Properties
    ) {
        self.elements = elements
        self.properties = properties()
    }

    func animatableData(for root: Root) -> AnimatableData {
        .init(root[keyPath: elements].map(properties.animatableData(for:)))
    }

    func applyAnimatableData(_ animatableData: AnimatableData, to root: inout Root) {
        var values = root[keyPath: elements]
        let propertyData = animatableData.wrappedValue

        for index in values.indices where propertyData.indices.contains(index) {
            properties.applyAnimatableData(propertyData[index], to: &values[index])
        }

        root[keyPath: elements] = values
    }
}
