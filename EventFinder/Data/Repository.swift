struct Repository {
  var getArtists: @Sendable () async throws -> [Artist]
}

import Foundation
import ComposableArchitecture

extension Repository: DependencyKey {
  static var liveValue: Self {
    let BASE_URL = "http://ec2-44-211-66-223.compute-1.amazonaws.com"
    return .init(
      getArtists: {
        // force unwrapped only because it's fully under our control and in that file
        let url = URL(string: "\(BASE_URL)/artists")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Artist].self, from: data)
      }
    )
  }
}

extension Repository {
  static var noop: Self {
    .init(
      getArtists: { [] }
    )
  }
}

extension DependencyValues {
  var repository: Repository {
    get { self[Repository.self] }
    set { self[Repository.self] = newValue }
  }
}
