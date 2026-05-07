// Haptic mapping. Source: docs/design-tokens-spec.md §5 + motion guide v1 §6.
// One enum for every UX moment. Callers say `SDHaptic.cardSwipeCommit.fire()`.
//
// macOS does NOT have UIKit haptic generators; calls are no-ops on macOS so
// SnapDoCore stays cross-platform (iOS app + macOS trainer share this lib).
import Foundation

public enum SDHaptic {
    // MARK: B-group (received-inbox screens)
    /// B1 swipe-to-delete commit threshold.
    case cardSwipeCommit            // .impact .medium
    /// B1 light tap feedback at action begin.
    case cardActionStart            // .impact .light
    /// B2 category cell selection while scrolling.
    case categoryHover              // .selection
    /// B2 success after category change applies.
    case categoryChangeApplied      // .notification .success
    /// B3 toast appears (variant-aware).
    case toastSuccess               // .notification .success
    case toastWarning               // .notification .warning
    case toastError                 // .notification .error
    // MARK: D-group (detail / sheet)
    /// D1 sheet close commit.
    case sheetDismiss               // .impact .light
    // MARK: F-group (settings)
    /// F4 toggle flip.
    case settingsToggle             // .impact .light
    // MARK: Snap pipeline events
    case snapCreateSuccess          // .notification .success
    case destructiveConfirm         // .notification .warning

    /// Fires the haptic. Must be called on the main actor (typical SwiftUI body / button handler).
    @MainActor
    public func fire() {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        Self.fireImpl(self)
        #endif
    }

    #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
    @MainActor
    private static func fireImpl(_ event: SDHaptic) {
        switch event {
        case .cardSwipeCommit:
            let g = UIImpactFeedbackGenerator(style: .medium); g.prepare(); g.impactOccurred()
        case .cardActionStart, .sheetDismiss, .settingsToggle:
            let g = UIImpactFeedbackGenerator(style: .light); g.prepare(); g.impactOccurred()
        case .categoryHover:
            let g = UISelectionFeedbackGenerator(); g.prepare(); g.selectionChanged()
        case .categoryChangeApplied, .toastSuccess, .snapCreateSuccess:
            let g = UINotificationFeedbackGenerator(); g.prepare(); g.notificationOccurred(.success)
        case .toastWarning, .destructiveConfirm:
            let g = UINotificationFeedbackGenerator(); g.prepare(); g.notificationOccurred(.warning)
        case .toastError:
            let g = UINotificationFeedbackGenerator(); g.prepare(); g.notificationOccurred(.error)
        }
    }
    #endif
}

#if canImport(UIKit)
import UIKit
#endif
