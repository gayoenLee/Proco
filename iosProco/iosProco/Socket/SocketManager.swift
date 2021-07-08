//
//  SocketManager.swift
//  proco
//
//  Created by 이은호 on 2021/01/03.
//

import Foundation
import SocketIO
import SQLite3
import Combine
import SwiftUI
import SwiftyJSON
import UserNotifications
import Alamofire
import Firebase
import UIKit

let access_token = UserDefaults.standard.string(forKey: "access_token")
let nickname = UserDefaults.standard.string(forKey: "nickname")
//config 옵션 주석 추가할 것.
let manager = SocketManager(socketURL: URL(string: "https://3.37.11.107//")!, config: [.log(true), .compress, .forceWebsockets(true), .connectParams(["token" : access_token!, "nickname": nickname!]), .reconnectWaitMax(2), .reconnectWait(1), .forceNew(false)])
let socket = manager.defaultSocket
var db : ChatDataManager = ChatDataManager()
var packet : [Any] = []

class SockMgr : ObservableObject {
    //모든 클래스에서 소켓 매니저를 가져와서 쓸 수 있도록 만든 것.
    static let socket_manager = SockMgr()
    
    let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    //채팅 방 목록 데이터 모델
    @Published var chat_room_struct : [ChatRoomModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var current_chatroom_info_struct : ChatRoomModel = ChatRoomModel(){
        didSet{
            objectWillChange.send()
        }
    }
    //1개 채팅방 정보 담기 위한 모델
    //채팅 - 카드 모델
    @Published var card_struct : CardModel =  CardModel(){
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅 - 태그 모델
    @Published var tag_struct : [TagModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅 - 유저 모델
    @Published var user_chat_struct : [UserChatModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //채팅 - 채팅 모델
    @Published var chatting_model : [ChattingModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //(친구)뷰에 친구 채팅 목록 보여줄 때 사용.
    @Published var friend_chat_model : [FriendChatRoomListModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //(그룹)모여 볼래 채팅방 목록 뷰를 위한 모델
    @Published var group_chat_model : [FriendChatRoomListModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //일반 채팅방 목록 뷰를 위한 모델
    @Published var normal_chat_model : [FriendChatRoomListModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //카드 만들기 시에 카드 참여자 리스트 목록 데이터 모델
    @Published var user_chat_in_model = UserChatInListModel() {
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅 메세지 모델
    @Published var chat_message_struct :  [ChatMessage] = []
    {
        didSet{
            objectWillChange.send()
        }
    }
    
    //동적링크 클릭 후 선택한 카드 idx -> 일반 채팅방에서 저장 후 상세페이지에서 친구 또는 모임 뷰모델에서 상세 데이터 가져오는 통신에서 사용.
    @Published var selected_card_idx : Int
    = -1
    {
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅 메세지를 같은 사람이 1분 내에 여러개 보낼 경우 프로필 이미지, 닉네임 한 번만 보여주기 위해 계산
    func is_consecutive(prev_created : String, prev_creator: String, current_created: String, current_creator: String) -> Bool{
        print("메세지 계산 메소드 안 : \(prev_created), \(prev_creator), \(current_created), \(current_creator) ")
        //이전 메세지와의 시간 격차
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let startTime = format.date(from: prev_created) else { return false}
        print("메세지 계산 메소드 안 startTime: \(startTime)")
        
        guard let endTime = format.date(from: current_created) else { return false}
        print("메세지 계산 메소드 안 endTime: \(endTime)")
        
        //초를 리턴함.
        let send_interval_time = Int(endTime.timeIntervalSince(startTime))
        print("메세지 비교 결과: 시간 = \(send_interval_time) 이전에 보낸 사람 = \(prev_creator), 지금 보낸 사람: \(current_creator), 이전에 보낸 시간 = \(prev_created), 지금 보낸 시간: \(current_created)")
        let calendar = Calendar.current
        let interval = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startTime, to: endTime).minute!
        print("차이값 확인: \(interval)")
        //이전에 같은 메세지 && 보낸 시간이 1분 이내일 때
        if (prev_creator == current_creator) && (interval < 1){
            return true
            
        }else{
            return false
        }
    }
    
    
    //드로어에서 보여줄 참가자 리스트 모델
    @Published var user_drawer_struct :  [UserInDrawerStruct] = []
    {
        didSet{
            objectWillChange.send()
        }
    }
    //추방하려는 사람의 정보를 이곳에 담는다.
    @Published var banish_user_info = UserChatModel(){
        didSet{
            objectWillChange.send()
        }
    }
    @Published var my_profile_photo : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    //--------------------------------------------------------------------------------------------------------
    //채팅 서버에 카드 만들었을 경우 chatroom_idx보내기 위함.
    @Published var  send_chatroom_idx: Int = -1{
        didSet{
            objectWillChange.send()
        }
    }
    
    //들어가려는 채팅방의 chatroom_idx. 읽음 처리시 사용.
    @Published var enter_chatroom_idx = -1 {
        didSet{
            objectWillChange.send()
        }
    }
    
    //새로운 채팅 메세지가 왔을 때 어떤 뷰에 있느냐에 따라 노티피케이션을 띄워주는게 다르기 때문에 알기 위해 사용.
    //채팅 목록 페이지 : 222, 채팅방 안: 333
    @Published var current_view: Int = 111{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var stored_front_created : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅방 주인 idx, 닉네임
    @Published var creator_nickname : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    //채팅방 주인 idx, 닉네임
    @Published var creator_idx : Int = -1{
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅방 주인 사진
    @Published var creator_profile_photo : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    //일대일 임시 채팅방 생성시 기존에 채팅방이 없었던 경우 메세지 보내기시 소켓에 보내는 이벤트가 다르므로 구분 위함.
    @Published var is_first_temp_room : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var temp_chat_friend_model  = UserChatInListModel(){
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅방 안에서 카드 상세 정보 보기와 메인에서 카드 상세 페이지를 구분하기 위함.
    @Published var is_from_chatroom: Bool  = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //채팅방 - 친구 카드 초대하기 -> 카드 1개 상세 페이지 이동시 구분값
    @Published var detail_to_invite: Bool  = false{
        didSet{
            objectWillChange.send()
        }
    }
    //채팅방 드로어 안에서 카드 편집 화면으로 이동했을 때 값 true
    @Published var edit_from_chatroom: Bool  = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //드로어 - 친구 내 카드에 초대하기시 내 모든 카드 리스트 - 모여볼래 데이터 모델
    @Published var group_card : [GroupCardStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //드로어 - 친구 내 카드에 초대하기시 내 모든 카드 리스트 - 친구랑 볼래
    @Published var friend_card : [FriendVollehCardStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //동적 링크 생성 후 저장.
    @Published var invitation_link : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    //동적링크인 경우를 뷰 예외처리하기 위함.
    @Published var is_dynamic_link : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //동적링크 url에 보내는 채팅룸 idx저장한 후 수락한 경우에 채팅서버에 보낼 때 사용.
    @Published var invite_chatroom_idx: Int = -1{
        didSet{
            objectWillChange.send()
        }
    }
    
    //동적링크 클릭 후 채팅방으로 이동시키기 위해 뷰에 알릴 때 사용.
    @Published var server_invite_accepted: Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //동적 링크가 만들어지는 경우 -> 친구/모임 모두 있음. -> 동적링크 수락 클릭 후 이동시킬 채팅방 종류가 달라지므로 구분시키기 위함.
    //친구랑 채팅방일 경우: FRIEND, 모임 : GROUP
    @Published var which_type_room: String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    //신고하기 후 알림창 띄우는데 사용 변수, 메소드
    @Published var show_result_alert : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var request_result_alert :ResultAlert  = .success{
        didSet{
            objectWillChange.send()
        }
    }
    
    func request_result_alert_func(_ active: ResultAlert) -> Void {
        DispatchQueue.main.async {
            self.request_result_alert = active
            self.show_result_alert = true
        }
    }
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func load(fileName: String) -> UIImage? {
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            print("이미지 로드: \(fileURL)")
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func save(file_name : String, image_data : Data) -> String? {
        let fileName = "\(file_name)"
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        
        try? image_data.write(to: fileURL, options: .atomic)
        print("이미지 저장: \(fileURL)")
        return fileName // ----> Save fileName
        
        print("Error saving image")
        return nil
    }
    
    func convert_img_base64(image_data : Data?) -> String{
        //compression quality : 압축 퀄리티. 1일수록 최고 품질
        //let image_data = ui_image.jpegData(compressionQuality: 0.2)
        print("이미지 크기: \(String(describing: image_data?.count))")
        print("이미지 데이터로 바꾼 것: \(String(describing: image_data))")
        
        return (image_data?.base64EncodedString(options:  Data.Base64EncodingOptions.lineLength64Characters))!
    }
    
    //채팅방 드로어에서 회원 신고하기 기능
    func send_reports(kinds: String, unique_idx: String, report_kinds: String, content: String) {
        
        cancellation = APIClient.send_reports(kinds: "채팅방회원", unique_idx: unique_idx, report_kinds: report_kinds, content: content)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("채팅방 회원 신고하기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("채팅방 회원  신고하기 resopnse: \(response)")
                
            })
    }
    
    
    func string_to_date(expiration: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = formatter.date(from: expiration)
        return date ?? Date()
    }
    
    ///카드 편집시 서버에서 받은 시간 date로 변환
    func string_to_time(expiration: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss a"
        formatter.locale = Locale(identifier: "en_US")
        // formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = formatter.date(from: expiration)
        return date!
    }
    
    func establish_connection(){
        socket.connect()
        
        socket.on(clientEvent: .connect){data, ack in
            print("소켓 연결됨 ")
            let state = UserDefaults.standard.integer(forKey: "\(db.my_idx!)_state")
            print("내 idx 확인: \(db.my_idx!), \(state)")
            if state == 0{
                print("off임.")
            }else{
                print("on이므로 상태 보냄.")
                self.click_on_off(user_idx: Int(db.my_idx!)!, state: state, state_data: "")
            }
            self.emit_get_chat()
            
        }
        
        print("establishConnection 완료")
        
        stop_connect()
        reconnect()
        //채팅 메세지 데이터 끄고 보냈을 때 -1이었던 채팅 메세지 idx를 -2로 바꾸기
        db.change_message_status()
        
        //서버로부터 응답 받는 이벤트들을 등록하는 것. 소켓 연결시에 자동으로 진행되도록 함.
        // handle_event()
        get_update_read()
        get_new_message()
        get_state_update()
        //임시 채팅방 생성 후 클라b가 다시 받는 이벤트
        //get_join_room_event()
        get_join_card_ok()
    }
    
    func stop_connect(){
        socket.on(clientEvent: .disconnect){data, ack in
            print("소켓 연결 끊는 이벤트: \(data)")
        }
    }
    
    func reconnect(){
        socket.on(clientEvent: .reconnect){data, ack in
            print("소켓 연결 재시도")
        }
    }
    func error(){
        socket.didError(reason: "에러로그")
    }
    
    func close_connection(){
        print("소켓 연결 끊음")
        manager.disconnect()
    }
    
    //소켓 연결시 get chat 이벤트
    func emit_get_chat(){
        db.open_db()
        
        let last_msg_idx = db.get_last_stored_message_idx()
        print("소켓으로 보내는 마지막 메세지 idx: \(last_msg_idx)")
        db.create_tag_table()
        db.create_card_table()
        db.create_user_table()
        db.create_chatroom_table()
        db.create_chatting_table()
        
        let updated_time = UserDefaults.standard.string(forKey: "\(db.my_idx!)")
        socket.emitWithAck("client_to_serverget_chat", last_msg_idx, updated_time ?? "").timingOut(after: 0.0){ data in
            print("get chat 응답: \(data)")
            
            if packet.count > 0{
                for item in packet{
                    let data = JSON(item)
                    let event_name = data["event"].stringValue
                    let object = data["object"]
                    
                    print("이벤트 확인: \(data), 이벤트 이름: \(event_name), 데이터: \(object)")
                    if event_name == "client_to_servermessage"{
                    }
                    let json_encoder = JSONEncoder()
                    let json_data = try? json_encoder.encode(object)
                    let json = String(data: json_data!, encoding: String.Encoding.utf8)
                    socket.emitWithAck("\(event_name)", json!).timingOut(after: 300.0){ (data) in
                        
                        //성공했는지 실패했는지 이 값에서 알 수 있음.
                        let check_ok = data[0]
                        print("메세지 보낸 후 응답0: \(data[0])")
                        //응답
                        print("메세지 보낸 후 응답1: \(data[1])")
                        _ = data[1]
                        
                        //1. sqlite에 메세지 데이터 업데이트해서 저장.
                        //2.read last idx 이번에 보낸 메세지 idx로 업데이트해서 저장.
                        if check_ok as! String == "success"{
                            print("메세지 보내기 후 응답 success")
                            
                            let result = JSON(data[1])
                            let chatroom_idx = result["chatroom_idx"].intValue
                            let content = result["content"].stringValue
                            let created_at = result["created_at"].stringValue
                            let front_created_at = result["front_created_at"].stringValue
                            let chatting_idx = result["idx"].intValue
                            let kinds = result["kinds"].stringValue
                            let user_idx = result["user_idx"].intValue
                            let server_idx = result["server_idx"].intValue
                            
                            print("채팅 idx 새로 온것 확인: \(chatting_idx)")
                            print("front_created_at 새로 온것 확인: \(front_created_at)")
                            print("채팅 메세지 새로 온것 확인: \(content)")
                            
                            //-1.메세지 성공적으로 보낸 후 sqlite에 다시 업데이트해서 저장.
                            ChatDataManager.shared.update_send_message(chatroom_idx: chatroom_idx, chatting_idx: chatting_idx, front_created_at: String(front_created_at), content: content)
                            
                            print("내가 메세지 보내서 읽은 메세지로 업데이트하려는 메세지 index : read_last_idx \(chatting_idx)")
                            print("내가 메세지 보내서 읽은 메세지 업데이트 하기 전 업데이트하려는 내idx \(Int(db.my_idx!)!) user_idx \(user_idx)")
                            let my_idx = Int(db.my_idx!)!
                            
                            let current_time = ChatDataManager.shared.make_created_at()
                            //-2.read last idx업데이트(나)
                            ChatDataManager.shared.update_user_read( chatroom_idx: chatroom_idx, read_last_idx: chatting_idx, user_idx: my_idx, updated_at: current_time)
                            
                            /*
                             안읽은 사람 표시
                             새로운 메세지 보냈을 때 해당 메세지의 안읽은 갯수 구하기 위함.
                             1.방 참가자들의 read last idx를 가져와 리스트를 만든다.
                             2.해당 메세지 idx와 비교해서 안읽은 사람 계산하는 메소드 돌리기.
                             */
                            //1.
                            if ChatDataManager.shared.get_read_last_list(chatroom_idx: chatroom_idx){
                                print("send_message메세지 보내기 이벤트에서 채팅방 마지막 메세지 idx 가져옴: \(db.user_read_list)")
                            }
                            
                            //2.
                            //뷰 업데이트 시키기 위해 데이터 모델도 업데이트
                            let index = self.chat_message_struct.firstIndex(where: {$0.front_created_at == front_created_at})
                            print("메세지 보내기 이벤트에서 index: \(String(describing: index))")
                            let num = db.unread_num_first(message_idx: chatting_idx)
                            
                            self.chat_message_struct[index!].read_num = num
                            self.chat_message_struct[index!].message_idx = chatting_idx
                            let send = "\(String(describing: index)) \(chatting_idx)"
                            
                            //뷰 업데이트 위해 보내기
                            NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new message" : send])
                            
                            //서버에서 fail오류 떴을 경우 - chatting idx를 -2로 업데이트해서 저장.(에러 메시지라는 것.)
                        }else{
                            print("메세지 보내기 후 응답 fail")
                            ChatDataManager.shared.update_send_message(chatroom_idx: object["chatroom_idx"].intValue, chatting_idx: -2, front_created_at: object["front_created_at"].stringValue, content: object["content"].stringValue)
                        }
                    }
                }
                packet.removeAll()
            }
            //채팅룸
            print("연결 후 핸들 이벤트 메소드 데이터 0번째 : \(data[0])")
            //유저
            print("소켓에서 받은 데이터 확인1: \(data[1])")
            //메세지
            print("소켓 메세지 데이터: \(data[2])")
            //알림 데이터
            print("get chat 이벤트 ")
            //채팅방이 존재하던 것인지 확인하기 위해 채팅방 idx리스트 만들기
            db.get_all_chatroom_idx()
            print("소켓에서 채팅방 리스트 idx 확인: \(db.chatroom_idx_list)")
            //////////////////////////삭제
            //                                          db.delete_user_table()
            //                                              db.delete_chatroom()
            //                                                db.delete_tag_table()
            //                                                db.delete_card_table()
            //                                                 db.delete_chatting_table()
            //                db.delete_messages(chatroom_idx: 94)
            let room_result = JSON(data[0])
            
            if room_result != "no_chatrooms"{
                var count = 0
                
                
                self.chat_room_struct.removeAll()
                //서버에서 채팅룸 idx가져온 것만 따로 리스트 만든 것.계산은 모든 데이터 저장 후에 진행함.
                var server_chatroom_idx : [Int] = []
                
                //0배열 정보 집어넣기
                for chat_room in room_result{
                    
                    //ChatRoom모델 데이터
                    let idx = chat_room.1["idx"].intValue
                    //서버에서 채팅룸 idx가져온 것만 따로 리스트 만들기 위해 for문 돌림
                    server_chatroom_idx.append(idx)
                    
                    let card_idx = chat_room.1["card_idx"].intValue
                    let created_at = chat_room.1["created_at"].stringValue
                    
                    let creator_idx = chat_room.1["creator_idx"].intValue
                    print("소켓에서 크리에이터 idx: \(creator_idx)")
                    let deleted_at = chat_room.1["deleted_at"].stringValue
                    let kinds = chat_room.1["kinds"].stringValue
                    //let room_name = chat_room.1["room_name"].stringValue
                    let updated_at = chat_room.1["updated_at"].stringValue
                    let state = chat_room.1["state"].intValue
                    print("state데이터 가져온 것 확인: \(state)")
                    
                    let card_creator_num = chat_room.1["card"]["creator_idx"].intValue
                    let expiration_at = chat_room.1["card"]["expiration_at"].stringValue
                    let card_photo_path = chat_room.1["card"]["card_photo_path"].stringValue
                    let card_kinds = chat_room.1["card"]["kinds"].stringValue
                    let lock_state = chat_room.1["card"]["lock_state"].intValue
                    let card_title = chat_room.1["card"]["title"].stringValue
                    let introduce = chat_room.1["card"]["introduce"].stringValue
                    let address = chat_room.1["card"]["address"].stringValue
                    
                    let cur_user = chat_room.1["card"]["cur_user"].intValue
                    let apply_user = chat_room.1["card"]["apply_user"].intValue
                    let map_lat = chat_room.1["card"]["map_lat"].stringValue
                    let map_lng = chat_room.1["card"]["map_lng"].stringValue
                    let card_created_at = chat_room.1["card"]["created_at"].stringValue
                    let card_updated_at = chat_room.1["card"]["updated_at"].stringValue
                    let card_deleted_at = chat_room.1["card"]["deleted_at"].stringValue
                    
                    //카드 데이터 집어넣기
                    self.card_struct.creator_idx = card_creator_num
                    self.card_struct.expiration_at = expiration_at
                    self.card_struct.card_photo_path = card_photo_path
                    self.card_struct.kinds = card_kinds
                    self.card_struct.lock_state = lock_state
                    self.card_struct.kinds = card_kinds
                    self.card_struct.lock_state = lock_state
                    self.card_struct.title = card_title
                    self.card_struct.introduce = introduce
                    self.card_struct.address = address
                    
                    self.card_struct.cur_user = cur_user
                    self.card_struct.apply_user = apply_user
                    self.card_struct.map_lat = map_lat
                    self.card_struct.map_lng = map_lng
                    self.card_struct.created_at = card_created_at
                    self.card_struct.updated_at = card_updated_at
                    self.card_struct.deleted_at = card_deleted_at
                    
                    print("소켓에서 카드 데이터 확인: \(self.card_struct)")
                    //데이터 모델에 넣기 전에 삭제
                    self.tag_struct.removeAll()
                    
                    let card_tags = chat_room.1["card_tag_list"].arrayValue
                    print("태그 데이터 확인: \(card_tags)")
                    //카드 태그
                    for tag in card_tags{
                        let tag_idx = tag["idx"].intValue
                        print("태그 데이터 뽑은 것: \(tag_idx)")
                        let tag_name = tag["tag_name"].stringValue
                        //태그 데이터 집어넣기
                        self.tag_struct.append(TagModel(idx: tag_idx, tag_name: tag_name))
                        print("태그 데이터 넣은 것 확인: \(self.tag_struct)")
                        
                        //sqlite 태그 데이터 넣기
                        //새로운 채팅방 idx의 경우에는 idx가 000이 온다. 이때는 insert
                        if !db.chatroom_idx_list.contains(idx){
                            
                            print("채팅방이 새로 만들어진 경우의 태그 테이블 만들기")
                            db.insert_tag(chatroom_idx: idx, tag_idx: tag_idx, tag_name: tag_name)
                            
                            //이미 존재하던 채팅방인 경우 update
                        }else{
                            print("채팅방이 이미 있던 경우의 태그 테이블 업데이트")
                            db.update_tag_table(chatroom_idx: idx, tag_idx: tag_idx, tag_name: tag_name)
                        }
                    }
                    print("채팅룸 모델에 저장됐던 것 확인: \(self.chat_room_struct)")
                    
                    //채팅방이 이미 존재하는지 여부를 알기 위해 조건과 일치하는 인덱스 값을 가져온다.
                    var check_exist_idx = self.chat_room_struct.firstIndex(where: {
                        $0.idx == idx
                    })
                    
                    //채팅방 인덱스가 기존에 없었다면
                    if check_exist_idx == nil{
                        
                        print("데이터 모델 안에 채팅방 인덱스 기존에 없었음")
                        self.chat_room_struct.insert(ChatRoomModel(idx: idx, card_idx: card_idx, created_at: created_at, creator_idx: creator_idx, deleted_at: deleted_at, kinds: kinds, updated_at: updated_at, card_tag_list: self.tag_struct, card: self.card_struct), at: count)
                        count = count + 1
                        
                        //만약 채팅방 인덱스가 이미 저장된 경우 기존 저장한 데이터 지우고 다시 저장.
                    }else{
                        print("데이터 모델 안에 채팅방 인덱스 기존에 있었음")
                        self.chat_room_struct.remove(at: idx)
                        self.chat_room_struct.insert(ChatRoomModel(idx: idx, card_idx: card_idx, created_at: created_at, creator_idx: creator_idx, deleted_at: deleted_at, kinds: kinds,  updated_at: updated_at, card_tag_list: self.tag_struct, card: self.card_struct), at: count)
                        count = count + 1
                    }
                    //--------------sqlite 채팅방, 카드 테이블
                    //  채팅방 데이터 넣기(친구, 그룹에 나눠서)
                    if kinds == "일반"{
                        if !db.chatroom_idx_list.contains(idx){
                            print("채팅방이 새로 만들어진 경우의 채팅방, 카드 테이블 만들기")
                            
                            db.insert_chatroom_getchat(idx: idx, card_idx: card_idx, creator_idx: creator_idx, kinds: kinds, created_at: created_at, updated_at: updated_at, deleted_at: deleted_at, state: state)
                            
                            //이미 있던 채팅방의 경우 update
                        }else{
                            print("채팅방이 이미 존재하는 경우의 채팅방, 카드 테이블 업데이트")
                            db.update_chatroom_table(chatroom_idx: idx, card_idx: card_idx, creator_idx: creator_idx, kinds: kinds, created_at: created_at, updated_at: updated_at, deleted_at: deleted_at, state: state)
                        }
                    }else{
                        //클라에서 저장됐던 채팅방이 아닌 경우
                        if !db.chatroom_idx_list.contains(idx){
                            print("채팅방이 새로 만들어진 경우의 채팅방, 카드 테이블 만들기")
                            
                            db.insert_chatroom_getchat(idx: idx, card_idx: card_idx, creator_idx: creator_idx, kinds: kinds, created_at: created_at, updated_at: updated_at, deleted_at: deleted_at, state: state)
                            
                            //  카드 데이터 넣기
                            db.insert_card(chatroom_idx: idx, creator_idx: creator_idx, kinds: card_kinds, card_photo_path: card_photo_path, lock_state: lock_state, title: card_title, introduce: introduce, address: address, map_lat: map_lat, map_lng: map_lng, current_people_count: cur_user, apply_user: apply_user, expiration_at: expiration_at, created_at: card_created_at, updated_at: card_updated_at, deleted_at: card_deleted_at)
                            
                            //이미 있던 채팅방의 경우 update
                        }else{
                            print("채팅방이 이미 존재하는 경우의 채팅방, 카드 테이블 업데이트")
                            
                            db.update_chatroom_table(chatroom_idx: idx, card_idx: card_idx, creator_idx: creator_idx, kinds: kinds,  created_at: created_at, updated_at: updated_at, deleted_at: deleted_at,state: state)
                            
                            db.update_card_table(chatroom_idx: idx, creator_idx: creator_idx, kinds: card_kinds, card_photo_path: card_photo_path, lock_state: lock_state, title: card_title, introduce: introduce, address: address, map_lat: map_lat, map_lng: map_lng, current_people_count: cur_user, apply_user: apply_user, expiration_at: expiration_at, created_at: card_created_at, updated_at: card_updated_at, deleted_at: card_deleted_at)
                            
                        }
                    }
                }
                
                print("채팅룸: \(self.chat_room_struct)")
            }else{
                print("chat room 데이터 없음")
            }
            /*
             메시지 저장하기
             */
            
            if JSON(data[2]) == "no_messages"{
                
            }else{
                let response = JSON(data[2])
                print("메세지가 있는 경우 저장하는데 방 idx저장돼 있는지 확인: \(db.chatroom_idx_list)")
                db.create_chatting_table()
                db.get_all_chatroom_idx()
                let rooms = db.chatroom_idx_list
                print("방 리스트 확인: \(rooms) ")
                
                //저장한 방 리스트를 키값으로 가져온다.
                for room in rooms{
                    print("현재 채팅방 idx: \(room)")
                    let one_room = response["\(room)"].arrayValue
                    print("현재 채팅방 idx 1개 뽑은 것: \(one_room)")
                    
                    //한 채팅방 안에 메세지 리스트
                    for message in one_room{
                        
                        print("메세지 user idx온 것: \(message["user_idx"])")
                        print("메세지 확인6: \(message["content"])")
                        
                        let message_idx = message["idx"].intValue
                        let chatroom_idx = message["chatroom_idx"].intValue
                        let user_idx = message["user_idx"].intValue
                        let content = message["content"].stringValue
                        let kinds = message["kinds"].stringValue
                        let created_at = message["created_at"].stringValue
                        let front_created_at = message["front_created_at"].intValue
                        print("프론트 크리에이티드 변환 전 확인: \(front_created_at)")
                        
                        let string_front = String(front_created_at)
                        print("프론트 크리에이티드 변환 확인: \(string_front)")
                        
                        self.chatting_model.append(ChattingModel(idx: message_idx, chatroom_idx: chatroom_idx, user_idx: user_idx, content: content, kinds: kinds, created_at: created_at, front_created_at: front_created_at))
                        
                        db.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: message_idx, user_idx: user_idx, content: content, kinds: kinds, created_at: created_at, front_created_at: string_front)
                    }
                }
                print("채팅 모델 데이터 확인: \( self.chatting_model)")
            }
            
            /*
             유저 테이블에 저장시 나간 사람, 새로 들어온 사람, 기존 있던 사람 나눠 처리.
             1.서버에서 받은 한 채팅방의 유저 리스트 가져오기
             2.로컬 디비에 저장된 한 채팅방의 유저 리스트 가져오기
             3.저장할 때 비교해서 저장.
             */
            
            //채팅방 유저
            let user_data = JSON(data[1])
            print("유저 데이터: \(user_data)")
            if user_data != "no_users"{
                let chat_user = user_data.array
                
                self.user_chat_struct.removeAll()
                print("유저 데이터 뽑는 것 확인: \(String(describing: chat_user))")
                
                //2.(로컬 디비)현재 idx의 채팅방에 있는 유저 정보들 리스트 가져오는 쿼리.
                db.get_client_server_idx_user()
                
                //2-1.위의 쿼리를 통해 저장한 해당 채팅방의 유저 리스트.
                let sqlite_list = db.exist_chatroom_list
                
                print("로컬 디비에 저장됐던 유저 리스트: \(sqlite_list)")
                
                for user in chat_user! {
                    let server_idx = user["server_idx"].intValue
                    let user_idx = user["idx"].intValue
                    let nickname = user["nickname"].stringValue
                    let read_last_idx = user["read_last_idx"].intValue
                    let read_start_idx = user["read_start_idx"].intValue
                    let chatroom_idx = user["chatroom_idx"].intValue
                    let updated_at = user["updated_at"].stringValue
                    let deleted_at = user["deleted_at"].stringValue
                    
                    print("유저 데이터 뽑는 것 확인: \(user_idx)")
                    print("유저 정보 닉네임 확인: \(nickname)")
                    
                    
                    //유저 데이터 집어넣기(데이터 모델)
                    self.user_chat_struct.append(UserChatModel(idx: user_idx, nickname: nickname, profile_photo_path: "", read_start_idx: read_start_idx, read_last_idx: read_last_idx, updated_at: updated_at, deleted_at: deleted_at))
                    
                    //sqlite
                    //채팅방이 새로 만들어진 경우
                    if !sqlite_list.contains(server_idx){
                        print("채팅방이 새로 만들어진 경우의 유저 테이블 만들기")
                        print("유저 테이블 저장 값 확인: read last idx \(read_last_idx)")
                        print("유저 테이블 저장 값 확인 user idx: \(user_idx)")
                        
                        //sqlite유저 데이터. 이미 있던 채팅방의 경우에는 update
                        db.insert_user(chatroom_idx: chatroom_idx, user_idx: user_idx, nickname: nickname, profile_photo_path: "", read_last_idx: read_last_idx, read_start_idx: read_start_idx, temp_key: "", server_idx: server_idx, updated_at: updated_at, deleted_at: deleted_at)
                        
                        //채팅방이 원래 있었을 경우
                    }else{
                        print("채팅방 원래 있었을 때")
                        
                        //원래 있던 사람 : 로컬 디비 & 서버 저장
                        print("채팅방이 이미 있던 경우의 유저 테이블 업데이트")
                        print("채팅방이 이미 있던 경우 유저 테이블 업데이트에서 채팅방 idx확인: \(chatroom_idx)")
                        print("유저 테이블 저장 값 확인: read last idx \(read_last_idx)")
                        print("유저 테이블 저장 값 확인 user idx: \(user_idx)")
                        
                        db.update_user_table(chatroom_idx: chatroom_idx, user_idx: user_idx, nickname: nickname, profile_photo_path: "", read_last_idx: read_last_idx, read_start_idx: read_start_idx, updated_at: updated_at, deleted_at: deleted_at)
                        
                    }
                }
                print("유저 데이터 집어넣은 것 확인: \(self.user_chat_struct)")
            }
            //key: 유저 idx, value: 현재 시간 "2020-01-01 01:01:01"
            let prev_updated_at = UserDefaults.standard.string(forKey: "\(db.my_idx!)")
            let current_time = db.make_created_at()
            print("현재 시간 확인: \(String(current_time))")
            let current_time_string = String(current_time)
            UserDefaults.standard.set(current_time_string,forKey: "\(db.my_idx!)")
            
            //채팅방 알리 ㅁ데이터
            let chatroom_alarm_data = JSON(data[3])
            print("서버에게 받은 알림 데이터 확인: \(chatroom_alarm_data)")
            //update at이 null일 경우에만 서버에게 알림 데이터 받음.
            if chatroom_alarm_data != "no_notifys" {
                
                let notify_data = chatroom_alarm_data.arrayValue
                let my_idx = db.my_idx!
                
                for info in notify_data{
                    print("현재 알림 1개 정보 포문 안 확인: \(info)")
                    let chatroom_idx = info["chatroom_idx"].intValue
                    let notify_state = info["notify_state"].intValue
                    
                    UserDefaults.standard.set("\(notify_state)",forKey: "\(my_idx)_chatroom_alarm_\(chatroom_idx)")
                    
                }
            }else{
                print("서버에게 받은 알림 정보 없음.")
            }
        }
    }
    
    //************노티피케이션 알림 만들기
    //TODO 클릭시 이동처리
    func create_noti(){
        let content = UNMutableNotificationContent()
        content.title = "알림"
        content.subtitle = "새로운 메세지가 도착했습니다."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "proco", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func noti_data(_ notification: Notification){
        print("노티피케이션 유저인포: \(String(describing: notification.userInfo))")
        if let dictionary = notification.userInfo as NSDictionary?{
            print("노티 값: \(dictionary)")
            if (dictionary["banish"] as! String == "banish"){
                print("받음")
            }
        }
    }
    
    //초대링크 만들어서 보내기
    func make_invite_link(chatroom_idx: Int, card_idx: Int, kinds: String, meeting_date : String, meeting_time: String){
        
        let front_created_at = ChatDataManager.shared.get_current_time()
        let created_at = ChatDataManager.shared.make_created_at()
        let current_room = SockMgr.socket_manager.enter_chatroom_idx
        let idx = Int(ChatDataManager.shared.my_idx!)
        ChatDataManager.shared.insert_chatting(chatroom_idx: current_room, chatting_idx: -1, user_idx: idx!, content: "\(self.invitation_link)", kinds: "D", created_at: created_at, front_created_at: String(front_created_at))
        
        print("채팅메세지 확인 \(self.chat_message_struct)")
        print("채팅메세지 확인2 \(SockMgr.socket_manager.chat_message_struct)")
        
        //바로 전 메세지를 보낸 시각
        var prev_msg_created : String?
        prev_msg_created = self.chat_message_struct.last?.created_at ?? ""
        //바로 전 메세지를 보낸 사람
        var prev_msg_user : String? = ""
        prev_msg_user  = self.chat_message_struct.last?.sender ?? ""
        
        let is_same =  self.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(idx!))
        
        var is_last_consecutive_msg : Bool = true
        if is_same{
            //이번 메세지가 마지막 연속 순서의 메세지이므로
            is_last_consecutive_msg = true
            
            //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
            self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
        }
        
        //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기...idx가 -1일 때 아닐 때로 보여주는 ui변경하기.
        self.chat_message_struct.append(ChatMessage(created_at: created_at,message: "\(self.invitation_link)",message_idx: -1, myMsg: true, front_created_at: String(front_created_at), is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
        print("동적링크 보낸 후 chat_message_struct: \(self.chat_message_struct) ")
        
        self.invitation_link = "\(chatroom_idx)-\(card_idx)-\(kinds)-\(meeting_date)-\(meeting_time)"
        
        //채팅 서버에 메세지 보내기 이벤트 실행.
        self.send_message(message_idx: -1, chatroom_idx: current_room, user_idx: idx!, content: self.invitation_link, kinds: "D", created_at: created_at, front_created_at: front_created_at)
        print("서버에 보내는 메세지: \(self.invitation_link)")
        print("서버에 보내는 채팅방 : \(chatroom_idx)")
        
        //뷰에 예외처리 위해 사용
        //SockMgr.socket_manager.is_dynamic_link = true
    }
    
    @Published var accept_dynamic_link_result: String = ""{
        didSet{
            print("동적링크 클릭 후 값: \(self.accept_dynamic_link_result)")
            objectWillChange.send()
        }
    }
    
    @Published var show_dynamick_link_alert: Bool = false{
        didSet{
            print("show_dynamick_link_alert \(self.show_dynamick_link_alert)")
            
            objectWillChange.send()
        }
    }
    
    //TODO 코드 이곳 말고 다른 클래스에 넣어놓는 것 고려하기
    //동적링크 통해서 카드 참여하는 api 서버 통신
    func accept_dynamic_link(chatroom_idx: Int){
        cancellation = APIClient.accept_dynamic_link(chatroom_idx: chatroom_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("동적링크 카드 참가 신청 수락 에러 발생 : \(error)")
                //self.alert_type = .fail
                
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("동적링크 참가신청 수락 결과 : \(response)")
                
                //동적링크 참가 신청 통신이 result ok로 왔을 경우 채팅서버와도 통신 진행.
                if response["result"] == "ok"{
                    print("동적 링크 참가 신청 api 서버 ok ")
                    let chatroom_idx = response["chatroom_idx"].intValue
                    //수락된 채팅방의 마지막 메세지 idx
                    let last_message_idx = response["message_last_idx"].intValue
                    //유저챗모델: 내 idx, 닉네임, 프로필 경로
                    let my_idx = Int(ChatDataManager.shared.my_idx!)
                    let my_nickname = ChatDataManager.shared.my_nickname
                    
                    //채팅서버에 수락 이벤트 보내기
                    SockMgr.socket_manager.dynamiclink_apply_event(user_idx: my_idx!, chatroom_idx: chatroom_idx)
                    
                    //참가 신청 완료 알림 나타내기
                    //self.alert_type = .success
                }else if response["result"] == "already exist"{
                    print("이미 참가한 경우")
                    self.accept_dynamic_link_result = "already exist"
                    self.show_dynamick_link_alert = true
                }else if response["result"] == "not permitted"{
                    print("동적링크 참가 허가 안됨.")
                    self.accept_dynamic_link_result = "not permitted"
                    self.show_dynamick_link_alert = true
                }else{
                    print("동적링크 참가 신청 실패")
                    self.accept_dynamic_link_result = "error"
                    self.show_dynamick_link_alert = true
                }
                
            })
    }
    
    //동적링크 만들기 - 여기에서 카드idx는 초대할 카드의 idx
    func make_dynamic_link(chatroom_idx: Int, link_img: String?, card_idx: Int, kinds: String){
        print("동적 링크 만드는 메소드 안: \(chatroom_idx)")
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.procomain.page.link"
        components.path = "/invitation"
        print("component만듬")
        
        //링크에 카드idx, 채팅방, 이미지 정보 넣어서 링크 클릭시 이동에 사용.
        let query_item_room = URLQueryItem(name: "chatroom_idx", value: String(chatroom_idx))
        var query_item_image : URLQueryItem
        //TODO 링크 이미지는 보류
        if link_img == nil{
            query_item_image = URLQueryItem(name: "link_img", value: "tab_friend_fill")
            //모임 카드의 이미지는 카드 이미지.
        }else{
            query_item_image = URLQueryItem(name: "link_img", value: "tab_grp_fill")
        }
        let query_item_card = URLQueryItem(name: "card_idx", value: String(card_idx))
        let query_item_kinds = URLQueryItem(name: "kinds", value: kinds)
        components.queryItems = [query_item_room, query_item_image, query_item_card, query_item_kinds]
        print("component 쿼리 파라미터 만듬")
        
        guard let link_param = components.url else{return}
        print("공유하려는 파라미터: \(link_param.absoluteString)")
        
        //긴 동적링크 생성
        guard let share_link = DynamicLinkComponents.init(link: link_param, domainURIPrefix: "https://procomain.page.link")else{
            print("긴 동적링크 안만들어짐 오류.")
            return
        }
        print("긴 동적링크: \(share_link.link)")
        if let my_bundle_id = Bundle.main.bundleIdentifier{
            share_link.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.proco.iosProco")
        }
        print("동적링크 bundle id")
        
        //안드로이드 패키지
        share_link.androidParameters = DynamicLinkAndroidParameters(packageName: "com.example.proco")
        
        //TODO 앱스토어 아이디 내 것으로 바꿀 것.
        share_link.iOSParameters?.appStoreID = "962194608"
        share_link.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        share_link.socialMetaTagParameters?.title = "프로코 초대장이 도착했습니다"
        share_link.socialMetaTagParameters?.descriptionText = "약속 초대장"
        share_link.socialMetaTagParameters?.imageURL = URL(string: "https://search.muz.li/ZmE4MzVjOTY5")
        
        share_link.shorten(completion: {(url, warnings, error) in
            print("단축 링크 만들기")
            if let error = error{
                print("단축 링크 만드는데 오류 발생: \(error)")
                return
            }
            if let warnings = warnings{
                for warning in warnings{
                    print("단축 링크 만드는데 경고: \(warning)")
                }
            }
            guard let url = url else{return}
            print("단축 링크 만들어짐: \(url.absoluteString)")
            //self.invitation_link = url
            print("저장한 링크 확인: \(self.invitation_link)")
            
            let front_created_at = ChatDataManager.shared.get_current_time()
            let created_at = ChatDataManager.shared.make_created_at()
            let current_room = SockMgr.socket_manager.enter_chatroom_idx
            let idx = Int(ChatDataManager.shared.my_idx!)
            ChatDataManager.shared.insert_chatting(chatroom_idx: current_room, chatting_idx: -1, user_idx: idx!, content: "\(self.invitation_link)", kinds: "D", created_at: created_at, front_created_at: String(front_created_at))
            
            print("채팅메세지 확인 \(self.chat_message_struct)")
            print("채팅메세지 확인2 \(SockMgr.socket_manager.chat_message_struct)")
            
            //바로 전 메세지를 보낸 시각
            var prev_msg_created : String?
            prev_msg_created = self.chat_message_struct.last?.created_at ?? ""
            //바로 전 메세지를 보낸 사람
            var prev_msg_user : String? = ""
            prev_msg_user  = self.chat_message_struct.last?.sender ?? ""
            
            let is_same =  self.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(idx!))
            
            var is_last_consecutive_msg : Bool = true
            if is_same{
                //이번 메세지가 마지막 연속 순서의 메세지이므로
                is_last_consecutive_msg = true
                
                //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
            }
            
            //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기...idx가 -1일 때 아닐 때로 보여주는 ui변경하기.
            self.chat_message_struct.append(ChatMessage(created_at: created_at,message: "\(self.invitation_link)",message_idx: -1, myMsg: true, front_created_at: String(front_created_at), is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
            print("동적링크 보낸 후 chat_message_struct: \(self.chat_message_struct) ")
            
            //채팅 서버에 메세지 보내기 이벤트 실행.
            self.send_message(message_idx: -1, chatroom_idx: current_room, user_idx: idx!, content: "\(self.invitation_link)!!\(chatroom_idx)", kinds: "D", created_at: created_at, front_created_at: front_created_at)
            print("서버에 보내는 메세지: \(self.invitation_link)")
            print("서버에 보내는 채팅방 : \(chatroom_idx)")
            
            //뷰에 예외처리 위해 사용
            SockMgr.socket_manager.is_dynamic_link = true
        })
    }
    
    //동적링크 클릭시 동작함.
    //동적링크 안의 파라미터 값을 빼내오기 위해 사용. -> return: 카드 종류를 리턴해서 일반 채팅방에서 뷰 이동시 사용.
    func handle_dynamic_link(_ dynamicLink: URL) -> String {
        print("핸들 다이나믹 링크 : \(dynamicLink)")
        
        let deepLink = dynamicLink.absoluteURL
        let query_items = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        print("핸들 다이나믹 링크 query items: \(String(describing: query_items))")
        
        let link = query_items?.filter({$0.name == "link"}).first?.value
        print("링크 확인: \(String(describing: link))")
        
        let new_link = URLComponents(string: link!)?.queryItems
        print("뉴링크: \(String(describing: new_link))")
        
        let chatroom_idx = new_link?.filter({$0.name == "chatroom_idx"}).first!.value
        print("chatroom_idx 확인: \(String(describing: chatroom_idx))")
        
        let link_img = new_link?.filter({$0.name == "link_img"}).first?.value
        print("링크 이미지 뺀 것 확인: \(String(describing: link_img))")
        
        let card_idx = new_link!.filter({$0.name == "card_idx"}).first!.value!
        print("카드idx 뺸 것 확인: \(String(describing: card_idx))")
        
        let kinds = (new_link?.filter({$0.name == "kinds"}).first!.value)!
        
        self.invite_chatroom_idx = Int(chatroom_idx!)!
        //친구 카드면 친구카드 뷰모델, 모임카드면 모임카드 뷰모델에 선택한 카드 idx를 저장해줘야 상세페이지 가져오는 통신할 때 사용 가능.
        let result = "\(kinds)-\(String(describing: card_idx))"
        print("핸들 다이나믹 링크에서 리턴값: \(result)")
        
        return result
    }
    
    /*
     일반 채팅방 - 친구 내 카드에 초대하기페이지 - 내 모든 카드 리스트 가져오는 통신(api서버)
     1. 데이터 디코딩
     2. 디코딩한 값들 뷰에 보여주기 위해 데이터 모델에 넣기
     */
    func get_all_my_cards(){
        cancellation = APIClient.get_all_my_cards(type: "both")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구 내 카드에 초대하기 - 내 모든 카드 리스트 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("내 모든 카드 리스트 가져옴: \(response)")
                self.friend_card.removeAll()
                self.group_card.removeAll()
                
                if response["result"] == "no result"{
                    print("통신 결과 아직 만든 카드가 없음 no result")
                    
                }else{
                    print("카드 리스트 존재, 이미 넣어진 데이터 있는지 확인: \(self.group_card)")
                    self.group_card.removeAll()
                    self.friend_card.removeAll()
                    
                    let friend_cards = response["friend"].arrayValue
                    let meeting_cards = response["meeting"].arrayValue
                    
                    if friend_cards.count > 0{
                        let json_string = """
                                \(friend_cards)
                                """
                        print("친구 카드 string변환")
                        
                        let json_data = json_string.data(using: .utf8)
                        
                        let card = try? JSONDecoder().decode([FriendVollehCardStruct].self, from: json_data!)
                        
                        print("내가 만든 친구랑 볼래 카드 리스트 디코딩한 값: \(String(describing: card))")
                        
                        self.friend_card = card!
                    }
                    
                    if meeting_cards.count > 0{
                        let json_string = """
                                \(meeting_cards)
                                """
                        print("모임 카드 string변환")
                        
                        let json_data = json_string.data(using: .utf8)
                        
                        let card = try? JSONDecoder().decode([GroupCardStruct].self, from: json_data!)
                        
                        print("내가 만든 모임 카드 리스트 디코딩한 값: \(String(describing: card))")
                        
                        self.group_card = card!
                    }
                }
            })
    }
    
    /*
     새 채팅방 참여 수락 버튼을 누른 사람이 받는 이벤트(동적 링크)
     - 성공시 ChatRoomModel, ChattingModel들어옴.
     1.로컬 데이터에 받은 데이터 저장.
     2.chatroom_idx publish변수에 저장
     3.채팅방으로 이동.
     */
    func dynamiclink_apply_event(user_idx: Int,chatroom_idx: Int){
        
        print("동적 링크에서 카드 참여 이벤트 들어온 값 확인: \(user_idx)")
        
        socket.emitWithAck("client_to_serverjoin_user", user_idx, chatroom_idx, true).timingOut(after: 0.0){data in
            print("동적 링크에서 참가하기 버튼 누른 사람 서버 응답 받음.")
            //data[0] : success, fail
            let result = JSON(data[0])
            //1.채팅룸, 채팅 모델 데이터 저장, 2.enter chatroom idx 저장.
            if result == "success"{
                
                let chatroom_model = JSON(data[1])
                let user_model = JSON(data[2])
                print("조인 유저 이벤트 data 응답: \(data)")
                
                //채팅룸 모델 저장.
                let creator_idx = chatroom_model["creator_idx"].intValue
                let kinds = chatroom_model["kinds"].stringValue
                print("동적링크  채팅방 만든 후 응답 chatroom_idx: \(chatroom_idx)")
                print("동적링크 채팅방 만든 후 응답 kinds: \(kinds)")
                let card_idx = chatroom_model["card_idx"].intValue
                let created_at = chatroom_model["created_at"].stringValue
                let room_name = chatroom_model["room_name"].stringValue
                let updated_at = chatroom_model["updated_at"].string
                let room_deleted_at = chatroom_model["deleted_at"].string
                
                //유저 모델
                let users_list = user_model.arrayValue
                print("임시 채팅방 생성 후 유저 리스트: \(users_list)")
                ChatDataManager.shared.insert_chatroom(idx: chatroom_idx, card_idx: card_idx, creator_idx: creator_idx, kinds: kinds, room_name: room_name, created_at: created_at, updated_at: updated_at ?? "", deleted_at: room_deleted_at ?? "", state: 0)
                
                //유저 모델 저장하기
                for user in users_list{
                    let user_idx = user["idx"].intValue
                    print("동적링크 채팅방 생성 후 유저 저장.: \(user_idx)")
                    
                    let nickname = user["nickname"].stringValue
                    let read_last_idx = user["read_last_idx"].intValue
                    let read_start_idx = user["read_start_idx"].intValue
                    let profile_photo_path = user["profile_photo_path"].stringValue
                    let server_idx = user["server_idx"].intValue
                    
                    ChatDataManager.shared.insert_user(chatroom_idx: chatroom_idx, user_idx: user_idx, nickname: nickname, profile_photo_path: profile_photo_path, read_last_idx: read_last_idx, read_start_idx: read_start_idx, temp_key: "", server_idx: server_idx, updated_at: updated_at ?? "", deleted_at: room_deleted_at ?? "")
                }
                
                //카드 모델 저장하기
                
                let card_creator_idx = chatroom_model["card"]["creator_idx"].intValue
                
                let expiration_at = chatroom_model["card"]["expiration_at"].stringValue
                let card_photo_path = chatroom_model["card"]["card_photo_path"].stringValue
                let card_kinds = chatroom_model["card"]["kinds"].stringValue
                let lock_state = chatroom_model["card"]["lock_state"].intValue
                let card_title = chatroom_model["card"]["title"].stringValue
                let introduce = chatroom_model["card"]["introduce"].stringValue
                let address = chatroom_model["card"]["address"].stringValue
                
                let cur_user = chatroom_model["card"]["cur_user"].intValue
                let apply_user = chatroom_model["card"]["apply_user"].intValue
                let map_lat = chatroom_model["card"]["map_lat"].stringValue
                let map_lng = chatroom_model["card"]["map_lng"].stringValue
                let card_created_at = chatroom_model["card"]["created_at"].stringValue
                let card_updated_at = chatroom_model["card"]["updated_at"].stringValue
                let delete_at = chatroom_model["card"]["deleted_at"].stringValue
                //  카드 데이터 넣기
                ChatDataManager.shared.insert_card(chatroom_idx: chatroom_idx, creator_idx: creator_idx, kinds: card_kinds, card_photo_path: card_photo_path, lock_state: lock_state, title: card_title, introduce: introduce, address: address,  map_lat: map_lat, map_lng: map_lng, current_people_count: cur_user, apply_user: apply_user, expiration_at: expiration_at, created_at: card_created_at, updated_at: card_updated_at, deleted_at: delete_at)
                //태그
                let card_tags = chatroom_model["card_tag_list"].arrayValue
                print("동적링크 태그 데이터 확인: \(card_tags)")
                //카드 태그
                for tag in card_tags{
                    let tag_idx = tag["idx"].intValue
                    print("태그 데이터 뽑은 것: \(tag_idx)")
                    let tag_name = tag["tag_name"].stringValue
                    //태그 데이터 집어넣기
                    self.tag_struct.append(TagModel(idx: tag_idx, tag_name: tag_name))
                    print("태그 데이터 넣은 것 확인: \(self.tag_struct)")
                    
                    //sqlite 태그 데이터 넣기
                    ChatDataManager.shared.insert_tag(chatroom_idx: chatroom_idx, tag_idx: tag_idx, tag_name: tag_name)
                }
                //2.채팅룸 idx 저장.
                self.enter_chatroom_idx = chatroom_idx
                print("동적링크 수락 된 후 이동하려는 채팅방 idx: \(self.enter_chatroom_idx)")
                
                //뷰에 어떤 종류 채팅방으로 이동시킬지(친구/모임), 채팅방 idx전달
                let data = "chatroom: \(chatroom_idx)"
                //3.수락이 완료됐으므로 채팅방으로 이동시키기 위함.
                NotificationCenter.default.post(name: Notification.dynamic_link_move_view, object: nil, userInfo: ["dynamic_link_move_view" : chatroom_idx, "kind" : kinds])
                
                print("채팅방으로 이동시키기 위해 값 true 확인: \(self.server_invite_accepted)")
                
                //fail인 경우
            }else{
                print("동적 링크 통해 참여 후 서버에 응답 오류:\(result)")
            }
        }
    }
    /*
     모임 카드 신청한 사람이 수락 됐다는 이벤트 받은 것.
     1. 받은 데이터 모델 저장.
     2. 서버에 채팅방 참여할 수 있도록 채팅방 번호와 이벤트 보내기.
     */
    func get_join_card_ok(){
        
        socket.on("server_to_clientjoin_room"){data, ack in
            print("모임 신청 수락 됐다는 이벤트 받음: \(data)")
            let chatroom_model = JSON(data[0])
            let user_model = JSON(data[1])
            
            //채팅룸 모델 저장.
            let chatroom_idx = chatroom_model["idx"].intValue
            let creator_idx = chatroom_model["creator_idx"].intValue
            let kinds = chatroom_model["kinds"].stringValue
            print("임시 채팅방 만든 후 응답 chatroom_idx: \(chatroom_idx)")
            print("임시 채팅방 만든 후 응답 kinds: \(kinds)")
            let card_idx = chatroom_model["card_idx"].int
            let created_at = chatroom_model["created_at"].stringValue
            let room_name = chatroom_model["room_name"].stringValue
            let updated_at = chatroom_model["updated_at"].stringValue
            let deleted_at = chatroom_model["deleted_at"].stringValue
            
            db.insert_chatroom(idx: chatroom_idx, card_idx: card_idx ?? -1, creator_idx: creator_idx, kinds: kinds, room_name: room_name, created_at: created_at, updated_at: updated_at, deleted_at: deleted_at, state: 0)
            
            let users_list = user_model.arrayValue
            print("임시 채팅방 생성 후 유저 리스트: \(users_list)")
            
            //유저 모델 저장하기
            for user in users_list{
                let user_idx = user["idx"].intValue
                print("임시 채팅방 생성 후 유저 저장.: \(user_idx)")
                
                let user_image = user["profile_photo_path"].stringValue
                let nickname = user["nickname"].stringValue
                let read_last_idx = user["read_last_idx"].intValue
                let read_start_idx = user["read_start_idx"].intValue
                let profile_photo_path = user["profile_photo_path"].string
                let server_idx = user["server_idx"].intValue
                let updated_at = user["updated_at"].string
                let deleted_at = user["deleted_at"].string
                
                
                db.insert_user(chatroom_idx: chatroom_idx, user_idx: user_idx, nickname: nickname, profile_photo_path: profile_photo_path ?? "", read_last_idx: read_last_idx, read_start_idx: read_start_idx, temp_key: "", server_idx: server_idx,updated_at: updated_at ?? "", deleted_at: deleted_at ?? "")
            }
            print("카드 idx: \(String(describing: card_idx))")
            
            //1대일 채팅
            if card_idx == nil{
                let chatting_model = JSON(data[2])
                print("일대일 채팅인 경우 채팅 메세지 추가: \(chatting_model)")
                
                //메세지 모델
                let message_idx = chatting_model["idx"].intValue
                let chatting_kinds = chatting_model["kinds"].stringValue
                let content = chatting_model["content"].stringValue
                let chatting_created_at = chatting_model["created_at"].stringValue
                let front_created_at = chatting_model["front_created_at"].stringValue
                let chatting_user_idx = chatting_model["user_idx"].intValue
                
                print("join room이벤트에서 메세지 정보 저장: \(content)")
                db.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: message_idx, user_idx: chatting_user_idx, content: content, kinds: chatting_kinds, created_at: created_at, front_created_at: front_created_at)
                print("조인룸 이벤트 받았을 때 enter: \(SockMgr.socket_manager.enter_chatroom_idx)")
                print("조인룸 이벤트 받았을 때 chatroom_idx: \(chatroom_idx)")
                
                //채팅방 안에 있었을 경우
                if self.current_view == 333 && self.enter_chatroom_idx == chatroom_idx {
                    print("join room이벤트를 채팅방 안에서 받은 경우")
                    
                    let num = db.unread_num_first(message_idx: message_idx)
                    //뷰에 보여주기 위해 데이터 모델에 추가
                    self.chat_message_struct.append(ChatMessage( created_at: chatting_created_at, sender: "server", message: content, message_idx: message_idx, myMsg: true, profilePic: self.my_profile_photo, read_num: num, front_created_at: String(front_created_at), is_same_person_msg: false, is_last_consecutive_msg: false))
                    print("임시 채팅방 메세지 보낸 후 데이터 추가한 것 확인: \(self.chat_message_struct)")
                    
                    //TODO 채팅 목록을 보고 있었을 경우
                }else if self.current_view == 222{
                    print("join room이벤트를 채팅 목록을 보고 있을 때 받은 경우")
                    self.create_noti()
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.new_message_in_room_normal, object: nil, userInfo: ["new_message_in_room_normal" : chatroom_idx])
                    
                    //그 외 경우
                }else{
                    print("join room이벤트를 채팅 관련 뷰가 아닌 다른 곳에서 받은 경우")
                    self.create_noti()
                }
                
            }else{
                //수락 후 모임 참여 이벤트
                //let card_model = chatroom_model["card"].dictionaryValue
                let json_string = """
                \(chatroom_model)
                """
                print("카드들 - card string으로 변환: \(json_string)")
                let json_data = json_string.data(using: .utf8)
                
                do{
                    let card_decode = try! JSONDecoder().decode(ChatRoomModel.self, from: json_data!)
                    print("card decode: \(card_decode)")
                    
                    db.insert_card(chatroom_idx: chatroom_idx, creator_idx: card_decode.card!.creator_idx, kinds: card_decode.card!.kinds, card_photo_path:card_decode.card!.card_photo_path ?? "", lock_state: card_decode.card!.lock_state, title: card_decode.card!.title, introduce: card_decode.card!.introduce, address: card_decode.card!.address, map_lat: card_decode.card!.map_lat, map_lng: card_decode.card!.map_lng, current_people_count: card_decode.card!.cur_user, apply_user: card_decode.card!.apply_user, expiration_at: card_decode.card!.expiration_at, created_at: card_decode.card!.created_at, updated_at: card_decode.card!.updated_at ?? "", deleted_at: card_decode.card!.deleted_at ?? "")
                    
                }catch let jsonError as NSError {
                    print("JSON decode failed: \(jsonError.localizedDescription)")
                }
            }
            self.send_join_room_event(chatroom_idx: chatroom_idx)
        }
    }
    
    //모임 카드 참여 이벤트(방장이 수락했을 때 보내는 것.) - api서버 통신 결과 받은 후 이 이벤트 보냄.
    func send_join_card_ok(user_idx: Int, chatroom_idx: Int){
        print("모임 카드 참여 이벤트 들어온 값 확인: \(user_idx), 채팅방 : \(chatroom_idx)")
        
        socket.emit("client_to_serverjoin_user", user_idx, chatroom_idx)
    }
    
    
    //카드 정보 수정...서버 응답을 받는 클라b는 message이벤트로 응답 받음.
    func edit_card_info_event(chatroom: ChatRoomModel){
        print("카드 편집 이벤트 들어옴 : \(chatroom)")
        
        let json_encoder = JSONEncoder()
        let json_data = try? json_encoder.encode(chatroom)
        let json = String(data: json_data!, encoding: String.Encoding.utf8)
        print("제이슨 확인: \(String(describing: json))")
        
        socket.emit("client_to_serverupdate_card", json!)
        print("서버에 카드 수정 이벤트 보냄: 데이터 확인 : \(chatroom)")
    }
    
    //일대일 채팅하기(일반 채팅방 생성 후 대화) - 기존에 채팅방이 없었을 경우
    /*
     1.보내는 데이터
     - 내 유저모델, 상대방 유저모델, 구분자텍스트, 챗모델
     2.클라b : join_room으로 이벤트 받음
     */
    func make_private_chatroom(my_idx: Int, my_nickname: String, my_image: String, friend_idx: Int, friend_nickname: String, friend_image: String, content: String, created_at: String, front_created_at: CLong, kinds: String){
        
        //아래에서 서버에서 응답받은 kinds는 C,P와 같지 않음.
        let message_kinds = kinds
        print("내 : \(my_idx), 친구: \(friend_idx), 메세지 종류: \(kinds)")
        let my_data = ["idx": my_idx, "nickname": my_nickname, "profile_photo_path": my_image] as [String : Any]
        let op_data = ["idx": friend_idx, "nickname": friend_nickname, "profile_photo_path": friend_image] as [String : Any]
        var friend_list : Array<Any> = Array<Any>()
        friend_list.append(op_data)
        
        let my_user_model = try? JSONSerialization.data(withJSONObject: my_data, options: [])
        let op_user_model = try? JSONSerialization.data(withJSONObject: friend_list, options: [])
        
        //채팅방 참여시킬 유저 idx순으로 정렬해서 보내기...사용: 서버에서 응답 받았을 때 내가 보낸 임시메시지, 임시 채팅방 찾는 키값 용도
        //a: 텍스트 구분자, i: 유저 idx구분자
        let idx_array = [my_idx, self.temp_chat_friend_model.idx].sorted()
        let temp_key = "a\(idx_array[0])i\(idx_array[1])"
        print("임시 채팅방 데이터 보내기에서 idx_array: \(idx_array)")
        
        //채팅 모델: 메세지 idx, 채팅방 idx, 보낸사람 idx, 채팅메세지 종류(kinds), 메세지 내용, 서버에서 보낸 시간, 프론트에서 보낸 시간
        let chat_model = ["idx": -1, "chatroom_idx": -1, "user_idx": my_idx, "content": content, "kinds": kinds, "created_at": created_at, "front_created_at": front_created_at] as [String : Any]
        let chat_model_object = try? JSONSerialization.data(withJSONObject: chat_model, options: [])
        print("임시 채팅방 생성시 서버에 보내는 파라미터 확인:my_user_model \(my_data)")
        print("임시 채팅방 생성시 서버에 보내는 파라미터 확인:op_user_model \(op_data)")
        print("임시 채팅방 생성시 서버에 보내는 파라미터 확인:chat_model_object \(chat_model)")
        
        socket.emitWithAck("client_to_servermake_default_room", my_user_model!, op_user_model!, temp_key, chat_model_object!).timingOut(after: 300.0){data in
            print("임시 채팅방 생성 후 서버 응답: \(data)")
            //종류: success, server_error, sql_error
            let response = JSON(data[0])
            
            if response == "success"{
                //response가 success일뗴 아래 응답 3개 추가로 옴.
                //채팅방 객체, 유저객체, 메세지 객체
                let chatroom_model = JSON(data[1])
                let user_model = JSON(data[2])
                let chatting_model = JSON(data[3])
                
                //채팅방 모델
                let chatroom_idx = chatroom_model["idx"].intValue
                let creator_idx = chatroom_model["creator_idx"].intValue
                let kinds = chatroom_model["kinds"].stringValue
                print("임시 채팅방 만든 후 응답 chatroom_idx: \(chatroom_idx)")
                print("임시 채팅방 만든 후 응답 kinds: \(kinds)")
                
                //-1이었던 채팅방 idx도 업데이트시켜줘야 읽음 처리 이벤트가 정상적으로 됨.
                self.enter_chatroom_idx = chatroom_idx
                let created_at = chatroom_model["created_at"].stringValue
                let users_list = user_model.arrayValue
                print("임시 채팅방 생성 후 유저 리스트: \(users_list)")
                
                for user in users_list{
                    let user_idx = user["idx"].intValue
                    print("임시 채팅방 생성 후 유저 저장.: \(user_idx)")
                    
                    let user_image = user["profile_photo_path"].stringValue
                    let nickname = user["nickname"].stringValue
                    let read_last_idx = user["read_last_idx"].intValue
                    let read_start_idx = user["read_start_idx"].intValue
                    let profile_photo_path = user["profile_photo_path"].stringValue
                    let server_idx = user["server_idx"].intValue
                    
                    print("임시 채팅방 생성 후 read last idx: \(read_last_idx)")
                    print("임시 채팅방 생성 후 read_start_idx: \(read_start_idx)")
                    print("임시 채팅방 생성 후 server_idx: \(server_idx)")
                    
                    //임시 유저 찾기 : temp_key이용 (내것, 상대방 것)/ 업데이트 때는 temp_key를 null로 변경.
                    db.update_temp_user_row(user_idx: user_idx, chatroom_idx: chatroom_idx, nickname: nickname, profile_photo_path:profile_photo_path , read_last_idx: read_last_idx, read_start_idx: read_start_idx, temp_key: String(kinds), server_idx: server_idx)
                    
                    //안읽은 갯수 구하기 위해 user read list에 데이터 넣기
                    db.user_read_list.append(read_last_idx)
                    print("join room에서 마지막 메세지 idx리스트 넣은 것 확인: \(db.user_read_list)")
                }
                
                //메세지 모델
                let message_idx = chatting_model["idx"].intValue
                let chatting_kinds = chatting_model["kinds"].stringValue
                let content = chatting_model["content"].stringValue
                let chatting_created_at = chatting_model["created_at"].stringValue
                let front_created_at = chatting_model["front_created_at"].stringValue
                let chatting_user_idx = chatting_model["user_idx"].intValue
                
                //임시 채팅방 찾기 : kinds이용해서 가져오기
                db.update_temp_chatroom(chatroom_idx: chatroom_idx, creator_idx: creator_idx, before_kinds: "일반\(temp_key)", created_at: created_at, new_kinds: "일반")
                //임시 메세지테이블 찾기 : front_created_at이용해서 가져오기
                db.update_temp_chatting(front_created_at: front_created_at, chatting_idx: message_idx, chatroom_idx: chatroom_idx, content: content, created_at: chatting_created_at, kinds: chatting_kinds)
                
                let num = db.unread_num_first(message_idx: message_idx)
                
                //바로 전 메세지를 보낸 시각
                var is_same : Bool = false
                if self.chat_message_struct.count > 1{
                    var prev_msg_created : String?
                    prev_msg_created = self.chat_message_struct[self.chat_message_struct.endIndex-1].created_at ?? ""
                    
                    //바로 전 메세지를 보낸 사람
                    var prev_msg_user : String?
                    prev_msg_user  = self.chat_message_struct[self.chat_message_struct.endIndex-1].sender ?? ""
                    is_same =  self.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(chatting_user_idx))
                }
                
                var is_last_consecutive_msg : Bool = true
                if is_same{
                    //  is_last_consecutive_msg = true
                    //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                    self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                }
                
                if message_kinds == "P"{
                    print("임시 채팅방 메세지가 이미지인 경우")
                    let index = self.chat_message_struct.firstIndex(where: {$0.front_created_at == front_created_at})
                    print("메세지 보내기 이벤트에서 index: \(String(describing: index))")
                    let num = db.unread_num_first(message_idx: message_idx)
                    
                    self.chat_message_struct[index!].read_num = num
                    self.chat_message_struct[index!].message_idx = message_idx
                    self.chat_message_struct[index!].kinds = "P"
                    self.chat_message_struct[index!].message = content
                    self.chat_message_struct[index!].is_same_person_msg = is_same
                    self.chat_message_struct[index!].is_last_consecutive_msg = is_last_consecutive_msg
                    
                }else{
                    //뷰에 보여주기 위해 데이터 모델에 추가
                    self.chat_message_struct.append(ChatMessage( created_at: chatting_created_at, sender: ChatDataManager.shared.my_idx!, message: content, message_idx: message_idx, myMsg: true, profilePic: self.my_profile_photo, read_num: num, front_created_at: String(front_created_at), is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
                }
                print("임시 채팅방 메세지 보낸 후 데이터 추가한 것 확인: \(self.chat_message_struct)")
                
                //-2.read last idx업데이트(나)
                db.update_user_read(chatroom_idx: chatroom_idx, read_last_idx: message_idx, user_idx:Int(ChatDataManager.shared.my_idx!)!, updated_at: chatting_created_at)
                
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.normal_new_message, object: nil, userInfo: ["normal new message" : send])
                
                //5분 타이밍 아웃으로 에러 났을 때
            }else if response == "No Ack"{
                print("임시 채팅방 타임 아웃 에러: \(response)")
                
                //그 외 에러 발생시
            }else{
                print("임시 채팅방 에러: \(response)")
                
            }
        }
    }
    
    //join room이벤트를 받은 사람이 다시 서버에 참여 요청 이벤트를 보내기 위함.
    func send_join_room_event(chatroom_idx: Int){
        
        socket.emit("client_to_serverjoin_room", chatroom_idx)
        print("클라b가 서버에 joinroom 참여 요청 보냄.: \(chatroom_idx)")
    }
    //추방하기 이벤트 : 방장, 방장 이외에 다른 사람들 : 응답 message이벤트로 응답 받음.
    func banish_user(chatroom_idx: Int, my_idx: Int, my_nickname: String, my_profile_photo_path: String, op_idx: Int, op_nickname: String, op_profile_photo_path: String){
        
        let my_data = ["idx": my_idx, "nickname": my_nickname, "profile_photo_path": my_profile_photo_path] as [String : Any]
        let op_data = ["idx": op_idx, "nickname": op_nickname, "profile_photo_path": op_profile_photo_path] as [String : Any]
        
        let my_user_model = try? JSONSerialization.data(withJSONObject: my_data, options: [])
        let op_user_model = try? JSONSerialization.data(withJSONObject: op_data, options: [])
        print("채팅방 추방시킬 때 서버에 보낼 op 파라미터 확인: \(op_data)")
        
        socket.emitWithAck("client_to_serverbanish_user", my_user_model!, op_user_model!, chatroom_idx).timingOut(after: 0){data in
            print("추방 이벤트 응답: \(data[0])")
            let response = JSON(data[0])
            let detail_response = JSON(data[1])
            
            //처리 완료 응답 받았을 때
            if response == "success"{
                print("추방 이벤트 처리 완료: \(detail_response)")
                
                
            }else{
                print("추방 이벤트 처리 실패: \(detail_response)")
                
                if detail_response == "server_error" {
                    print("서버 에러 발생. 로그 확인 요청할 것.")
                    
                }else{
                    print("나가기 도중에 추방을 당한 경우 에러.")
                    //TODO 에러로 추방 못했다는 알림 띄우기.
                    
                }
            }
        }
    }
    
    //추방 당하는 사람이 추방하기 이벤트 응답 받은 후에 다시 서버에 추방 알림 이벤트 보내는 것.
    func send_banished_again(chatroom_idx: Int){
        print("추방 당하는 사람이 다시 서버에 이벤트 보냄. 채팅방idx: \(chatroom_idx)")
        socket.emit("client_to_serverbanished_room", chatroom_idx)
    }
    
    @Published  var chatroom_exit_ok:Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    //채팅방 퇴장하기 이벤트..나중에 message로 이벤트 응답 받음.
    func exit_room(chatroom_idx: Int, idx: Int, nickname: String, profile_photo_path: String, kinds: String?){
        let parameters = ["idx": idx, "nickname": nickname, "profile_photo_path": profile_photo_path] as [String : Any]
        print("채팅방 나갈 때 서버에 보낼 파라미터 확인: \(parameters)")
        
        let object = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        //일반 채팅방의 경우 상대방만 나간 경우 채팅방은 완전히 삭제되지 않음. 메세지만 삭제함.
        if kinds == "일반"{
            print("일반 채팅방에서 나간 경우 exit room 이벤트 모델: \(self.normal_chat_model.count)")
            ChatDataManager.shared.delete_messages(chatroom_idx: chatroom_idx)
            print("일반 채팅방 목록 확인: \(SockMgr.socket_manager.normal_chat_model)")
            print("일반 채팅방 목록 확인2222: \(self.normal_chat_model)")
            
            //일반 채팅방 목록 데이터에서 삭제
            var model_idx : Int
            model_idx = SockMgr.socket_manager.normal_chat_model.firstIndex(where: {
                $0.chatroom_idx == chatroom_idx
            })!
            SockMgr.socket_manager.normal_chat_model.remove(at: model_idx)
            print("일반 채팅방에서 나간 경우 exit room 이벤트 모델 후: \(SockMgr.socket_manager.normal_chat_model.count)")
            self.chatroom_exit_ok = true
            
        }else{
            //emitWithAck사용시 무조건 timingout을 적용해야 emit이 가능함.
            socket.emitWithAck("client_to_serverleave_room", object!, chatroom_idx).timingOut(after: 0){data in
                
                print("채팅방 나갈 때 이벤트 받은 응답: \(data[0])")
                let result = JSON(data[0])
                //퇴장 처리 완료
                if result == "success"{
                    let server_message = JSON(data[1])
                    print("서버 응답 문자: \(server_message)")
                    //저장된 채팅방 idx -1로 만듬.
                    self.enter_chatroom_idx = -1
                    
                    //sqlite업데이트(채팅방, 유저, 카드)
                    ChatDataManager.shared.update_exit_user_table(chatroom_idx: chatroom_idx)
                    ChatDataManager.shared.update_exit_user_chatroom(chatroom_idx: chatroom_idx)
                    ChatDataManager.shared.update_exit_user_card(chatroom_idx: chatroom_idx)
                    
                    self.chatroom_exit_ok = true
                    
                    print("채팅방 나가기 토글값: \(self.chatroom_exit_ok)")
                }else{
                    print("퇴장 처리 이벤트 소켓 클래스에서 fail.")
                }
            }
        }
    }
    
    //상태 업데이트 이벤트.
    //버튼 클릭했을 때
    func click_on_off(user_idx: Int, state: Int, state_data: String){
        let parameters = ["user_idx":user_idx , "state":state , "state_data":state_data] as [String : Any]
        let object = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        print("상태 온오프때 서버에 보낼 파라미터 확인: \(parameters)")
        
        socket.emit("client_to_serverupdate_user_state", object!)
        print("상태 온오프시 서버에 유저 스테이트 모델 보냄")
    }
    
    //상태 업데이트 이벤트 응답 서버에서 받은 경우
    func get_state_update(){
        socket.on("server_to_clientupdate_user_state"){data, ack in
            print("상태 온오프 변경한 이벤트 받음 : \(data)")
            
            let result = JSON(data)
            let user_idx = result["user_idx"].intValue
            let state = result["state"].intValue
            let state_data = result["state_data"].stringValue
            
            UserDefaults.standard.set(state,forKey: "\(db.my_idx!)_state")
        }
    }
    
    //친구랑 볼래에서 카드 만들었을 경우 진행하는 이벤트
    func make_chat_room_friend(chatroom_idx: Int, idx: Int, nickname: String){
        let parameters = ["idx": idx, "nickname": nickname, "profile_photo_path": ""] as [String : Any]
        let object =  try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        socket.emit("client_to_servermake_chatroom", object!, chatroom_idx)
        print("채팅 서버에 친구랑 볼래에서 만든 카드 유저 모델과 채팅룸 idx 보냄: \(chatroom_idx), 파라미터: \(parameters)")
        
    }
    
    /*
     친구랑 볼래 방 입장시 읽음 처리 이벤트.
     1. 채팅방 클릭시 chatroom_idx저장.
     2.서버에 user_read이벤트 실행
     2-1. sqlite에서 CHAT_USER테이블 중 내 idx인 것 가져오기
     */
    //읽음처리 이벤트 보내기
    func enter_friend_card_chat(server_idx: Int,user_idx: Int, chatroom_idx: Int, nickname: String, profile_photo_path: String, read_start_idx: Int, read_last_idx: Int, updated_at : String, deleted_at: String){
        
        let parameters = ["server_idx": server_idx, "idx": user_idx, "nickname": nickname, "profile_photo_path": profile_photo_path, "read_start_idx": read_start_idx, "read_last_idx": read_last_idx, "chatroom_idx": chatroom_idx, "updated_at" : updated_at, "deleted_at" : deleted_at] as [AnyHashable : Any]
        
        let object =  try? JSONSerialization.data(withJSONObject: parameters, options: [])
        socket.emit("client_to_serveruser_read", object!, chatroom_idx)
        print("서버에 채팅방 입장시 읽음 처리 이벤트 보냄. 파라미터 확인: \(parameters)")
        
    }
    
    //메세지 보내기 이벤트
    func send_message(message_idx: Int, chatroom_idx: Int, user_idx: Int, content: String, kinds: String, created_at: String, front_created_at: CLong){
        
        //에러가 난 경우 에러난 메세지를 찾기 위해 front_created_at을 보내는 것.
        let parameters = ["idx": message_idx, "chatroom_idx": chatroom_idx, "user_idx": user_idx, "content": content, "kinds": kinds, "created_at": created_at, "front_created_at": front_created_at] as [String : Any]
        // print("메세지 보내기 이벤트에서 파라미터들 확인: \(parameters)")
        
        let send_object = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        if  socket.status == .connected {
            print("연결된 상태: \(content.count)")
            socket.emitWithAck("client_to_servermessage", send_object!).timingOut(after: 20.0) { (data) in
                
                //성공했는지 실패했는지 이 값에서 알 수 있음.
                let check_ok = data[0]
                print("메세지 보낸 후 응답0: \(data[0])")
                
                //1. sqlite에 메세지 데이터 업데이트해서 저장.
                //2.read last idx 이번에 보낸 메세지 idx로 업데이트해서 저장.
                if check_ok as! String == "success"{
                    print("메세지 보내기 후 응답 success")
                    print("메세지 보낸 후 응답1: \(data[1])")
                    _ = data[1]
                    let result = JSON(data[1])
                    let chatroom_idx = result["chatroom_idx"].intValue
                    let content = result["content"].stringValue
                    let created_at = result["created_at"].stringValue
                    let front_created_at = result["front_created_at"].stringValue
                    let chatting_idx = result["idx"].intValue
                    let kinds = result["kinds"].stringValue
                    let user_idx = result["user_idx"].intValue
                    let server_idx = result["server_idx"].intValue
                    print("채팅 idx 새로 온것 확인: \(chatting_idx)")
                    print("front_created_at 새로 온것 확인: \(front_created_at)")
                    print("채팅 메세지 새로 온것 확인: \(content)")
                    
                    //-1.메세지 성공적으로 보낸 후 sqlite에 다시 업데이트해서 저장.
                    ChatDataManager.shared.update_send_message(chatroom_idx: chatroom_idx, chatting_idx: chatting_idx, front_created_at: String(front_created_at), content: content)
                    
                    print("내가 메세지 보내서 읽은 메세지로 업데이트하려는 메세지 index : read_last_idx \(chatting_idx)")
                    print("내가 메세지 보내서 읽은 메세지 업데이트 하기 전 업데이트하려는 내idx \(Int(db.my_idx!)!) user_idx \(user_idx)")
                    let my_idx = Int(db.my_idx!)!
                    
                    let current_time = ChatDataManager.shared.make_created_at()
                    //07-05, 동적링크 초대시 마지막메시지 idx업데이트 안되는 문제 수정
                    ChatDataManager.shared.last_message_idx = chatting_idx
                    //-2.read last idx업데이트(나)
                    db.update_user_read(chatroom_idx: chatroom_idx, read_last_idx:  ChatDataManager.shared.last_message_idx, user_idx: my_idx, updated_at: current_time)
                    
                    /*
                     안읽은 사람 표시
                     새로운 메세지 보냈을 때 해당 메세지의 안읽은 갯수 구하기 위함.
                     1.방 참가자들의 read last idx를 가져와 리스트를 만든다.
                     2.해당 메세지 idx와 비교해서 안읽은 사람 계산하는 메소드 돌리기.
                     */
                    //1.
                    if db.get_read_last_list(chatroom_idx: chatroom_idx){
                        print("send_message메세지 보내기 이벤트에서 채팅방 마지막 메세지 idx 가져옴: \(db.user_read_list)")
                    }
                    print("메세지 보내기에서 채팅 메세지 확인: \(self.chat_message_struct)")
                    //2.
                    //뷰 업데이트 시키기 위해 데이터 모델도 업데이트
                    let index = self.chat_message_struct.firstIndex(where: {$0.front_created_at == front_created_at})
                    print("메세지 보내기 이벤트에서 index: \(String(describing: index))")
                    let num = db.unread_num_first(message_idx: chatting_idx)
                    
                    self.chat_message_struct[index!].read_num = num
                    self.chat_message_struct[index!].message_idx = chatting_idx
                    self.chat_message_struct[index!].kinds = kinds
                    self.chat_message_struct[index!].message = content
                    let send = "\(String(describing: index)) \(chatting_idx)"
                    
                    var data_array =  self.make_noti_data(message_idx: chatting_idx, user_idx: user_idx, chatroom_idx: chatroom_idx, content: content, front_created_at: front_created_at, created_at: created_at)
                    
                    let json_object = try? JSONSerialization.data(withJSONObject: data_array, options: [])
                    
                    if kinds == "D"{
                        //뷰 업데이트 위해 보내기
                        NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new_message_link" : "ok", "chatroom_idx" : String(chatroom_idx)])
                    }
                }
                else{
                    //서버에서 fail오류 떴을 경우 - chatting idx를 -2로 업데이트해서 저장.(에러 메시지라는 것.)
                    print("메세지 보내기 후 응답 fail")
                    
                    //채팅방을 보고 있을 떄만 데이터 모델 업데이트
                    if SockMgr.socket_manager.current_view == 333 && SockMgr.socket_manager.enter_chatroom_idx == chatroom_idx{
                        print("채팅방 안에 있을 때")
                        
                        let index = self.chat_message_struct.firstIndex(where: {$0.front_created_at == String(front_created_at)})
                        print("메세지 보내기 이벤트에서 index: \(String(describing: index))")
                        let num = db.unread_num_first(message_idx: message_idx)
                        
                        self.chat_message_struct[index!].read_num = num
                        self.chat_message_struct[index!].message_idx = -2
                        self.chat_message_struct[index!].kinds = kinds
                        self.chat_message_struct[index!].message = content
                        
                    }
                    ChatDataManager.shared.update_send_message(chatroom_idx: chatroom_idx, chatting_idx: -2, front_created_at: String(front_created_at), content: content)
                    
                    if kinds == "D"{
                        //뷰 업데이트 위해 보내기
                        NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new_message_link" : "fail", "chatroom_idx" : String(chatroom_idx)])
                    }
                }
            }
        }else{
            print("연결 안된 상태")
            let my_data = ["event": "client_to_servermessage", "object" :parameters] as [String : Any]
            print("연결 안된 상태에서 리스트: \(my_data)")
            print("데이터")
            packet.append(my_data as Any)
            print("패킷에 리스트 넣음: \(packet)")
        }
    }
    
    func make_noti_data(message_idx: Int, user_idx: Int, chatroom_idx: Int, content: String, front_created_at: String, created_at: String) -> Dictionary<String,Any>{
        
        let array = ["idx": message_idx, "user_idx": user_idx, "chatroom_idx": chatroom_idx,"content": content , "front_created_at": front_created_at, "created_at": created_at] as [String : Any]
        
        print("만든 배열 확인: \(array)")
        return array
        
    }
    
    /*
     채팅 메세지 받기 이벤트( 퇴장하기, 추방하기 이벤트도 이곳에서 응답 받음.)
     1. read last idx업데이트하기(메세지를 보낸 사람.)
     2. 시점에 따라 업데이트 - 노티피케이션 센터사용.
     current_view =  채팅 목록 페이지 : 222, 채팅방 안: 333
     */
    
    //메세지 새로 왔을 때 notification center에 사용되는 퍼블리셔
    public let update_chatroom_publisher : PassthroughSubject<String, Never> = PassthroughSubject()
    
    // 메세지 받기 이벤트 응답, 퇴장하기, 추방하기 이벤트, 카드 수정 이벤트, 동적링크에서 누군가 참여 했을 때도 이곳에서 응답 받음.
    func get_new_message(){
        socket.on("server_to_clientmessage"){ [self] data, ack in
            print("메세지 이벤트: \(data)")
            let chatting_model = JSON(data[0])
            print("메세지 받기 이벤트 chatting_model: \(chatting_model)")
            
            let second_data = JSON(data[1])
            
            let chatroom_idx = chatting_model["chatroom_idx"].intValue
            let content = chatting_model["content"].stringValue
            let created_at = chatting_model["created_at"].stringValue
            let front_created_at = chatting_model["front_created_at"].stringValue
            let chatting_idx = chatting_model["idx"].intValue
            let kinds = chatting_model["kinds"].stringValue
            let user_idx = chatting_model["user_idx"].intValue
            
            //1.메세지 성공적으로 받은 후 sqlite에 저장.(메세지 받기, exit user, banish userd, update card 이벤트 모두 해당.)
            db.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: chatting_idx, user_idx: user_idx, content: content, kinds: kinds, created_at: created_at, front_created_at: String(front_created_at))
            
            /*
             메세지 받기 이벤트일 때
             1.sqlite에 저장.(위에서 진행)
             2.메세지 보낸 사람의 읽은 메세지 idx업데이트.
             3.시점에 따른 업데이트.
             */
            if second_data == "Chat"{
                
                let current_time = ChatDataManager.shared.make_created_at()
                //2.read last idx업데이트 - sqlite(메세지를 보낸 사람.)
                ChatDataManager.shared.update_user_read(chatroom_idx: chatroom_idx, read_last_idx: chatting_idx, user_idx: user_idx, updated_at: current_time)
                print("받기 이벤트에서 메세지 보낸 사람 user idx: \(user_idx)")
                
                //채팅방 액티비티에 메시지 추가하기
                var is_mine  = false
                if Int(db.my_idx!) == user_idx{
                    is_mine = true
                    
                }else{is_mine = false}
                
                print("서버 메세지 이벤트 받았을 때 enter: \(SockMgr.socket_manager.enter_chatroom_idx)")
                print("메세지 받았을 때 보고 있는 곳: \(SockMgr.socket_manager.current_view)")
                //3-1. 채팅방 안에 있을 경우, 들어간 채팅방이 같을 경우(current_view=333)
                //채팅방에 메시지 보여주기, user_read이벤트 보내기
                if SockMgr.socket_manager.current_view == 333 && SockMgr.socket_manager.enter_chatroom_idx == chatroom_idx{
                    print("채팅방 안에 있을 때 메세지 받기 이벤트")
                    //바로 전 메세지를 보낸 시각
                    var prev_msg_created : String?
                    prev_msg_created = self.chat_message_struct[self.chat_message_struct.endIndex-1].created_at ?? ""
                    
                    //바로 전 메세지를 보낸 사람
                    var prev_msg_user : String?
                    prev_msg_user  = self.chat_message_struct[self.chat_message_struct.endIndex-1].sender ?? ""
                    let is_same =  self.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(user_idx))
                    print("메세지 받기 이벤트에서 is_same: \(is_same)")
                    var is_last_consecutive_msg : Bool = true
                    if is_same{
                        is_last_consecutive_msg = true
                        
                        //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                        self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                    }
                    print("메세지 받기 이벤트에서 las consecutive: \(self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg)")
                    
                    self.chat_message_struct.append(ChatMessage(kinds: kinds,created_at: created_at, sender: String(user_idx), message: content, message_idx: chatting_idx, myMsg: is_mine, profilePic: "", photo: nil, read_num: -1, front_created_at: front_created_at, is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
                    print("메세지 받기 이벤트에서 데이터 확인: \(self.chat_message_struct)")
                    
                    let my_idx = Int(db.my_idx!)
                    
                    let current_time = ChatDataManager.shared.make_created_at()
                    
                    //내 read last idx업데이트
                    ChatDataManager.shared.update_user_read(chatroom_idx: chatroom_idx, read_last_idx: chatting_idx, user_idx: my_idx!, updated_at: current_time)
                    
                    //누가 메세지를 보냈다는 이벤트를 받은 후 내가 그 메세지를 읽었다는 user read 이벤트 보내기..read start idx는 select로 꺼내오기
                    //read start idx가져오기 위함
                    let read_start_idx = db.get_read_start_idx(user_idx: my_idx!, chatroom_idx: chatroom_idx)
                    //sever idx 가져오는 쿼리
                    ChatDataManager.shared.get_server_idx_to_chat_server(user_idx:  my_idx!, chatroom_idx: chatroom_idx)
                    let got_server_idx = ChatDataManager.shared.user_server_idx
                    
                    //서버에 user read이벤트 보냄.
                    self.update_other_message_read(server_idx: got_server_idx, user_idx: my_idx!, chatroom_idx: chatroom_idx, nickname: UserDefaults.standard.string(forKey: "nickname")!, profile_photo_path: "", read_start_idx: read_start_idx, read_last_idx: chatting_idx, updated_at: current_time, deleted_at: "")
                    /*
                     안읽은 사람 표시
                     새로운 메세지 보냈을 때 해당 메세지의 안읽은 갯수 구하기 위함.
                     1.방 참가자들의 read last idx를 가져와 리스트를 만든다.
                     2.해당 메세지 idx와 비교해서 안읽은 사람 계산하는 메소드 돌리기.
                     */
                    //1.
                    if db.get_read_last_list(chatroom_idx: chatroom_idx){
                        print("get_new_message메세지 받기 이벤트에서 채팅방 마지막 메세지 idx 가져옴: \(db.user_read_list)")
                    }
                    //2.
                    let num = db.unread_num_first(message_idx: chatting_idx)
                    let index = self.chat_message_struct.firstIndex(where: {$0.front_created_at == front_created_at})
                    print("채팅방 안에 있을 때 메세지 받기 이벤트에서 업데이트 시키는 index: \(String(describing: index))")
                    
                    self.chat_message_struct[index!].read_num = num
                    self.chat_message_struct[index!].message_idx = chatting_idx
                    let send = "\(String(describing: index)) \(chatting_idx) \(num)"
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new message" : send])
                    
                    //2-2.채팅방 목록을 보고 있을 때
                }
                else if SockMgr.socket_manager.current_view == 222{
                    print("채팅방 목록을 보고 있을 때")
                    
                    var is_same : Bool = false
                    print("채팅방 목록 보고 있을 때 chat message struct: \(self.chat_message_struct)")
                    if self.chat_message_struct.count > 1{
                        //바로 전 메세지를 보낸 시각
                        var prev_msg_created : String?
                        prev_msg_created = self.chat_message_struct[self.chat_message_struct.endIndex-1].created_at ?? ""
                        
                        //바로 전 메세지를 보낸 사람
                        var prev_msg_user : String?
                        prev_msg_user  = self.chat_message_struct[self.chat_message_struct.endIndex-1].sender ?? ""
                        is_same =  self.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(user_idx))
                    }
                    
                    var is_last_consecutive_msg : Bool = true
                    if is_same{
                        is_last_consecutive_msg = true
                        
                        //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                        self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                        
                    }
                    
                    self.chat_message_struct.append(ChatMessage(created_at: created_at, sender: String(user_idx), message: content, message_idx: chatting_idx, myMsg: is_mine, profilePic: "", photo: nil, read_num: -1, front_created_at: front_created_at, is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
                    
                    
                    //해당 채팅방 최상단으로 올리기
                    //친구, 모임, 일반인지 타입 확인하기 위해 디비 쿼리 & 마지막 메시지, 안읽은 메시지, 시간 업데이트
                    ChatDataManager.shared.read_chatroom(chatroom_idx: chatroom_idx)
                    if self.current_chatroom_info_struct.kinds == "친구"{
                        print("채팅방 목록 보고 있을 때friend_chat_model확인: \(self.friend_chat_model)")
                        
                        let index = self.friend_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        self.friend_chat_model[index!].last_chat = content
                        self.friend_chat_model[index!].chat_time = created_at
                        
                        //안읽은 메세지 갯수 업데이트
                        let before = Int(self.friend_chat_model[index!].message_num!)
                        let after = before! + 1
                        self.friend_chat_model[index!].message_num = String(after)
                        
                        //최근 온 메세지가 포함된 채팅방 목록을 가장 상단으로 올리기 위함.
                        self.friend_chat_model.insert(self.friend_chat_model.remove(at: index!), at: 0)
                        
                    }else if self.current_chatroom_info_struct.kinds == "모임"{
                        
                        let index = self.group_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        self.group_chat_model[index!].last_chat = content
                        self.group_chat_model[index!].chat_time = created_at
                        
                        //안읽은 메세지 갯수 업데이트
                        let before = Int(self.group_chat_model[index!].message_num!)
                        let after = before! + 1
                        self.group_chat_model[index!].message_num = String(after)
                        
                        //최근 온 메세지가 포함된 채팅방 목록을 가장 상단으로 올리기 위함.
                        self.group_chat_model.insert(self.group_chat_model.remove(at: index!), at: 0)
                    }else{
                        
                        print("일반 채팅방 메세지일 때")
                        let index = self.normal_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        self.normal_chat_model[index!].last_chat = content
                        self.normal_chat_model[index!].chat_time = created_at
                        
                        //안읽은 메세지 갯수 업데이트
                        let before = Int(self.normal_chat_model[index!].message_num!)
                        let after = before! + 1
                        self.normal_chat_model[index!].message_num = String(after)
                        
                        //최근 온 메세지가 포함된 채팅방 목록을 가장 상단으로 올리기 위함.
                        var temp_data = self.normal_chat_model[index!]
                        
                        self.normal_chat_model.insert(self.normal_chat_model.remove(at: index!), at: 0)
                        
                    }
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.new_message_in_room, object: nil, userInfo: ["new_message_in_room" : chatroom_idx])
                    
                    //다른 채팅방을 보고 있거나 다른 화면을 보고 있을 때
                    //노티피케이션 띄우기
                }
                else{
                    print("다른 채팅방을 보고 있거나 다른 화면을 보고 있을 때")
                    self.create_noti()
                }
            }
            
            /*
             퇴장하기 이벤트
             퇴장한 사람이 아니라 같은 채팅방에 있던 사람이 응답 받는 것.
             1.받은 메시지 저장.(위에서 진행)
             2. 유저 모델중 채팅방 idx 조건 넣어서 클라이언트a정보 삭제.
             */
            else if second_data == "ExitUser"{
                
                //deleted_at 추가하는 것으로 변경. 1/17
                db.delete_exit_user(chatroom_idx: chatroom_idx, user_idx: user_idx)
                
                if creator_idx == user_idx{
                    //sqlite업데이트(채팅방, 유저, 카드)
                    ChatDataManager.shared.update_exit_user_table(chatroom_idx: chatroom_idx)
                    ChatDataManager.shared.update_exit_user_chatroom(chatroom_idx: chatroom_idx)
                    ChatDataManager.shared.update_exit_user_card(chatroom_idx: chatroom_idx)
                }
                
                self.chat_message_struct.append(ChatMessage(created_at: created_at, sender: "server", message: content, message_idx: chatting_idx, myMsg: false, profilePic: "", read_num: 0, front_created_at: front_created_at, is_same_person_msg: false, is_last_consecutive_msg: false))
                
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new message" : "server"])
            }
            
            /*
             추방하기 이벤트
             1.받은 메세지 저장(위에서 진행)
             2.추방 당하는 사람, 알림을 받는 사람 구분
             */
            else if second_data == "BanishUser"{
                print("추방 당하기 이벤트일 경우")
                
                let user_model = JSON(data[2])
                print("추방 당하기 이벤트에서 받은 유저 모델: \(user_model)")
                
                //유저 모델에 저장된 유저 idx
                var out_user_idx = user_model["idx"].intValue
                print("내 idx: \(String(describing: Int(db.my_idx!))), 추방 당한 사람: \(out_user_idx)")
                
                
                //추방 당하는 사람이 나라면
                if out_user_idx == Int(db.my_idx!){
                    print("추방 당하는 사람이 나일 때")
                    //~가 추방당했습니다 라는 메시지 추가
                    self.chat_message_struct.append(ChatMessage(created_at: created_at, sender: "server", message: content, message_idx: chatting_idx, myMsg: false, profilePic: "", read_num: 0, front_created_at: front_created_at, is_same_person_msg: false, is_last_consecutive_msg: false))
                    
                    let current_time = db.make_created_at()
                    //해당 채팅방, 메세지 정보 삭제
                    db.delete_my_chatroom(chatroom_idx: chatroom_idx, deleted_at: current_time, user_idx: out_user_idx)
                    db.delete_my_chatting(chatroom_idx: chatroom_idx, user_idx: out_user_idx)
                    db.delete_my_user(chatroom_idx: chatroom_idx, deleted_at: current_time, user_idx: out_user_idx)
                    
                    //채팅방 드로어에 대화상대 목록에서 삭제.
                    let stored_user_idx =  SockMgr.socket_manager.user_drawer_struct.firstIndex(where: {
                        $0.user_idx == Int(db.my_idx!)
                    })
                    SockMgr.socket_manager.user_drawer_struct.remove(at: stored_user_idx!)
                    
                    //만약 채팅방안에 있었다면
                    if current_view == 333 && SockMgr.socket_manager.enter_chatroom_idx == chatroom_idx{
                        print("내가 추방 당할 때 채팅방 안에 있었을 때")
                        //뷰 업데이트 위해 보내기, 서버 메세지 보여주고 다른 뷰로 이동시키기
                        NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["banished" : "banished"])
                        
                        //채팅방 목록을 보고 있었다면
                    }else if current_view == 222{
                        print("내가 추방 당할 때 채팅방 목록을 보고 있었을 때")
                        
                        //채팅방 드로어에 대화상대 목록에서 삭제.
                        let stored_user_idx =  SockMgr.socket_manager.user_drawer_struct.firstIndex(where: {
                            $0.user_idx == out_user_idx
                        })
                        SockMgr.socket_manager.user_drawer_struct.remove(at: stored_user_idx!)
                        
                        //뷰 업데이트 위해 보내기
                        NotificationCenter.default.post(name: Notification.new_message_in_room, object: nil, userInfo: ["new_message_in_room" : chatroom_idx])
                    }
                    
                    //서버에 다시 추방 알림 이벤트 보내기.
                    self.send_banished_again(chatroom_idx: chatroom_idx)
                    
                    //추방 당하는 사람이 아닌 사람들
                }else{
                    
                    //deleted at유저 테이블에 추가하는 것.(쿼리 안에서 deleted at 만듬.)
                    db.delete_exit_user(chatroom_idx: chatroom_idx, user_idx: out_user_idx)
                    
                    //~가 추방당했습니다 라는 메시지 추가
                    self.chat_message_struct.append(ChatMessage(created_at: created_at, sender: "server", message: content, message_idx: chatting_idx, myMsg: false, profilePic: "", read_num: 0, front_created_at: front_created_at, is_same_person_msg: false, is_last_consecutive_msg: false))
                    
                    //추방당한 유저 모델에서 삭제
                    let model_idx =  self.user_drawer_struct.firstIndex(where: {
                        $0.user_idx == out_user_idx
                    })
                    self.user_drawer_struct.remove(at: model_idx!)
                    
                    //만약 채팅방안에 있었다면
                    if current_view == 333{
                        print("추방 당하는 사람이 아닌 유저가 채팅방 안에 있었을 때")
                        //뷰 업데이트 위해 보내기
                        NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new message" : "server"])
                        
                    }else if current_view == 222{
                        print("추방 당하는 사람이 아닌 유저가 채팅방 목록 보고 있었을 때")
                        
                        //뷰 업데이트 위해 보내기
                        NotificationCenter.default.post(name: Notification.new_message_in_room, object: nil, userInfo: ["new_message_in_room" : chatroom_idx])
                    }
                }
            }
            /*
             카드 정보 수정하기 이벤트
             - 채팅방 안에 있는 사람이 카드가 수정 됐다라는 이벤트를 받았을 때
             1. 로컬db에 메세지 저장.(위에서 진행)
             2. 시점에 따라 업데이트
             */
            else if second_data == "UpdateCard"{
                
                let chat_room = JSON(data[2])
                print("카드 업데이트 이벤트 받음, 채팅룸 데이터: \(chat_room)")
                let json_string = """
                \(chat_room)
                """
                print("제이슨 스트링 확인: \(json_string)")
                let json_data = json_string.data(using: .utf8)
                do{
                    let room_data = try? JSONDecoder().decode(ChatRoomModel.self, from: json_data!)
                    
                    //카드 데이터 집어넣기
                    self.card_struct = CardModel(creator_idx: room_data!.card!.creator_idx, expiration_at: room_data!.card!.expiration_at, card_photo_path: room_data!.card!.card_photo_path, kinds: room_data!.card!.kinds, lock_state: room_data!.card!.lock_state, title: room_data!.card!.title, introduce: room_data!.card!.introduce, address: room_data!.card!.address, cur_user: room_data!.card!.cur_user, apply_user: room_data!.card!.apply_user, map_lat: room_data!.card!.map_lat, map_lng: room_data!.card!.map_lng, created_at: room_data!.card!.created_at, updated_at: room_data!.card!.updated_at, deleted_at: room_data!.card!.deleted_at)
                    print("카드 데이터 넣은 것 확인: \(self.card_struct)")
                    
                    let card_tags = room_data!.card_tag_list
                    //카드 태그
                    for tag in card_tags!{
                        self.tag_struct.append(TagModel(idx: tag.idx, tag_name: tag.tag_name))
                        
                        print("태그 데이터 넣은 것 확인: \(self.tag_struct)")
                        
                        //sqlite 태그 데이터 넣기
                        print("채팅방이 이미 있던 경우의 태그 테이블 업데이트")
                        db.update_tag_table(chatroom_idx: chatroom_idx, tag_idx: tag.idx, tag_name: tag.tag_name)
                    }
                    
                    // if room_data!.card!.creator_idx != Int(db.my_idx!){
                    db.update_chatroom_card(chatroom_idx: room_data!.idx, card_idx: room_data!.card_idx, creator_idx: room_data!.creator_idx, kinds: room_data!.kinds, created_at: room_data!.created_at, updated_at: room_data!.updated_at ?? "", deleted_at: room_data!.deleted_at ?? "",room_name: room_data!.room_name, state: 0)
                    
                    db.update_card_table(chatroom_idx: room_data!.idx, creator_idx: room_data!.creator_idx, kinds: room_data!.kinds, card_photo_path: room_data!.card!.card_photo_path ?? "", lock_state: room_data!.card!.lock_state, title: room_data!.card!.title, introduce: room_data!.card!.introduce, address: room_data!.card!.address, map_lat: room_data!.card!.map_lat, map_lng: room_data!.card!.map_lng, current_people_count: room_data!.card!.cur_user, apply_user: room_data!.card!.apply_user, expiration_at: room_data!.card!.expiration_at, created_at: room_data!.card!.created_at, updated_at: room_data!.card!.updated_at ?? "", deleted_at: room_data!.card!.deleted_at ?? "")
                    // }
                }catch{
                    print("카드 업데이트 이벤트 디코딩 오류: \(error.localizedDescription)")
                }
                
                //서버로부터 카드 정보 수정되었다는 메세지 받은 것 추가.
                self.chat_message_struct.append(ChatMessage(created_at: created_at, sender: "server", message: content, message_idx: chatting_idx, myMsg: false, profilePic: "", read_num: 0, front_created_at: front_created_at, is_same_person_msg: false, is_last_consecutive_msg: false))
                
                //뷰 시점에 따른 업데이트(채팅방 안, 목록, 그 외)
                if SockMgr.socket_manager.current_view == 333 && SockMgr.socket_manager.enter_chatroom_idx == chatroom_idx{
                    print("채팅방 안에 있을 때")
                    NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new message" : "server"])
                    
                }else if SockMgr.socket_manager.current_view == 222{
                    print("채팅방 목록을 보고 있을 때")
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.new_message_in_room, object: nil, userInfo: ["new_message_in_room" : chatroom_idx])
                    
                }
            }
            /*
             모임 참여 이벤트
             - 새로운 사람이 들어왔을 때(동적 링크 통해서 참여한 사람이 있을 경우 기존 채팅방 참가자들은 이 이벤트 받음)
             1. 받은 메세지 저장(위에서 진행)
             2. chatroom모델에서 chatroom users에 새로 들어온 사람 정보 저장.
             */
            else if second_data == "NewUser"{
                
                
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new message" : "server"])
                
                let user_model = JSON(data[2])
                let new_user_idx = user_model["idx"].intValue
                let nickname = user_model["nickname"].stringValue
                let profile_photo = user_model["profile_photo_path"].stringValue
                let read_last_idx = user_model["read_last_idx"].intValue
                let rad_start_idx = user_model["rad_start_idx"].intValue
                let server_idx = user_model["server_idx"].intValue
                let updated_at = user_model["updated_at"].stringValue
                let deleted_at = user_model["deleted_at"].stringValue
                
                if new_user_idx != Int(ChatDataManager.shared.my_idx!){
                    //새로 들어온 참가자 정보 저장.
                    db.insert_user(chatroom_idx: chatroom_idx, user_idx: new_user_idx, nickname: nickname, profile_photo_path: profile_photo, read_last_idx: read_last_idx, read_start_idx: rad_start_idx, temp_key: "", server_idx: server_idx, updated_at: updated_at, deleted_at: deleted_at)
                }
                
                if SockMgr.socket_manager.current_view == 333 && SockMgr.socket_manager.enter_chatroom_idx == chatroom_idx{
                    print("채팅방 안에 있을 때")
                    
                    var is_same : Bool = false
                    if self.chat_message_struct.count > 1{
                        //바로 전 메세지를 보낸 시각
                        var prev_msg_created : String?
                        prev_msg_created = self.chat_message_struct[self.chat_message_struct.endIndex-1].created_at ?? ""
                        
                        //바로 전 메세지를 보낸 사람
                        var prev_msg_user : String?
                        prev_msg_user  = self.chat_message_struct[self.chat_message_struct.endIndex-1].sender ?? ""
                        is_same =  self.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(user_idx))
                    }
                    var is_last_consecutive_msg : Bool = true
                    if is_same{
                        is_last_consecutive_msg = true
                        
                        //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                        self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                        
                    }
                    
                    self.chat_message_struct.append(ChatMessage(created_at: created_at, sender: "server", message: content, message_idx: chatting_idx, myMsg: false, profilePic: "", read_num: 0, front_created_at: front_created_at, is_same_person_msg: false, is_last_consecutive_msg: false))
                    
                    let my_idx = Int(db.my_idx!)
                    
                    let current_time = ChatDataManager.shared.make_created_at()
                    
                    //내 read last idx업데이트
                    ChatDataManager.shared.update_user_read(chatroom_idx: chatroom_idx, read_last_idx: chatting_idx, user_idx: my_idx!, updated_at: current_time)
                    
                    //누가 메세지를 보냈다는 이벤트를 받은 후 내가 그 메세지를 읽었다는 user read 이벤트 보내기..read start idx는 select로 꺼내오기
                    //read start idx가져오기 위함
                    let read_start_idx = db.get_read_start_idx(user_idx: my_idx!, chatroom_idx: chatroom_idx)
                    //sever idx 가져오는 쿼리
                    ChatDataManager.shared.get_server_idx_to_chat_server(user_idx:  my_idx!, chatroom_idx: chatroom_idx)
                    let got_server_idx = ChatDataManager.shared.user_server_idx
                    
                    //서버에 user read이벤트 보냄.
                    self.update_other_message_read(server_idx: got_server_idx, user_idx: my_idx!, chatroom_idx: chatroom_idx, nickname: UserDefaults.standard.string(forKey: "nickname")!, profile_photo_path: "", read_start_idx: read_start_idx, read_last_idx: chatting_idx, updated_at: current_time, deleted_at: "")
                    /*
                     안읽은 사람 표시
                     새로운 메세지 보냈을 때 해당 메세지의 안읽은 갯수 구하기 위함.
                     1.방 참가자들의 read last idx를 가져와 리스트를 만든다.
                     2.해당 메세지 idx와 비교해서 안읽은 사람 계산하는 메소드 돌리기.
                     */
                    //1.
                    if db.get_read_last_list(chatroom_idx: chatroom_idx){
                        print("get_new_message메세지 받기 이벤트에서 채팅방 마지막 메세지 idx 가져옴: \(db.user_read_list)")
                    }
                    //2.
                    let num = db.unread_num_first(message_idx: chatting_idx)
                    
                    let index = self.chat_message_struct.firstIndex(where: {$0.front_created_at == front_created_at})
                    print("채팅방 안에 있을 때 메세지 받기 이벤트에서 업데이트 시키는 index: \(String(describing: index))")
                    self.chat_message_struct[index!].read_num = num
                    self.chat_message_struct[index!].message_idx = chatting_idx
                    let send = "\(String(describing: index)) \(chatting_idx) \(num)"
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.new_message, object: nil, userInfo: ["new message" : send])
                    
                    //2-2.채팅방 목록을 보고 있을 때
                }
                else if SockMgr.socket_manager.current_view == 222{
                    print("채팅방 목록을 보고 있을 때")
                    
                    var is_same : Bool = false
                    print("채팅방 목록 보고 있을 때 chat message struct: \(self.chat_message_struct)")
                    if self.chat_message_struct.count > 1{
                        //바로 전 메세지를 보낸 시각
                        var prev_msg_created : String?
                        prev_msg_created = self.chat_message_struct[self.chat_message_struct.endIndex-1].created_at ?? ""
                        
                        //바로 전 메세지를 보낸 사람
                        var prev_msg_user : String?
                        prev_msg_user  = self.chat_message_struct[self.chat_message_struct.endIndex-1].sender ?? ""
                        is_same =  self.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(user_idx))
                    }
                    
                    var is_last_consecutive_msg : Bool = true
                    if is_same{
                        is_last_consecutive_msg = true
                        
                        //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                        self.chat_message_struct[self.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                        
                    }
                    
                    self.chat_message_struct.append(ChatMessage(created_at: created_at, sender: "server", message: content, message_idx: chatting_idx, myMsg: false, profilePic: "", read_num: 0, front_created_at: front_created_at, is_same_person_msg: false, is_last_consecutive_msg: false))
                    
                    //해당 채팅방 최상단으로 올리기
                    //친구, 모임, 일반인지 타입 확인하기 위해 디비 쿼리 & 마지막 메시지, 안읽은 메시지, 시간 업데이트
                    ChatDataManager.shared.read_chatroom(chatroom_idx: chatroom_idx)
                    if self.current_chatroom_info_struct.kinds == "친구"{
                        print("채팅방 목록 보고 있을 때friend_chat_model확인: \(self.friend_chat_model)")
                        
                        let index = self.friend_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        self.friend_chat_model[index!].last_chat = content
                        self.friend_chat_model[index!].chat_time = created_at
                        
                        //안읽은 메세지 갯수 업데이트
                        let before = Int(self.friend_chat_model[index!].message_num!)
                        let after = before! + 1
                        self.friend_chat_model[index!].message_num = String(after)
                        
                    }else if self.current_chatroom_info_struct.kinds == "모임"{
                        
                        let index = self.group_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        self.group_chat_model[index!].last_chat = content
                        self.group_chat_model[index!].chat_time = created_at
                        
                        //안읽은 메세지 갯수 업데이트
                        let before = Int(self.group_chat_model[index!].message_num!)
                        let after = before! + 1
                        self.group_chat_model[index!].message_num = String(after)
                        
                    }else{
                        
                        print("일반 채팅방 메세지일 때")
                        let index = self.normal_chat_model.firstIndex(where: {$0.chatroom_idx == chatroom_idx})
                        self.normal_chat_model[index!].last_chat = content
                        self.normal_chat_model[index!].chat_time = created_at
                        
                        //안읽은 메세지 갯수 업데이트
                        let before = Int(self.normal_chat_model[index!].message_num!)
                        let after = before! + 1
                        self.normal_chat_model[index!].message_num = String(after)
                    }
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.new_message_in_room, object: nil, userInfo: ["new_message_in_room" : chatroom_idx])
                    
                    //다른 채팅방을 보고 있거나 다른 화면을 보고 있을 때
                    //노티피케이션 띄우기
                }
                else{
                    print("다른 채팅방을 보고 있거나 다른 화면을 보고 있을 때")
                    self.create_noti()
                }
                
            }
        }
    }
    
    //메세지 받기 이벤트에서
    //다른 사람이 메시지 보낸 걸 내가 채팅방 안에서 봤을 때(채팅방 입장시 보내는 user read 아님)
    func update_other_message_read(server_idx:Int,user_idx: Int, chatroom_idx: Int, nickname: String, profile_photo_path: String, read_start_idx: Int, read_last_idx: Int, updated_at: String, deleted_at : String){
        
        let parameters = ["server_idx": server_idx, "idx": user_idx, "nickname": nickname, "profile_photo_path": profile_photo_path, "read_start_idx": read_start_idx, "read_last_idx": read_last_idx, "chatroom_idx": chatroom_idx, "updated_at": updated_at, "deleted_at": deleted_at] as [AnyHashable : Any]
        
        let object =  try? JSONSerialization.data(withJSONObject: parameters, options: [])
        print("메세지 받기 이벤트에서 보내는 user read 이벤트 파라미터: \(parameters)")
        socket.emit("client_to_serveruser_read", object!, chatroom_idx, true)
    }
    
    //채팅방 읽음 처리 이벤트(클라b) user read 이벤트 왔을 때
    //채팅방 읽음 처리 위해 서버에 데이터 보낸 후 response받았을 때
    func get_update_read(){
        
        socket.on("server_to_clientuser_read"){ data,ack  in
            print("채팅방 입장 후 서버에서 응답 받음 첫번째: \(data[0])")
            let user_chat = JSON(data[0])
            let idx = data[1]
            let past_read_idx = JSON(data[2]).intValue
            print("서버에서 받은 과거 read last idx: \(past_read_idx)")
            
            //서버에서 받은 첫번째 인자 파싱
            let profile = user_chat["profile_photo_path"].stringValue
            let user_idx = user_chat["idx"].intValue
            print("채팅방 입장후 받은 응답 파싱 확인: \(user_idx)")
            let read_last_idx = user_chat["read_last_idx"].intValue
            let nickname = user_chat["nickname"].stringValue
            print("채팅방 입장후 받은 응답 파싱 확인: 닉네임: \(nickname), 마지막 읽은 idx:\(read_last_idx)")
            let read_start_idx = user_chat["read_start_idx"].intValue
            let chatroom_idx = user_chat["chatroom_idx"].intValue
            let server_idx = user_chat["server_idx"].intValue
            
            print("현재 있는 채팅방 idx: \(SockMgr.socket_manager.enter_chatroom_idx)")
            print("서버한테 받은 채팅방 idx: \(chatroom_idx)")
            
            //현재 사용자가 채팅방안에 있을 때
            if SockMgr.socket_manager.current_view == 333 && SockMgr.socket_manager.enter_chatroom_idx == chatroom_idx{
                print("클라b가 채팅을 보고 있었을 때 읽은 마지막 메세지 idx업데이트")
                
                let currenet_time = ChatDataManager.shared.make_created_at()
                //클라b에서 클라a의 read last idx업데이트
                ChatDataManager.shared.update_user_read(chatroom_idx: chatroom_idx, read_last_idx: read_last_idx, user_idx: user_idx, updated_at: currenet_time)
                
                print("받은 user idx: \(user_idx), 내 idx\(Int(db.my_idx!)!)")
                /*
                 안읽은 사람 표시
                 새로운 메세지 보냈을 때 해당 메세지의 안읽은 갯수 구하기 위함.
                 1.방 참가자들의 read last idx를 가져와 리스트를 만든다.
                 2.해당 메세지 idx와 비교해서 안읽은 사람 계산하는 메소드 돌리기.
                 */
                //1.
                if db.get_read_last_list(chatroom_idx: chatroom_idx){
                    print("get_update_read이벤트에서 채팅방 마지막 메세지 idx 가져옴: \(db.user_read_list)")
                }
                //2.
                //채팅문제
                //안읽은 메세지 갯수가 여러개일 때 안읽은 메세지 중 마지막 메세지만 업데이트 되기 때문.
                if past_read_idx == 0 && read_last_idx == 0{
                    print("past read idx와 read last idx가 0인 경우")
                    
                }else if past_read_idx == read_last_idx{
                    print("past read idx와 read last idx가 같은 경우")
                    
                    let unread_num =  db.unread_num_first(message_idx: read_last_idx)
                    
                    let index = self.chat_message_struct.firstIndex(where: {$0.message_idx ==  read_last_idx})
                    self.chat_message_struct[index!].read_num = unread_num
                    //notification center 사용해 메시지 실시간 읽은 것 구현.
                    NotificationCenter.default.post(name: Notification.new_message, object: nil)
                    
                }else{
                    print("past read idx와 read last idx가 다른 경우")
                    var past_index = self.chat_message_struct.firstIndex(where: {$0.message_idx! >  past_read_idx})
                    
                    let last_index = self.chat_message_struct.firstIndex(where: {$0.message_idx ==  read_last_idx})
                    print("클라b읽음처리 할 때 메세지 데이터 모델 확인: \(self.chat_message_struct)")
                    print("클라b읽음처리 할 때 메세지 데이터 모델 카운트 확인2: \(self.chat_message_struct.count)")
                    if past_index == nil{
                        past_index = 0
                    }
                    print("past index 확인: \(past_index)")
                    
                    for idx in past_index!...last_index!{
                        print("클라b에서 읽음처리 idx: \(idx) ")
                        self.chat_message_struct[idx].read_num -= 1
                    }
                    //notification center 사용해 메시지 실시간 읽은 것 구현.
                    NotificationCenter.default.post(name: Notification.new_message, object: nil)
                }
            }else{
                print("클라b가 채팅방, 채팅방 목록을 보고 있지 않을 경우 읽은 마지막 메세지 idx업데이트")
                let current_time = ChatDataManager.shared.make_created_at()
                //클라b에서 클라a의 read last idx업데이트.
                ChatDataManager.shared.update_user_read(chatroom_idx: chatroom_idx, read_last_idx: read_last_idx, user_idx: user_idx, updated_at: current_time)
            }
        }
    }
    
    //아웃포커싱 이벤트
    func exit_chatroom(chatroom_idx: Int){
        socket.emit("client_to_serveroutfocus_room", chatroom_idx)
        print("채팅방 아웃포커싱이벤트 진행.")
    }
    
    //알림 설저 이벤트 응답 받은 후 ui변경 위해서 success를 받으면 true로 변경.
    @Published var chatroom_alarm_changed: Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    //채팅방 알림 설정 이벤트
    func chatroom_alarm_setting_event(chatroom_idx: Int, state: Int){
        
        socket.emitWithAck("client_to_serverset_alarm", chatroom_idx, state).timingOut(after: 300.0){data in
            
            print("채팅방 알림 설정 응답: \(data)")
            
            let result = JSON(data[0])
            
            if result == "success"{
                
                UserDefaults.standard.setValue("\(state)", forKey: "\(db.my_idx!)!_chatroom_alarm_\(chatroom_idx)")
                self.chatroom_alarm_changed = true
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.alarm_changed, object: nil, userInfo: ["alarm_changed" : state])
                
                print("채팅방 알림 설정 success: \(self.chatroom_alarm_changed)")
            }else{
                
            }
        }
        
        
    }
    
}

