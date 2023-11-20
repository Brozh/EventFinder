import ComposableArchitecture
import Foundation

struct ArtistDetailFeature: Reducer {
  struct State: Equatable {
    var artist: Artist
    var performances: IdentifiedArrayOf<Artist.Performance> = []
    var isLoading = false
  }

  enum Action: Equatable {
    case onAppear
    case performancesDidLoad([Artist.Performance])
  }

  @Dependency(\.repository) var repository
  @Dependency(\.date) var now

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.performances.isEmpty, !state.isLoading else { return .none }
        state.isLoading = true
        state.performances = Self.placeholderPerformances
        return .run { [artistId = state.artist.id] send in
          try await send(.performancesDidLoad(performances(for: artistId)))
        }
      case let .performancesDidLoad(performances):
        state.isLoading = false
        state.performances = .init(uncheckedUniqueElements: performances.sorted { $0.date < $1.date })
        return .none
      }
    }
  }
}

// MARK: - Helpers
private extension ArtistDetailFeature {
  func performances(for artistId: Artist.ID) async throws -> [Artist.Performance] {
    let from = now()
    let to = from.addingTimeInterval(60 * 60 * 24 * 13) // seconds * minutes * hours * days

    return try await repository.getArtistPerformances(artistId, from, to)
  }
}

// MARK: - Placeholder
extension ArtistDetailFeature {
  static let placeholderPerformances = IdentifiedArrayOf<Artist.Performance>(
    uniqueElements: (1...6).map { .placeholder(id: $0) }
  )
}
