// AccuracyReport — per-category accuracy measurement utility.
// Source: classification spec §8.2 (verification matrix per Cycle).
//
// Use case (Phase C → D):
//   1. Drop manually-labelled phone screenshots into ~/SnapDoTest/<topCategory>/
//   2. Run classifier over each, compare argmax vs folder name.
//   3. Print confusion matrix + per-category accuracy + average.
//
// This file just declares the data types; the runner script lives in SnapDoTrainer.
import Foundation

public struct AccuracyReport: Sendable, Equatable {
    public struct Cell: Sendable, Equatable {
        public let category: TopCategory
        public let correct: Int
        public let total: Int
        public var accuracy: Double { total == 0 ? 0 : Double(correct) / Double(total) }
        public init(category: TopCategory, correct: Int, total: Int) {
            self.category = category
            self.correct = correct
            self.total = total
        }
    }

    /// rows[gt][pred] = count. Six-by-six confusion matrix.
    public let confusion: [TopCategory: [TopCategory: Int]]
    public let perCategory: [Cell]
    public let average: Double

    public init(
        confusion: [TopCategory: [TopCategory: Int]],
        perCategory: [Cell],
        average: Double
    ) {
        self.confusion = confusion
        self.perCategory = perCategory
        self.average = average
    }

    /// Pretty-print as the table shape in spec §8.2.
    public func formattedTable() -> String {
        // String(format: %s ...) doesn't accept Swift String; pad manually.
        func pad(_ s: String, _ w: Int) -> String {
            s + String(repeating: " ", count: max(0, w - s.count))
        }
        var lines: [String] = []
        lines.append(pad("category", 14) + pad("correct", 12) + "accuracy")
        lines.append(String(repeating: "-", count: 36))
        for cell in perCategory {
            let pct = Int(cell.accuracy * 100)
            let mark = pct < 70 ? " ← weak" : ""
            let correctStr = "\(cell.correct)/\(cell.total)"
            let pctStr = "\(pct)%"
            lines.append(pad(cell.category.rawValue, 14) + pad(correctStr, 12) + pad(pctStr, 6) + mark)
        }
        lines.append(String(repeating: "-", count: 36))
        lines.append(pad("average", 14) + pad("\(Int(average * 100))%", 12))
        return lines.joined(separator: "\n")
    }

    public func formattedConfusion() -> String {
        func pad(_ s: String, _ w: Int) -> String {
            s + String(repeating: " ", count: max(0, w - s.count))
        }
        let cats = TopCategory.allCases
        var lines: [String] = []
        var header = pad("", 10)
        for c in cats { header += pad(String(c.rawValue.prefix(6)), 7) }
        lines.append(header)
        for gt in cats {
            var row = pad(String(gt.rawValue.prefix(8)), 10)
            for pred in cats {
                let n = confusion[gt]?[pred] ?? 0
                row += pad("\(n)", 7)
            }
            lines.append(row)
        }
        return lines.joined(separator: "\n")
    }
}

public enum AccuracyMeter {
    /// Builds a report from (groundTruth, predicted) pairs.
    public static func make(
        from pairs: [(gt: TopCategory, pred: TopCategory)]
    ) -> AccuracyReport {
        var confusion: [TopCategory: [TopCategory: Int]] = [:]
        var totalByCat: [TopCategory: Int] = [:]
        var correctByCat: [TopCategory: Int] = [:]

        for cat in TopCategory.allCases {
            confusion[cat] = Dictionary(uniqueKeysWithValues: TopCategory.allCases.map { ($0, 0) })
            totalByCat[cat] = 0
            correctByCat[cat] = 0
        }

        for (gt, pred) in pairs {
            confusion[gt, default: [:]][pred, default: 0] += 1
            totalByCat[gt, default: 0] += 1
            if gt == pred { correctByCat[gt, default: 0] += 1 }
        }

        let cells = TopCategory.allCases.map { cat in
            AccuracyReport.Cell(
                category: cat,
                correct: correctByCat[cat] ?? 0,
                total: totalByCat[cat] ?? 0
            )
        }
        let totals = cells.reduce(0) { $0 + $1.total }
        let corrects = cells.reduce(0) { $0 + $1.correct }
        let avg = totals == 0 ? 0 : Double(corrects) / Double(totals)
        return AccuracyReport(confusion: confusion, perCategory: cells, average: avg)
    }
}
