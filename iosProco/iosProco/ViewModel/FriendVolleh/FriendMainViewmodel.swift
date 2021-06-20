//
//  FriendMainViewmodel.swift
//  proco
//
//  Created by 이은호 on 2020/12/25.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON
import SwiftUI
import SocketIO
import SQLite3

extension DateFormatter {
    static var dateformatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static var time_formatter: DateFormatter {
        let time_format = DateFormatter()
        time_format.dateFormat = "hh:mm:ss"
        return time_format
    }
    
    static var detail_time_formatter: DateFormatter{
        let changer = DateFormatter()
        changer.dateFormat = "hh:mm a"
        changer.locale = Locale(identifier: "ko")
        return changer
    }
    
    static var pm_time_formatter : DateFormatter {
        let time_format = DateFormatter()
        time_format.dateFormat = "HH:mm:ss"
        return time_format
    }
}

//카드 만들기 후 통신 성공, 실패에 따른 alert창 띄우기 위해 사용.
enum ResultAlert{
    case success,fail
}

//신고하기 후 알림창 주기 위해 사용.
enum ReportsAlert{
    case success, fail
}

var socket_manager : SockMgr = SockMgr()

class FriendVollehMainViewmodel: ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    //필터에서 선택한 태그 리스트와 set..기존에 카드 만들기등과 같은 변수 썼을 때 오류 발생해서 따로 뻄
    @Published var selected_filter_tag_list : [String] = []{
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var selected_filter_tag_set = Set<String>(){
        didSet {
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
    
    /*
     데이터 모델들
     */
    //친구 카드 참여자 모델
    @Published var apply_user_struct : [ApplyUserStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    ///카테고리 태그
    @Published var volleh_category_tag_struct = [VollehTagCategoryStruct(category_name: "아무거나"),VollehTagCategoryStruct(category_name: "게임/오락"),VollehTagCategoryStruct(category_name: "사교/인맥"), VollehTagCategoryStruct(category_name: "문화/공연/축제"), VollehTagCategoryStruct(category_name: "운동/스포츠"), VollehTagCategoryStruct(category_name: "취미/여가"), VollehTagCategoryStruct(category_name: "스터디")]
    
    //카테고리중 최소 1개는 선택해야 하므로 체크하기 위해 만든 변수
    @Published var category_struct : Set<String> = ["아무거나","사교/인맥", "게임/오락", "문화/공연/축제", "운동/스포츠", "취미/여가", "스터디" ]
    
    ///친구랑 볼래 카드 데이터모델
    @Published var friend_volleh_card_struct : [FriendVollehCardStruct] = []{
        didSet {
            objectWillChange.send()
        }
    }
    ///내 카드 데이터 모델
    @Published var my_friend_volleh_card_struct :[FriendVollehCardStruct] = []{
        didSet{
            objectWillChange.send()
            print("내 카드 만들기 didset")
        }
    }
    //상세 페이지에 보여줄 카드 1개. (나)
    @Published var my_card_detail_struct  = FriendVollehCardStruct(){
        didSet {
            objectWillChange.send()
        }
    }
    //다른 사람들 카드 상세 페이지 모델
    @Published var card_detail_struct  = FriendVollehCardStruct(){
        didSet {
            objectWillChange.send()
        }
    }
    //친구 상세 프로필 다이얼로그 띄우기 위해 저장하는 모델
    @Published var friend_info_struct  = GetFriendListStruct(){
        didSet {
            objectWillChange.send()
        }
    }
    //친구 한 명 선택했을 때 idx정보
    @Published var selected_friend_index : Int = -1{
        didSet {
            objectWillChange.send()
        }
    }
    
    //친구 정보 리스트 가져온 후 저장하는 모델
    @Published var friend_list_struct : [GetFriendListStruct] = []
    {
        didSet {
            //카드 만들기에서 알릴 친구들 이동시 메인 친구 뷰가 다시 나타나는 문제 발생해서 삭제함.
            //objectWillChange.send()
        }
    }
    
    ///그룹 리스트 하나당 데이터 갖고 있는 모델
    @Published var manage_groups = [ManageGroupStruct](){
        
        didSet{
           // objectWillChange.send()
        }
    }
    
    ///친구랑 볼래 카드 태그 데이터 모델
    @Published var friend_volleh_tag_struct: [FriendVollehTags] = []{
        didSet {
            objectWillChange.send()
        }
    }
    
    ///카드 추가 request할때 사용
    @Published var add_card_struct = AddCardFriendVollehStruct(){
        didSet {
            objectWillChange.send()
        }
    }
    ///카드 상세 페이지 데이터 모델
    @Published var friend_volleh_card_detail = FriendVollehCardDetailModel(){
        didSet {
            objectWillChange.send()
        }
    }
    
    ///오늘 심심기간인 친구들 모델
    @Published var today_boring_friends_model = [BoringFriendsModel](){
        didSet{
            objectWillChange.send()
        }
    }
    /*데이터 모델 끝
     */
    
    /*
     카드 편집, 카드 추가 변수들 시작
     날짜(저장시 date로 변환), 태그
     
     카드 만들기에 사용하는 변수들
     1.시간
     2.태그들 배열 : user_selected_tag_list
     3.알릴 친구들 : 1)그룹 = show_card_group_array를 dictionary로 만들기
     */
    //날짜
    ///카드 편집시 사용
    @Published var string_to_date : Date = Date(){
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var string_to_time : Date = Date(){
        didSet {
            objectWillChange.send()
        }
    }
    
    
    //태그
    ///친구랑 볼래 태그 "입력" 텍스트필드 임시 저장값
    @Published var user_input_tag_value : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    ///친구랑 볼래에서 사용자가 "최종 선택한" 태그 리스트를 set으로 저장해놓는 곳.
    @Published var user_selected_tag_set = Set<String>(){
        didSet {
            objectWillChange.send()
        }
    }
    
    ///친구랑 볼래에서 사용자가 "최종 선택한" 태그 리스트 set을 배열로 바꿔서 저장.
    @Published var user_selected_tag_list : [String] = []{
        didSet {
            objectWillChange.send()
        }
    }
    
    
    ///카드 만들기에서 선택한 알릴 친구 모음 Set
    //알릴 친구들
    @Published var show_card_friend_set = Set<Int>(){
        didSet {
            objectWillChange.send()
        }
    }
    ///카드 만들기에서 선택한 알릴 그룹 모음 Set
    @Published var show_card_group_set = Set<Int>(){
        didSet {
            objectWillChange.send()
        }
    }
    ///카드 만들기에서 선택한 알릴 친구 모음 Set > 배열로 변환 값
    @Published var show_card_friend_array : [Int] = []{
        didSet {
            objectWillChange.send()
        }
    }
    
    ///카드 만들기에서 선택한 알릴 그룹 모음 Set > 배열로 변환 값
    @Published var show_card_group_array : [Int] = []{
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var show_card_friend_name : Dictionary<Int , String> = [:]{
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var show_card_group_name : Dictionary<Int , String> = [:]{
        didSet {
            objectWillChange.send()
        }
    }
    
    
    //카드 설정 날짜 및 시간
    @Published var card_date : Date = Date(){
        didSet {
            objectWillChange.send()
        }
    }
    
    ///카드 만료 시간
    @Published var card_time : Date = Date(){
        didSet {
            objectWillChange.send()
        }
    }
    ///카드 만료일 + 시간(서버에 보내기 위해 string으로 합쳐서 바꿈.)
    @Published var card_expire_time : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    
    //알릴 친구들 리스트로 보여줄 때 사용 - 타입 : 친구, 그룹.....unique_idx: 친구,그룹의 idx
    @Published var pra : [Dictionary<String , Any>] = []{
        didSet {
            objectWillChange.send()
        }
    }
    
    /*
     통신 결과 후
     */
    ///친구 리스트 가져오는 통신 성공했을 때 true로 바뀌고 화면 전환됨.
    @Published var got_friend_list_all : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
    /*
     카드 편집 및 삭제
     */
    ///내 닉네임 가져와서 메인 페이지에서 내 카드만 보여줄 때 사용, 카드 만들기 후 user_chat_in_model에 저장할 때 사용.
    @Published var my_nickname = ""{
        didSet {
            objectWillChange.send()
        }
    }
    ///카드 리스트중 선택한 카드 idx값 저장.
    @Published var selected_card_idx : Int = -1 {
        didSet {
            objectWillChange.send()
        }
    }
    ///카드 리스트중 선택한 카드 row값 저장.
    @Published var selected_card_row : Int = -1 {
        didSet {
            objectWillChange.send()
        }
    }
    /*카드 만들기 통신 결과 이용
     */
    ///카드 만들기 통신 완료시 아래 alert띄운 후 메인 뷰로 화면 전환
    @Published var show_alert: Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var alert_type : ResultAlert = .success{
        didSet{
            objectWillChange.send()
        }
    }
    
    /*
     친구랑 볼래 필터 - 날짜값 저장, 선택한 태그 저장.
     */
    //시작날짜
    @Published var filter_start_date : Date = Date(){
        didSet{
            objectWillChange.send()
        }
    }
    //끝나는 날짜
    @Published var filter_end_date : Date = Date(){
        didSet{
            objectWillChange.send()
        }
    }
    //시작날짜 string
    @Published var filter_start_date_string :String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    //끝나는 날짜 string
    @Published var filter_end_date_string : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    //카드 만들기 후 user_chat_in_model에 내 idx저장하기 위함.
    @Published var my_idx = UserDefaults.standard.string(forKey: "user_id"){
        didSet{
            objectWillChange.send()
        }
    }
    
    //카드 좋아요 유저 모델
    @Published var card_like_user_model : [Creator] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    /*
     ------------------------------------------------------------------
     */
    /*
     카드 상세 데이터
     */
    
    func result_alert(_ active: ResultAlert) -> Void{
        DispatchQueue.main.async {
            self.alert_type = active
            self.show_alert = true
        }
    }
    /*
     카드 리스트 보여줄 때 foreach안에 index이용하기 위해 사용
     */
    func get_index(item: FriendVollehCardStruct )->Int{
        
        return self.my_friend_volleh_card_struct.firstIndex { (item1) -> Bool in
            return item.card_idx == item1.card_idx
        } ?? 0
    }
    //친구 카드 인덱스 갖고 오기
    func get_friend_index(item: FriendVollehCardStruct )->Int{
        
        return self.friend_volleh_card_struct.firstIndex { (item1) -> Bool in
            return item.card_idx == item1.card_idx
        } ?? 0
    }
    
    //친구 상태 리스트 보여줄 때 인덱스 사용
    func get_state_index(item: GetFriendListStruct)->Int{
        
        return self.friend_list_struct.firstIndex { (item1) -> Bool in
            return item.idx == item1.idx
        } ?? 0
    }
    //----------------------------------------------------
    ///내 아이디 갖고와서 카드 리스트에 내 카드만 보여주기 위해 비교할 때 이용.
    func get_my_nickname(){
        self.my_nickname = UserDefaults.standard.string(forKey: "nickname")!    }
    
    ///카드 만들기, 편집에서 파라미터로 share_list보낼 때 데이터 형식 맞추기 위해 실행하는 메소드
    func make_dictionary(){
        
        for group_idx in self.show_card_group_array{
            let object = ["type" : "group", "unique_idx" : group_idx] as [String : Any]
            self.pra.append(object as [String : Any])
        }
        
        for friend_idx in self.show_card_friend_array{
            let object2 = ["type" : "friend", "unique_idx" : friend_idx]as [String : Any]
            self.pra.append(object2 as [String : Any])
        }
    }
    
    ///카드 만들기에서 날짜 형식 맞춰서 보내기 위해 실행하는 메소드
    func make_card_date() -> String{
        print("시간: \(self.card_time)")
        print("날짜: \(self.card_date)")
        let day = DateFormatter.dateformatter.string(from: self.card_date)
        let time = DateFormatter.pm_time_formatter.string(from: self.card_time)
        self.card_expire_time = day + " "+time
        return self.card_expire_time
    }
    
    ///카드 편집시 서버에서 받은 날짜 date로 변환
    func string_to_date(expiration: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = formatter.date(from: expiration)
        return date!
    }
    
    ///카드 편집시 서버에서 받은 시간 date로 변환
    func string_to_time(expiration: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        // formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = formatter.date(from: expiration)
        return date!
    }
    
    /*
     카드 필터 적용시 날짜 -> 스트링 변환해서 서버에 보내기
     */
    ///카드 만들기에서 날짜 형식 맞춰서 보내기 위해 실행하는 메소드
    func date_to_string() -> String{
        let day = DateFormatter.dateformatter.string(from: self.filter_start_date)
        self.filter_start_date_string = day
        return self.filter_start_date_string
    }
    
    //카테고리를 최소 1개는 선택해야함. 안했을 때 false
    @Published var category_selected : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    ///카드 카테고리 선택 예외처리 메소드
    func category_is_selected() -> Bool {
        var check_set : Set<String>
        //intersection: set을 비교해서 교집합 추출
        check_set = self.user_selected_tag_set.intersection(self.category_struct)
        if check_set.isEmpty{
            print("카테고리 포함 안돼있음 : \(check_set)")
            return false
        //카테고리는 최소 한개만 선택 가능.
        }else if check_set.count == 1{
            print("카테고리 포함돼 있음  : \(check_set)")
            return true
         //카테고리를 1개 이상 선택한 경우
        }else{
            return false
        }
    }
    /*
     태그 최대 3개 선택
     */
    //태그 선택 최대 3개까지 제한하는 메소드
    func limit_tag_num(tag_list: Array<String>) -> Bool{
        var limit_tag_num_result : Bool = false
        if self.user_selected_tag_list.count>2{
            print("뷰모델 태그 갯수 메소드에서 3개 넘음")
            limit_tag_num_result = true
        }else{
            print("뷰모델 태그 갯수 메소드에서 3개 안넘음")
            
            limit_tag_num_result = false
        }
        return limit_tag_num_result
    }
    
    //필터 카테고리 선택 갯수 최대 3개 제한 메소드
    func limit_filter_category_num(tag_list: Array<String>) -> Bool{
        var limit_tag_num_result : Bool = false
        if self.selected_filter_tag_list.count>2{
            print("친구 필터 태그 갯수 메소드에서 3개 넘음")
            limit_tag_num_result = true
        }else{
            print("뷰모델 태그 갯수 메소드에서 3개 안넘음")
            
            limit_tag_num_result = false
        }
        return limit_tag_num_result
    }
    /*
     -----------------------------상세 페이지 정보 위한 메소드-----------------------------
     */
    ///카드 날짜 년, 월, 일로 나눔.시간
    @Published var year : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var month : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    @Published var date : String = ""{
        didSet {
            objectWillChange.send()
        }
    }

    //on.off나타내는 친구 리스트 중 친구 한 명 클릭했을 때 채팅하기, 피드 가기 다이얼로그 띄우기 위함.
    func get_friend_info(){
        
        let detail_index = self.friend_list_struct.firstIndex(where: {$0.idx == self.selected_friend_index})
        
        self.friend_info_struct.idx = self.friend_list_struct[detail_index!].idx
        self.friend_info_struct.nickname = self.friend_list_struct[detail_index!].nickname
        
        self.friend_info_struct.profile_photo = self.friend_list_struct[detail_index!].profile_photo
        //on.off상태
        self.friend_info_struct.state = self.friend_list_struct[detail_index!].state
            }
    /*
     ------------------------------------ 통신 코드 시작--------------------------
     */
    //카드 만들기
    func make_card_friend_volleh(){
        cancellation = APIClient.make_card_friend_volleh(type: "친구", time: self.card_expire_time, tags: self.user_selected_tag_list, share_list: self.pra)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구랑 볼래 카드 만들기 에러 발생 : \(error)")
                    //alert창 띄움.
                    self.alert_type = .fail
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구랑 볼래 카드 만들기 결과값 : \(response)")
                //결과가 제대로 왔을 때 화면 전화 가능하도록 함.
                if response.result == "ok"{
                    
                    var tags : [FriendVollehTags] = []
                    for tag in response.tags{
                        tags.append(FriendVollehTags(idx: tag.idx, tag_name: tag.tag_name))
                    }
                    //////
                    self.my_friend_volleh_card_struct.append(FriendVollehCardStruct(card_idx: response.card_idx, kinds: "친구", expiration_at: self.card_expire_time, lock_state: 0, like_count: 0, like_state: 0, tags:  tags, creator: Creator(idx: Int(self.my_idx!), nickname: self.my_nickname, profile_photo_path: ""), share_list: [], offset: 0.0))
                    print("내 카드 추가했는지 확인: \(self.card_expire_time), \(self.my_friend_volleh_card_struct.first(where: {$0.card_idx == response.card_idx}))")
                    
                    //카드 만들기 후 다시 들어갔을 때 이전 입력값이 그대로 남아 있는 문제가 있었음.
                    self.card_expire_time.removeAll()
                    self.user_selected_tag_list.removeAll()
                    self.user_selected_tag_set.removeAll()
                    /*
                     카드가 성공적으로 만들어졌을 경우 채팅 서버에 채팅방 idx, 유저 모델 보내기
                     1. 우선 카드 참여자 모델에 내 정보 넣기.(sqlite 저장 안함)
                     2. sqlite에 CHAT_ROOM에 채팅방 정보 넣기
                     3. 채팅 서버에 소켓으로 데이터 보내기. -> enter chatroom idx를 이때 변경함.
                     4. 동적 링크 보내기
                     */
                    self.get_my_nickname()
                    let idx = Int(self.my_idx!)
                    let chatroom_idx = Int(response.chatroom_idx)
                    let card_idx = Int(response.card_idx)
                    print("내 idx가져왔는지 확인: \(String(describing: idx))")
                    
                    //1.데이터 모델에 저장.
                    SockMgr.socket_manager.$user_chat_in_model.append(UserChatInListModel(idx: idx!, nickname: self.my_nickname, profile_photo_path: ""))
                    
                    //2.sqlite에 데이터 저장 - room, user, card, tag
                    ChatDataManager.shared.insert_chat_info_friend(idx: chatroom_idx, card_idx: card_idx, creator_idx: Int(ChatDataManager.shared.my_idx!)!, room_name: "", kinds: "친구")
                    
                    let current_time = ChatDataManager.shared.make_created_at()
                    //TODO profile 사진 변경해야함
                    ChatDataManager.shared.insert_user(chatroom_idx: response.chatroom_idx, user_idx: idx!, nickname: self.my_nickname, profile_photo_path: "", read_last_idx: 0, read_start_idx: 0, temp_key: "", server_idx: response.server_idx, updated_at: current_time, deleted_at: "")
                    
                    //태그
                    for tag in response.tags{
                        
                        ChatDataManager.shared.insert_tag(chatroom_idx: response.chatroom_idx, tag_idx: tag.idx, tag_name: tag.tag_name)
                    }
                    //card
                    let created_at = ChatDataManager.shared.make_created_at()
                    ChatDataManager.shared.insert_card(chatroom_idx: response.chatroom_idx, creator_idx: Int(ChatDataManager.shared.my_idx!)!, kinds: "친구", card_photo_path: "", lock_state: 0, title: "", introduce: "", address: "",  map_lat: "0.0", map_lng: "0.0", current_people_count: 1, apply_user: 0, expiration_at: self.card_expire_time, created_at: created_at, updated_at: "", deleted_at: "")
                    
                    //3.소켓으로 데이터 보내기
                    socket_manager.make_chat_room_friend(chatroom_idx: chatroom_idx, idx: idx!, nickname: self.my_nickname)
                    
                    //TODO 동적링크 코드 위치 수정해야함.
                    //4.메세지 보내기(동적 링크)
                    if socket_manager.is_from_chatroom{
                        print("동적링크인 경우")
                        self.selected_card_idx = card_idx
                        //동적링크 생성하기
//                        socket_manager.make_dynamic_link(chatroom_idx: chatroom_idx, link_img: "", card_idx: card_idx, kinds: "friend")
                        
                        
                        print("메세지 보낼 때 링크 확인: \(socket_manager.invitation_link)")
                        print("메세지 보낼 때 링크 : \(SockMgr.socket_manager.invitation_link)")
                        print("동적링크 만들 때 채팅방 idx: \(chatroom_idx), 현재 채팅방 idx: \(SockMgr.socket_manager.enter_chatroom_idx)")
                    }
                    self.alert_type = .success
                }else{
                    //결과가 왔지만 제대로 오지 않았을 경우 화면 전환 불가.
                    self.alert_type = .fail
                }
            })
    }
    
    //친구랑 볼래 카드 리스트 가져오기 이때 내가 만든 카드, 친구가 만든 카드로 나눠서 저장.
    func get_friend_volleh_cards(){
        cancellation = APIClient.get_friend_volleh_card_list_api()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구랑 볼래 카드 가져오기 에러 발생 : \(error)")
                case .finished:
                    print("친구랑 볼래 카드 가져온 후 친구 리스트 가져오기")
                    //self.get_friends_state()
                    break
                }
                
            }, receiveValue: {response in
                print("친구랑 볼래 카드 리스트 가져오기 결과값 : \(response)")
                self.my_friend_volleh_card_struct.removeAll()
                self.friend_volleh_card_struct.removeAll()
                              
                let result : String?
                result = response["result"].string
                if result == "no result"{
                    
                }
               else{
                    print("카드 있는 경우")
                    //let result = response.arrayValue
                    var my_count = 0
                let friend_cards = response.arrayValue
                
                let json_string = """
                        \(friend_cards)
                        """
                print("친구 카드 string변환")
                
                let json_data = json_string.data(using: .utf8)
                
                let card = try? JSONDecoder().decode([FriendVollehCardStruct].self, from: json_data!)
                
                print("내가 만든 친구랑 볼래 카드 리스트 디코딩한 값: \(String(describing: card))")
                
                let my_card_list = card?.filter({
                    $0.creator!.idx == Int(self.my_idx!)
                }).map({$0})
                print("내 카드 뽑아낸 것 확인: \(String(describing: my_card_list))")
                self.my_friend_volleh_card_struct = my_card_list!
                
                let friend_card_list = card?.filter({
                    $0.creator!.idx != Int(self.my_idx!)
                }).map({$0})
                print("친구카드 뽑아낸 것 확인: \(String(describing: friend_card_list))")
                      self.friend_volleh_card_struct = friend_card_list!
                
//                    for card in response{
//                        if my_count < response.count {
//                            my_count = my_count + 1
//
//                            //내 카드일 경우
//                            if card.creator!.nickname == self.my_nickname{
//
//                                self.my_friend_volleh_card_struct.append(FriendVollehCardStruct(card_idx: card.card_idx, kinds: card.kinds, expiration_at: card.expiration_at,lock_state: card.lock_state,like_count: card.like_count, like_state: card.like_state, tags: card.tags, creator: card.creator, offset: 0.0))
//
//                            }else{
//
//                                self.friend_volleh_card_struct.append(FriendVollehCardStruct(card_idx: card.card_idx, kinds: card.kinds, expiration_at: card.expiration_at,lock_state: card.lock_state,like_count: card.like_count, like_state: card.like_state, tags: card.tags, creator: card.creator, offset: 0.0))
//                            }
//                        }
//                    }
                }
                print("내 카드 저장한 것 확인: \(self.my_friend_volleh_card_struct)")
                //오늘 심심기간인 친구들 가져오는 통신
                let today_date = Date()
                let bored_date = String.date_string(date: today_date)
                self.get_today_boring_friends(bored_date: bored_date)
            })
    }
    
    ///카드 설정시 알릴 친구 선택하기에 사용할 친구리스트 가져오기
    func get_all_people(){
        ///친구 리스트 먼저 가져옴.
        cancellation = APIClient.get_friend_list_api(friend_type: "친구")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("메인에서 sink후 친구 리스트 가져올 때 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                
                print("메인에서 친구 리스트 가져오는 뷰모델의 receive value값 : \(String(describing: response))")
                //있는 데이터 제거 후 추가
                self.friend_list_struct.removeAll()
                
                for friend in response{

                    if friend.nickname != nil{

                        self.friend_list_struct.append(GetFriendListStruct(result: friend.result, idx: friend.idx!, nickname: friend.nickname!, profile_photo: friend.profile_photo, state: friend.state))
                    }
                }
//               // self.got_friend_list_all.toggle()
                self.get_all_groups()
            })
    }
    
    ///카드 설정시 사용할 그룹 리스트 가져오기
    func get_all_groups(){
        cancellation = APIClient.get_all_manage_group()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:
                    {result in
                        switch result{
                        case .failure(let error):
                            print("그룹 리스트만 가져오는 데 에러 발생 : \(error)")
                        case .finished:
                            break
                        }
                    }
                  , receiveValue: {(response) in
                    //그룹 리스트 업데이트 된 경우 다시 가져와야하므로 기존의 모델에 있던 데이터삭제 후 다시 append
                    self.manage_groups.removeAll()
                    print("그룹 리스트만 가져오는 데 받은 value값 : \(response)")
                    
                    for group in response{

                        if group.name != nil{
                            self.manage_groups.append(ManageGroupStruct(result: group.result, idx: group.idx!, name: group.name!))
                        }
                    }
                  })
    }
    
    //내 카드 편집 통신
    func edit_my_card(){
        cancellation = APIClient.edit_friend_volleh_card(card_idx: self.selected_card_idx, type: "친구", time: self.card_expire_time, tags: self.user_selected_tag_list, share_list: self.pra)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카드 수정 오류 발생 : \(error)")
                    self.alert_type = .fail
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구랑 볼래 카드 편집 결과값 : \(response)")
                
                //통신 오류 발생했을 경우
                if response.result == "no result"{
                    self.alert_type = .fail
                    
                }else{
                    //채팅방 드로어에서 편집 화면으로 넘어온 경우
                    if SockMgr.socket_manager.edit_from_chatroom{
                        print("채팅방 드로어에서 편집 화면으로 넘어와서 편집 완료")
                        
                        //로컬 디비에 카드 데이터 업데이트
                        ChatDataManager.shared.update_card_table(chatroom_idx: socket_manager.enter_chatroom_idx, creator_idx: socket_manager.card_struct.creator_idx, kinds: socket_manager.card_struct.kinds , card_photo_path: socket_manager.card_struct.card_photo_path ?? "", lock_state: socket_manager.card_struct.lock_state, title: socket_manager.card_struct.title, introduce: socket_manager.card_struct.introduce, address: socket_manager.card_struct.address, map_lat: socket_manager.card_struct.map_lat, map_lng: socket_manager.card_struct.map_lng, current_people_count: socket_manager.card_struct.cur_user, apply_user: socket_manager.card_struct.apply_user, expiration_at: self.card_expire_time, created_at: socket_manager.card_struct.created_at, updated_at: socket_manager.card_struct.updated_at ?? "", deleted_at: socket_manager.card_struct.deleted_at ?? "")
                        
                        let updated_at = ChatDataManager.shared.make_created_at()
                        
                        //채팅 서버에 보낼 때 이곳에 데이터 넣기 위해 변수 만듬.
                        var tag_model : [TagModel] = []
                        //태그 데이터 업데이트
                        for item in response.tags{
                            ChatDataManager.shared.update_tag_table(chatroom_idx: socket_manager.enter_chatroom_idx, tag_idx: item.idx, tag_name: item.tag_name)
                            
                            tag_model.append(TagModel(idx: item.idx, tag_name: item.tag_name))
                        }
                        print("서버에 보내는 태그 모델 확인: \(tag_model)")
                        
                        //채팅 서버에 보내기 위해 만든 데이터.
                        let chatroom_model = ChatRoomModel(idx: socket_manager.enter_chatroom_idx, card_idx: socket_manager.current_chatroom_info_struct.card_idx, created_at: socket_manager.current_chatroom_info_struct.created_at, creator_idx: socket_manager.current_chatroom_info_struct.creator_idx, deleted_at: socket_manager.current_chatroom_info_struct.deleted_at, kinds: "친구", room_name: socket_manager.current_chatroom_info_struct.room_name, updated_at: updated_at, card_tag_list: tag_model, card: socket_manager.card_struct)
                        
                        socket_manager.edit_card_info_event(chatroom: chatroom_model)
                        
                        
                    }else{
                        print("메인에서 편집 화면으로 넘어와서 편집 완료")
                        
                        let detail_index = self.my_friend_volleh_card_struct.firstIndex(where: {$0.card_idx == self.selected_card_idx})
                        
                        //TODO!! 편집한 후에 여기에서 데이터를 업데이트해야 메인뷰에 돌아가면 데이터 업데이트 돼있음.!!!
                        //편집한 데이터를 모델에 집어넣기.
                        self.my_friend_volleh_card_struct[detail_index!].expiration_at = self.card_expire_time
                        
                        //이전에 입력했던 태그 삭제하고 업데이트하는 형식.그래야 이전 태그와 중첩돼서 저장 안됨.
                        self.my_friend_volleh_card_struct[detail_index!].tags?.removeAll()
                        
                        //********채팅 서버에 보낼 태그 모델*********
                        var tag_model : [TagModel] = []
                        
                        for item in response.tags{
                            self.my_friend_volleh_card_struct[detail_index!].tags?.append(FriendVollehTags(idx: item.idx, tag_name: item.tag_name))
                            
                            //채팅 서버에 보낼 태그 데이터 넣고 태그 테이블 업데이트
                            ChatDataManager.shared.update_tag_table(chatroom_idx: socket_manager.enter_chatroom_idx, tag_idx: item.idx, tag_name: item.tag_name)
                            
                            tag_model.append(TagModel(idx: item.idx, tag_name: item.tag_name))
                        }
                        
                        print("편집한 데이터 집어넣었는지 확인 : \(String(describing: self.my_friend_volleh_card_struct[detail_index!].tags))")
                        //----------------뷰를 위한 데이터 모델은 업데이트 완료------------------------
                        
                        //채팅 서버에 보내기 위해 데이터 만들기(채팅룸 idx가져오기, 카드 업데이트 날짜 만들기, 카드 모델 만들기)
                        let chatroom = ChatDataManager.shared.get_chatroom_from_card(card_idx: self.selected_card_idx)
                        print("친구랑 볼래 뷰모델에서 채팅방 idx: \(chatroom)")
                        //업데이트한 날짜 만들기
                        let updated_at = ChatDataManager.shared.make_created_at()
                        
                        //카드 idx로 디비에 저장된 카드 데이터 갖고 오기.
                        ChatDataManager.shared.get_card_info_from_main(chatroom_idx: chatroom)
                        print("카드 데이터 저장한 것 확인: \(SockMgr.socket_manager.card_struct)")
                        
                        //로컬 디비에 카드 데이터 업데이트
                        ChatDataManager.shared.update_card_table(chatroom_idx: chatroom, creator_idx: SockMgr.socket_manager.card_struct.creator_idx, kinds: "친구" , card_photo_path: SockMgr.socket_manager.card_struct.card_photo_path ?? "" , lock_state: SockMgr.socket_manager.card_struct.lock_state, title: SockMgr.socket_manager.card_struct.title, introduce: SockMgr.socket_manager.card_struct.introduce, address: SockMgr.socket_manager.card_struct.address, map_lat: SockMgr.socket_manager.card_struct.map_lat, map_lng: SockMgr.socket_manager.card_struct.map_lng, current_people_count: SockMgr.socket_manager.card_struct.cur_user, apply_user: SockMgr.socket_manager.card_struct.apply_user, expiration_at: self.card_expire_time, created_at: SockMgr.socket_manager.card_struct.created_at, updated_at: updated_at, deleted_at: SockMgr.socket_manager.card_struct.deleted_at ?? "")
                        
                        let chatroom_model = ChatRoomModel(idx: chatroom, card_idx: self.selected_card_idx, created_at: "", creator_idx: Int(self.my_idx!)!, deleted_at: "", kinds: "", room_name: "", updated_at: updated_at, card_tag_list: tag_model, card: SockMgr.socket_manager.card_struct)
                        //서버에 이벤트 보냄.
                        socket_manager.edit_card_info_event(chatroom: chatroom_model)
                        
                        //편집한 데이터 집어넣고는 publish변수에 있던 값들 없애주기
//                        self.card_expire_time = ""
//                        self.user_selected_tag_list = []
//                        self.user_selected_tag_set = []
                        print("편집 후 값 없앴는지 확인 : \( self.card_expire_time)")
                    }
                    self.alert_type = .success
                }
            })
    }
    
    //카드 클릭시 상세 페이지 이동 위한 카드 정보 가져오기
    func get_card_detail(card_idx: Int){
        cancellation = APIClient.get_card_info_friend_volleh(card_idx: card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카드 상세 데이터 가져오는 데 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }
            , receiveValue: {response in
                print("카드 상세 데이터 가져온 것 확인 : \(response)")
                
                //해당하는 카드 없거나 만료됨
                if response.result == "no result"{
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["get_friend_card_detail_finish" : "no result"])
                }else{
                print("만료날짜 원래 데이터 확인 : \(response.expiration_at)")
                
                let first_filtered_day = self.string_to_date(expiration: response.expiration_at)
                print("날짜 변환했는지 확인 : \(first_filtered_day)")
                self.card_date = first_filtered_day
                
                let time_filtered = self.string_to_time(expiration: String(response.expiration_at.split(separator: " ")[1]))
                self.card_time = time_filtered
                print("시간 변환 확인 : \(self.card_time)")
                
                self.friend_volleh_card_detail = FriendVollehCardDetailModel(card_idx: response.card_idx!, kinds: response.kinds!, expiration_at: response.expiration_at, lock_state: response.lock_state, like_count: response.like_count, like_state: response.like_state, tags: response.tags, share_list: response.share_list, creator: response.creator, is_favor_friend: response.is_favor_friend, cur_user: response.cur_user)
                
                //태그 set, array에 이름 저장
                self.user_selected_tag_set.removeAll()
                self.user_selected_tag_list.removeAll()
                
                                if response.tags != nil{
                                    for tag in response.tags!{
                                        self.user_selected_tag_set.insert(tag.tag_name)
                                        self.user_selected_tag_list.append(tag.tag_name)
                                        if self.volleh_category_tag_struct.contains(where: {
                                            $0.category_name == tag.tag_name
                                        }){
                                            //태그 데이터중 카테고리는 뷰에 selected category로 세팅해놔야 하므로 뷰에 알리는 것.
                                            NotificationCenter.default.post(name: Notification.send_selected_card_category, object: nil, userInfo: ["selected_category" : tag.tag_name])
                                        }
                                    }
                                }
                print("카드 정보 가져와서 태그 저장한 것 확인: \(self.user_selected_tag_list)")

                                //알릴 사람들 set, array, dictionary에 저장
                                if response.share_list != nil{
                                    print("카드 상세 데이터 share_list 널 아닐 때")
                                    for person in response.share_list!{
                                        if person.idx_kinds == "friend"{
                                            self.show_card_friend_set.insert(person.unique_idx)
                                            self.show_card_friend_array.append(person.unique_idx)
                                            self.show_card_friend_name.updateValue(person.name, forKey: person.unique_idx)

                                        }
                                        print("알릴 그룹 set 저장됐는지 확인 : \( self.show_card_friend_set)")
                                        if person.idx_kinds == "group"{
                                            self.show_card_group_set.insert(person.unique_idx)
                                            self.show_card_group_array.append(person.unique_idx)
                                            self.show_card_group_name.updateValue(person.name, forKey: person.unique_idx)
                                        }
                                    }
                                    print("알릴 친구들 저장됐는지 확인 : \(self.show_card_group_name)")
                                }
                
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["get_friend_card_detail_finish" : response.expiration_at])
                }
                
            })
    }
    
    //친구랑 볼래 카드 삭제하기
    func delete_friend_volleh_card(){
        cancellation = APIClient.delete_friend_volleh_card(card_idx: self.selected_card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구랑 볼래 카드 삭제 에러 발생 : \(error)")
                    self.alert_type = .fail
                case .finished:
                    break
                }
            }, receiveValue: {response in
                if response["result"] == "ok"{
                    //삭제에 성공했다는 alert띄우기 위한 것.
                    self.alert_type = .success
                    
                }else{
                    self.alert_type = .fail
                }
            })
    }
    
    @Published var applied_filter : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //친구랑 볼래 필터 적용하기(날짜, 태그)
    func friend_volleh_filter(tag: Array<Any>){
        cancellation = APIClient.friend_volleh_filter(date_start: self.filter_start_date_string, date_end: self.filter_start_date_string, tag: tag)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구랑 볼래 카드 필터 에러 발생 : \(error)")
                    self.alert_type = .fail
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구랑 볼래 필터 결과값 : \(response)")
                if response["result"] == "no result"{
                    print("필터 결과 no result 들어옴")
                    //필터 적용 결과가 없다는 alert창 띄우기
                    self.my_friend_volleh_card_struct.removeAll()
                    self.friend_volleh_card_struct.removeAll()
                    self.alert_type = .fail
                    
                }else{
                    self.my_friend_volleh_card_struct.removeAll()
                    self.friend_volleh_card_struct.removeAll()
                    
                    var my_count = 0
                    for card in response{
                        //여기에서 태그를 한 번 삭제해줘야 태그들이 이전 것까지 중복돼서 저장되지 않는다.
                        self.friend_volleh_tag_struct.removeAll()
                        
                        if my_count < response.count {
                            my_count = my_count + 1
                            
                            let card_idx = card.1["card_idx"].int
                            let kinds = card.1["kinds"].string
                            let creator_name = card.1["creator"]["nickname"].stringValue
                            let creator_idx = card.1["creator"]["idx"].intValue
                            let creator_image = card.1["creator"]["profile_photo_path"].stringValue
                            let tags = card.1["tags"].array
                            let expiration_at = card.1["expiration_at"].stringValue
                            let lock_state = card.1["lock_state"].intValue
                            let like_count = card.1["like_count"].intValue
                            let like_state = card.1["like_state"].intValue
                            print("만든 사람 닉네임: \(creator_name)")
                            print("내 닉네임: \(self.my_nickname)")
                            
                            //내가 만든 카드일 경우
                            if self.my_nickname == creator_name{
                                for tag in tags!{
                                    self.friend_volleh_tag_struct.append(FriendVollehTags(idx: tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                                }
                                
                                print("내 카드 추가됨 \(my_count)")
                                self.my_friend_volleh_card_struct.append(FriendVollehCardStruct(card_idx: card_idx!, kinds: kinds!, expiration_at: expiration_at, lock_state: lock_state, like_count: like_count, like_state: like_state,tags: self.friend_volleh_tag_struct, creator: Creator(idx: creator_idx, nickname: creator_name, profile_photo_path: creator_image)))
                                
                            }else{
                                for tag in tags!{
                                    self.friend_volleh_tag_struct.append(FriendVollehTags(idx: tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                                }
                                print("다른 사람 카드 추가됨\(my_count)")
                                self.friend_volleh_card_struct.append(FriendVollehCardStruct(card_idx: card_idx!, kinds: kinds!, expiration_at: expiration_at, lock_state: lock_state, like_count: like_count, like_state: like_state, tags: self.friend_volleh_tag_struct, creator: Creator(idx: creator_idx, nickname: creator_name, profile_photo_path: creator_image)))
                            }
                        }
                    }
                    print("최종 내 카드 데이터 확인: \(self.my_friend_volleh_card_struct)")
                    //메인뷰에서 필터 적용시 필터버튼 이미지 변경 위함.
                    self.applied_filter = true
                }
            })
    }
    
    //메인에 친구 on,off 보여주기 위해 리스트 가져오기..친구랑 볼래 카드 가져온 후 finished되면 가져옴.
    func get_friends_state(){
        ///친구 리스트 먼저 가져옴.
        cancellation = APIClient.get_friend_list_api(friend_type: "친구상태")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("메인에서 친구 상태 가져오기 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("메인에서 친구 상태 리스트 가져올 때 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("메인에서 친구 상태 리스트 결과값 : \(String(describing: response))")
                //TODO 데이터 없을 경우 확인해야 함.
                if JSON(response)["result"] == "no result"{
                    print("친구 뷰모델에서 친구 없음 no result")
                    
                }else{
                    //있는 데이터 제거 후 추가
                    self.friend_list_struct.removeAll()
                    
//                    for friend in response{
//                        
//                        if friend.nickname != nil{
//                            self.friend_list_struct.append(GetFriendListStruct(result: friend.result, idx: friend.idx!, nickname: friend.nickname!, profile_photo: friend.profile_photo, state: friend.state ?? 0))
//                        }
//                    }
                    print("친구 데이터 넣어졌는지 확인: \(self.friend_list_struct)")
                }
            })
    }
    
    //신고하기 통신
    func send_reports(kinds: String, unique_idx: String, report_kinds: String, content: String) {
        
        cancellation = APIClient.send_reports(kinds: "카드", unique_idx: unique_idx, report_kinds: report_kinds, content: content)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구 카드 신고하기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                
                print("친구 카드 신고하기 resopnse: \(response)")
                
                let result = response["result"].string
                if result == result{
                    if result == "ok"{
                        print("신고하기 완료")
                        self.request_result_alert = .success
                        
                    }else{
                        print("신고하기 실패")
                        self.request_result_alert = .fail
                        
                    }
                }
            })
    }
    //좋아요 클릭 통신 성공한 경우
    @Published var like_event_copmplete : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    //카드 좋아요 클릭 이벤트
    func send_like_card(card_idx: Int){
        cancellation = APIClient.send_like_card(card_idx: card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카드 좋아요 클릭 이벤트 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("좋아요 클릭 response: \(response)")
                let result = response["result"].string
                if result == "ok"{
                    print("좋아요 ok")
                    
                    var clicked_card : Int? = -1
                        clicked_card =  self.friend_volleh_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       }) ?? -1
                    if clicked_card != -1{
                       self.friend_volleh_card_struct[clicked_card!].like_count += 1
                       self.friend_volleh_card_struct[clicked_card!].like_state = 1
                    }else{
                        clicked_card =  self.my_friend_volleh_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       })
                        
                        self.my_friend_volleh_card_struct[clicked_card!].like_count += 1
                        self.my_friend_volleh_card_struct[clicked_card!].like_state = 1
                    }
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.clicked_like, object: nil, userInfo: ["clicked_like" : "ok", "card_idx": "\(card_idx)"])
                    self.like_event_copmplete = true
                    
                    
                }else{
                    print("좋아요 안됨.")
                }
            })
    }
    //좋아요 취소 통신 성공한 경우
    @Published var like_cancel_copmplete : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    //카드 좋아요 취소
    func cancel_like_card(card_idx: Int){
        cancellation = APIClient.cancel_like_card(card_idx: card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카드 좋아요 취소 이벤트 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("좋아요 취소 response: \(response)")
                let result = response["result"].string
                if result == "ok"{
                    print("좋아요 취소 ok")
                    
                    var clicked_card : Int? = -1
                        clicked_card =  self.friend_volleh_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       }) ?? -1
                    if clicked_card != -1{
                       self.friend_volleh_card_struct[clicked_card!].like_count -= 1
                       self.friend_volleh_card_struct[clicked_card!].like_state = 0
                    }else{
                        clicked_card =  self.my_friend_volleh_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       })
                        
                        self.my_friend_volleh_card_struct[clicked_card!].like_count -= 1
                        self.my_friend_volleh_card_struct[clicked_card!].like_state = 0
                    }
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.clicked_like, object: nil, userInfo: ["clicked_like" : "canceled_ok", "card_idx": "\(card_idx)"])
                    //ui에서 사용하기 위한 boolean값 true
                    self.like_cancel_copmplete = true
                }else{
                    print("좋아요 취소 안됨.")
                }
            })
    }
    
    @Published var got_like_card_users : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    //카드1개에 대한 좋아요 유저 확인
    func get_like_card_users(card_idx: Int){
        cancellation = APIClient.get_like_card_users(card_idx: card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카드 좋아요 유저 확인 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("좋아요 유저 확인 response: \(response)")
                let no_result =  response["result"].string
                if no_result == "no result"{
                    
                }else{
                    let result = response.arrayValue
                    
                    if result.count ?? 0 > 0{
                        /*
                         json -> decoder이용해서 모델로 디코딩
                         1. json decoder 선언
                         2. json string -> data타입으로 변환
                         3. json decoder.decode이용
                         */
                        let json_decoder = JSONDecoder()
                        
                        let json_string = """
                            \(String(describing: result))
                            """
                        let data = json_string.data(using: .utf8)
                        print("좋아요 유저 스트링 변환 확인: \(json_string)")
                        
                        let json_data = try? json_decoder.decode([Creator].self, from: data!)
                        print("좋아요 유저 디코딩 확인: \(String(describing: json_data))")
                        
                        for user in json_data!{
                            
                            self.card_like_user_model.append(Creator(idx: user.idx, nickname: user.nickname, profile_photo_path: user.profile_photo_path))
                        }
                        self.got_like_card_users.toggle()
                        print("카드 좋아요 유저 가져온 것 확인: \(self.card_like_user_model)")
                    }
                }
            })
    }
    
    //오늘 심심기간인 친구들 목록 가져오기
    func get_today_boring_friends(bored_date: String){
        cancellation = APIClient.get_today_boring_friends(bored_date: bored_date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("오늘 심심기간인 친구들 목록 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("오늘 심심기간인 친구들 목록 가져오기 응답: \(response)")
                
                if response != "no result"{
                    self.today_boring_friends_model.removeAll()
                    
                    let result = response.arrayValue
                    let json_decoder = JSONDecoder()
                    
                    let json_string = """
                            \(String(describing: result))
                            """
                    let data = json_string.data(using: .utf8)
                    print("심심기간인 친구들 스트링 변환 확인: \(json_string)")
                    
                    let json_data = try? json_decoder.decode([BoringFriendsModel].self, from: data!)
                    print("심심기간인 친구들 디코딩 확인: \(String(describing: json_data))")
                    
                    for user in json_data!{
                        
                        self.today_boring_friends_model.append(BoringFriendsModel(idx: user.idx, nickname: user.nickname, profile_photo_path: user.profile_photo_path, state: user.state, kinds: user.kinds))
                    }
                    print("심심기간인 친구들 가져온 것 확인: \(self.today_boring_friends_model)")
                    
                    //오늘이 심심기간이었는지 확인.....이거 되는지 확인하기
                    var action : Int = -1
                    action = self.today_boring_friends_model.firstIndex(where: {
                        $0.kinds == "me"
                    }) ?? -1
                    //처음에 뷰에 오늘 심심기간인지 아닌지 onappear에서 처리하면 시간차 때문에 설정 제대로 되지 않아서 노티 이용해서 보낸 후 뷰에서 처리.
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["set_today_boring_data" : String(action)])
                    
                }else{
                    print("심심기간인 친구들 결과 없음.")
                }
            })
    }
    
    //오늘 심심기간 설정 통신
    func set_boring_today(action: Int, date: String){
        cancellation = APIClient.set_boring_today(action: action, date: date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("오늘 심심기간 설정 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("오늘 심심기간 설정 통신 응답: \(response)")
                if response["result"].stringValue == "ok"{
                    print("심심기간 정보 확인: \(self.today_boring_friends_model)")
                   let model_idx =  self.today_boring_friends_model.firstIndex(where: {
                        $0.idx == Int(self.my_idx!)
                    }) ?? -1
                    
                    //기존에 심심기간 설정이 됐던 경우라면 삭제
                    if action == 1{
                        self.today_boring_friends_model.append(BoringFriendsModel(idx: Int(self.my_idx!)!, nickname: self.my_nickname, state: 1, kinds: ""))

                    }
                    //기존에 심심기간 설정이 안됐었던 경우라면 추가
                    else{
                        self.today_boring_friends_model.remove(at: model_idx)
                       
                    }
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.set_boring_today, object: nil, userInfo: ["today_boring_event" : "ok"])
                    
                    print("심심기간 설정 완료")
                    
                }else{
                    print("심심기간 설정 안됨")
                    NotificationCenter.default.post(name: Notification.set_boring_today, object: nil, userInfo: ["today_boring_event" : "fail"])
                }
                
            })
    }
    
    //관심친구 설정
    func set_interest_friend(f_idx: Int, action: String){
        cancellation = APIClient.set_interest_friend(f_idx: f_idx, action: action)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("관심친구 설정 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
    
        print("관심친구 설정 통신 response: \(response)")
                let result = response["result"].string
                if result == "ok"{
                    print("관심친구 설정 완료")
                    NotificationCenter.default.post(name: Notification.set_interest_friend, object: nil, userInfo: ["set_interest_friend" : "set_ok_\(action)"])
                    
                    
                }else {
                    print("관심친구설정 오류")
                    NotificationCenter.default.post(name: Notification.set_interest_friend, object: nil, userInfo: ["set_interest_friend" : "error"])
                }
    })
    }
    
    //카드 만들 때 현재 시간 +10분인 경우에만 만들기 가능
    func make_card_time_check(make_time : String) -> Bool{
        print("들어온 카드 약속 날: \(make_time)")

        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        format.timeZone = TimeZone(abbreviation: "UTC")

        let today_format = Int(Date().timeIntervalSince1970)+3600*9
                    let timeintervel = TimeInterval(today_format)
                    let korean_time  = Date(timeIntervalSince1970: timeintervel)
        let today_string = format.string(from: korean_time)
        
        let today = format.date(from: today_string)
        
        guard let card_time = format.date(from: make_time) else { return false}
        print("현재 시간: \(today)")
        print("카드 약속날 date형식: \(card_time)")
        //초를 리턴함.
        //let interval_time = Int(card_time.timeIntervalSince(today))
        //print("비교 결과: 시간 = \(interval_time) ")
        let calendar = Calendar.current
        let interval = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: today!, to: card_time).minute
        
        let minute_interval = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: today!, to: card_time)
        var date = minute_interval.day
        var hour = minute_interval.hour
        var minute = minute_interval.minute!
        print("분 차이 확인: \(date), \(hour), \(minute)")
        print("차이값 확인: \(interval)")
        date = date!*60*24
        hour = hour!*60
        if (date!+hour!+minute)>10{
            return true
        }else{
            return false
        }
    }
    
    //카드 잠그기
    func lock_card(card_idx: Int, lock_state: Int){
        cancellation = APIClient.lock_card(card_idx: card_idx, lock_state: lock_state)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("관심친구 설정 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구 - 카드 잠그기")
                
                let result : String?
                if response["result"] == "ok"{
                    
                    let changed_lock_state : String
                    if lock_state == 0{
                        changed_lock_state = "잠금해제"
                    }else{
                        changed_lock_state = "잠금"
                    }
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.event_finished, object: nil, userInfo: ["lock" : changed_lock_state, "card_idx": String(card_idx)])
                }
    })}
    
    //친구 카드 참여자 목록 가져오기
    func get_friend_card_apply_people(card_idx: Int){
        cancellation = APIClient.get_friend_card_apply_people(card_idx: card_idx)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("관심친구 설정 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
                }, receiveValue: {response in
                    print("카드 참여자 response: \(response)")
                    
                    let result = response.array
                    if (result?.count)! > 0{
                        print("참여자 있을 때")
                        
                        let json_string = """
                                \(result)
                                """
                        let json_data = json_string.data(using: .utf8)
                        
                        let apply_users = try? JSONDecoder().decode([ApplyUserStruct].self, from: json_data!)
                        self.apply_user_struct = apply_users!
                        
                    }else{
                        print("참여자 없음")
                    }
                })
    }
    
}
