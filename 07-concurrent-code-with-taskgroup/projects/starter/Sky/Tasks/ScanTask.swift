/// Copyright (c) 2021 Razeware LLC


import Foundation

/// A single scanning task.
struct ScanTask: Identifiable {
  let id: UUID
  let input: Int
  
  init(input: Int, id: UUID = UUID()) {
    self.id = id
    self.input = input
  }
  
  /// A method that performs the scanning.
  /// > Note: This is a mock method that just suspends for a second.
  func run() async throws -> String {
    try await UnreliableAPI.shared.action(failingEvery: 10)
    await Task(priority: .medium) {
      // Block the thread as a real heavy-computation functon will.
      Thread.sleep(forTimeInterval: 1)
    }.value
    
    return "\(input)"
  }
}
