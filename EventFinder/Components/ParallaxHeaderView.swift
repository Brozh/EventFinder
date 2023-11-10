import SwiftUI

struct ParallaxHeaderView<Title, CollapsedTitle, Content>: View where CollapsedTitle: View, Title: View, Content: View {
  private let headerHeight: CGFloat
  private let collapsedHeaderHeight: CGFloat
  private let imageUrl: URL
  private let title: Title
  private let collapsedTitle: CollapsedTitle
  private let content: Content

  @ObservedObject private var articleContent: ViewFrame = ViewFrame()
  @State private var titleRect: CGRect = .zero
  @State private var headerImageRect: CGRect = .zero

  init(
    headerHeight: CGFloat = 300,
    collapsedHeaderHeight: CGFloat = 90,
    imageUrl: URL,
    @ViewBuilder title: () -> Title,
    @ViewBuilder collapsedTitle: () -> CollapsedTitle,
    @ViewBuilder content: () -> Content
  ) {
    self.headerHeight = headerHeight
    self.collapsedHeaderHeight = collapsedHeaderHeight
    self.imageUrl = imageUrl
    self.title = title()
    self.collapsedTitle = collapsedTitle()
    self.content = content()
  }

  func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
    geometry.frame(in: .global).minY
  }

  func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = getScrollOffset(geometry)
    let sizeOffScreen = headerHeight - collapsedHeaderHeight
    // if our offset is roughly less than -225 (the amount scrolled / amount off screen)
    if offset < -sizeOffScreen {
      // Since we want 75 px fixed on the screen we get our offset of -225 or anything less than. Take the abs value of
      let imageOffset = abs(min(-sizeOffScreen, offset))
      // Now we can the amount of offset above our size off screen. So if we've scrolled -250px our size offscreen is -225px we offset our image by an additional 25 px to put it back at the amount needed to remain offscreen/amount on screen.
      return imageOffset - sizeOffScreen
    }
    // Image was pulled down
    if offset > 0 {
      return -offset
    }
    return 0
  }

  func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = getScrollOffset(geometry)
    let imageHeight = geometry.size.height
    if offset > 0 {
      return imageHeight + offset
    }
    return imageHeight
  }

  // at 0 offset our blur will be 0
  // at 300 offset our blur will be 6
  func getBlurRadiusForImage(_ geometry: GeometryProxy) -> CGFloat {
    let offset = geometry.frame(in: .global).maxY
    let height = geometry.size.height
    let blur = (height - max(offset, 0)) / height // (values will range from 0 - 1)

    return blur * 6 // Values will range from 0 - 6
  }

  private func getHeaderTitleOffset() -> CGFloat {
    let currentYPos = titleRect.midY
    // (x - min) / (max - min) -> Normalize our values between 0 and 1

    // If our Title has surpassed the bottom of our image at the top
    // Current Y POS will start at 75 in the beggining. We essentially only want to offset our 'Title' about 30px.
    if currentYPos < headerImageRect.maxY {
      let minYValue: CGFloat = 50.0 // What we consider our min for our scroll offset
      let maxYValue: CGFloat = collapsedHeaderHeight // What we start at for our scroll offset (75)
      let currentYValue = currentYPos
      let percentage = max(-1, (currentYValue - maxYValue) / (maxYValue - minYValue)) // Normalize our values from 75 - 50 to be between 0 to -1, If scrolled past that, just default to -1
      let finalOffset: CGFloat = -30.0 // We want our final offset to be -30 from the bottom of the image header view
                                       // We will start at 20 pixels from the bottom (under our sticky header)
                                       // At the beginning, our percentage will be 0, with this resulting in 20 - (x * -30)
                                       // as x increases, our offset will go from 20 to 0 to -30, thus translating our title from 20px to -30px.

      return 20 - (percentage * finalOffset)
    }
    return .infinity
  }

  var body: some View {
    ScrollView {
      VStack {
        VStack(alignment: .leading, spacing: 10) {
          title
            .background(GeometryGetter(rect: self.$titleRect)) // 2

          content
        }
        .padding(.horizontal)
        .padding(.top, 16.0)
      }
      .offset(y: headerHeight + 16)
      .background(GeometryGetter(rect: $articleContent.frame))

      GeometryReader { geometry in
        ZStack(alignment: .bottom) {
          AsyncImage(url: imageUrl) { image in
            image
              .resizable()
              .background(.gray)
          } placeholder: {
            Rectangle()
              .fill(.gray)
          }
          .aspectRatio(contentMode: .fill)
          .frame(width: geometry.size.width, height: getHeightForHeaderImage(geometry))
          .blur(radius: getBlurRadiusForImage(geometry))
          .clipped()
          .background(GeometryGetter(rect: self.$headerImageRect))
          collapsedTitle
            .offset(x: 0, y: getHeaderTitleOffset())
        }
        .clipped()
        .offset(x: 0, y: getOffsetForHeaderImage(geometry))
      }
      .frame(height: headerHeight)
      .offset(x: 0, y: -(articleContent.startingRect?.maxY ?? UIScreen.main.bounds.height))
    }
    .ignoresSafeArea()
  }
}

private class ViewFrame: ObservableObject {
  var startingRect: CGRect?
  @Published var frame: CGRect {
    willSet {
      if startingRect == nil {
        startingRect = newValue
      }
    }
  }
  init() {
    self.frame = .zero
  }
}

private struct GeometryGetter: View {
  @Binding var rect: CGRect

  var body: some View {
    GeometryReader { geometry in
      Color.clear
        .preference(key: RectanglePreferenceKey.self, value: geometry.frame(in: .global))
    }
    .onPreferenceChange(RectanglePreferenceKey.self) { (value) in
      self.rect = value
    }
  }
}

private struct RectanglePreferenceKey: PreferenceKey {
  static var defaultValue: CGRect = .zero
  static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
    value = nextValue()
  }
}

private let loremIpsum = """
Lorem ipsum dolor sit amet consectetur adipiscing elit donec, gravida commodo hac non mattis augue duis vitae inceptos, laoreet taciti at vehicula cum arcu dictum. Cras netus vivamus sociis pulvinar est erat, quisque imperdiet velit a justo maecenas, pretium gravida ut himenaeos nam. Tellus quis libero sociis class nec hendrerit, id proin facilisis praesent bibendum vehicula tristique, fringilla augue vitae primis turpis.
"""
private let loremIpsums = loremIpsum + loremIpsum + loremIpsum + loremIpsum

#Preview {
  ParallaxHeaderView(imageUrl: URL(string: "https://songleap.s3.amazonaws.com/venues/The+Velvet+Unicorn.png")!) {
    Text("How to build a parallax")
      .font(.title)
      .bold()
  } collapsedTitle: {
    Text("How to build a parallax")
      .font(.title3)
      .bold()
      .foregroundColor(.white)
  } content: {
    Text(loremIpsums)
      .lineLimit(nil)
  }
}
