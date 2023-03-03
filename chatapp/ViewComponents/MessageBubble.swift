//
//  MessageBubble.swift
//  chatapp
//
//  Created by Leopold on 3/3/2023.
//

import SwiftUI

struct MessageBubble: View {
  var chatMessage: ChatMessage
  @State private var showTime = false

  var time = "12:00"

  var body: some View {
    VStack(alignment: chatMessage.role == .user ? .trailing : .leading) {
      HStack {
        // myMessage
        Text(chatMessage.content)
          .padding()
          .background(
            chatMessage.role == .user ? Color(UIColor.systemBlue) : Color.secondary.opacity(0.2)
          )
          .clipShape(MessageBubbleShape(chatMessage: chatMessage))
          .foregroundColor(
            chatMessage.role == .user ? .white : .primary
          )
      }
      .frame(maxWidth: .infinity, alignment: chatMessage.role == .user ? .trailing : .leading)
      .onTapGesture {
        showTime.toggle()
      }

      if showTime {
        Text(time)
          .font(.caption)
          .foregroundColor(.gray)
          .padding(.top, 2)
          .padding(.bottom, 5)
          .padding(chatMessage.role == .user ? .trailing : .leading)
      }

    }
  }
}

struct MessageBubble_Previews: PreviewProvider {
  static var previews: some View {
    MessageBubble(
      //      chatMessage: ChatMessage(
      //        role: .assistant,
      //        content:
      //          "You can quote them, disagree with them, glorify or vilify them, but the only thing you can’t do is ignore them because they change things…"
      //      )
      chatMessage: ChatMessage(
        role: .assistant,
        content:
          "Here’s to the crazy ones, the misfits, the rebels, the troublemakers, the round pegs in the square holes… the ones who see things differently — they’re not fond of rules…"
      )
    )
  }
}
