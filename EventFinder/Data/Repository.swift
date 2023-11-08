import Foundation

struct Repository {
  var getArtists: @Sendable () async throws -> [Artist]
}

extension Repository {
  static var noop: Self {
    .init(
      getArtists: { [] }
    )
  }
}

extension Repository {
  static var urlError: Self {
    .init(
      getArtists: { throw URLError(.init(rawValue: 404)) }
    )
  }
}
