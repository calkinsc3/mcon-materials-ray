/// Copyright (c) 2021 Razeware LLC

import SwiftUI
import Combine

struct LoadingView: View {
  @EnvironmentObject var model: EmojiArtModel
  
  /// The latest error message.
  @State var lastErrorMessage = "None" {
    didSet {
      isDisplayingError = true
    }
  }
  @State var isDisplayingError = false
  @State var progress = 0.0
  
  @Binding var isVerified: Bool
  
  let timer = Timer.publish(every: 0.2, on: .main, in: .common)
    .autoconnect()
  
  var body: some View {
    VStack(spacing: 4) {
      ProgressView("Verifying feed", value: progress)
        .tint(.gray)
        .font(.subheadline)
      
      if !model.imageFeed.isEmpty {
        Text("\(Int(progress * 100))%")
          .fontWeight(.bold)
          .font(.caption)
          .foregroundColor(.gray)
      }
    }
    .padding(.horizontal, 20)
    .task {
      guard model.imageFeed.isEmpty else { return }
      Task {
        do {
          try await model.loadImages()
          try await model.verifyImages()
          withAnimation {
            isVerified = true
          }
        } catch {
          lastErrorMessage = error.localizedDescription
        }
      }
    }
    .alert("Error", isPresented: $isDisplayingError, actions: {
      Button("Close", role: .cancel) { }
    }, message: {
      Text(lastErrorMessage)
    })
    .onReceive(timer) { _ in
      guard !model.imageFeed.isEmpty else { return }
      progress = Double(model.verifiedCount) / Double(model.imageFeed.count)
    }
  }
}
