import Tagged
import Foundation

struct DecodableArtist: Decodable {
  let id: Tagged<Artist, Int>
  let name: String
  let genre: String
}

extension DecodableArtist {
  struct Performance: Decodable {
    let id: Artist.Performance.ID
    let date: Date
    let artistId: Artist.ID
    let venue: DecodableVenue
  }
}

extension DecodableArtist {
  func asArtist(imageBaseUrl: URL) -> Artist {
    .init(
      id: id,
      name: name,
      genre: genre,
      imageUrl: imageBaseUrl
        .appending(path: "artists")
        .appending(path: name.replacingOccurrences(of: " ", with: "+") + ".png")
    )
  }
}

extension DecodableArtist.Performance {
  func asPerformance(imageBaseUrl: URL) -> Artist.Performance {
    .init(
      id: id,
      date: date,
      venue: venue.asVenue(imageBaseUrl: imageBaseUrl)
    )
  }
}
