<img width="456" alt="ShapeUp Logo" src="https://user-images.githubusercontent.com/2143656/157464613-38fd35cc-7802-4cb7-914b-4da480a0411e.pn">

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
- [`CornerRectangle`](#cornerrectangle), similar to a SwiftUI `Rectangle` but you can apply any mix of `CornerStyle`s
- [Other Shapes](#othershapes) including `CornerTriangle` and `CornerPentagon` with adjustment properties and any mix of `CornerStyle`s
- [`CornerCustom`](#cornercustom), for building open or closed shapes from and array of `Corner`s in a view without needing to define your own type.
- Add a [`Notch`](#notch) of any `NotchStyle` inbetween two corners.
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
