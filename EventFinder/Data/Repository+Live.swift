import Foundation
import ComposableArchitecture

extension Repository: DependencyKey {
  static var liveValue: Self {
    let baseUrl = URL(string: "http://ec2-44-211-66-223.compute-1.amazonaws.com")
    let imageBaseUrl = URL(string: "https://songleap.s3.amazonaws.com")

    return .init(
      getArtists: {
        // force unwrapped only because it's fully under our control and in that file
        guard let url = baseUrl?.appending(path: "artists"), let imageBaseUrl else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodableArtists = try JSONDecoder().decode([DecodableArtist].self, from: data)
        return decodableArtists.map { $0.asArtist(with: imageBaseUrl) }
      }
    )
  }
}

extension DependencyValues {
  var repository: Repository {
    get { self[Repository.self] }
    set { self[Repository.self] = newValue }
  }
}
