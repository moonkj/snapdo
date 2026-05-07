// 41 sub-pattern category codes — single source of truth for the trainer.
// Source: classification spec v1 §1.1-§1.7 (total 41 sub-patterns × 13,600 imgs).
import Foundation

public enum CategoryCode: String, CaseIterable, Sendable {
    // MARK: receipt (13 sub-patterns, 4,300 imgs)
    case receiptKakaoPay        = "receipt.kakao_pay"
    case receiptTossTransfer    = "receipt.toss_transfer"
    case receiptTossPayment     = "receipt.toss_payment"
    case receiptKakaobank       = "receipt.kakaobank"
    case receiptCardKB          = "receipt.card_kb"
    case receiptCardShinhan     = "receipt.card_shinhan"
    case receiptCardSamsung     = "receipt.card_samsung"
    case receiptCardHyundai     = "receipt.card_hyundai"
    case receiptCardWoori       = "receipt.card_woori"
    case receiptNaverPay        = "receipt.naver_pay"
    case receiptBaemin          = "receipt.baemin"
    case receiptCoupangEats     = "receipt.coupang_eats"
    case receiptOnlineShopping  = "receipt.online_shopping"

    // MARK: place (4 sub-patterns, 1,500 imgs)
    case placeKakaomap          = "place.kakaomap"
    case placeNavermap          = "place.navermap"
    case placeAppleMaps         = "place.apple_maps"
    case placeAddressText       = "place.address_text"

    // MARK: conversation (8 sub-patterns, 3,200 imgs)
    case convKakao1on1Light     = "conv.kakao_1on1_light"
    case convKakao1on1Dark      = "conv.kakao_1on1_dark"
    case convKakaoGroupLight    = "conv.kakao_group_light"
    case convKakaoGroupDark     = "conv.kakao_group_dark"
    case convKakaoOpen          = "conv.kakao_open"
    case convImessageLight      = "conv.imessage_light"
    case convImessageDark       = "conv.imessage_dark"
    case convInstagramDM        = "conv.instagram_dm"

    // MARK: link (5 sub-patterns, 1,500 imgs)
    case linkSafariTop          = "link.safari_top"
    case linkSafariArticle      = "link.safari_article"
    case linkChrome             = "link.chrome"
    case linkYoutubeVideo       = "link.youtube_video"
    case linkSharedLinkCard     = "link.shared_link_card"

    // MARK: todo (5 sub-patterns, 1,100 imgs)
    case todoNotesLight         = "todo.notes_light"
    case todoNotesDark          = "todo.notes_dark"
    case todoReminders          = "todo.reminders"
    case todoChecklistText      = "todo.checklist_text"
    case todoImperativeText     = "todo.imperative_text"

    // MARK: other (6 sub-patterns, 2,000 imgs)
    case otherMeme              = "other.meme"
    case otherProductPhoto      = "other.product_photo"
    case otherFoodPhoto         = "other.food_photo"
    case otherScenery           = "other.scenery"
    case otherSelfiePortrait    = "other.selfie_portrait"
    case otherAppUnknown        = "other.app_unknown"

    /// Top-level category folder name for Create ML.
    public var topCategory: TopCategory {
        switch self {
        case .receiptKakaoPay, .receiptTossTransfer, .receiptTossPayment,
             .receiptKakaobank, .receiptCardKB, .receiptCardShinhan,
             .receiptCardSamsung, .receiptCardHyundai, .receiptCardWoori,
             .receiptNaverPay, .receiptBaemin, .receiptCoupangEats,
             .receiptOnlineShopping:
            return .receipt
        case .placeKakaomap, .placeNavermap, .placeAppleMaps, .placeAddressText:
            return .place
        case .convKakao1on1Light, .convKakao1on1Dark, .convKakaoGroupLight,
             .convKakaoGroupDark, .convKakaoOpen, .convImessageLight,
             .convImessageDark, .convInstagramDM:
            return .conversation
        case .linkSafariTop, .linkSafariArticle, .linkChrome,
             .linkYoutubeVideo, .linkSharedLinkCard:
            return .link
        case .todoNotesLight, .todoNotesDark, .todoReminders,
             .todoChecklistText, .todoImperativeText:
            return .todo
        case .otherMeme, .otherProductPhoto, .otherFoodPhoto,
             .otherScenery, .otherSelfiePortrait, .otherAppUnknown:
            return .other
        }
    }

    /// Number of synthetic images to generate per sub-pattern, per spec §1.1-§1.6.
    public var targetCount: Int {
        switch self {
        case .receiptKakaoPay:        return 500
        case .receiptTossTransfer:    return 500
        case .receiptTossPayment:     return 300
        case .receiptKakaobank:       return 400
        case .receiptCardKB:          return 300
        case .receiptCardShinhan:     return 300
        case .receiptCardSamsung:     return 300
        case .receiptCardHyundai:     return 300
        case .receiptCardWoori:       return 200
        case .receiptNaverPay:        return 300
        case .receiptBaemin:          return 300
        case .receiptCoupangEats:     return 200
        case .receiptOnlineShopping:  return 400

        case .placeKakaomap:          return 600
        case .placeNavermap:          return 500
        case .placeAppleMaps:         return 200
        case .placeAddressText:       return 200

        case .convKakao1on1Light:     return 700
        case .convKakao1on1Dark:      return 700
        case .convKakaoGroupLight:    return 400
        case .convKakaoGroupDark:     return 400
        case .convKakaoOpen:          return 300
        case .convImessageLight:      return 200
        case .convImessageDark:       return 200
        case .convInstagramDM:        return 300

        case .linkSafariTop:          return 400
        case .linkSafariArticle:      return 300
        case .linkChrome:             return 200
        case .linkYoutubeVideo:       return 300
        case .linkSharedLinkCard:     return 300

        case .todoNotesLight:         return 300
        case .todoNotesDark:          return 200
        case .todoReminders:          return 200
        case .todoChecklistText:      return 200
        case .todoImperativeText:     return 200

        case .otherMeme:              return 500
        case .otherProductPhoto:      return 400
        case .otherFoodPhoto:         return 300
        case .otherScenery:           return 300
        case .otherSelfiePortrait:    return 200
        case .otherAppUnknown:        return 300
        }
    }
}

public enum TopCategory: String, CaseIterable, Sendable {
    case receipt, place, conversation, link, todo, other

    /// Folder name for Create ML auto-labelling. Source: spec §4.6.
    public var folderName: String { rawValue }
}

public extension CategoryCode {
    /// `conv_kakao_1on1_light` for filenames.
    var fileSlug: String {
        rawValue.replacingOccurrences(of: ".", with: "_")
    }
}
