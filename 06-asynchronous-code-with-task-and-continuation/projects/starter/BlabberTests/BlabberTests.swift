/// Copyright (c) 2021 Razeware LLC


import XCTest
@testable import Blabber


class BlabberTests: XCTestCase {
  
  let model: BlabberModel = {
    //1
    let model = BlabberModel()
    model.username = "test"
    
    //2
    let testConfiguration = URLSessionConfiguration.default
    testConfiguration.protocolClasses = [TestURLProtocol.self]
    
    //3
    model.urlSession = URLSession(configuration: testConfiguration)
    return model
    
  }()
  
  func testModelSay() async throws {
    
    try await model.say("Hello!")
    
    let request = try XCTUnwrap(TestURLProtocol.lastRequest)
    
    XCTAssertEqual(request.url?.absoluteString, "http://localhost:8080/chat/say")
    
    let httpBody = try XCTUnwrap(request.httpBody)
    let message = try XCTUnwrap(try? JSONDecoder().decode(Message.self, from: httpBody))
    
    XCTAssertEqual(message.message, "Hello!")
  }
  
}
