//
//  MessageInput.swift
//  chatapp
//
//  Created by Leopold on 3/3/2023.
//

import SwiftUI

struct MessageInput: View {
    var body: some View {
        HStack {
            TextField("Type your message here...", text: $message)
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
    

    func sendMessage() {
        if message.isEmpty {
            return
        }
        
        let newChatMessage = ChatMessage(role: .user, content: message)
        chatHistory.append(newChatMessage)
        message = ""
        
        let staticResponse = ChatMessage(role: .assistant, content: "Cool")
        chatHistory.append(staticResponse)
//
//        let parameters: [String: Any] = [
//            "model": openAIModel,
//            "prompt": "\(newChatMessage.content)\n\nAI:",
//            "temperature": 0.7,
//            "max_tokens": 60,
//            "stop": ["\n\n"],
//        ]
//
//        var request = URLRequest(url: URL(string: openAIURL)!)
//        request.httpMethod = "POST"
//        request.addValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
//        request.httpBody = jsonData
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let data = data,
//               let jsonString = String(data: data, encoding: .utf8),
//               let chatCompletionResponse = try? JSONDecoder().decode(ChatCompletionResponse.self, from: data),
//               let completionMessage = chatCompletionResponse.choices.first?.text {
//                DispatchQueue.main.async {
//                    let newChatMessage = ChatMessage(role: .assistant, content: completionMessage)
//                    chatHistory.append(newChatMessage)
//                }
//            }
//        }.resume()
    }
}

struct MessageInput_Previews: PreviewProvider {
    static var previews: some View {
        MessageInput()
    }
}
