# ``ShapeUp``

A Swift Package that makes SwiftUI shapes easier to build, transform, inset, and animate.

## Overview

Create a ``Corner`` using relative ``RectAnchor`` points, apply a ``CornerStyle``, copy/move/rotate/scale/mirror arrays of corners to build complex shapes, add a ``Notch`` along any edge, and wrap it in a ``CornerShape`` that is automatically insettable and animatable.

```swift
struct MyCornerShape: CornerShape {
    var insetAmount: CGFloat = .zero
    let closed: Bool = true

    func corners(in rect: CGRect) -> [Corner] {
        rect[.topLeft]
            .moved(dy: 40)
            .rounded(radius: .relative(0.4))

        Notch(length: .relative(0.3), depth: .relative(0.1)) {
            RelativeCorners {
                (0.0, 0.0)
                (0.2, 0.6)
                (0.8, -0.6)
                (1.0, 0.0)
            }
            .defaultCornerStyle(.rounded(radius: .absolute(15), style: .continuous))
        }

        rect[.topRight]
            .concave(radius: .relative(0.5))

        Corners {
            rect[.right]

            rect[.bottom]
                .cutout(
                    radius: .relative(0.3),
                    cornerStyle: .straight(radius: .absolute(6))
                )

            rect[.left]
        }
        .scaledPositions(x: 0.4, anchor: .center)
        .rotated(.degrees(20), anchor: .center)
        .defaultCornerStyle(.rounded(radius: .relative(0.3)))
    }
}
```

Additional features help extend existing SwiftUI and Core Graphics types. Corner shapes and continuous curves of any angle can be drawn into any ``SwiftUICore/Path``. Any ``SwiftUICore/View`` or `InsettableShape` can be embossed or debossed. Types can more easily conform to `Animatable` with ``AnimatableProperties``.

Requires iOS 15+, macOS 12+, watchOS 9+, tvOS 15+, or visionOS 1+.

For a feature-by-feature guide with examples, see the [README](https://github.com/ryanlintott/ShapeUp), and the `Example` folder in the [repository](https://github.com/ryanlintott/ShapeUp) for a demo app.

## Topics

### Corners

- ``Corner``
- ``CornerStyle``
- ``Corners``
- ``CornerArrayBuilder``
- ``RelativeCorner``
- ``RelativeCorners``
- ``RelativeCornerArrayBuilder``
- ``CornerStylable``

### Shapes

- ``CornerShape``
- ``CornerCustom``
- ``RelativeCornerCustom``
- ``CornerRectangle``
- ``CornerTriangle``
- ``CornerPentagon``
- ``EnumeratedCornerShape``
- ``InsettableShapeByProperty``
- ``SketchyLine``
- ``SketchyLines``

### Notches

- ``Notch``
- ``NotchStyle``

### Rects and Frames

- ``RectAnchor``
- ``RectAnchorArrayBuilder``
- ``CGFrame``
- ``CGFrameRepresentable``

### Values

- ``RelatableValue``

### Vectors

- ``Vector2``
- ``Vector2Representable``
- ``Vector2Algebraic``
- ``Vector2Transformable``

### Angles

- ``AngleRepresentable``

### Animation

- ``AnimatableProperties``
- ``AnimatableArray``
- ``AnimatableDictionary``
- ``AnimatablePack``

### Path Extensions

- ``SwiftUICore/Path/addClosedCornerShape(_:)-4v0dg``
- ``SwiftUICore/Path/addOpenCornerShape(_:previousPoint:nextPoint:moveToStart:)``
- ``SwiftUICore/Path/addContinuousCurve(tangent1End:tangent2End:radius:)``

### Emboss and Deboss

- ``SwiftUICore/View/emboss(baseColor:amount:blur:angle:opacity:)``
- ``SwiftUICore/View/deboss(baseColor:amount:blur:angle:opacity:)``
- ``SwiftUICore/InsettableShape/embossEdges(size:angle:opacity:backgroundColor:)``
- ``SwiftUICore/InsettableShape/debossEdges(size:angle:opacity:backgroundColor:)``

### Extended Types

- ``CoreFoundation/CGPoint``
- ``CoreFoundation/CGRect``
- ``CoreFoundation/CGSize``
- ``SwiftUICore/Path``
- ``SwiftUICore/Shape``
- ``SwiftUICore/View``
- ``SwiftUICore/Rectangle``


