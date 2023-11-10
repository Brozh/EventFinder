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

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.performances.isEmpty, !state.isLoading else { return .none }
        state.isLoading = true
        state.performances = Self.placeholderPerformances
        return .run { [artistId = state.artist.id] send in
          try await send(.performancesDidLoad(repository.getArtistPerformances(artistId)))
        }
      case let .performancesDidLoad(performances):
        state.isLoading = false
        state.performances = .init(uncheckedUniqueElements: performances.sorted(by: { $0.date < $1.date }))
        return .none
      }
    }
  }
}

// MARK: - Placeholder
extension ArtistDetailFeature {
  static let placeholderPerformances = IdentifiedArrayOf<Artist.Performance>(
    uniqueElements: (1...6).map { .placeholder(id: $0) }
  )
}
