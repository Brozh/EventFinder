import ComposableArchitecture
import XCTest

@testable import EventFinder

@MainActor
final class ArtistsListFeatureTests: XCTestCase {
  func test_onAppear() async throws {
    // Given
    let receivedArtists = [
      Artist(id: 1, name: "Foo", genre: "Pop", imageUrl: nil),
      Artist(id: 2, name: "Bar", genre: "Dance", imageUrl: nil)
    ]
    let store = TestStore(
      initialState: .init(),
      reducer: ArtistsListFeature.init,
      withDependencies: {
        $0.repository.getArtists = { receivedArtists }
      }
    )

    // When
    await store.send(.onAppear) {
      $0.isLoading = true
      $0.artists = ArtistsListFeature.placeholderArtists
    }

    // Then
    await store.receive(.artistsDidLoad(receivedArtists)) {
      $0.isLoading = false
      $0.artists = .init(uncheckedUniqueElements: receivedArtists.sorted(by: { $0.name < $1.name }))
    }

    // When calling onAppear a second time, nothing more is supposed to happen
    await store.send(.onAppear)
  }

  func test_onAppear_twice() async throws {
    // Given
    let receivedArtists = [
      Artist(id: 1, name: "Foo", genre: "Pop", imageUrl: nil),
      Artist(id: 2, name: "Bar", genre: "Dance", imageUrl: nil)
    ]
    let store = TestStore(
      initialState: .init(),
      reducer: ArtistsListFeature.init,
      withDependencies: {
        $0.repository.getArtists = { receivedArtists }
      }
    )

    await store.send(.onAppear) {
      $0.isLoading = true
      $0.artists = ArtistsListFeature.placeholderArtists
    }

    await store.receive(.artistsDidLoad(receivedArtists)) {
      $0.isLoading = false
      $0.artists = .init(uncheckedUniqueElements: receivedArtists.sorted(by: { $0.name < $1.name }))
    }

    await store.send(.onAppear)
  }

  func test_detail() async throws {
    let artist = Artist(id: 1, name: "Foo", genre: "Pop", imageUrl: nil)
    let store = TestStore(
      initialState: .init(),
      reducer: ArtistsListFeature.init
    )

    await store.send(.path(.push(id: 0, state: .detail(.init(artist: artist))))) {
      $0.path.append(.detail(.init(artist: artist)))
    }

    // Nothing is updated at the list level when something happens on the detail screen
    await store.send(.path(.element(id: 0, action: .detail(.performancesDidLoad([])))))
  }
}
