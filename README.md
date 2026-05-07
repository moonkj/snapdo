# SnapDo

> 스크린샷이 다음 단계로, 1탭으로.

iOS app that auto-organizes your screenshots. Six categories (Receipt / Place / Conversation / Link / Todo / Other), 100% on-device ML, Korean hyper-local (KakaoTalk / Toss / Naver / KB·신한·삼성·현대·우리 cards).

- **Stack:** Swift 5.9 · SwiftUI · SwiftData · Vision · Create ML
- **Targets:** iOS 17+ (app), macOS 14+ (training CLI)
- **Pricing:** ₩3,900 one-time IAP + 14-day free trial. No subscription. No ads. No server.

## Project structure

```
SnapDo.xcodeproj
├── SnapDo            (iOS app target)
├── SnapDoCore        (Swift Package — design tokens, classifier, mock views)
└── SnapDoTrainer     (macOS CLI — synthetic data generator)
```

## Build status

🚧 Phase A1 — Xcode project initialization (in progress).

See [Tasklist.md](./Tasklist.md) for live progress and [process.md](./process.md) for build log.

## Agent team

This project is built by a multi-agent team (UX · Architect · Coder · Debugger · Test · Reviewer · Performance · DocWriter). See [AGENTS.md](./AGENTS.md) for the charter.

---

© 2026 moonkj. All rights reserved.
