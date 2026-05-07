// Augmentation — post-render image transforms to bridge sim-to-real gap.
// Source: classification spec §4.4 (augmentation table).
//
// Applied AFTER the SwiftUI view is rasterised, BEFORE writing the PNG.
// Probabilistic per spec table; intensity scaled by `Augmentation.Strength`.
//
// Pipeline order (deterministic for a given seed):
//   1. brightness  — always ±5..10%
//   2. color jitter — always ±3% per channel
//   3. scale        — always 95..105%
//   4. rotate       — 5% chance, ±0.5..1°
//   5. blur         — 10% chance, sigma 0.5..1.5
//   6. JPEG re-compress — 30% chance, quality 70..95
//
// Notch mask + status-bar variation are applied at view-construction time
// inside the generator (per §4.4 "always"), not here.
import CoreGraphics
import Foundation
import CoreImage

#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

public enum Augmentation {
    /// Spec §4.4 strength tier — controls amount, not probability.
    public enum Strength: String, Sendable {
        case none, light, medium, heavy
    }

    public struct Plan: Sendable {
        public let brightness: Double      // additive ±0..0.10 (sRGB scale)
        public let colorJitter: Double     // ±0..0.03 per channel
        public let scale: Double           // 0.95..1.05
        public let rotate: Double          // ±0..0.0175 rad (~1°)
        public let applyBlur: Bool
        public let blurSigma: Double       // 0.5..1.5 if applyBlur
        public let applyJPEG: Bool
        public let jpegQuality: Double     // 0.70..0.95 if applyJPEG

        public static let identity = Plan(
            brightness: 0, colorJitter: 0, scale: 1.0, rotate: 0,
            applyBlur: false, blurSigma: 0,
            applyJPEG: false, jpegQuality: 1.0
        )
    }

    /// Build a randomised plan. spec §4.4 probabilities + strength scaling.
    public static func plan<R: RandomNumberGenerator>(
        strength: Strength,
        rng: inout R
    ) -> Plan {
        guard strength != .none else { return .identity }
        let amp: Double = {
            switch strength {
            case .none: return 0
            case .light: return 0.5
            case .medium: return 1.0
            case .heavy: return 1.5
            }
        }()
        let jitterMax = 0.03 * amp
        let brightMax = 0.10 * amp
        let rotateMax = 0.0175 * amp // 1° in radians
        let blurProb = 0.10
        let jpegProb = 0.30
        let rotateProb = 0.05

        return Plan(
            brightness: Double.random(in: -brightMax...brightMax, using: &rng),
            colorJitter: Double.random(in: -jitterMax...jitterMax, using: &rng),
            scale: Double.random(in: (1 - 0.05*amp)...(1 + 0.05*amp), using: &rng),
            rotate: Bool.random(using: &rng) && Double.random(in: 0...1, using: &rng) < rotateProb
                ? Double.random(in: -rotateMax...rotateMax, using: &rng) : 0,
            applyBlur: Double.random(in: 0...1, using: &rng) < blurProb,
            blurSigma: Double.random(in: 0.5...(0.5 + 1.0*amp), using: &rng),
            applyJPEG: Double.random(in: 0...1, using: &rng) < jpegProb,
            jpegQuality: Double.random(in: 0.70...0.95, using: &rng)
        )
    }

    /// Apply the plan to a CGImage. May allocate. Returns a new CGImage.
    public static func apply(_ image: CGImage, plan: Plan) -> CGImage {
        var ci = CIImage(cgImage: image)
        let context = CIContext(options: nil)

        // 1. Brightness + color jitter via CIColorControls + CIColorMatrix.
        if plan.brightness != 0 || plan.colorJitter != 0 {
            let f = CIFilter(name: "CIColorControls")!
            f.setValue(ci, forKey: kCIInputImageKey)
            f.setValue(plan.brightness, forKey: kCIInputBrightnessKey)
            f.setValue(1.0, forKey: kCIInputContrastKey)
            f.setValue(1.0 + plan.colorJitter, forKey: kCIInputSaturationKey)
            if let out = f.outputImage { ci = out }
        }
        // 2. Scale (uniform).
        if plan.scale != 1.0 {
            ci = ci.transformed(by: CGAffineTransform(scaleX: plan.scale, y: plan.scale))
        }
        // 3. Rotate (radians).
        if plan.rotate != 0 {
            ci = ci.transformed(by: CGAffineTransform(rotationAngle: plan.rotate))
        }
        // 4. Blur.
        if plan.applyBlur, plan.blurSigma > 0 {
            let f = CIFilter(name: "CIGaussianBlur")!
            f.setValue(ci, forKey: kCIInputImageKey)
            f.setValue(plan.blurSigma, forKey: kCIInputRadiusKey)
            if let out = f.outputImage { ci = out }
        }

        guard let out = context.createCGImage(ci, from: ci.extent) else {
            return image
        }
        return out
    }

    /// Encode a CGImage as JPEG with the given quality, then decode back to CGImage.
    /// Used to simulate compression artefacts for §4.4 row "JPEG 압축 30% 확률 quality 70~95".
    public static func roundTripJPEG(_ image: CGImage, quality: Double) -> CGImage {
        let q = CGFloat(max(0.0, min(1.0, quality)))
        #if canImport(UIKit)
        let ui = UIImage(cgImage: image)
        guard let data = ui.jpegData(compressionQuality: q),
              let decoded = UIImage(data: data),
              let cg = decoded.cgImage else { return image }
        return cg
        #elseif canImport(AppKit)
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .jpeg, properties: [.compressionFactor: q]),
              let dec = NSBitmapImageRep(data: data),
              let cg = dec.cgImage else { return image }
        return cg
        #else
        return image
        #endif
    }
}
