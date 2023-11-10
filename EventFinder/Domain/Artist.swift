import Tagged
import Foundation

struct Artist: Identifiable, Equatable {
  let id: Tagged<Self, Int>
  let name: String
  let genre: String
  let imageUrl: URL?
}

extension Artist {
  struct Performance: Identifiable, Equatable {
    let id: Tagged<Self, Int>
    let date: Date
    let venue: Venue
  }
}

extension Artist {
  static func placeholder(id: Int = 1) -> Self {
    .init(
      id: .init(id),
      name: String(repeating: " ", count: .random(in: 10...20)),
      genre: String(repeating: " ", count: .random(in: 3...10)),
      imageUrl: nil
    )
  }
}

extension Artist.Performance {
  static func placeholder(id: Int = 1) -> Self {
    .init(
      id: .init(id),
      date: Date(),
      venue: .placeholder()
    )
  }
}
