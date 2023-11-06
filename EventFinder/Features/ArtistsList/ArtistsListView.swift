import SwiftUI
import ComposableArchitecture

struct ArtistsListFeature: Reducer {
  struct State: Equatable {
    var artists: IdentifiedArrayOf<Artist> = []
  }

  enum Action {
    case viewDidAppear
    case artistsDidLoad([Artist])
  }

  @Dependency(\.repository) var repository

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    switch action {
    case .viewDidAppear:
      return .run { send in
        try await send(.artistsDidLoad(repository.getArtists()))
      }
    case let .artistsDidLoad(artists):
      state.artists = .init(uncheckedUniqueElements: artists.sorted(by: { $0.name > $1.name }))
      return .none
    }
  }
}

struct ArtistsListView: View {
  let store: StoreOf<ArtistsListFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView(.vertical, showsIndicators: false) {
        VStack{
          ForEach(viewStore.artists) { artist in
            ArtistCard(artist: artist)
          }
        }
      }
      .navigationTitle("Artists")
      .task {
        await viewStore.send(.viewDidAppear).finish()
      }
    }
  }
}

private struct ArtistCard: View {
  let artist: Artist

  var body: some View {
    ZStack(alignment: .topLeading) {
      Image(uiImage: UIImage())
        .resizable()
        .background(.gray)
        .aspectRatio(contentMode: .fill)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 250)

      HStack {
        Spacer()
        Text(artist.genre)
          .font(.subheadline)
          .foregroundColor(.white)
          .padding(10)
          .background(.ultraThinMaterial)
          .cornerRadius(10)
          .padding(.trailing, 20)
          .padding(.top, 20)
      }

      VStack(alignment: .leading) {
        Spacer()

        HStack{
          Text(artist.name)
            .font(.title3)
            .bold()
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
      }
    }
    .cornerRadius(10)
    .padding()
  }
}

#Preview {
  NavigationStack {
    ArtistsListView(
      store: Store(
        initialState: .init(
          artists: [
            .init(id: 1, name: "Sample Artist", genre: "New genre")
          ]
        ),
        reducer: ArtistsListFeature.init
      )
    )
  }
}
