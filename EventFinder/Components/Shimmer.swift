import SwiftUI

public struct Shimmer: ViewModifier {
  private let min, max, bandSize, opacity: CGFloat
  @State private var isInitialState = true
  @Environment(\.layoutDirection) private var layoutDirection

  public init(
    bandSize: CGFloat = 0.3,
    opacity: CGFloat = 0.3
  ) {
    self.bandSize = bandSize
    self.opacity = opacity
    self.min = 0 - bandSize
    self.max = 1 + bandSize
  }

  private let animation = Animation.linear(duration: 1.5).delay(0.25).repeatForever(autoreverses: false)

  private var gradient: Gradient {
    Gradient(colors: [.black, .black.opacity(opacity), .black])
  }

  var startPoint: UnitPoint { isInitialState ? UnitPoint(x: min, y: 1) : UnitPoint(x: 1, y: 1) }
  var endPoint: UnitPoint { isInitialState ? UnitPoint(x: 0, y: 1) : UnitPoint(x: max, y: 1) }

  public func body(content: Content) -> some View {
    content
      .mask(LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint))
      .animation(animation, value: isInitialState)
      .onAppear { isInitialState = false }
  }
}

public extension View {
  @ViewBuilder func shimmering(
    active: Bool = true,
    bandSize: CGFloat = 0.3,
    opacity: CGFloat = 0.5
  ) -> some View {
    if active {
      modifier(Shimmer(bandSize: bandSize, opacity: opacity))
    } else {
      self
    }
  }
}

#Preview {
  Group {
    Text("SwiftUI Shimmer")
    Text("SwiftUI Shimmer").preferredColorScheme(.light)
    Text("SwiftUI Shimmer").preferredColorScheme(.dark)
    VStack(alignment: .leading) {
      Text("Loading...").font(.title)
      Text(String(repeating: "Shimmer", count: 12))
        .redacted(reason: .placeholder)
    }.frame(maxWidth: 400)
  }
  .padding()
  .shimmering(opacity: 0.5)
  .previewLayout(.sizeThatFits)
}
