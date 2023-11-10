import Foundation

extension Date {
  var performanceStyle: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: self)
  }
}
