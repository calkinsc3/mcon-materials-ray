/// Copyright (c) 2021 Razeware LLC


import Foundation
import UIKit

actor EmojiArtModel: ObservableObject {
  @Published private(set) var imageFeed: [ImageFile] = []
  private(set) var verifiedCount = 0
  
  func verifyImages() async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      imageFeed.forEach { file in
        group.addTask { [unowned self] in
          try await Checksum.verify(file.checksum)
          await self.increaseVerifiedCount()
        }
      }
      
      try await group.waitForAll()
    }
  }
  
  private func increaseVerifiedCount() {
    verifiedCount += 1
  }

  func loadImages() async throws {
    imageFeed.removeAll()
    guard let url = URL(string: "http://localhost:8080/gallery/images") else {
      throw "Could not create endpoint URL"
    }
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }
    guard let list = try? JSONDecoder().decode([ImageFile].self, from: data) else {
      throw "The server response was not recognized."
    }
    imageFeed = list
  }

  /// Downloads an image and returns its content.
  func downloadImage(_ image: ImageFile) async throws -> Data {
    guard let url = URL(string: "http://localhost:8080\(image.url)") else {
      throw "Could not create image URL"
    }
    let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw "The server responded with an error."
    }
    return data
  }
}
