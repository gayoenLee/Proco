//
//  NormalChatRoomListModel.swift
//  proco
//
//  Created by 이은호 on 2021/01/06.
//

import Foundation
import SwiftUI
import Combine

struct NormalChatRoomListModel: Identifiable{
    let id = UUID()
    var chatroom_idx : Int
    var creator_name : String? = ""
    var room_name : String? = ""
    var image : String? = ""
    var last_chat : String? = ""
    var chat_time : String? = ""
    var message_num : String? = ""
}

