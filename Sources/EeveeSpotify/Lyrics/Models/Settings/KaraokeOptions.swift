import Foundation

enum KaraokeTextAlignment: String, Codable, CaseIterable {
    case leading
    case center
    case trailing

    var displayName: String {
        switch self {
        case .leading: return "左"
        case .center: return "居中"
        case .trailing: return "右"
        }
    }
}

struct KaraokeOptions: Codable, Hashable {
    var textAlignment: KaraokeTextAlignment
    /// When true, lines flow bottom-to-top instead of top-to-bottom: the
    /// active line sits lower on screen, already-sung lines end up below
    /// it, and upcoming lines above — the reverse of the normal reading
    /// order.
    var reversedDirection: Bool
}
