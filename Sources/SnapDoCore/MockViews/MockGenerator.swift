// MockGenerator — protocol every category generator implements.
// Source: classification spec §3 (visual detail), §4.1 (CLI interface).
//
// The generator owns randomisation: given a deterministic seed, it produces
// a SwiftUI view that the renderer turns into a PNG. Determinism makes the
// pipeline reproducible (same seed → same image), which is critical for
// debugging weak categories during cycle 1-5 reinforcement.
import Foundation
import SwiftUI

public protocol MockGenerator: Sendable {
    /// The category produced by this generator.
    var code: CategoryCode { get }

    /// Returns a view to render. The seed should be the only source of randomness.
    @MainActor
    func makeView(seed: UInt64) -> AnyView
}

/// Tiny seedable RNG (xorshift64*). Lets generators stay deterministic and Sendable.
/// Source: standard reference, public domain.
public struct SeededRNG: RandomNumberGenerator, Sendable {
    private var state: UInt64

    public init(seed: UInt64) {
        // Avoid 0 which would lock the generator at 0 forever.
        self.state = seed == 0 ? 0xDEAD_BEEF_CAFE_F00D : seed
    }

    public mutating func next() -> UInt64 {
        state ^= state >> 12
        state ^= state << 25
        state ^= state >> 27
        return state &* 2685821657736338717
    }
}

public extension SeededRNG {
    mutating func pick<T>(_ array: [T]) -> T {
        precondition(!array.isEmpty)
        let i = Int(next() % UInt64(array.count))
        return array[i]
    }

    mutating func int(in range: ClosedRange<Int>) -> Int {
        let span = UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(next() % span)
    }

    mutating func double(in range: ClosedRange<Double>) -> Double {
        let n = Double(next() & 0xFFFFFFFFFFFFF) / Double(0xFFFFFFFFFFFFF)
        return range.lowerBound + n * (range.upperBound - range.lowerBound)
    }

    mutating func bool(_ trueProbability: Double) -> Bool {
        return double(in: 0...1) < trueProbability
    }
}
