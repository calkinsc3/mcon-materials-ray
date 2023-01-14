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
    
    try await withThrowingTaskGroup(of: Result<String, Error>.self, body: { [unowned self] group in
      
      let batchSize = 4
      
      for index in 0..<batchSize {
        group.addTask {
          await self.worker(number: index)
        }
      }
      
      // 1
      var index = batchSize
      
      // 2
      for try await result in group {
        
        switch result {
        case .success(let result):
          print("Completed: \(result)")
        case .failure(let error) :
          print("Failed: \(error.localizedDescription)")
        }
        print("Completed: \(result)")
        // 3
        if index < total {
          group.addTask { [index] in
            await self.worker(number: index)
          }
          index += 1
        }
      }
      
      await MainActor.run(body: {
        completed = 0
        countPerSecond = 0
        scheduled = 0
      })
    })
    
  }
  
  func worker(number: Int) async -> Result<String, Error> {
    
    await onScheduled()
    
    let task = ScanTask(input: number)
    let result: String
    
    do {
      result = try await task.run()
    } catch {
      return .failure(error)
    }
    
    await onTaskCompleted()
    return .success(result)
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
