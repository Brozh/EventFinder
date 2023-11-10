import Foundation

struct Repository {
  var getArtists: @Sendable () async throws -> [Artist]
  var getVenues: @Sendable () async throws -> [Venue]
  var getArtistPerformances: @Sendable (Artist.ID) async throws -> [Artist.Performance]
  var getVenuePerformances: @Sendable (Venue.ID) async throws -> [Venue.Performance]
}

extension Repository {
  static var noop: Self {
    .init(
      getArtists: { [] },
      getVenues: { [] },
      getArtistPerformances: { _ in [] },
      getVenuePerformances: { _ in [] }
    )
  }
}

extension Repository {
  static func waitThenFail(wait waitSeconds: UInt64 = 10) -> Self {
    .init(
      getArtists: {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      },
      getVenues: { 
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      },
      getArtistPerformances: { _ in 
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      },
      getVenuePerformances: { _ in 
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      }
    )
  }
}
