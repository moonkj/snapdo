// MLClassifier — Core ML softmax over the 6 TopCategory buckets. Spec §5.
// Phase E1 implements with VNCoreMLRequest + Vision Vision pipeline.
//
// This file declares the abstract surface; concrete VisionMLClassifier lands in Phase E
// once SnapDoClassifier.mlmodel is trained in Phase C.
import Foundation
import CoreGraphics

public protocol MLClassifier: Sendable {
    /// Returns softmax-normalised scores for all 6 top categories.
    /// Sum of values ≈ 1.0.
    func classify(_ image: CGImage) async throws -> [TopCategory: Double]
}

/// Uniform-prior placeholder for tests / pre-Phase-C development.
public struct UniformMLClassifier: MLClassifier {
    public init() {}
    public func classify(_ image: CGImage) async throws -> [TopCategory: Double] {
        let v = 1.0 / Double(TopCategory.allCases.count)
        return Dictionary(uniqueKeysWithValues: TopCategory.allCases.map { ($0, v) })
    }
}
