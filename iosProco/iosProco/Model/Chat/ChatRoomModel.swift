//
//  ChatRoomModel.swift
//  proco
//
//  Created by 이은호 on 2021/01/03.
//

import Foundation

struct ChatRoomModel: Identifiable, Codable{
    var idx : Int = -1
    var card_idx: Int = -1
    var created_at : String = ""
    var creator_idx: Int = -1
    var deleted_at: String? = ""
    var kinds: String = ""
    var room_name: String = ""
    var updated_at: String? = ""
    var card_tag_list:[TagModel]? = []
    var state : Int = -1
    var card: CardModel? = CardModel()
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        return self.idx ?? -1
    }
    
}


struct TagModel: Codable{
    var idx : Int = -1
    var tag_name : String = ""
}

struct UserChatModel: Codable{
    var server_idx: Int = -1
    var idx : Int = -1
    var chatroom_idx: Int = -1
    var nickname : String = ""
    var profile_photo_path :String? = ""
    var read_start_idx : Int = -1
    var read_last_idx : Int = -1
    var updated_at : String? = ""
    var deleted_at : String? = ""
}

struct CardModel : Codable, Identifiable{
    var creator_idx: Int = -1
    var expiration_at: String = ""
    var card_photo_path: String? = ""
    var kinds: String = ""
    var lock_state : Int = -1
    var title: String = ""
    var introduce: String = ""
    var address : String = ""
    var cur_user: Int = -1
    var apply_user : Int = -1
    var map_lat: String = ""
    var map_lng: String = ""
    var created_at: String = ""
    var updated_at: String? = ""
    var deleted_at: String? = ""
    var id: Int{
        return self.id ?? -1
    }
}


