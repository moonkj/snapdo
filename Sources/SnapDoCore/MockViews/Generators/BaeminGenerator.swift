// BaeminGenerator — 배달의민족 (배민) order-receipt mock view.
// Source: classification spec receipt family; Baemin variant
// (mint #2AC1BC header, order list + total + 배달완료 badge).
import SwiftUI

public struct BaeminGenerator: MockGenerator {
    public let code: CategoryCode = .receiptBaemin

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(BaeminView(seed: seed))
    }
}

struct BaeminView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let store   = rng.pick(KoreanStores.all)
        let stamp   = KoreanTimestamps.receiptStamp(rng: &rng)
        let card    = rng.pick(KoreanCards.all)
        let timeStr = "\(rng.int(in: 8...22)):\(String(format: "%02d", rng.int(in: 0...59)))"
        let itemCount = rng.int(in: 2...4)

        var items: [(name: String, qty: Int, price: Int)] = []
        var subtotal = 0
        for _ in 0..<itemCount {
            let name = rng.pick(BaeminPool.menuItems)
            let qty  = rng.int(in: 1...2)
            let price = rng.int(in: 6...28) * 1000
            subtotal += price * qty
            items.append((name, qty, price))
        }
        let deliveryFee = rng.bool(0.5) ? 3000 : 0
        let total = subtotal + deliveryFee

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            header
            badge
            storeBlock(store: store, stamp: stamp)
            itemList(items)
            totalsBlock(subtotal: subtotal, delivery: deliveryFee, total: total, card: card.displayName)
            Spacer(minLength: 0)
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    private func statusBar(time: String) -> some View {
        HStack {
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.white)
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "wifi").font(.system(size: 14))
                Image(systemName: "battery.100").font(.system(size: 18))
            }
            .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 24)
        .frame(height: 47)
        .background(BaeminColors.mint)
    }

    private var header: some View {
        ZStack {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding(.horizontal, 16)

            Text("배달의민족")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(height: 56)
        .background(BaeminColors.mint)
    }

    private var badge: some View {
        HStack {
            Text("배달완료")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(BaeminColors.mint)
                )
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private func storeBlock(store: String, stamp: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(store)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.black)
            Text(stamp)
                .font(.system(size: 13))
                .foregroundStyle(Color.black.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private func itemList(_ items: [(name: String, qty: Int, price: Int)]) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.black)
                        Text("\(item.qty)개")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                    Spacer()
                    Text(KoreanAmounts.formatKRW(item.price * item.qty))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.black)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(BaeminColors.rowDivider, alignment: .top)
    }

    private func totalsBlock(subtotal: Int, delivery: Int, total: Int, card: String) -> some View {
        VStack(spacing: 10) {
            row("주문금액", KoreanAmounts.formatKRW(subtotal))
            row("배달팁", KoreanAmounts.formatKRW(delivery))
            Divider().padding(.vertical, 4)
            HStack {
                Text("총 결제금액")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(KoreanAmounts.formatKRW(total))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(BaeminColors.mint)
            }
            row("결제수단", card)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.55))
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(Color.black)
        }
    }
}

private enum BaeminColors {
    static let mint       = Color(red: 42.0/255.0, green: 193.0/255.0, blue: 188.0/255.0) // #2AC1BC
    static let rowDivider = Color.black.opacity(0.05)
}

enum BaeminPool {
    static let menuItems: [String] = [
        "양념치킨", "후라이드치킨", "반반치킨", "마라탕", "짜장면",
        "짬뽕", "탕수육", "쌀국수", "초밥세트", "김치찌개",
        "된장찌개", "떡볶이", "순대", "튀김", "햄버거 세트",
        "피자 라지", "치즈피자", "페퍼로니피자", "파스타", "스테이크"
    ]
}
