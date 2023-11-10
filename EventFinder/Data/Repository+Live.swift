import Foundation
import ComposableArchitecture

extension Repository: DependencyKey {
  static var liveValue: Self {
    let liveRepository = LiveRepository()

    return .init(
      getArtists: liveRepository.getArtists,
      getVenues: liveRepository.getVenues,
      getArtistPerformances: liveRepository.getArtistPerformances(for:),
      getVenuePerformances: liveRepository.getVenuePerformances(for:)
    )
  }
}

extension DependencyValues {
  var repository: Repository {
    get { self[Repository.self] }
    set { self[Repository.self] = newValue }
  }
}

private struct LiveRepository {
  let baseUrl = URL(string: "http://ec2-44-211-66-223.compute-1.amazonaws.com")
  let imageBaseUrl = URL(string: "https://songleap.s3.amazonaws.com")

  let decoder = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    return decoder
  }()

  @Sendable
  func getArtists() async throws -> [Artist] {
    guard let url = baseUrl?.appending(path: "artists"), let imageBaseUrl else { throw URLError(.badURL) }
    let (data, _) = try await URLSession.shared.data(from: url)
    let decodedArtists = try decoder.decode([DecodableArtist].self, from: data)
    return decodedArtists.map { $0.asArtist(imageBaseUrl: imageBaseUrl) }
  }

  @Sendable
  func getArtistPerformances(for artistId: Artist.ID) async throws -> [Artist.Performance] {
    guard
      let url = baseUrl?.appending(path: "artists").appending(path: "\(artistId)").appending(path: "performances"),
      let imageBaseUrl
    else { throw URLError(.badURL) }
    let (data, _) = try await URLSession.shared.data(from: url)
    let decodedPerformances = try decoder.decode([DecodableArtist.Performance].self, from: data)
    return decodedPerformances.map { $0.asPerformance(imageBaseUrl: imageBaseUrl) }
  }

  @Sendable
  func getVenues() async throws -> [Venue] {
    guard let url = baseUrl?.appending(path: "venues"), let imageBaseUrl else { throw URLError(.badURL) }
    let (data, _) = try await URLSession.shared.data(from: url)
    let decodedVenues = try decoder.decode([DecodableVenue].self, from: data)
    return decodedVenues.map { $0.asVenue(imageBaseUrl: imageBaseUrl) }
  }

  @Sendable
  func getVenuePerformances(for venueId: Venue.ID) async throws -> [Venue.Performance] {
    guard
      let url = baseUrl?.appending(path: "venues").appending(path: "\(venueId)").appending(path: "performances"),
      let imageBaseUrl
    else { throw URLError(.badURL) }
    let (data, _) = try await URLSession.shared.data(from: url)
    let decodedPerformances = try decoder.decode([DecodableVenue.Performance].self, from: data)
    return decodedPerformances.map { $0.asPerformance(imageBaseUrl: imageBaseUrl) }
  }
}
