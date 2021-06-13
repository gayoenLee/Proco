//
//  GroupVollehMainViewmodel.swift
//  proco
//
//  Created by 이은호 on 2020/12/27.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON
import SwiftUI
import WebKit


//카드 만들기 후 통신 성공, 실패에 따른 alert창 띄우기 위해 사용.
enum ResultTypeAlert{
    case success,fail
}
// For identifiying WebView's forward and backward navigation
enum WebViewNavigation {
    case backward, forward, reload
}

// For identifying what type of url should load into WebView
enum WebUrlType {
    case localUrl, publicUrl
}

class GroupVollehMainViewmodel: ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    //카드 만들기 - 지도 관련 설정
    var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
    var showWebTitle = PassthroughSubject<String, Never>()
    var showLoader = PassthroughSubject<Bool, Never>()
    var valuePublisher = PassthroughSubject<String, Never>()
    
    @Published var map_data : MeetingCardLocationModel = MeetingCardLocationModel()
    {
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var response_address : String = ""
    
    @Published var is_just_showing : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var is_making : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
    @Published var is_editing_card : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var map_edited : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }


    /*
     --------------------------데이터 모델들----------------------------
     */
    @Published var group_card_struct : [GroupCardStruct] = []
    {
        didSet {
            objectWillChange.send()
        }
    }
    
    //내 카드 여러장
    @Published var my_group_card_struct : [GroupCardStruct] = []{
        didSet {
            objectWillChange.send()
        }
    }
    //상세 페이지에 보여줄 카드 1개. (나)
    @Published var my_card_detail_struct  = GroupCardStruct()
    {
        didSet {
            objectWillChange.send()
        }
    }
    //다른 사람들 카드 상세 페이지 모델
    @Published var card_detail_struct  = GroupCardStruct()
    {
        didSet {
            objectWillChange.send()
        }
    }
    
    //카드 신청자 모델
    @Published var apply_user_struct  = [ApplyUserStruct](){
        didSet {
            objectWillChange.send()
        }
    }
    //카드 신청자의 프로필 사진, 닉네임 저장해서 채팅 서버에 보낼 때 사용.
    @Published var apply_user_nickname : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    @Published var apply_user_profile_photo : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    //내 모임 신청 목록
    @Published var apply_meeting_struct  = [MyApplyMeetingStruct](){
        didSet {
            objectWillChange.send()
        }
    }
    //내 모임 신청 목록 상세 페이지
    @Published var apply_meeting_detail_struct  = MyApplyMeetingStruct(){
        didSet {
            objectWillChange.send()
        }
    }
    ///모여 볼래 카드 태그 데이터 모델..카드 필터에 사용.
    @Published var volleh_tag_struct: [Tags] = []{
        didSet {
            objectWillChange.send()
        }
    }
    ///카테고리 태그
    @Published var category_tag_struct = [VollehTagCategoryStruct(category_name: "아무거나"),VollehTagCategoryStruct(category_name: "게임/오락"),VollehTagCategoryStruct(category_name: "사교/인맥"), VollehTagCategoryStruct(category_name: "문화/공연/축제"), VollehTagCategoryStruct(category_name: "운동/스포츠"), VollehTagCategoryStruct(category_name: "취미/여가"), VollehTagCategoryStruct(category_name: "스터디")]
    
    //카테고리중 최소 1개는 선택해야 하므로 체크하기 위해 만든 변수
    @Published var category_struct : Set<String> = ["아무거나","사교/인맥", "게임/오락", "문화/공연/축제", "운동/스포츠", "취미/여가", "스터디" ]
    
    @Published var location_struct = [LocationCategoryStruct(name: "전체"), LocationCategoryStruct(name: "서울"), LocationCategoryStruct(name: "인천"), LocationCategoryStruct(name: "경기"), LocationCategoryStruct(name: "충청"), LocationCategoryStruct(name: "강원"), LocationCategoryStruct(name: "전라"), LocationCategoryStruct(name: "경상"), LocationCategoryStruct(name: "제주")]
    
    @Published var location_set : Set<String> = ["전체","서울", "인천", "경기", "충청", "강원", "전라", "경상", "제주"]
    //---------------------------------------------------------------------------------
    ///내 닉네임 가져와서 메인 페이지에서 내 카드만 보여줄 때 사용.
    @Published var my_nickname = ""{
        didSet {
            objectWillChange.send()
        }
    }
    @Published var my_idx = UserDefaults.standard.string(forKey: "user_id"){
        didSet{
            objectWillChange.send()
        }
    }
    /*
     카드 상세 페이지(다른 사람)
     */
    ///카드 만든 사람 이미지, 이름
    @Published var creator_image : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    @Published var creator_name : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    
    ///카드 날짜 년, 월, 일로 나눔.시간
    @Published var year : String = ""{
        didSet {
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
    
    @Published var time : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    
    @Published var appply_end : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
    /*
     -------------------------------------- 카드 편집-------------------------
     */
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
    
    /*카드 만들기 통신 결과 이용
     */
    ///카드 만들기 통신 완료시 아래 alert띄운 후 메인 뷰로 화면 전환
    @Published var show_alert: Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var alert_type : ResultAlert = .fail{
        didSet{
            objectWillChange.send()
        }
    }
    
    /*
     ---------------------------------------------- 카드 만들기 사용 변수 시작--------
     */
    ///카드 만들 때 모임 이름 이곳에 저장.
    @Published var card_name : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    //태그
    ///사용자가 입력한 태그값
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
    //지역
    ///사용자가 입력한 지역 이름
    @Published var input_location : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    //소개글
    ///사용자가 입력한 소개글
    @Published var input_introduce : String = ""{
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
    
    /*
     참가 신청 수락, 거절
     */
    //주최자가 참가 신청을 수락, 거절하고자 하는 사람의 idx
    @Published var apply_user_idx: Int = -1{
        didSet {
            objectWillChange.send()
        }
    }
    
    //카테고리를 최소 1개는 선택해야함. 안했을 때 false
    @Published var category_selected : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //-------------------------------------------------------------------------------
    /*
     모여볼래에서 카드 시간 am, pm표시 위해서사용
     */
    @Published var meeting_time: String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    //모여볼래 카드에 시간 표시하기 위해, 상세 페이지에 am, pm표시하기 위함.
    func card_time_converter(meet_time: String) -> String{
       let initial_value = self.string_to_time(expiration: meet_time)
        print("date형식으로 변환한 값 확인: \(initial_value)")
        let time = DateFormatter.time_formatter.string(from: initial_value)
        print("시간 확인: \(time)")
        return time
    }
    /*
     -------------------------카드 만들기
     */
    ///카드 만들기 통신 후 alert창 띄울 때 사용.
    func result_alert(_ active: ResultAlert) -> Void{
        DispatchQueue.main.async {
            self.alert_type = active
            self.show_alert = true
        }
    }
    ///카드 만들기에서 날짜 형식 맞춰서 보내기 위해 실행하는 메소드
    func make_card_date() -> String{
        let day = DateFormatter.dateformatter.string(from: self.card_date)
        let time = DateFormatter.time_formatter.string(from: self.card_time)
        self.card_expire_time = day + " "+time
        return self.card_expire_time
    }
    
    /*
    -------------------------- 카드 필터 적용시 날짜 -> 스트링 변환해서 서버에 보내기
     */
    
    //날짜
    ///카드 필터에서 날짜 형식 맞춰서 보내기 위해 실행하는 메소드
    func date_to_string() -> String{
        let day = DateFormatter.dateformatter.string(from: self.filter_start_date)
        self.filter_start_date_string = day
        return self.filter_start_date_string
    }
    
    /*
     --------------------------태그 부분 예외처리
     */
    ///태그 선택 최대 3개까지 제한하는 메소드
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
    
    ///카드에서 카테고리중 최소 1개는 선택해야하므로 이것 체크하는 메소드
    func category_is_selected() -> Bool {
        var check_set : Set<String>
        //intersection: set을 비교해서 교집합 추출
        check_set = self.user_selected_tag_set.intersection(self.category_struct)
        if check_set.isEmpty{
            print("카테고리 포함 안돼있음 : \(check_set)")
            return false
        }else{
            print("카테고리 포함돼 있음  : \(check_set)")
            return true
            
        }
    }

    
    /*
     ---------------------------카드 편집
     */
    ///카드 편집시 서버에서 받은 날짜로 변환하기
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
        formatter.locale = Locale(identifier: "en_US")
        // formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = formatter.date(from: expiration)
        return date!
    }
    
    /*
     -------------카드 리스트 보여줄 때 foreach안에 index이용하기 위해 사용
     */
    ///내가 만든 카드 인덱스
    func get_index(item: GroupCardStruct )->Int{
        
        return self.my_group_card_struct.firstIndex { (item1) -> Bool in
            return item.card_idx == item1.card_idx
        } ?? -1
    }
    ///내가 만든 카드가 아닌 다른 카드들 index
    func get_other_card_index(item: GroupCardStruct )->Int{
        
        return self.group_card_struct.firstIndex { (item1) -> Bool in
            return item.card_idx == item1.card_idx
        } ?? -1
    }
    
    ///신청 목록 보여줄 때 카드 리스트에 사용하는 인덱스
    func apply_index(item: MyApplyMeetingStruct)->Int{
        
        return self.apply_meeting_struct.firstIndex { (item1) -> Bool in
            return item.card_idx == item1.card_idx
        } ?? -1
    }
    /*
     -----------------------신청자 리스트 보여줄 때 사용
     */
    func get_user_index(item: ApplyUserStruct )->Int{
        
        return self.apply_user_struct.firstIndex { (item1) -> Bool in
            return item.id == item1.id
        } ?? -1
    }
    @Published var check_owner_result : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    ///모임 신청자 페이지에서 주최자인지 알기 위해
    func find_owner() -> Bool{
        
        var idx : Bool = false
            
        idx =  self.my_group_card_struct.contains(where: {
            $0.card_idx == self.selected_card_idx
        })
    
       return idx
        //print("주최자인지 확인: \(self.check_owner_result)")
    }
    /*
     -----------------------카드 편집
     */
    ///제목은 필수 입력이므로 모임 제목 입력하지 않고 완료 버튼눌렀을 때 체크하는 메소드
    func title_check(title: String) -> Bool{
        var is_title_empty = false
        if self.card_name.isEmpty{
            is_title_empty = true
        }else{
            is_title_empty = false
        }
        return is_title_empty
    }
    /*
     ----------------------그 외
     */
    ///내 아이디 갖고와서 카드 리스트에 내 카드만 보여주기 위해 비교할 때 이용.
    func get_my_nickname(){
        self.my_nickname = UserDefaults.standard.string(forKey: "nickname")!
    }
    
    /*
    ------------------------------------------- 통신 코드 시작------------------------------------
     */
    
    //신고하기
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
    
    
    func get_group_volleh_card_list(){
        cancellation = APIClient.get_group_volleh_card_list()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("모여 볼래 카드 리스트 가져오기 결과값 : \(response)")
                
                if response.isEmpty{
                    print("모여볼래 카드 목록 없음.")
                    self.my_group_card_struct.removeAll()
                    self.group_card_struct.removeAll()

                }else{

                    self.my_group_card_struct.removeAll()
                    self.group_card_struct.removeAll()

                    var my_count = 0
                    for card in response{
                        if my_count < response.count {
                            my_count = my_count + 1

                            print("만든 사람 닉네임: \(card.creator!.nickname)")
                            print("내 닉네임: \(self.my_nickname)")
                            print("데이터 제이슨 가져와졌는지 확인: \(card.expiration_at)")
                            //내가 만든 카드일 경우
                            if self.my_nickname == card.creator!.nickname{

                                print("내 카드 추가됨 \(my_count)")
                                self.my_group_card_struct.append(GroupCardStruct(result: "", card_idx: card.card_idx, title: card.title, kinds: card.kinds, expiration_at: card.expiration_at, address: card.address, map_lat: card.map_lat, map_lng: card.map_lng, cur_user: card.cur_user, apply_user: card.apply_user, introduce: card.introduce, lock_state:card.lock_state, like_state: card.like_state, like_count: card.like_count, tags: card.tags!, creator: card.creator!, offset: 0.0))

                            }else{

                                print("다른 사람 카드 추가됨\(my_count)")
                                self.group_card_struct.append(GroupCardStruct(result: "", card_idx: card.card_idx, title: card.title, kinds: card.kinds, expiration_at: card.expiration_at, address: card.address, map_lat: card.map_lat, map_lng: card.map_lng, cur_user: card.cur_user, apply_user: card.apply_user, introduce: card.introduce, lock_state:card.lock_state, like_state: card.like_state, like_count: card.like_count, tags: card.tags!, creator: card.creator!, offset: 0.0))
                            }
                          

                        }
                    }
                    print("친구 카드 저장됐는지 확인: \(self.group_card_struct)")
                    print("내 카드에 데이터 추가 됐는지 확인: \(self.my_group_card_struct)")
                }
            })
    }
    
    func make_group_card(type: String, map_lat: Double, map_lng: Double){
        cancellation = APIClient.make_group_card(type: type, title: self.card_name, tags: self.user_selected_tag_list, time: self.card_expire_time, address: self.map_data.location_name, content: self.input_introduce, map_lat: String(map_lat), map_lng: String(map_lng))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 만들기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("카드 만들기 결과값 : \(response)")
                if response.result == "ok"{
                    
                    self.my_group_card_struct.append(GroupCardStruct(result: "", card_idx: response.card_idx, title: self.card_name, kinds: type, expiration_at: self.card_expire_time, address: self.map_data.location_name, map_lat: String(self.map_data.map_lat), map_lng:  String(self.map_data.map_lng), cur_user: 1, apply_user: 0, introduce: self.input_introduce, tags: response.tags, creator: nil, offset: 0.0))
                    print("카드 만들기 후 데이터 집어넣어졌는지 확인: \(self.card_name)")
                    print("카드 만들기 후 데이터 집어넣어졌는지 확인2: \(self.my_group_card_struct)")
                    
                    let idx = Int(self.my_idx!)
                    
                    //1.데이터 모델에 저장.
                    SockMgr.socket_manager.$user_chat_in_model.append(UserChatInListModel(idx: idx!, nickname: self.my_nickname, profile_photo_path: ""))
                    
                    print("카드 이름: \(self.card_name)")
                    //2.sqlite에 데이터 저장 - chatroom, user, card, tag
                    ChatDataManager.shared.insert_chat_info_friend(idx: response.chatroom_idx, card_idx: response.card_idx, creator_idx: Int(ChatDataManager.shared.my_idx!)!, room_name: self.card_name, kinds: type)
                    
                    let current_time = ChatDataManager.shared.make_created_at()
                    //TODO profile 사진 변경해야함
                    ChatDataManager.shared.insert_user(chatroom_idx: response.chatroom_idx, user_idx: idx!, nickname: self.my_nickname, profile_photo_path: "", read_last_idx: 0, read_start_idx: 0, temp_key: "", server_idx: response.server_idx, updated_at: current_time, deleted_at: "")
                    
                    //태그
                    for tag in response.tags{
                        
                        ChatDataManager.shared.insert_tag(chatroom_idx: response.chatroom_idx, tag_idx: tag.idx, tag_name: tag.tag_name)
                    }
                    //card
                    let created_at = ChatDataManager.shared.make_created_at()
                    ChatDataManager.shared.insert_card(chatroom_idx: response.chatroom_idx, creator_idx: Int(ChatDataManager.shared.my_idx!)!, kinds: type, card_photo_path: "", lock_state: 0, title: self.card_name, introduce: self.input_introduce, address: self.input_location, map_lat: "0.0", map_lng: "0.0", current_people_count: 1, apply_user: 0, expiration_at: self.card_expire_time, created_at: created_at, updated_at: "", deleted_at: "")
                    
                    //3.소켓으로 데이터 보내기
                    SockMgr.socket_manager.make_chat_room_friend(chatroom_idx: response.chatroom_idx, idx: idx!, nickname: self.my_nickname)
                    
                    //추가 후 데이터 집어넣고는 publish변수에 있던 값들 없애주기
                    self.input_location = ""
                    self.card_expire_time = ""
                    self.input_introduce = ""
                    self.card_name = ""
                    self.user_selected_tag_list = []
                    self.user_selected_tag_set = []
                    
                    print("추가 후 값 없앴는지 확인 : \( self.card_name)")
                    self.alert_type = .success
                }else{
                    print("카드 안만들어졌음 오류 발생 : \(String(describing: response.result))")
                    self.alert_type = .fail
                }
            })
    }
    
    
    func edit_group_card(type: String){
        cancellation = APIClient.edit_group_card(card_idx: self.selected_card_idx, type: type, title: self.card_name, tags: self.user_selected_tag_list, time: self.card_expire_time, address: self.input_location, content: self.input_introduce, map_lat: String(self.map_data.map_lat), map_lng: String(self.map_data.map_lng))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 편집 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("카드 편집 결과값 : \(response)")
                if response.result == "ok"{


                    if socket_manager.edit_from_chatroom{
                        print("채팅방 드로어에서 편집 화면으로 넘어와서 편집 완료")

                        let string_expirtaion = self.make_card_date()

                            print("socket_manager.card_struct 확인1: \(socket_manager.card_struct)")
                        //소켓 뷰모델 안의 카드 모델 데이터 업데이트
                            socket_manager.card_struct.address = self.input_location
                            socket_manager.card_struct.expiration_at = string_expirtaion
                            socket_manager.card_struct.introduce = self.input_introduce
                            socket_manager.card_struct.title = self.card_name
                            print("socket_manager.card_struct 확인2: \(socket_manager.card_struct)")

                        //로컬 디비에 카드 데이터 업데이트
                        ChatDataManager.shared.update_card_table(chatroom_idx: socket_manager.enter_chatroom_idx, creator_idx: socket_manager.card_struct.creator_idx, kinds: socket_manager.card_struct.kinds , card_photo_path: socket_manager.card_struct.card_photo_path ?? "", lock_state: socket_manager.card_struct.lock_state, title: self.card_name, introduce: self.input_introduce, address: self.input_location, map_lat: socket_manager.card_struct.map_lat, map_lng: socket_manager.card_struct.map_lng, current_people_count: socket_manager.card_struct.cur_user, apply_user: socket_manager.card_struct.apply_user, expiration_at: string_expirtaion, created_at: socket_manager.card_struct.created_at, updated_at: socket_manager.card_struct.updated_at ?? "", deleted_at: socket_manager.card_struct.deleted_at ?? "")

                        let updated_at = ChatDataManager.shared.make_created_at()

                        //채팅 서버에 보낼 때 이곳에 데이터 넣기 위해 변수 만듬.
                       var tag_model : [TagModel] = []
                        //태그 데이터 업데이트
                        for item in response.tags!{
                            ChatDataManager.shared.update_tag_table(chatroom_idx: socket_manager.enter_chatroom_idx, tag_idx: item.idx, tag_name: item.tag_name)

                            tag_model.append(TagModel(idx: item.idx, tag_name: item.tag_name))
                            }
                        print("서버에 보내는 태그 모델 확인: \(tag_model)")


                        //채팅 서버에 보내기 위해 만든 데이터.
                        let chatroom_model = ChatRoomModel(idx: socket_manager.enter_chatroom_idx, card_idx: socket_manager.current_chatroom_info_struct.card_idx, created_at: socket_manager.current_chatroom_info_struct.created_at, creator_idx: socket_manager.current_chatroom_info_struct.creator_idx, deleted_at: socket_manager.current_chatroom_info_struct.deleted_at, kinds: type, room_name: self.card_name, updated_at: updated_at, card_tag_list: tag_model, card: socket_manager.card_struct)
                        print("채팅룸 데이터: \(socket_manager.current_chatroom_info_struct)")
                        print("보내는 데이터: \(chatroom_model)")
                        socket_manager.edit_card_info_event(chatroom: chatroom_model)


                    }else{
                        print("드로어에서 온 경우가 아닐 때")
                        let string_expirtaion = self.make_card_date()

                    let detail_index = self.my_group_card_struct.firstIndex(where: {$0.card_idx == self.selected_card_idx})
                    //TODO!! 편집한 후에 여기에서 데이터를 업데이트해야 메인뷰에 돌아가면 데이터 업데이트 돼있음.!!!
                    //편집한 데이터를 모델에 집어넣기.
                    self.my_group_card_struct[detail_index!].address = self.input_location
                    self.my_group_card_struct[detail_index!].expiration_at = self.card_expire_time
                    self.my_group_card_struct[detail_index!].introduce = self.input_introduce
                    self.my_group_card_struct[detail_index!].title! = self.card_name

                        //********채팅 서버에 보낼 태그 모델*********
                        var tag_model : [TagModel] = []

                    for item in response.tags!{
                        self.my_group_card_struct[detail_index!].tags?.append(Tags(idx: item.idx, tag_name: item.tag_name))

                        //채팅 서버에 보낼 태그 데이터 넣고 태그 테이블 업데이트
                        ChatDataManager.shared.update_tag_table(chatroom_idx: socket_manager.enter_chatroom_idx, tag_idx: item.idx, tag_name: item.tag_name)

                        tag_model.append(TagModel(idx: item.idx, tag_name: item.tag_name))

                        }
                        print("편집한 데이터 집어넣었는지 확인 : \(String(describing: self.my_group_card_struct[detail_index!].tags))")

                        //채팅 서버에 보내기 위해 데이터 만들기(채팅룸 idx가져오기, 카드 업데이트 날짜 만들기, 카드 모델 만들기)
                        let chatroom = ChatDataManager.shared.get_chatroom_from_card(card_idx: self.selected_card_idx)
                        print("친구랑 볼래 뷰모델에서 채팅방 idx: \(chatroom)")

                        //업데이트한 날짜 만들기
                        let updated_at = ChatDataManager.shared.make_created_at()

                        //카드 idx로 디비에 저장된 카드 데이터 갖고 오기.
                        ChatDataManager.shared.get_card_info_from_main(chatroom_idx: chatroom)
                        print("카드 데이터 저장한 것 확인: \(socket_manager.card_struct)")
                        print("socket_manager.card_struct 확인1: \(socket_manager.card_struct)")

                    //소켓 뷰모델 안의 카드 모델 데이터 업데이트
                        socket_manager.card_struct.address = self.input_location
                        socket_manager.card_struct.expiration_at = string_expirtaion
                        socket_manager.card_struct.introduce = self.input_introduce
                        socket_manager.card_struct.title = self.card_name
                        print("socket_manager.card_struct 확인2: \(socket_manager.card_struct)")
                        //로컬 디비에 카드 데이터 업데이트
                        ChatDataManager.shared.update_card_table(chatroom_idx: chatroom, creator_idx: socket_manager.card_struct.creator_idx, kinds: type , card_photo_path: socket_manager.card_struct.card_photo_path ?? "", lock_state: socket_manager.card_struct.lock_state, title: self.card_name, introduce: self.input_introduce, address: self.input_location, map_lat: socket_manager.card_struct.map_lat, map_lng: socket_manager.card_struct.map_lng, current_people_count: socket_manager.card_struct.cur_user, apply_user: socket_manager.card_struct.apply_user, expiration_at: string_expirtaion, created_at: socket_manager.card_struct.created_at, updated_at: updated_at, deleted_at: socket_manager.card_struct.deleted_at ?? "")

                        socket_manager.card_struct.updated_at = updated_at
                        let chatroom_model = ChatRoomModel(idx: chatroom, card_idx: self.selected_card_idx, created_at: socket_manager.card_struct.created_at, creator_idx: Int(self.my_idx!)!, deleted_at: "", kinds: type, room_name: self.card_name, updated_at: updated_at, card_tag_list: tag_model, card: socket_manager.card_struct)

                        print("채팅룸 데이터: \(socket_manager.current_chatroom_info_struct)")
                        print("보내는 데이터: \(chatroom_model)")
                        SockMgr.socket_manager.edit_card_info_event(chatroom: chatroom_model)
                        //서버에 이벤트 보냄.
                        //socket_manager.edit_card_info_event(chatroom: chatroom_model)

                    //편집한 데이터 집어넣고는 publish변수에 있던 값들 없애주기
                    self.input_location = ""
                    self.card_expire_time = ""
                    self.input_introduce = ""
                    self.card_name = ""
                    self.user_selected_tag_list = []
                    self.user_selected_tag_set = []
                    print("편집 후 값 없앴는지 확인 : \( self.card_name)")
                    }
                    self.alert_type = .success

                }else{
                    print("카드 편집 오류 발생 : \(String(describing: response.result))")
                    self.alert_type = .fail

                }
            })
    }
    
    func delete_group_card(){
        cancellation = APIClient.delete_group_card(card_idx: self.selected_card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 삭제 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("모임 카드 삭제 response: \(response)")
                if response["result"] == "ok"{
                    //삭제 성공
                    //확인을 누르면 삭제하려는 카드 이곳에서 바로 지움.
                    print("뷰모델에서카드 삭제 진행")
                }else{
                    
                }
            })
        
    }
    
    func apply_group_card(card_idx: Int){
        cancellation = APIClient.apply_group_card(card_idx: card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 참가 신청 에러 발생 : \(error)")
                   // self.alert_type = .fail
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("참가신청 완료 결과 : \(response)")
                
                if response["result"] == "ok"{
                    //참가 신청 완료 알림 나타내기
                    NotificationCenter.default.post(name: Notification.apply_meeting_result, object: nil, userInfo: ["apply_meeting_result" : "ok"])
                }else{
                    NotificationCenter.default.post(name: Notification.apply_meeting_result, object: nil, userInfo: ["apply_meeting_result" : "ok"])
                }
            })
    }
    // 참가자 있을 경우 결과 제대로 오는지 확인 필요.
    func get_apply_people_list(){
      cancellation =  APIClient.get_apply_people(card_idx: self.selected_card_idx)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: {result in
            switch result{
            case .failure(let error):
                print("참가자 가져오기 에러 발생 : \(error)")
                //alert창 띄움.
                self.alert_type = .fail
            case .finished:
                break
            }
        }, receiveValue: {response in
            print("참가자 : \(response)")
            //신청자 및 참여자가 없을 경우 오는 결과값
            if response["result"] == "no result"{
                print("참가자 없음 no result")
            }else{
                
                for user in response{
                    print("user확인 \(user)")
                    
                    let nickname = user.1["nickname"].string
                    let idx = user.1["idx"].int
                    let level = user.1["level"].int
                    let kinds = user.1["kinds"].string
                    let profile_photo_path = user.1["profile_photo_path"].string
                    
                    print("nickname확인 \(String(describing: nickname))")
                    self.apply_user_struct.append(ApplyUserStruct(result: "", idx: idx, nickname: nickname, level: level, profile_photo_path: profile_photo_path, kinds: kinds))
                }
                print("결과 확인: \(JSON(response))")
            }
        })
    }
    
    //참가 신청 수락 - api 서버에 결과 ok왔을 때 채팅 서버에 모임 카드 참여 수락 이벤트 보냄.
    func apply_accept(){
        cancellation = APIClient.apply_accept(card_idx: self.selected_card_idx, meet_user_idx: self.apply_user_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 참가 신청 수락 에러 발생 : \(error)")
                    self.alert_type = .fail
                    
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("참가신청 수락 결과 : \(response)")
                
                //참가 신청 통신이 result ok로 왔을 경우 채팅서버와도 통신 진행.
                if response["result"] == "ok"{
                    print("침기지 : \(self.apply_user_idx)")

                    let chatroom_idx = response["chatroom_idx"].intValue
                    print("chatroom_idx : \(chatroom_idx)")

                    //수락된 채팅방의 마지막 메세지 idx
                    let last_message_idx = response["message_last_idx"].intValue
                    
                    
                    //채팅 서버에 모임 카드 참여 통신 진행.
                    SockMgr.socket_manager.send_join_card_ok(user_idx: self.apply_user_idx, chatroom_idx: chatroom_idx)

                    
                    //참가 신청 완료 알림 나타내기
                    self.alert_type = .success
                }else{
                    self.alert_type = .fail
                    
                }
            })
    }
    //참가 신청 거절
    func apply_decline(){
        cancellation = APIClient.apply_decline(card_idx: self.selected_card_idx, meet_user_idx: self.apply_user_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 참가 신청 거절 에러 발생 : \(error)")
                    self.alert_type = .fail
                    
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("참가신청 거절 결과 : \(response)")
                if response["result"] == "ok"{
                    //참가 신청 완료 알림 나타내기
                    self.alert_type = .success
                }else{
                    self.alert_type = .fail
                    
                }
            })
    }
    
    //모임 신청목록 가져오기
    func get_my_apply_list(){
        cancellation = APIClient.get_my_apply_list(type: "신청목록")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 신청목록 가져오기 에러 발생 : \(error)")
                    self.alert_type = .fail
                    
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("모여 볼래 신청목록 가져오기 결과 : \(response)")
                
                if response["result"] == "no result"{
                    //참가 신청 완료 알림 나타내기
                    print("참가 신청 목록 없음")
                }else{
                    
                    let json_decoder = JSONDecoder()
                    
                    let json_string = """
                        \(String(describing: response))
                        """
                    let data = json_string.data(using: .utf8)
                    print("data 스트링 변환 확인: \(json_string)")
                    
                    let json_data = try? json_decoder.decode([MyApplyMeetingStruct].self, from: data!)
                    
                    print("참가 신청 목록이 있을 경우 : \(json_data)")
                    for meeting in json_data!{
                        print("user확인 \(meeting)")

                        self.apply_meeting_struct.append(MyApplyMeetingStruct( creator: meeting.creator, card_idx: meeting.card_idx, kinds: meeting.kinds, apply_user: meeting.apply_user, introduce: meeting.introduce ?? "", apply_kinds: meeting.apply_kinds, tags: meeting.tags!, map_lat: meeting.map_lat, map_lng: meeting.map_lng, expiration_at: meeting.expiration_at, address: meeting.address, title: meeting.title, cur_user: meeting.cur_user, card_photo_path: meeting.card_photo_path ?? "", lock_state: meeting.lock_state, like_count: meeting.like_count, like_state: meeting.like_state))
    
                    }
                    print("데이터 들어간 것확인 \( self.apply_meeting_struct))")
                }
            })
    }
    
    //모임 신청 목록에서 상세 페이지 갈 때
    func get_apply_detail(){
        let detail_index = self.apply_meeting_struct.firstIndex(where: { $0.card_idx == self.selected_card_idx})
        
        self.apply_meeting_detail_struct.creator = self.apply_meeting_struct[detail_index!].creator
        
        self.creator_name = self.apply_meeting_detail_struct.creator!.nickname!
        self.creator_image = self.apply_meeting_detail_struct.creator?.profile_photo_path ?? ""
        ///상세 페이지 데이터 뷰모델 안의 변수들에 넣어줌.
        self.card_name = self.apply_meeting_detail_struct.title!
        //조심 : 데이터를 새로운 변수에 넣어줄 때 왼쪽에 넣을 변수, 오른쪽에 넣을 값을 갖고 있는 변수 위치로 해줘야 데이터 들어감.
        //지역
        self.input_location = self.apply_meeting_detail_struct.address!
        //소개글
        self.input_introduce = self.apply_meeting_detail_struct.introduce!
        
        //태그 set, array에 이름 저장
        if self.apply_meeting_detail_struct.tags != nil{
            for tag in self.apply_meeting_detail_struct.tags!{
                self.user_selected_tag_set.insert(tag.tag_name)
                self.user_selected_tag_list.append(tag.tag_name)
            }}
        
        let total_day  = String(self.apply_meeting_detail_struct.expiration_at!.split(separator: " ")[0])
        self.year = String(total_day.split(separator: "-")[0])
        self.month = String(total_day.split(separator: "-")[1])
        self.date = String(total_day.split(separator: "-")[2])
   
    }
    //필터 전체, 채팅만, 만나서 종류 설정 어떻게 해놨는지 저장.
    @Published var filter_kind : String? = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var filter_location : String? = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    func group_volleh_filter(address: String, kinds: String){
        cancellation = APIClient.group_volleh_filter(date_start: self.filter_start_date_string, date_end: self.filter_start_date_string,address: address, tag: self.user_selected_tag_list, kinds: kinds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드 필터 에러 발생 : \(error)")
                    //self.alert_type = .fail
                case .finished:
                    break
                }
            }, receiveValue: {response in
             print("모여 볼래 필터 결과값 : \(response)")
                
                if response["result"] == "no result"{
                    
                    print("필터 결과 no result 들어옴")
                    //필터 적용 결과가 없다는 alert창 띄우기
                    self.my_group_card_struct.removeAll()
                    self.group_card_struct.removeAll()
                    self.volleh_tag_struct.removeAll()
                    //self.alert_type = .fail
                    
                }else{
                self.my_group_card_struct.removeAll()
                self.group_card_struct.removeAll()

                var my_count = 0
                for card in response{
                    //여기에서 태그를 한 번 삭제해줘야 태그들이 이전 것까지 중복돼서 저장되지 않는다.
                    self.volleh_tag_struct.removeAll()

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
                                self.volleh_tag_struct.append(Tags(idx: tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                            }

                            print("내 카드 추가됨 \(my_count)")
                            self.my_group_card_struct.append(GroupCardStruct(card_idx: card_idx!, kinds: kinds!, expiration_at: expiration_at, lock_state: lock_state, like_state: like_state, like_count: like_count, tags: self.volleh_tag_struct, creator: Creator(idx: creator_idx, nickname: creator_name, profile_photo_path: creator_image)))

                        }else{
                            
                            for tag in tags!{
                                self.volleh_tag_struct.append(Tags(idx: tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                            }
                            
                            print("다른 사람 카드 추가됨\(my_count)")
                            self.group_card_struct.append(GroupCardStruct(card_idx: card_idx!, kinds: kinds!, expiration_at: expiration_at,  lock_state: lock_state, like_state: like_state, like_count: like_count, tags: self.volleh_tag_struct, creator: Creator(idx: creator_idx, nickname: creator_name, profile_photo_path: creator_image)))
                        }
                    }
                }
                    print("최종 내 카드 데이터 확인: \(self.my_group_card_struct)")
                }
            })
    }
    
    func get_group_card_detail(card_idx: Int){
        cancellation = APIClient.get_group_card_detail(card_idx: card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("모여 볼래 카드상세 정보 데이터 가져오기 에러 발생 : \(error)")
                //self.alert_type = .fail
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("모여볼래 카드 상세 정보 가져오기 response 확인: \(response)")
                
                if response.result == "no result"{
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["get_group_card_detail_finish" : "no result"])
                }else{
                    print("만료날짜 원래 데이터 확인 : \(String(describing: response.expiration_at))")
                
                let first_filtered_day = self.string_to_date(expiration: response.expiration_at!)
                print("날짜 변환했는지 확인 : \(first_filtered_day)")
                self.card_date = first_filtered_day

                let time_filtered = self.string_to_time(expiration: String(response.expiration_at!.split(separator: " ")[1]))
                self.card_time = time_filtered
                print("시간 변환 확인 : \(self.card_time)")

                self.input_location = response.address!
                self.input_introduce = response.introduce ?? ""
                self.card_name = response.title!

                //태그 set, array에 이름 저장
                self.user_selected_tag_set.removeAll()
                self.user_selected_tag_list.removeAll()

                                if response.tags != nil{
                                    for tag in response.tags!{
                                        self.user_selected_tag_set.insert(tag.tag_name)
                                        self.user_selected_tag_list.append(tag.tag_name)
                                        if self.category_tag_struct.contains(where: {
                                            $0.category_name == tag.tag_name
                                        }){
                                            //태그 데이터중 카테고리는 뷰에 selected category로 세팅해놔야 하므로 뷰에 알리는 것.
                                            NotificationCenter.default.post(name: Notification.send_selected_card_category, object: nil, userInfo: ["selected_category" : tag.tag_name])
                                        }
                                    }
                                }
                print("카드 정보 가져와서 태그 저장한 것 확인: \(self.user_selected_tag_list)")
//
             
                //내 카드인 경우
                if response.creator!.idx! == Int(self.my_idx!){

                    if self.is_editing_card{
                        print("지도 데이터 저장 안함 : \(self.map_data)")
                        self.input_location = self.map_data.location_name

                    }else{
                    //상세페이지에서 띄울 지도에서 필요한 위도, 경도 저장.
                    self.map_data = MeetingCardLocationModel( location_name: response.address!, map_lat: Double(response.map_lat!)! , map_lng: Double(response.map_lng!)!)
                    print("맵 데이터 저장한 것 확인: \( self.map_data)")
                    }

                    self.my_card_detail_struct = response
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["get_group_card_detail_finish" : response.expiration_at!])
              
                    //다른 사람 카드인 경우
                }else{
                    if self.is_editing_card{
                        print("지도 데이터 저장 안함 : \(self.map_data)")
                        self.input_location = self.map_data.location_name
                    }else{
                    //상세페이지에서 띄울 지도에서 필요한 위도, 경도 저장.
                    self.map_data = MeetingCardLocationModel( location_name: response.address!, map_lat: Double(response.map_lat!)! , map_lng: Double(response.map_lng!)!)
                    print("맵 데이터 저장한 것 확인: \( self.map_data)")
                    }

                    self.card_detail_struct =  response
//
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["get_group_card_detail_finish" : response.expiration_at!])
                }
            }
            }
        )}
    
    //좋아요 클릭 이벤트(카드)
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
                    clicked_card =  self.group_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       }) ?? -1
                    if clicked_card != -1{
                        self.group_card_struct[clicked_card!].like_count! += 1
                       self.group_card_struct[clicked_card!].like_state = 1
                    }else{
                        clicked_card =  self.my_group_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       })
                        
                        self.my_group_card_struct[clicked_card!].like_count! += 1
                        self.my_group_card_struct[clicked_card!].like_state = 1
                    }
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.clicked_like, object: nil, userInfo: ["clicked_like" : "ok", "card_idx": "\(card_idx)"])
                   // self.like_event_copmplete = true
                    
                    
                }else{
                    print("좋아요 안됨.")
                }
            })
    }
    
    //좋아요 취소
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
                    clicked_card =  self.group_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       }) ?? -1
                    if clicked_card != -1{
                        self.group_card_struct[clicked_card!].like_count! -= 1
                       self.group_card_struct[clicked_card!].like_state = 0
                    }else{
                        clicked_card =  self.my_group_card_struct.firstIndex(where: {
                           $0.card_idx == card_idx
                       })
                        
                        self.my_group_card_struct[clicked_card!].like_count! -= 1
                        self.my_group_card_struct[clicked_card!].like_state = 0
                    }
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.clicked_like, object: nil, userInfo: ["clicked_like" : "canceled_ok", "card_idx": "\(card_idx)"])
                    //ui에서 사용하기 위한 boolean값 true
                   // self.like_cancel_copmplete = true
                }else{
                    print("좋아요 취소 안됨.")
                }
            })
    }
}
