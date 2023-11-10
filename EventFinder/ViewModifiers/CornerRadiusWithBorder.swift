import SwiftUI

fileprivate struct ModifierCornerRadiusWithBorder: ViewModifier {
  var radius: CGFloat
  var lineWidth: CGFloat
  var color: Color
  var antialiased: Bool

  func body(content: Content) -> some View {
    content
      .cornerRadius(radius, antialiased: antialiased)
      .overlay(
        RoundedRectangle(cornerRadius: radius)
//          .inset(by: lineWidth)
          .strokeBorder(color, lineWidth: lineWidth, antialiased: antialiased)
      )
  }
}

extension View {
  func cornerRadius(
    _ radius: CGFloat,
    color: Color,
    lineWidth: CGFloat = 1,
    antialiased: Bool = true
  ) -> some View {
    modifier(
      ModifierCornerRadiusWithBorder(
        radius: radius,
        lineWidth: lineWidth,
        color: color,
        antialiased: antialiased
      )
    )
  }
}
