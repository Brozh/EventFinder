import ComposableArchitecture

struct ArtistDetailFeature: Reducer {
  struct State: Equatable {
    var artist: Artist
  }

  enum Action: Equatable {}

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    return .none
  }
}
