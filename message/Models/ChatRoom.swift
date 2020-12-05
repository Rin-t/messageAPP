//
//  ChatRoom.swift
//  message
//
//  Created by Rin on 2020/11/20.
//

import Foundation
import Firebase

class ChatRoom {
    
    let latestMessageId: String
    let members: [String]
    let creatAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.creatAt = dic["creatAt"] as? Timestamp ?? Timestamp()
    }
}
