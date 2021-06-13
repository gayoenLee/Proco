//
//  GroupChatRoomListModel.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//

import Foundation
import SwiftUI
import Combine

struct GroupChatRoomListModel: Identifiable{
    let id = UUID()
    var chatroom_idx : Int
    var room_name : String? = ""
    var message : String? = ""
    var time : String? = ""
    var image: String? = ""
    var message_num : String? = ""
    var promise_day : String? = ""
    
}

