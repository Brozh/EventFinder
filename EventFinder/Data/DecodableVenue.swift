import Tagged
import Foundation

struct DecodableVenue: Decodable {
  let id: Tagged<Venue, Int>
  let name: String
  let sortId: Int
}

extension DecodableVenue {
  struct Performance: Decodable {
    let id: Venue.Performance.ID
    let date: Date
    let artist: DecodableArtist
  }
}

extension DecodableVenue {
  func asVenue(imageBaseUrl: URL) -> Venue {
    .init(
      id: id,
      name: name,
      sortId: sortId,
      imageUrl: imageBaseUrl
        .appending(path: "venues")
        .appending(path: name.replacingOccurrences(of: " ", with: "+") + ".png")
    )
  }
}

extension DecodableVenue.Performance {
  func asPerformance(imageBaseUrl: URL) -> Venue.Performance {
    .init(
      id: id,
      date: date,
      artist: artist.asArtist(imageBaseUrl: imageBaseUrl)
    )
  }
}
