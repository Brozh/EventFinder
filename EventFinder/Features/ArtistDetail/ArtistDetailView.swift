import SwiftUI
import Tagged
import ComposableArchitecture

struct ArtistDetailView: View {
  let store: StoreOf<ArtistDetailFeature>

  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ScrollView {
        ArtistHeader(artist: viewStore.artist)
          .padding(.bottom)
        LazyVStack(spacing: 8) {
          ForEach(viewStore.performances) { performance in
            PerformanceCard(performance: performance, isLoading: viewStore.isLoading)
              .redacted(reason: viewStore.isLoading ? .placeholder : [])
          }
        }
        .padding(.horizontal, 16)
      }
      .navigationTitle(viewStore.artist.name)
    }
    .onAppear { store.send(.onAppear) }
  }
}

private struct ArtistHeader: View {
  let artist: Artist

  var body: some View {
    ZStack(alignment: .topLeading) {
      AsyncImage(url: artist.imageUrl) { image in
        image
          .resizable()
          .background(Color(white: 0.70))
      } placeholder: {
        Rectangle()
          .fill(Color(white: 0.70))
      }
      .aspectRatio(contentMode: .fill)
      .frame(maxWidth: .infinity)
      .frame(maxHeight: 250)
      .clipped()

      HStack {
        Spacer()
        Text(artist.genre)
          .font(.subheadline)
          .foregroundColor(.white)
          .padding(10)
          .background(.ultraThinMaterial)
          .cornerRadius(8)
          .padding(.trailing, 16)
          .padding(.top, 8)
      }
    }
  }
}

private struct PerformanceCard: View {
  let performance: Artist.Performance
  let isLoading: Bool

  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      AsyncImage(url: performance.venue.imageUrl) { image in
        image
          .resizable()
          .background(Color(white: 0.70))
      } placeholder: {
        Rectangle().fill(Color(white: 0.70))
      }
      .aspectRatio(contentMode: .fill)
      .frame(width: 80)
      .clipped()

      VStack(alignment: .leading, spacing: 8) {
        Text(performance.venue.name)
          .font(.title3)
          .bold()
          .multilineTextAlignment(.leading)
          .shimmering(active: isLoading)
        Text(performance.date.performanceStyle)
          .font(.headline)
          .bold()
          .foregroundStyle(Color(white: 0.5))
          .multilineTextAlignment(.leading)
          .shimmering(active: isLoading)
      }
      .padding(.vertical)
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Color(white: 0.99))
    .cornerRadius(8, color: .init(white: 0.70))
  }
}

#Preview("Loading") {
  NavigationStack {
    ArtistDetailView(
      store: Store(
        initialState: .init(artist: .init(
          id: 7,
          name: "Beat Illuminati",
          genre: "Dance",
          imageUrl: nil
        )),
        reducer: ArtistDetailFeature.init,
        withDependencies: {
          $0.repository = .waitForever()
        }
      )
    )
  }
}

#Preview("Live") {
  NavigationStack {
    ArtistDetailView(
      store: Store(
        initialState: .init(artist: .init(
          id: 7,
          name: "Beat Illuminati",
          genre: "Dance",
          imageUrl: URL(string: "https://songleap.s3.amazonaws.com/artists/Beat+Illuminati.png")
        )),
        reducer: ArtistDetailFeature.init,
        withDependencies: {
          $0.repository = .liveValue
        }
      )
    )
  }
}
