import Tagged

struct Artist: Codable, Identifiable, Equatable {
  let id: Tagged<Artist, Int>
  let name: String
  let genre: String
}
