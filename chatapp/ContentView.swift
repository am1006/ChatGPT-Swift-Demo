//
//  ContentView.swift
//  chatapp
//
//  Created by Leopold on 3/3/2023.
//

import SwiftUI
import Alamofire

struct ChatView: View {
  @State private var message = ""
  @State private var botname = "LeoBot"
  @State private var chatHistory: [ChatMessage] = []
  @State private var isThinking: Bool = false

  private let chatGPTURL: String = "https://chatgpt.ddiu.me/api/generate"

  private func prepareRequest(message: ChatMessage) -> URLRequest {

    let parameters: Parameters = Parameters(
      messages: [
        ChatCompletionMessage(role: "user", content: message.content)
      ])

    var request = URLRequest(url: URL(string: chatGPTURL)!)
    request.httpMethod = "POST"

    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(parameters) {
      request.httpBody = encoded
    }

    debugPrint("Sending request to \(chatGPTURL)")
    debugPrint("Request body: \(String(describing: request.httpBody))")

    return request
  }

  private func sendMessage() async throws {
    if message.isEmpty {
      return
    }

    var newChatMessage = ChatMessage(role: .user, content: message)
    chatHistory.append(newChatMessage)

    isThinking.toggle()
    message = ""
    
    // TODO: Set "system" messages to fine tune the bot
    //        let staticResponse = ChatMessage(role: .assistant, content: "Cool")
    //        chatHistory.append(staticResponse)
    let request = prepareRequest(message: newChatMessage)

    let (data, response) = try await URLSession.shared.data(for: request)


    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
      debugPrint("Request Failure Error: ")
      isThinking.toggle()
      throw URLError(.cannotParseResponse)
    }

    var completionMessage = String(decoding: data, as: UTF8.self)
    debugPrint("Original: \(completionMessage)")

    // if the first two characters are \n\n, remove them
    if completionMessage.hasPrefix("\n\n") {
      completionMessage.removeFirst(2)
    }
    debugPrint("After: \(completionMessage)")

    newChatMessage = ChatMessage(role: .assistant, content: completionMessage)
    chatHistory.append(newChatMessage)

    isThinking.toggle()
  }

  var body: some View {
    NavigationView {
      VStack(alignment: .center) {
        ScrollView {
          Spacer()
          VStack(alignment: .leading) {
            ForEach(chatHistory, id: \.self) { chatMessage in
              MessageBubble(chatMessage: chatMessage)
            }
          }
        }
        .padding()

        HStack {
          if isThinking {
            Text("\(botname) is thinking")
              .foregroundColor(Color(.systemGray))
              .bold()
              .textCase(.uppercase)

            LoadingEffect()

          } else {
            TextField("Type your message here...", text: $message)

            if !message.isEmpty {
              Button {
                Task {
                  try await sendMessage()
                }
              } label: {
                Image(systemName: "paperplane")
              }
              .padding(.horizontal, 5.0)
              .padding(.vertical, 5.0)
              .foregroundColor(.white)
              .background(.blue)
              .clipShape(Circle())
            }
          }
        }
        // Make a small capsule shape for the text field with a nice border
        .padding(.horizontal, 15.0)
        .padding(.vertical, 10.0)
        .overlay(
          RoundedRectangle(cornerRadius: 999)
            .stroke(Color(.systemGray2), lineWidth: 1)
        )
        .cornerRadius(999)
        .padding(.horizontal)
      }
      .navigationTitle(botname)
    }
  }
}

struct ChatView_Previews: PreviewProvider {
  static var previews: some View {
    ChatView()
  }
}

struct Parameters: Codable {
  let messages: [ChatCompletionMessage]
}

struct ChatCompletionMessage: Codable {
  let role: String
  let content: String

  enum CodingKeys: String, CodingKey {
    case role, content
  }
}
