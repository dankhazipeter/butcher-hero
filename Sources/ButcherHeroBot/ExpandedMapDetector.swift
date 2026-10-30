import Foundation
import CoreGraphics
import ImageIO

/// Matches the fixed minus-magnifier, not the changing map or the biome below it.
final class ExpandedMapDetector {
    private let reference: [UInt8]?
    private let greenReference: [UInt8]?
    private static let side = 24
    init(referencePath: String = "docs/runs/20260919-133816-62ee5a19-observe/frame-00000.png") {
        if let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: referencePath) as CFURL, nil),
           let image = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            reference = Self.patch(image)
        } else { reference = nil }
        // Same minus icon against the bright snowy/green biome. The old full
        // patch included its background and rejected this verified open map.
        let greenPath = "docs/runs/20260919-192415-29b0f273-observe/frame-00000.png"
        if let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: greenPath) as CFURL, nil),
           let image = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            greenReference = Self.patch(image)
        } else { greenReference = nil }
    }
    private static func patch(_ image: CGImage) -> [UInt8]? {
        let rect = CGRect(x: Double(image.width) * 585 / 637,
                          y: Double(image.height) * 58 / 882,
                          width: Double(image.width) * 38 / 637,
                          height: Double(image.height) * 43 / 882).integral
        guard let crop = image.cropping(to: rect),
              let context = CGContext(data: nil, width: side, height: side,
                  bitsPerComponent: 8, bytesPerRow: side,
                  space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0) else { return nil }
        context.interpolationQuality = .low
        context.draw(crop, in: CGRect(x: 0, y: 0, width: side, height: side))
        guard let data = context.data else { return nil }
        return Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: side * side))
    }
    func difference(_ image: CGImage) -> Double? {
        guard let patch = Self.patch(image) else { return nil }
        var best: Double?
        for reference in [reference, greenReference].compactMap({ $0 }) {
            var total = 0
            for (referencePixel, imagePixel) in zip(reference, patch) {
                total += abs(Int(referencePixel) - Int(imagePixel))
            }
            let difference = Double(total) / Double(reference.count)
            best = min(best ?? difference, difference)
        }
        return best
    }
    func matches(_ image: CGImage) -> Bool { (difference(image) ?? .infinity) < 18 }
}
