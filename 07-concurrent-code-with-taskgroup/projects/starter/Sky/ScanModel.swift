/// Copyright (c) 2021 Razeware LLC


import Foundation
import SwiftUI

final class ScanModel: ObservableObject {
  // MARK: - Private state
  private var counted = 0
  private var started = Date()
  
  // MARK: - Public, bindable state
  
  /// Currently scheduled for execution tasks.
  @MainActor @Published var scheduled = 0
  
  /// Completed scan tasks per second.
  @MainActor @Published var countPerSecond: Double = 0
  
  /// Completed scan tasks.
  @MainActor @Published var completed = 0
  
  @Published var total: Int
  
  @MainActor @Published var isCollaborating = false
  
  // MARK: - Methods
  
  init(total: Int, localName: String) {
    self.total = total
  }
  
  func runAllTasks() async throws {
    started = Date()
    
    let scans = await withTaskGroup(of: String.self, body: { [unowned self] group -> [String] in
      
      for number in 0..<total {
        group.addTask {
          await self.worker(number: number)
        }
      }
      
      return await group.reduce(into: [String](), { result, string in
        result.append(string)
      })
      
    })
    
    print(scans)
  }
  
  func worker(number: Int) async -> String {
    await onScheduled()
    
    let task = ScanTask(input: number)
    let result = await task.run()
    
    await onTaskCompleted()
    return result
  }
}

// MARK: - Tracking task progress.
extension ScanModel {
  @MainActor
  private func onTaskCompleted() {
    completed += 1
    counted += 1
    scheduled -= 1
    
    countPerSecond = Double(counted) / Date().timeIntervalSince(started)
  }
  
  @MainActor
  private func onScheduled() {
    scheduled += 1
  }
}
