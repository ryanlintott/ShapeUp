<img width="456" alt="ShapeUp Logo" src="https://user-images.githubusercontent.com/2143656/157464613-38fd35cc-7802-4cb7-914b-4da480a0411e.png">

[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FShapeUp%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ryanlintott/FrameUp)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fryanlintott%2FShapeUp%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ryanlintott/FrameUp)
![License - MIT](https://img.shields.io/github/license/ryanlintott/ShapeUp)
![Version](https://img.shields.io/github/v/tag/ryanlintott/ShapeUp?label=version)
![GitHub last commit](https://img.shields.io/github/last-commit/ryanlintott/ShapeUp)
[![Twitter](https://img.shields.io/badge/twitter-@ryanlintott-blue.svg?style=flat)](http://twitter.com/ryanlintott)

# Overview
A Swift Package that makes SwiftUI shapes easier to draw.

- [`Corner`](#corner), a `CGPoint` with style.
- [`CornerStyle`](#cornerstyle), an enum with style options for `Corner` including `.point`, `.rounded`, `.straight`, `.cutout`, and `.concave`
- [`CornerShape`](#cornershape), a protocol for making your own open or closed shapes out of an array of Corners that automatically conforms to `InsettableShape` with no extra code.
- [Basic Shapes](#basicshapes) like `CornerRectangle`, `CornerTriangle`, and `CornerPentagon`. All similar to a SwiftUI `Rectangle` but you can apply any mix of `CornerStyle`s
- [`CornerCustom`](#cornercustom), for building open or closed shapes from and array of `Corner`s in a view without needing to define your own type.
- Add a [`Notch`](#notch) of any `NotchStyle` inbetween two corners.
- [`.addOpenCornerShape()`](#addcornershape) or [`.addClosedCornerShape()`](#addcornershape) if you want to just add a few corners to a SwiftUI `Path`
- [`Vector2`](#vector2), a new type similar to `CGPoint` but used to do vector math.
- [`Vector2Representable`](#vector2representable) protocol that adds a `.vector` property needed to conform to other Vector2-related protocols. Applied to `Vector2`, `CGPoint`, and `Corner`
- [`Vector2Algebraic`](#vector2algebraic) protocol used to add vector algebra capabilities to `Vector2`
- [`Vector2Transformable`](#vector2transformable) protocol used to add transformm functions like `.moved()`, `.rotated()`, and `.flipped()` to `Vector2Representable` types and arrays of that type.
- [`RectAnchor`](#rectanchor), an enum for all major anchor points on a rectangle. Used for transform functions.
- [`RelatableValue`](#relatablevalue), an enum used to store `.relative` or `.absolute` values. Used for `CornerStyle.radius`, `Notch` properties, `CornerTriangle` and `CornerPentagon` properties and `SketchyLine`. Also useful for your own shapes.
- [`SketchyLine`](#sketchyline), an animatable line `Shape` that aligns to frame edges and can extend beyond the frame.
- [`.emboss()`](#emboss) or `.deboss()` any SwiftUI `Shape` or `View`.


# [ShapeUpExample](https://github.com/ryanlintott/ShapeUpExample)
Check out the example app to see how you can use this package in your iOS app.

# Installation
1. In XCode 12 go to `File -> Swift Packages -> Add Package Dependency` or in XCode 13 `File -> Add Packages`
2. Paste in the repo's url: `https://github.com/ryanlintott/ShapeUp` and select by version.

# Usage
Import the package using `import ShapeUp`

# Platforms
This package is compatible with iOS 14 or later. It's technically compatible with macOS 11 but hasn't been tested yet.

# Is this Production-Ready?
Really it's up to you. I currently use this package in my own [Old English Wordhord app](https://oldenglishwordhord.com/app).

# Support
If you like this package, buy me a coffee to say thanks!

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/X7X04PU6T)

- - -
# Details
## RelatableValue
A handy enumeration that represents either a relative or absolute value. This is used in lots of situations throughout ShapeUp to give flexibility when defining parameters.

When setting a corner radius you might want a fixed value like 20 or you might want a value that's 20% of the maximum so that it will scale proportionally. `RelatableValue` gives you both of those options.
```swift
let absolute = RelatableValue.absolute(20)
let relative = RelatableValue.relative(0.2)
```

Later, the value is determined by running the `value(using total:)` function. Absolute values will always be the same but any relative values will be calculated. In the case of a corner radius, the total would be the maximum radius that would fit that corner given the length of the two lines and the angle of the corner.
```swift
let radius = relatableRadius.value(using: maxRadius)
```

For ease of use, `RelatableValue` conforms to `ExpressibleByIntegerLiteral` and `ExpressibleByFloatLiteral`. This means in many cases you can omit `.absolute()` when writing absolute values.
```swift
// Both are the same
let cornerStyle = .rounded(.absolute(5))
let cornerStyle = .rounded(5)
```

## Corner
A point with a specified `CornerStyle` used to draw paths and create shapes.

```swift
Corner(.rounded(radius: 5), x: 0, y: 10)
```

Corners store no information about their orientation or where the previous and next points are located. When they're put into an array their order is assumed to be their drawing order. This means you can generate a path from this array. By default this path is assumed to be closed with the last point connecting back to the first.

```swift
[
    Corner(.rounded(radius: 10), x: 0, y: 0),
    Corner(.cutout(radius: 5), x: 10, y: 0),
    Corner(.straight(radius: 5), x: 5, y: 10)
].path()
```

## CornerStyle
An enum storing style information for a `Corner`. In all cases, the radius is a [`RelatableValue`](#relatablevalue) that can either be an absolue value or relative to the length of the shortest line from that corner.

### `.point`
A simple point corner with no properties.

### `.rounded(radius: RelatableValue)`
A rounded corner with a radius.

### `.concave(radius: RelatableValue, radiusOffset: CGFloat)`
A concave corner where the radius determines the start and end points of the cut and the radius offeset is the difference between the concave radius and the radius. The radiusOffset is mainly used when insetting a concave corner and is often left with the default value of zero.

### `.straight(radius: RelatableValue, cornerStyles: [CornerStyle] = [])`
A straight chamfer corner where the radius determines the start and end points of the cut. Additional cornerstyles can be used on the two resulting corners of the chamfer. (You can continue nesting recursively.)

### `cutout(radius: RelatableValue, cornerStyles: [CornerStyle] = [])`
A cutout corner where the radius determines the start and end points of the cut. Additional cornerstyles can be used on the three resulting corners of the cut. (Again, you can continue nesting recursively.)

## CornerShape
A protocol you can use to create a shape built from an array of `Corner`s. It automatically conforms to `InsettableShape`. The path function typically used for SwiftUI Shape is already implemented and will use this array to create a single path, applying any inset, and closing it if the closed parameter is true.

### How to build a CornerShape
- Define an insetAmount of zero as this property is mainly used if the shape is later inset.
- Use the closed property to define if your shape should be closed or left open.
- Write a function that returns an array of corners.
```swift
public struct MyShape: CornerShape {
    public var insetAmount: CGFloat = .zero
    public let closed = true
   
    public func corners(in rect: CGRect) -> [Corner] {
        [
            Corner(x: rect.midX, y: rect.minY),
            Corner(.rounded(radius: 5), x: rect.maxX, y: rect.maxY),
            Corner(.rounded(radius: 5), x: rect.minX, y: rect.maxY)
        ]
    }
}
```

### Using A CornerShape
A `CornerShape` is an `InsettableShape` so it can be used in SwiftUI Views in the same way as `RoundedRectangle` or similar.
```swift
MyShape()
    .fill()
```

The corners can also be accessed directly for use in a more complex shape
```swift
public func corners(in rect: CGRect) -> [Corner] {
    MyShape()
        .corners(in: rect)
        .inset(by: 10)
        .addingNotch(Notch(.rectangle, depth: 5), afterCornerIndex: 0)
}
```

## Basic Shapes
`CornerRectangle`, `CornerTriangle`, and `CornerPentagon` are ready-made `CornerShape`s

Examples:
```swift
CornerRectangle([
    .topLeft: .straight(radius: 60),
    .topRight: .cutout(radius: .relative(0.2)),
    .bottomRight: .rounded(radius: .relative(0.8)),
    .bottomLeft: .concave(radius: .relative(0.2))
])
.fill()

CornerTriangle(
    topPoint: .relative(0.6),
    styles: [
        .top: .straight(radius: 10),
        .bottomRight: .rounded(radius: .relative(0.3)),
        .bottomLeft: .concave(radius: .relative(0.2))
    ]
)
.stroke()
    
CornerPentagon(
    pointHeight: .relative(0.3),
    topTaper: .relative(0.1),
    bottomTaper: .relative(0.3),
    styles: [
        .topRight: .concave(radius: 30),
        .bottomLeft: .straight(radius: .relative(0.3))
    ]
)
.fill()
```

## CornerCustom
Sometimes you might want to make a shape inline without defining a new struct. `CornerCustom` is a `CornerShape` that takes a closure that returns an array of `Corner`s. All you do is provide the corners and the shape will draw itself.

```swift
CornerCustom { rect in
    [
        Corner(x: rect.midX, y: rect.minY),
        Corner(.rounded(radius: 10), x: rect.maxX, y: rect.maxY),
        Corner(.rounded(radius: 10), x: rect.minX, y: rect.maxY)
    ]
}
.strokeBorder(lineWidth: 5)
```
## Notch
## Add CornerShape
A way to add open and closed corner
## Vector2
## Vector2Representable
## Vector2Algebraic
## Vector2Transformable
## RectAnchor
## RelatableValue
## SketchyLine
## Emboss

