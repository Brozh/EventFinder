import Foundation
import Tagged

struct Venue: Identifiable, Equatable {
  let id: Tagged<Venue, Int>
  let name: String
  let sortId: Int
  let imageUrl: URL?
}

extension Venue {
  struct Performance: Identifiable, Equatable {
    let id: Tagged<Self, Int>
    let date: Date
    let artist: Artist
  }
}

extension Venue {
  static func placeholder(id: Int = 1) -> Self {
    .init(
      id: .init(id),
      name: String(repeating: " ", count: .random(in: 10...50)),
      sortId: .random(in: 0...100),
      imageUrl: nil
    )
  }
}

extension Venue.Performance {
  static func placeholder(id: Int = 1) -> Self {
    .init(
      id: .init(id),
      date: Date(),
      artist: .placeholder()
    )
  }
}
