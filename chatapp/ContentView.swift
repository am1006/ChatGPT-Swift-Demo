//
//  ContentView.swift
//  chatapp
//
//  Created by Leopold on 3/3/2023.
//

import SwiftUI

struct ChatView: View {
  @State private var message = ""
  @State private var botname = "LeoBot"
  @State private var chatHistory: [ChatMessage] = []
  @State private var isThinking: Bool = false

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
                sendMessage()
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

  private let chatGPTURL = "https://api.openai.com/v1/chat/completions"
  private let openAIModel = "gpt-3.5-turbo"
  private let openAIApiKey = ""

  private func prepareRequest(message: ChatMessage) -> URLRequest {

    let parameters: Parameters = Parameters(
      model: openAIModel,
      messages: [
        ChatCompletionMessage(role: "user", content: message.content)
      ])

    var request = URLRequest(url: URL(string: chatGPTURL)!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    request.addValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")

    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(parameters) {
      request.httpBody = encoded
    }

    print("Sending request to \(chatGPTURL)")
    print("Request body: \(String(describing: request.httpBody))")

    return request
  }

  func sendMessage() {
    if message.isEmpty {
      return
    }

    let newChatMessage = ChatMessage(role: .user, content: message)
    chatHistory.append(newChatMessage)

    isThinking.toggle()
    message = ""

    // TODO: Set "system" messages to fine tune the bot

    //        let staticResponse = ChatMessage(role: .assistant, content: "Cool")
    //        chatHistory.append(staticResponse)

    let request = prepareRequest(message: newChatMessage)

    let session = URLSession.shared
    let task = session.dataTask(with: request) { (data, response, error) in
      if let err = error {
          
        print("Request Failure Error: \(err)")
        isThinking.toggle()
          
      } else if let data = data {
          
        do {
            print(data)
          let res = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            var completionMessage = res.choices.first!.message.content
            
            // remove the first two \n
            let index = completionMessage.index(completionMessage.startIndex, offsetBy: 2)
            completionMessage = String(completionMessage[index...])
            
          // Print the debugging message
          print("Chat response: \(res)")
          print("Completion message: \(completionMessage)")

          DispatchQueue.main.async {
            let newChatMessage = ChatMessage(role: .assistant, content: completionMessage)
            chatHistory.append(newChatMessage)

            isThinking.toggle()
          }
        } catch {
          print("Request Success but Decoding Error: \(error)")
            isThinking.toggle()
        }
      }
    }
    task.resume()

  }
}

struct ChatView_Previews: PreviewProvider {
  static var previews: some View {
    ChatView()
  }
}

// {
//   "id": "chatcmpl-123",
//   "object": "chat.completion",
//   "created": 1677652288,
//   "choices": [{
//     "index": 0,
//     "message": {
//       "role": "assistant",
//       "content": "\n\nHello there, how may I assist you today?",
//     },
//     "finish_reason": "stop"
//   }],
//   "usage": {
//     "prompt_tokens": 9,
//     "completion_tokens": 12,
//     "total_tokens": 21
//   }
// }

struct ChatCompletionResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let choices: [ChatCompletionChoice]
    let usage: ChatCompletionUsage
}

struct ChatCompletionChoice: Codable {
    let index: Int
    let message: ChatCompletionMessage
    let finishReason: String
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

struct ChatCompletionMessage: Codable {
    let role: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case role, content
    }
}

struct ChatCompletionUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}


// {
//   "model": "gpt-3.5-turbo",
//   "messages": [{"role": "user", "content": "Hello!"}]
// }

struct Parameters: Codable {
  let model: String
  let messages: [ChatCompletionMessage]
}
