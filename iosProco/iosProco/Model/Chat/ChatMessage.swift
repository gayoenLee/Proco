//
//  ChatMessage.swift
//  proco
//
//  Created by 이은호 on 2021/01/07.
//

import Foundation


struct ChatMessage: Identifiable, Codable, Hashable{
    var id = UUID()
    var kinds: String? = ""
    //메세지 보낸 시각
    var created_at: String? = ""
    //메세지 보낸 사람 idx
    var sender: String? = ""
    var message: String? = ""
    var message_idx: Int?
    //내 메세지, 친구 메세지 구분자
    var myMsg : Bool = false
    var profilePic : String? = ""
    //혹시 보낼 수 있는 데이터
    var photo : Data? = Data()
    //메세지 안읽은 사람 갯수
    var read_num: Int = -1
    var front_created_at: String? = ""
    //이전 메세지, 현재 메세지 뷰 예외처리 위해 사용.
    var is_same_person_msg: Bool = false
    //이전 메세지를 보낸 사람이 같은 경우, 연속된 메세지의 마지막에만 시간을 보여줘야하는 예외처리에 사용.
    var is_last_consecutive_msg: Bool = true
}
