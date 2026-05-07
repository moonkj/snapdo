// SnapImageRenderer — SwiftUI View → CGImage → PNG file.
// Source: classification spec §4.3 (renderer) + §4.6 (output folder layout).
//
// We use SwiftUI's modern `ImageRenderer` (macOS 13+/iOS 16+). It handles
// off-screen rendering, scale, and proposed size identically to the
// NSHostingController pseudocode in the spec, with less boilerplate.
//
// Default canvas: 1170 × 2532 px @ 1× scale = iPhone 14 Pro logical pts at @3x.
// We render at logical points 390 × 844 with scale 3.0 to land on the spec target.
import Foundation
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

public enum SnapImageRendererError: Error, LocalizedError {
    case renderFailed
    case pngEncodeFailed
    case writeFailed(URL)

    public var errorDescription: String? {
        switch self {
        case .renderFailed:        return "ImageRenderer produced no CGImage."
        case .pngEncodeFailed:     return "Failed to encode CGImage to PNG."
        case .writeFailed(let u):  return "Failed to write PNG to \(u.path)."
        }
    }
}

public struct SnapImageRenderer {
    /// Default canvas: iPhone 14 Pro logical points (390 × 844) @ scale 3 → 1170 × 2532 px.
    public static let defaultLogicalSize = CGSize(width: 390, height: 844)
    public static let defaultScale: CGFloat = 3.0

    public init() {}

    /// Render a SwiftUI view to a CGImage.
    @MainActor
    public func render<V: View>(
        _ view: V,
        logicalSize: CGSize = defaultLogicalSize,
        scale: CGFloat = defaultScale
    ) throws -> CGImage {
        let renderer = ImageRenderer(content:
            view
                .frame(width: logicalSize.width, height: logicalSize.height)
                .environment(\.colorScheme, .light) // base; views can override
        )
        renderer.scale = scale
        guard let cg = renderer.cgImage else {
            throw SnapImageRendererError.renderFailed
        }
        return cg
    }

    /// Render and write a PNG file. Returns the URL written.
    @MainActor
    public func renderPNG<V: View>(
        _ view: V,
        to url: URL,
        logicalSize: CGSize = defaultLogicalSize,
        scale: CGFloat = defaultScale
    ) throws -> URL {
        let cg = try render(view, logicalSize: logicalSize, scale: scale)
        try Self.writePNG(cg, to: url)
        return url
    }

    /// Encodes a CGImage to PNG and writes to disk. Cross-platform.
    public static func writePNG(_ image: CGImage, to url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        #if canImport(AppKit)
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw SnapImageRendererError.pngEncodeFailed
        }
        do {
            try data.write(to: url)
        } catch {
            throw SnapImageRendererError.writeFailed(url)
        }
        #elseif canImport(UIKit)
        let ui = UIImage(cgImage: image)
        guard let data = ui.pngData() else {
            throw SnapImageRendererError.pngEncodeFailed
        }
        do {
            try data.write(to: url)
        } catch {
            throw SnapImageRendererError.writeFailed(url)
        }
        #else
        throw SnapImageRendererError.pngEncodeFailed
        #endif
    }
}

/// Layout helper: build the canonical output URL per spec §4.6.
/// `~/SnapDoTraining/<topCategory>/<fileSlug>_<index>.png`
public func snapTrainingOutputURL(
    base: URL,
    code: CategoryCode,
    index: Int,
    pad: Int = 4
) -> URL {
    let folder = base.appendingPathComponent(code.topCategory.folderName, isDirectory: true)
    let name = String(format: "%@_%0\(pad)d.png", code.fileSlug, index)
    return folder.appendingPathComponent(name)
}
