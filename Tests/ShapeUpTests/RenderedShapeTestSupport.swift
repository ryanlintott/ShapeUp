//
//  RenderedShapeTestSupport.swift
//  ShapeUpTests
//
//  Created by Ryan Lintott on 2026-08-14.
//

import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
enum RenderedShapeTestSupport {
    struct Difference {
        let changedPixels: Int
        let materiallyChangedPixels: Int
        let maximumDifference: Int
    }

    enum RenderingError: Error {
        case imageCreationFailed
        case contextCreationFailed
        case missingPixelData
    }

    @MainActor
    static func mask<Content: View>(
        scale: CGFloat,
        @ViewBuilder content: () -> Content
    ) throws -> [UInt8] {
        let renderer = ImageRenderer(content: content())
        renderer.scale = scale
        guard let image = renderer.cgImage else {
            throw RenderingError.imageCreationFailed
        }
        guard let context = CGContext(
            data: nil,
            width: image.width,
            height: image.height,
            bitsPerComponent: 8,
            bytesPerRow: image.width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            throw RenderingError.contextCreationFailed
        }
        context.setFillColor(gray: 0, alpha: 1)
        context.fill(
            CGRect(x: 0, y: 0, width: image.width, height: image.height)
        )
        context.draw(
            image,
            in: CGRect(x: 0, y: 0, width: image.width, height: image.height)
        )
        guard let data = context.data else {
            throw RenderingError.missingPixelData
        }

        return Array(
            UnsafeBufferPointer(
                start: data.assumingMemoryBound(to: UInt8.self),
                count: image.width * image.height
            )
        )
    }

    static func difference(
        between lhs: [UInt8],
        and rhs: [UInt8]
    ) -> Difference {
        guard lhs.count == rhs.count else {
            let count = max(lhs.count, rhs.count)
            return .init(
                changedPixels: count,
                materiallyChangedPixels: count,
                maximumDifference: 255
            )
        }

        var changedPixels = 0
        var materiallyChangedPixels = 0
        var maximumDifference = 0
        for (left, right) in zip(lhs, rhs) {
            let difference = abs(Int(left) - Int(right))
            if difference > 0 { changedPixels += 1 }
            if difference > 1 { materiallyChangedPixels += 1 }
            maximumDifference = max(maximumDifference, difference)
        }
        return .init(
            changedPixels: changedPixels,
            materiallyChangedPixels: materiallyChangedPixels,
            maximumDifference: maximumDifference
        )
    }
}
