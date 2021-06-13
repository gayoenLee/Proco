//
//  FriendChatRoomListModel.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//

import SwiftUI
import Foundation
import Combine

struct FriendChatRoomListModel: Identifiable{
    let id = UUID()
    var chatroom_idx : Int
    var creator_name : String? = ""
    var room_name : String? = ""
    var image : String? = ""
    var last_chat : String? = ""
    var chat_time : String? = ""
    var message_num : String? = ""
    var promise_day : String? = ""
    var total_member_num : Int
    var alarm_state: Bool
    var kinds : String
}



