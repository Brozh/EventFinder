import SwiftUI
import ComposableArchitecture

//struct HomeFeature: Reducer {
//  struct State {
//    var tab: Tab
//  }
//
//  enum Action {
//    case artistsTabTapped
//    case venuesTabTapped
//  }
//
//  func reduce(into state: inout State, action: Action) -> Effect<Action> {
//    switch action {
//    case .artistsTabTapped:
//      state.tab = .artistsList
//      return .none
//    case .venuesTabTapped:
//      state.tab = .venuesList
//      return .none
//    }
//  }
//}
//
//extension HomeFeature.State {
//  enum Tab {
//    case artistsList
//    case venuesList
//  }
//}

struct HomeView: View {
  var body: some View {
    TabView {
      NavigationStack {
        ArtistsListView(store: .init(initialState: .init()) {
          ArtistsListFeature()
            ._printChanges()
        })
      }
      .tabItem { Label("Artists", systemImage: "figure.wave") }
      Text("Venues")
        .tabItem { Label("Venues", systemImage: "hifispeaker") }
    }
  }
}

#Preview {
  HomeView()
}
