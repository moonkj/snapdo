// CreateMLBridge — wraps Apple's CreateML.MLImageClassifier for Phase C training.
// Source: classification spec §5.4 (학습 설정).
//
// macOS-only. Reads from a directory tree like:
//   <input>/<topCategory>/*.png    (Create ML auto-labels by folder name)
// Writes:
//   <output>/SnapDoClassifier.mlmodel
//
// CLI wiring lives in TrainerCLI.swift (`train` subcommand).
import Foundation

#if canImport(CreateML)
import CreateML
import CoreML

public enum CreateMLBridgeError: Error, LocalizedError {
    case directoryMissing(URL)
    case trainingFailed(String)
    case modelExportFailed(URL)

    public var errorDescription: String? {
        switch self {
        case .directoryMissing(let u):  return "Training directory missing: \(u.path)"
        case .trainingFailed(let msg):  return "Training failed: \(msg)"
        case .modelExportFailed(let u): return "Failed to write .mlmodel to \(u.path)"
        }
    }
}

public struct CreateMLBridge {
    public init() {}

    /// Trains an MLImageClassifier from `<input>/<category>/*.png` and writes the
    /// resulting `.mlmodel` to `<output>/SnapDoClassifier.mlmodel`.
    /// - Parameters:
    ///   - input: directory containing top-category sub-folders (`receipt`, `place`, ...).
    ///   - output: directory where the model should land. Created if missing.
    ///   - iterations: spec §5.4 — 50 to start, 100 for cycle reinforcement.
    public func train(
        input: URL,
        output: URL,
        iterations: Int = 50
    ) throws -> URL {
        let fm = FileManager.default
        guard fm.fileExists(atPath: input.path) else {
            throw CreateMLBridgeError.directoryMissing(input)
        }
        try fm.createDirectory(at: output, withIntermediateDirectories: true)

        // Source: spec §5.4 — Crop, Flip, Blur, Expose, Noise off (synth already noisy).
        // Note: Apple's enum doesn't expose `.rotate` (rotation is part of `.crop` in
        // recent Create ML versions); we keep the rest aligned with spec §5.4.
        let augmentations: MLImageClassifier.ImageAugmentationOptions =
            [.crop, .flip, .blur, .exposure]

        let params = MLImageClassifier.ModelParameters(
            featureExtractor: .scenePrint(revision: 1),
            validation: .split(strategy: .automatic),
            maxIterations: iterations,
            augmentationOptions: augmentations
        )

        let dataSource = MLImageClassifier.DataSource.labeledDirectories(at: input)

        print("Training MLImageClassifier (ScenePrint v1, \(iterations) iters, augs=\(augmentations))…")
        let started = Date()
        let classifier: MLImageClassifier
        do {
            classifier = try MLImageClassifier(trainingData: dataSource, parameters: params)
        } catch {
            throw CreateMLBridgeError.trainingFailed(String(describing: error))
        }
        let trainingSeconds = Date().timeIntervalSince(started)

        // Print metrics summary.
        let trainingMetrics = classifier.trainingMetrics
        let validationMetrics = classifier.validationMetrics
        print(String(format: "  training accuracy   : %.2f%%", (1 - trainingMetrics.classificationError) * 100))
        print(String(format: "  validation accuracy : %.2f%%", (1 - validationMetrics.classificationError) * 100))
        print(String(format: "  trained in %.1fs", trainingSeconds))

        // Export.
        let modelURL = output.appendingPathComponent("SnapDoClassifier.mlmodel")
        let metadata = MLModelMetadata(
            author: "SnapDo team",
            shortDescription: "Top-level snap classification (6 categories) trained on synthetic data per classification spec §5.",
            version: "0.1.0"
        )
        do {
            try classifier.write(to: modelURL, metadata: metadata)
        } catch {
            throw CreateMLBridgeError.modelExportFailed(modelURL)
        }
        print("Wrote \(modelURL.path)")
        return modelURL
    }
}
#else
// Stub for iOS / Linux — should never be reached because trainer is macOS-only.
public struct CreateMLBridge {
    public init() {}
    public func train(input: URL, output: URL, iterations: Int = 50) throws -> URL {
        fatalError("CreateML is macOS-only.")
    }
}
#endif
