// CoupangEatsGenerator — 쿠팡이츠 order-receipt mock view.
// Source: classification spec receipt family; CoupangEats variant
// (red #FF1414 header, delivery info + items + total).
import SwiftUI

public struct CoupangEatsGenerator: MockGenerator {
    public let code: CategoryCode = .receiptCoupangEats

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(CoupangEatsView(seed: seed))
    }
}

struct CoupangEatsView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let store    = rng.pick(KoreanStores.all)
        let stamp    = KoreanTimestamps.receiptStamp(rng: &rng)
        let card     = rng.pick(KoreanCards.all)
        let courier  = rng.pick(KoreanNames.givenNames)
        let timeStr  = "\(rng.int(in: 8...22)):\(String(format: "%02d", rng.int(in: 0...59)))"
        let itemCount = rng.int(in: 2...3)

        var items: [(name: String, qty: Int, price: Int)] = []
        var subtotal = 0
        for _ in 0..<itemCount {
            let name = rng.pick(BaeminPool.menuItems)
            let qty  = rng.int(in: 1...2)
            let price = rng.int(in: 7...30) * 1000
            subtotal += price * qty
            items.append((name, qty, price))
        }
        let deliveryFee = rng.bool(0.5) ? 0 : 2500   // 쿠팡이츠 무료배달 자주 등장
        let total = subtotal + deliveryFee

        return VStack(spacing: 0) {
            statusBar(time: timeStr)
            header
            statusRow(courier: courier)
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
        .background(CoupangEatsColors.brandRed)
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

            Text("쿠팡이츠")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(height: 56)
        .background(CoupangEatsColors.brandRed)
    }

    private func statusRow(courier: String) -> some View {
        HStack(spacing: 8) {
            Text("배달완료")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(CoupangEatsColors.brandRed))
            Text("배달원: \(courier)님")
                .font(.system(size: 13))
                .foregroundStyle(Color.black.opacity(0.6))
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
        .padding(.top, 10)
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
    }

    private func totalsBlock(subtotal: Int, delivery: Int, total: Int, card: String) -> some View {
        VStack(spacing: 10) {
            row("상품금액", KoreanAmounts.formatKRW(subtotal))
            row("배달비", delivery == 0 ? "무료" : KoreanAmounts.formatKRW(delivery))
            Divider().padding(.vertical, 4)
            HStack {
                Text("총 결제금액")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(KoreanAmounts.formatKRW(total))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(CoupangEatsColors.brandRed)
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

private enum CoupangEatsColors {
    static let brandRed = Color(red: 255.0/255.0, green: 20.0/255.0, blue: 20.0/255.0) // #FF1414
}
