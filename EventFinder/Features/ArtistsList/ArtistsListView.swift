import SwiftUI
import ComposableArchitecture

struct ArtistsListView: View {
  let store: StoreOf<ArtistsListFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStackStore(store.scope(state: \.path, action: { .path($0) })) {
        ListView(store: store)
          .redacted(reason: viewStore.isLoading ? .placeholder : [])
      } destination: { state in
        switch state {
        case .detail:
          CaseLet(
            /ArtistsListFeature.Path.State.detail,
             action: ArtistsListFeature.Path.Action.detail,
             then: ArtistDetailView.init(store:)
          )
        }
      }
      .navigationTitle("Artists")
    }
  }
}

private struct ListView: View {
  let store: StoreOf<ArtistsListFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())], spacing: 8) {
          ForEach(viewStore.state.artists) { artist in
            if viewStore.isLoading {
              ArtistCard(artist: artist, isLoading: viewStore.isLoading)
            } else {
              NavigationLink(state: ArtistsListFeature.Path.State.detail(ArtistDetailFeature.State(artist: artist))) {
                ArtistCard(artist: artist, isLoading: viewStore.isLoading)
              }
            }
          }
        }
        .padding(.horizontal, 16)
      }
      .onAppear { viewStore.send(.onAppear) }
    }
  }
}

private struct ArtistCard: View {
  let artist: Artist
  let isLoading: Bool

  var body: some View {
    ZStack(alignment: .topLeading) {
      AsyncImage(url: artist.imageUrl) { image in
        image
          .resizable()
          .background(.gray)
      } placeholder: {
        Rectangle().fill(.gray)
      }
      .aspectRatio(contentMode: .fill)
      .frame(maxWidth: .infinity)
      .frame(maxHeight: 250)

      HStack {
        Spacer()
        Text(artist.genre)
          .font(.subheadline)
          .foregroundColor(.white)
          .shimmering(active: isLoading)
          .padding(10)
          .background(.ultraThinMaterial)
          .clipShape(RoundedCorner(radius: 8, corners: .bottomLeft))
      }

      VStack(alignment: .leading) {
        Spacer()
        HStack{
          Text(artist.name)
            .font(.title3)
            .bold()
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
            .shimmering(active: isLoading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
          Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
      }
    }
    .cornerRadius(8)
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat
  var corners: UIRectCorner

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

#Preview("Loading 10 sec then fail") {
  NavigationStack {
    ArtistsListView(
      store: Store(
        initialState: .init(),
        reducer: ArtistsListFeature.init,
        withDependencies: {
          $0.repository.getArtists = {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 10)
            throw URLError(.badURL)
          }
        }
      )
    )
  }
}

#Preview("Live") {
  NavigationStack {
    ArtistsListView(
      store: Store(
        initialState: .init(),
        reducer: ArtistsListFeature.init
      )
    )
  }
}
