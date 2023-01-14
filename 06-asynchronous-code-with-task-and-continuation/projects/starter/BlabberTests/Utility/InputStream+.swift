/// Copyright (c) 2021 Razeware LLC


import Foundation

extension InputStream {
  /// The avalable stream data.
  var data: Data {
    var data = Data()
    open()

    let maxLength = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxLength)
    while hasBytesAvailable {
      let read = read(buffer, maxLength: maxLength)
      guard read > 0 else { break }
      data.append(buffer, count: read)
    }

    buffer.deallocate()
    close()

    return data
  }
}
