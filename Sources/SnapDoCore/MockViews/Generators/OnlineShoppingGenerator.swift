// OnlineShoppingGenerator — Generic online-shopping order receipt mock view.
// Source: classification spec receipt family; e-commerce variant
// (brand banner + product rows with thumbnail + total + delivery info).
import SwiftUI

public struct OnlineShoppingGenerator: MockGenerator {
    public let code: CategoryCode = .receiptOnlineShopping

    public init() {}

    @MainActor
    public func makeView(seed: UInt64) -> AnyView {
        AnyView(OnlineShoppingView(seed: seed))
    }
}

struct OnlineShoppingView: View {
    let seed: UInt64

    var body: some View {
        var rng = SeededRNG(seed: seed)
        let brand     = rng.pick(OnlineShoppingPool.brands)
        let stamp     = KoreanTimestamps.receiptStamp(rng: &rng)
        let card      = rng.pick(KoreanCards.all)
        let recipient = rng.pick(KoreanNames.givenNames)
        let timeStr   = "\(rng.int(in: 8...22)):\(String(format: "%02d", rng.int(in: 0...59)))"
        let count     = rng.int(in: 1...3)

        var products: [(name: String, qty: Int, price: Int)] = []
        var subtotal = 0
        for _ in 0..<count {
            let name  = rng.pick(OnlineShoppingPool.productNames)
            let qty   = rng.int(in: 1...2)
            let price = rng.int(in: 5...80) * 1000
            subtotal += price * qty
            products.append((name, qty, price))
        }
        let shipping = rng.bool(0.6) ? 0 : 3000
        let total    = subtotal + shipping

        return VStack(spacing: 0) {
            statusBar(time: timeStr, color: brand.color)
            header(brand: brand)
            statusRow(stamp: stamp)
            productList(products)
            deliveryBlock(recipient: recipient)
            totalsBlock(subtotal: subtotal, shipping: shipping, total: total, card: card.displayName, accent: brand.color)
            Spacer(minLength: 0)
        }
        .frame(width: 390, height: 844)
        .background(Color.white)
    }

    private func statusBar(time: String, color: Color) -> some View {
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
        .background(color)
    }

    private func header(brand: OnlineShoppingPool.Brand) -> some View {
        ZStack {
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                Spacer()
                Image(systemName: "cart")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal, 16)

            Text(brand.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(height: 56)
        .background(brand.color)
    }

    private func statusRow(stamp: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("주문 완료")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.black)
            Text(stamp)
                .font(.system(size: 13))
                .foregroundStyle(Color.black.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func productList(_ products: [(name: String, qty: Int, price: Int)]) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(products.enumerated()), id: \.offset) { _, p in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 60, height: 60)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(p.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.black)
                            .lineLimit(2)
                        Text("\(p.qty)개")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                    Spacer()
                    Text(KoreanAmounts.formatKRW(p.price * p.qty))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.black)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    private func deliveryBlock(recipient: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("배송 정보")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.6))
            Text("\(recipient) · 서울특별시 강남구 테헤란로 123")
                .font(.system(size: 13))
                .foregroundStyle(Color.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.04))
        )
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private func totalsBlock(subtotal: Int, shipping: Int, total: Int, card: String, accent: Color) -> some View {
        VStack(spacing: 10) {
            row("상품금액", KoreanAmounts.formatKRW(subtotal))
            row("배송비", shipping == 0 ? "무료" : KoreanAmounts.formatKRW(shipping))
            Divider().padding(.vertical, 4)
            HStack {
                Text("총 결제금액")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text(KoreanAmounts.formatKRW(total))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(accent)
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

enum OnlineShoppingPool {
    struct Brand: Sendable {
        let name: String
        let color: Color
    }

    static let brands: [Brand] = [
        Brand(name: "쿠팡",            color: Color(red: 255.0/255.0, green: 20.0/255.0,  blue: 20.0/255.0)),  // #FF1414
        Brand(name: "11번가",          color: Color(red: 255.0/255.0, green: 33.0/255.0,  blue: 71.0/255.0)),  // #FF2147
        Brand(name: "G마켓",           color: Color(red: 0.0/255.0,   green: 161.0/255.0, blue: 75.0/255.0)),  // green
        Brand(name: "네이버 스마트스토어", color: Color(red: 3.0/255.0,   green: 199.0/255.0, blue: 90.0/255.0)),  // #03C75A
        Brand(name: "옥션",            color: Color(red: 240.0/255.0, green: 80.0/255.0,  blue: 30.0/255.0))   // orange
    ]

    static let productNames: [String] = [
        "무선 블루투스 이어폰", "USB-C 충전 케이블", "스테인리스 텀블러 500ml",
        "면 100% 라운드 티셔츠", "데일리 백팩", "노트북 거치대",
        "주방용 실리콘 주걱 세트", "휴대용 보조배터리 20000mAh", "에코백 캔버스",
        "운동화 흰색 270mm", "차량용 핸드폰 거치대", "수면 안대 실크",
        "원목 도마", "유리 밀폐용기 4종", "모이스처 크림 50ml",
        "샴푸 500ml", "비타민C 1000mg 90정", "전동 칫솔",
        "무선 키보드", "USB 허브 4포트"
    ]
}
