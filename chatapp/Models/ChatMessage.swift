//
//  ChatMessage.swift
//  chatapp
//
//  Created by Leopold on 3/3/2023.
//

import Foundation

struct ChatMessage: Hashable {
    enum Role: Int {
        case user
        case assistant
    }
    
    let role: Role
    let content: String
//    let timestamp: Date
}
