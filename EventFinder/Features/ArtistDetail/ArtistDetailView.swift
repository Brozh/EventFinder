import SwiftUI
import ComposableArchitecture

struct ArtistDetailView: View {
  let store: StoreOf<ArtistDetailFeature>

  var body: some View {
    WithViewStore(store, observe: \.artist) { viewStore in
      Text(viewStore.state.name).bold()
    }
  }
}

#Preview {
  NavigationStack {
    ArtistDetailView(
      store: Store(
        initialState: .init(artist: .init(
          id: 1,
          name: "This is a test artist",
          genre: "Pop",
          imageUrl: nil
        )),
        reducer: ArtistDetailFeature.init
      )
    )
  }
}
