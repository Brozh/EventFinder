import Tagged
import Foundation

struct DecodableArtist: Decodable {
  let id: Tagged<Artist, Int>
  let name: String
  let genre: String
}

extension DecodableArtist {
  func asArtist(with imageBaseUrl: URL) -> Artist {
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
