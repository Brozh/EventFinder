import ComposableArchitecture
import XCTest

@testable import EventFinder

@MainActor
final class ArtistDetailFeatureTests: XCTestCase {
  func test_onAppear() async throws {
    // Given
    let now = Date()
    let repositoryCalls: ActorIsolated<[(Artist.ID, Date, Date)]> = .init([])
    let artist = Artist(id: 1, name: "Foo", genre: "Pop", imageUrl: nil)
    let receivedPerformances = [
      Artist.Performance(id: 2, date: now.addingTimeInterval(60 * 2), venue: .placeholder()),
      Artist.Performance(id: 3, date: now.addingTimeInterval(60), venue: .placeholder())
    ]
    let store = TestStore(
      initialState: .init(artist: artist),
      reducer: ArtistDetailFeature.init,
      withDependencies: {
        $0.date = .constant(now)
        $0.repository.getArtistPerformances = { artistID, from, to in
          await repositoryCalls.withValue { $0.append((artistID, from, to)) }
          return receivedPerformances
        }
      }
    )

    // When
    await store.send(.onAppear) {
      $0.isLoading = true
      $0.performances = ArtistDetailFeature.placeholderPerformances
    }

    // Then
    let calls = await repositoryCalls.value
    guard calls.count == 1, let repositoryCall = calls.first else { return XCTFail() }
    XCTAssertEqual(repositoryCall.0, artist.id)
    XCTAssertEqual(repositoryCall.1, now)
    XCTAssertEqual(repositoryCall.2, now.addingTimeInterval(60 * 60 * 24 * 13))
    await store.receive(.performancesDidLoad(receivedPerformances)) {
      $0.isLoading = false
      $0.performances = .init(uncheckedUniqueElements: receivedPerformances.sorted(by: { $0.date < $1.date }))
    }

    // When calling onAppear a second time, nothing more is supposed to happen
    await store.send(.onAppear)

    // Then
    let calls2 = await repositoryCalls.value
    guard calls2.count == 1 else { return XCTFail() }
  }
}
