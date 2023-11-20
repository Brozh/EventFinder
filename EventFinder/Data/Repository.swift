import Foundation
import Dependencies
import XCTestDynamicOverlay

struct Repository {
  var getArtists: @Sendable () async throws -> [Artist]
  var getVenues: @Sendable () async throws -> [Venue]
  var getArtistPerformances: @Sendable (Artist.ID, Date, Date) async throws -> [Artist.Performance]
  var getVenuePerformances: @Sendable (Venue.ID, Date, Date) async throws -> [Venue.Performance]
}

extension Repository {
  static let noop = Self(
    getArtists: { [] },
    getVenues: { [] },
    getArtistPerformances: { _, _, _ in [] },
    getVenuePerformances: { _, _, _ in [] }
  )
}

extension Repository {
  static func waitForever(_ waitSeconds: UInt64 = 100) -> Self {
    .init(
      getArtists: {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      },
      getVenues: {
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      },
      getArtistPerformances: { _, _, _ in
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      },
      getVenuePerformances: { _, _, _ in
        try await Task.sleep(nanoseconds: NSEC_PER_SEC * waitSeconds)
        throw URLError(.badURL)
      }
    )
  }
}

extension Repository: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    getArtists: unimplemented("\(Self.self).getArtists"),
    getVenues: unimplemented("\(Self.self).getVenues"),
    getArtistPerformances: unimplemented("\(Self.self).getArtistPerformances"),
    getVenuePerformances: unimplemented("\(Self.self).getVenuePerformances")
  )
}

extension DependencyValues {
  var repository: Repository {
    get { self[Repository.self] }
    set { self[Repository.self] = newValue }
  }
}
