import ComposableArchitecture

struct ArtistsListFeature: Reducer {
  struct State: Equatable {
    var path = StackState<Path.State>()
    var artists: IdentifiedArrayOf<Artist> = []
    var isLoading = false
  }

  enum Action {
    case path(StackAction<Path.State, Path.Action>)
    case onAppear
    case artistsDidLoad([Artist])
  }

  @Dependency(\.repository) var repository

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.artists.isEmpty, !state.isLoading else { return .none }
        state.isLoading = true
        state.artists = Self.placeholderArtists
        return .run { send in try await send(.artistsDidLoad(repository.getArtists())) }
      case let .artistsDidLoad(artists):
        state.isLoading = false
        state.artists = .init(uncheckedUniqueElements: artists.sorted(by: { $0.name < $1.name }))
        return .none
      case .path:
        return .none
      }
    }
    .forEach(\.path, action: /Action.path) { Path() }
  }
}

// MARK: - Path
extension ArtistsListFeature {
  struct Path: Reducer {
    enum State: Equatable {
      case detail(ArtistDetailFeature.State)
    }
    enum Action: Equatable {
      case detail(ArtistDetailFeature.Action)
    }
    var body: some ReducerOf<Self> {
      Scope(state: /State.detail, action: /Action.detail, child: ArtistDetailFeature.init)
    }
  }
}

// MARK: - Placeholder
extension ArtistsListFeature {
  static let placeholderArtists = IdentifiedArrayOf<Artist>(uniqueElements: (1...8).map { .placeholder(id: $0) })
}
