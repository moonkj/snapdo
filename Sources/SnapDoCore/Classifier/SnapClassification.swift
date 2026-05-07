// SnapClassification — public types for the 4-stage classification pipeline.
// Source: classification spec §2 (Rule), §5 (ML), §6 (OCR), §6.4 (Fusion), §7.1 (confidence buckets).
//
// This file defines only the *interfaces* that the pipeline produces and consumes.
// Concrete implementations land in Phase E1: RuleEngine, MLClassifier, OCRReader, FusionEngine.
import Foundation

// MARK: - Top-level result

public struct SnapClassification: Sendable, Equatable {
    /// Resolved top-level category from spec §1 (the 6 buckets).
    public let category: TopCategory
    /// Best match within the category, when known. Optional for `other`.
    public let subPattern: CategoryCode?
    /// Final confidence ∈ [0, 1] after fusion (§6.4 → §7.1 bucket).
    public let confidence: Double
    /// Which signals contributed and at what weight.
    public let evidence: ClassificationEvidence
    /// Human-readable reason ("카카오톡 NavBar 매치", "ML(0.83) + OCR(0.21)", ...).
    public let reason: String

    public init(
        category: TopCategory,
        subPattern: CategoryCode?,
        confidence: Double,
        evidence: ClassificationEvidence,
        reason: String
    ) {
        self.category = category
        self.subPattern = subPattern
        self.confidence = confidence
        self.evidence = evidence
        self.reason = reason
    }
}

public struct ClassificationEvidence: Sendable, Equatable {
    public let ruleHit: RuleHit?            // spec §2 — present when a rule fired
    public let mlScores: [TopCategory: Double]  // spec §5 — softmax over 6 categories
    public let ocrSnippet: String?          // first 200 chars of OCR output (debug)
    public let ocrKeywordScores: [TopCategory: Double] // spec §6.3
    /// α / β / γ that fed into argmax (spec §6.4: α=1 if rule, β=0.7, γ=0.3).
    public let weights: FusionWeights

    public init(
        ruleHit: RuleHit? = nil,
        mlScores: [TopCategory: Double] = [:],
        ocrSnippet: String? = nil,
        ocrKeywordScores: [TopCategory: Double] = [:],
        weights: FusionWeights = .default
    ) {
        self.ruleHit = ruleHit
        self.mlScores = mlScores
        self.ocrSnippet = ocrSnippet
        self.ocrKeywordScores = ocrKeywordScores
        self.weights = weights
    }
}

public struct FusionWeights: Sendable, Equatable {
    /// α — rule weight. spec §6.4: 1.0 if a rule matched, 0.0 otherwise.
    public let rule: Double
    /// β — ML weight (0.7).
    public let ml: Double
    /// γ — OCR keyword weight (0.3).
    public let ocr: Double

    public init(rule: Double, ml: Double, ocr: Double) {
        self.rule = rule; self.ml = ml; self.ocr = ocr
    }

    public static let `default` = FusionWeights(rule: 0.0, ml: 0.7, ocr: 0.3)
    public static let ruleHit  = FusionWeights(rule: 1.0, ml: 0.7, ocr: 0.3)
}

// MARK: - Rule engine output

public struct RuleHit: Sendable, Equatable {
    public let category: TopCategory
    public let subPattern: CategoryCode?
    /// 0.95 per spec §2 ("매치 시 confidence 95%로 즉시 확정").
    public let baseConfidence: Double
    public let ruleID: RuleID

    public init(
        category: TopCategory,
        subPattern: CategoryCode?,
        baseConfidence: Double = 0.95,
        ruleID: RuleID
    ) {
        self.category = category
        self.subPattern = subPattern
        self.baseConfidence = baseConfidence
        self.ruleID = ruleID
    }
}

/// Symbolic rule identifiers — one per heuristic in spec §2.
public enum RuleID: String, Sendable, Equatable, CaseIterable {
    case kakaoNavBarLight     // §2.1
    case kakaoNavBarDark      // §2.1 dark
    case tossPaymentScreen    // §2.2
    case cardAlertKB          // §2.3
    case cardAlertShinhan     // §2.3
    case cardAlertSamsung     // §2.3
    case cardAlertHyundai     // §2.3
    case cardAlertWoori       // §2.3
    case kakaoPayCompletion   // §2.3 sibling
    case kakaobankCompletion  // §2.3 sibling
    case safariURLBar         // §2.4
    case kakaoMap             // §2.5
    case naverMap             // §2.5
}

// MARK: - Confidence buckets (spec §7.1)

public enum ConfidenceBucket: String, Sendable {
    case veryHigh   // 0.95 - 1.00 — "{cat}" 명확, 의심 X
    case high       // 0.80 - 0.95 — "{cat}" 명확
    case medium     // 0.65 - 0.80 — "{cat} 같아요"
    case low        // 0.50 - 0.65 — "분류 중" 사용자 도움 요청
    case veryLow    // 0.00 - 0.50 — "기타"

    public init(confidence: Double) {
        switch confidence {
        case 0.95...:        self = .veryHigh
        case 0.80..<0.95:    self = .high
        case 0.65..<0.80:    self = .medium
        case 0.50..<0.65:    self = .low
        default:             self = .veryLow
        }
    }
}

// MARK: - Pipeline protocol (Phase E1 implementations conform)

public protocol SnapClassifier: Sendable {
    /// Classify a CGImage end-to-end (rule → ML → OCR → fusion).
    func classify(_ image: CGImage) async -> SnapClassification
}

import CoreGraphics
