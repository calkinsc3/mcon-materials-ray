/// Copyright (c) 2021 Razeware LLC

import SwiftUI

struct ListView: View {
  @EnvironmentObject var model: EmojiArtModel

  /// The latest error message.
  @State var lastErrorMessage = "None" {
    didSet {
      isDisplayingError = true
    }
  }
  @State var isDisplayingError = false

  @State var isDisplayingPreview = false
  @State var selected: ImageFile?

  var columns: [GridItem] = [
    GridItem(.flexible(minimum: 50, maximum: 120)),
    GridItem(.flexible(minimum: 50, maximum: 120)),
    GridItem(.flexible(minimum: 50, maximum: 120))
  ]

  var body: some View {
    VStack {
      Text("Emoji Art")
        .font(.custom("YoungSerif-Regular", size: 36))
        .foregroundColor(.pink)

      GeometryReader { geo in
        ScrollView {
          LazyVGrid(columns: columns, spacing: 2) {
            ForEach(model.imageFeed) { image in
              VStack(alignment: .center) {
                Button(action: {
                  selected = image
                }, label: {
                  ThumbImage(file: image)
                    .frame(width: geo.size.width / 3 * 0.75, height: geo.size.width / 3 * 0.75)
                    .clipped()
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                })

                Text(image.name)
                  .fontWeight(.bold)
                  .font(.caption)
                  .foregroundColor(.gray)
                  .lineLimit(2)

                Text(String(format: "$%.2f", image.price))
                  .font(.caption2)
                  .foregroundColor(.black)
              }
              .frame(height: geo.size.width / 3 + 20, alignment: .top)
            }
          }
        }
      }
      .alert("Error", isPresented: $isDisplayingError, actions: {
        Button("Close", role: .cancel) { }
      }, message: {
        Text(lastErrorMessage)
      })
      .sheet(isPresented: $isDisplayingPreview, onDismiss: {
        selected = nil
      }, content: {
        if let selected = selected {
          DetailsView(file: selected)
        }
      })
      .onChange(of: selected) { newValue in
        isDisplayingPreview = newValue != nil
      }

      BottomToolbar()
    }
  }
}
