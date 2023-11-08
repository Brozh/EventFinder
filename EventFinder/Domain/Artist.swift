import Tagged
import Foundation

struct Artist: Identifiable, Equatable {
  let id: Tagged<Artist, Int>
  let name: String
  let genre: String
  let imageUrl: URL?
}

extension Artist {
  static func placeholder(id: Int = 1) -> Artist {
    .init(
      id: .init(id),
      name: String(repeating: " ", count: .random(in: 10...20)),
      genre: String(repeating: " ", count: .random(in: 3...10)),
      imageUrl: nil
    )
  }
}
