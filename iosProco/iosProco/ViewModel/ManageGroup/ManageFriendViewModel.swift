//
//  GotGroupListData.swift
//  proco
//
//  Created by 이은호 on 2020/12/13.
// 친구 관리 페이지에서 그룹 리스트 가져오기 위해 사용하는 뷰모델 후에********* 친구 목록, 친구 신청 목록도 같이 가져오기

import Foundation
import Combine
import Alamofire
import Contacts
import SwiftyJSON

enum ActiveAlert {
    case accept, decline
}
enum FriendSearchAlert{
    case no_friends, myself
}

//연락처로 추가시 친구 찾은 결과가 있을 경우: find_ok
enum FriendRequestAlert{
    case no_friends, request_wait, requested, already_friend, denied, myself, success, fail, find_ok
}
enum AddFriendGroupAlert{
    case ok, duplicated, fail
}

//통신 실패시에만 띄우기 위한 알림창
enum RequestResultFail{
    case fail
}

enum CheckFriendAlert{
    case no_friends, request_wait, requested, already_friend, denied, myself, success, fail
}

class ManageFriendViewModel: ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    //친구 리스트 가져온 후 저장하는 모델
    @Published var friend_list_struct : [GetFriendListStruct] = []
    {
        didSet {
            objectWillChange.send()
        }
    }
    
    //그룹 리스트 하나당 데이터 갖고 있는 모델
    @Published var manage_groups = [ManageGroupStruct](){
        didSet{
            objectWillChange.send()
        }
    }
    
    private let didChange = PassthroughSubject<[FriendRequestListStruct], Never>()
    
    //친구 신청 목록 데이터 모델
    @Published var friend_request_struct = [FriendRequestListStruct](){
        
        didSet{
            objectWillChange.send()
            print("친구 신청 목록 didset들어옴 : \(friend_request_struct)")
        }
    }
    
    //내가 신청한 친구 목록 모델
    @Published var my_friend_request_struct = [MyRequestFriendModel](){
        didSet{
            objectWillChange.send()
        }
    }
    
    //친구 추가 진짜로 하기 전에 서버에 이 사람이 있는지 확인하는 통신 후 받는 response
    @Published var add_friend_check_struct = FriendRequestListStruct(){
        didSet {
            objectWillChange.send()
        }
    }
    
    var cancellation: AnyCancellable?
    
    //2.그룹 리스트 가져오는 통신이 성공한 경우
    @Published var get_group_ok : Bool = false{
        didSet{
            objectWillChange.send()
            
        }
    }
    
    //친구관리 페이지에서 해당 row클릭시 idx이곳에 저장하기, 그리고 상세 페이지에서 이값을 이용해 데이터 가져온다.
    @Published var detail_group_idx : Int = -1{
        
        didSet{
            objectWillChange.send()
        }
    }
    
    //친구를 그룹에 추가하기 - 선택한 그룹 idx를 이곳에 저장한 후 서버에 친구 그룹에 추가 통신시 사용
    @Published var selected_group_idx : Int = -1{
        didSet{
            objectWillChange.send()
        }
    }
    //친구를 그룹에 추가하기 - 선택한 친구 idx를 이곳에 저장한 후 서버에 친구 그룹에 추가 통신시 사용
    @Published var selected_friend_idx : Int = -1{
        didSet{
            objectWillChange.send()
        }
    }
    //그룹에 친구 추가 완료시 alert창 띄우기 위해 이 값을 통해 뷰에서 알 수 있도록 한다.
    @Published var add_friend_to_group_ok : Bool = false{
        
        didSet{
            objectWillChange.send()
        }
    }
    //친구 그룹에 추가시 이미 그룹에 친구가 있을 경우
    @Published var add_friend_to_group_already : Bool = false{
        
        didSet{
            objectWillChange.send()
        }
    }
    //친구 그룹에 추가 실패시
    @Published var add_friend_to_group_fail : Bool = false{
        
        didSet{
            objectWillChange.send()
        }
    }
    
    //번호로 친구추가하기 페이지에서 찾은 뒤 추가하려는 친구 idx값 이곳에 저장
    @Published var add_friend_idx_value: Int = -1{
        didSet{
            objectWillChange.send()
        }
    }
    //아이디로 친구추가하기에서 이곳에 추가하려는 아이디 저장
    @Published var add_friend_id_value : String = ""{
        
        didSet{
            objectWillChange.send()
        }
    }
    
    //번호로 친구추가하기에서 이곳에 추가하려는 번호 저장
    @Published var add_friend_number_value : String = ""{
        
        didSet{
            objectWillChange.send()
        }
    }
    
    //친구 신청 수락하려는 idx값 저장
    @Published var selected_friend_request_idx : Int = -1{
        didSet{
            objectWillChange.send()
        }
    }
    
    //친구 신청에 대한 통신 끝났는지 여부 알기 위한 변수
    @Published var accept_friend_request_end : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    //***********alert창 그룹에 친구 추가한 후 & 친구 삭제 실패 후 fail인 경우에만*********
    @Published var show_add_friend_group_alert : Bool  = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var active_friend_group_alert : AddFriendGroupAlert  = .ok{
        didSet{
            objectWillChange.send()
        }
    }
    
    func show_ok_alert(_ active: AddFriendGroupAlert) -> Void {
        DispatchQueue.main.async {
            self.active_friend_group_alert = active
            self.show_add_friend_group_alert = true
        }
    }
    
    //********alert창 친구 요청 수락/거절시 사용*********
    @Published var show_alert_now : Bool  = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var active_alert : ActiveAlert  = .accept{
        didSet{
            objectWillChange.send()
        }
    }
    
    func show_alert(_ active: ActiveAlert) -> Void {
        DispatchQueue.main.async {
            self.active_alert = active
            self.show_alert_now = true
        }
    }
    
    //******친구 번호 검색 후 친구 추가하기 통신 후의 alert창***************
    @Published var show_request_result_alert : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var request_result_alert :FriendRequestAlert  = .no_friends{
        didSet{
            objectWillChange.send()
        }
    }
    
    
    func request_result_alert_func(_ active: FriendRequestAlert) -> Void {
        
        DispatchQueue.main.async {
            self.request_result_alert = active
            
            //친구를 검색해서 찾은 경우에는 다이얼로그 띄우지 않기 위해 사용
            if self.request_result_alert == .find_ok{
                self.show_request_result_alert = false
            }else{
                self.show_request_result_alert = true
            }
        }
    }
    
    
    //************친구관리 - 그룹 리스트 가져오는 것**************
    func get_manage_data_and_fetch(){
        cancellation = APIClient.get_all_manage_group()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:
                    {result in
                        switch result{
                        case .failure(let error):
                            print("그룹 리스트 가져오는 데 에러 발생 : \(error)")
                        case .finished:
                            break
                        }
                    }
                  , receiveValue: {(response) in
                    //그룹 리스트 업데이트 된 경우 다시 가져와야하므로 기존의 모델에 있던 데이터삭제 후 다시 append
                    self.manage_groups.removeAll()
                    print("그룹 리스트 가져오는 데 받은 value값 : \(response)")
                    for group in response{
                        if group.name != nil{
                            self.manage_groups.append(ManageGroupStruct(result: group.result, idx: group.idx, name: group.name!))
                            print("그룹 데이터 가져와서 추가 확인 : \(String(describing: group.name))")
                            
                        }
                    }
                    
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["got_all_groups" : "ok"])
                    self.fetch_all_friend_list()
                  })
    }
    
    //내가 신청한 친구 요청 목록
    func get_my_request_friend_list(){
        cancellation = APIClient.get_my_request_friend_list(friend_type: "친구요청중")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("내가 친구 요청한 리스트 가져오는데 fail")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("내가 친구 신청한 리스트 가져오기 response: \(response)")
                
                self.my_friend_request_struct.removeAll()
                //요청 결과가 없을 경우 result만 딕셔너리 형태로 와서 예외처리 해줘야 함.
                let result: String?
                result = response["result"].string
                if result == "no result"{
                    print("내 친구 요청 리스트 없음")
                }
                else{
                    print("내 친구 요청 존재")
                    let data = JSON(response)
                    let json_string = """
                        \(data)
                        """
                    print("내 친구 요청 리스트 string변환: \(json_string)")
                    
                    let json_data = json_string.data(using: .utf8)
                    
                    let friend = try? JSONDecoder().decode([MyRequestFriendModel].self, from: json_data!)
                    
                    //있는 데이터 제거 후 추가
                    self.my_friend_request_struct.removeAll()
                    print("내 친구 요청 리스트 모델 넣기 전: \(self.my_friend_request_struct)")
                    self.my_friend_request_struct = friend!
                    print("내 친구 요청 리스트 모델 넣은 후 : \(self.my_friend_request_struct)")
                    
                }
            })
    }
    //친구관리 - 친구 신청 목록 가져온 후 내가 신청한 친구 목록 가져오기
    func get_friend_list_and_request(){
        cancellation = APIClient.get_friend_request_api(friend_type: "친구요청대기")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("sink후 친구 요청 리스트 가져올 때 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("친구 요청 리스트 뷰모델의 receive value값 : \(String(describing: response))")
                self.friend_request_struct.removeAll()
                //요청 결과가 없을 경우 result만 딕셔너리 형태로 와서 예외처리 해줘야 함.
                let result: String?
                result = response["result"].string
                if result == "no result"{
                    print("친구 요청 리스트 없음")
                }
                else{
                    print("친구 요청 존재")
                    let data = JSON(response)
                    let json_string = """
                        \(data)
                        """
                    print("친구 요청 리스트 string변환: \(json_string)")
                    
                    let json_data = json_string.data(using: .utf8)
                    
                    let friend = try? JSONDecoder().decode([FriendRequestListStruct].self, from: json_data!)
                    
                    //있는 데이터 제거 후 추가
                    self.friend_request_struct.removeAll()
                    print("친구 요청 리스트 모델 넣기 전: \(self.friend_request_struct)")
                    self.friend_request_struct = friend!
                    print("친구 요청 리스트 모델 넣은 후 : \(self.friend_request_struct)")
                    
                }
                self.get_my_request_friend_list()
            })
    }
    
    //친구를 그룹에 추가하기 - 친구 리스트에서 그룹 선택해서 추가하기
    func add_friend_to_group(){
        cancellation = APIClient.add_friend_to_group(group_idx: self.selected_group_idx, friend_idx: self.selected_friend_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:
                    {result in
                        switch result{
                        case .failure(let error):
                            print("친구 그룹에 추가하는 통신 에러 발생 : \(error)")
                        case .finished:
                            break
                        }
                    }
                  , receiveValue: {(response) in
                    //그룹 리스트 업데이트 된 경우 다시 가져와야하므로 기존의 모델에 있던 데이터삭제 후 다시 append
                    print("친구 그룹에 추가하는 통신 하는 데 받은 value값 : \(response)")
                    
                    if response["result"] == "ok"{
                        print("친구 그룹 추가 성공")
                        
                        self.active_friend_group_alert = .ok
                        
                    }else if response["result"] == "duplicated"{
                        
                        self.active_friend_group_alert = .duplicated
                        print("친구 그룹에 이미 있음")
                        
                    }else{
                        self.active_friend_group_alert = .fail
                        print("친구 그룹에 추가 실패")
                    }
                  })
    }
    
    //친구관리 - 그룹 리스트만 가져오고 싶을 때
    func get_manage_groups_only(){
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
                            self.manage_groups.append(ManageGroupStruct(result: group.result, idx: group.idx, name: group.name!))
                            print("그룹 데이터만 가져와서 추가 확인 : \(String(describing: group.name!))")
                        }
                    }
                  })
    }
    
    //전체 친구 목록 가져오기
    func fetch_all_friend_list(){
        cancellation = APIClient.get_friend_list_api(friend_type: "친구상태")
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
                print("친구관리에서 친구 리스트 가져오는 response: \(String(describing: response))")
                //있는 데이터 제거 후 추가
                self.friend_list_struct.removeAll()
                for friend in response{
                    if friend.nickname != nil{
                        self.friend_list_struct.append(GetFriendListStruct(result: friend.result, idx: friend.idx, nickname: friend.nickname!, profile_photo: friend.profile_photo, state: friend.state, kinds: friend.kinds))
                        print("데이터 추가 확인 : \(friend.nickname!)")
                    }
                }
                let friend_num = self.friend_list_struct.count
                
                //친구 수를 노티를 이용하는 이유는 친구 수락 또는 거절시 친구 수를 state로 동적으로 변화시키기 위함.
                NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["got_all_friend" : "ok", "friend_num":  String(friend_num)])
            })
    }
    
    //친구 신청 수락하기
    func accept_friend_request(){
        cancellation = APIClient.accpet_friend_request_api(friend_idx: self.selected_friend_request_idx,action: "수락")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("메인에서 sink후 친구 신청 수락시 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("메인에서 친구 신청 수락시 뷰모델의 receive value값 : \(String(describing: response))")
                let friend_idx = self.selected_friend_request_idx
                let result : String?
                if response["result"].string == "ok"{
                    
                    self.accept_friend_request_end.toggle()
                    
                    NotificationCenter.default.post(name: Notification.friend_request_event, object: nil, userInfo: ["friend_request_event" : "accepted", "friend_idx": String(friend_idx) ])
                    
                    //수락 요청 실패시 뷰에 알리기
                }else{
                    
                    NotificationCenter.default.post(name: Notification.friend_request_event, object: nil, userInfo: ["friend_request_event" : "failed", "friend_idx": String(friend_idx) ])
                }
            })
    }
    
    //친구 신청 거절
    func decline_friend_request(){
        cancellation = APIClient.decline_friend_request_api(friend_idx: self.selected_friend_request_idx,action: "거절")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("메인에서 sink후 친구 신청 거절시 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("메인에서 친구 신청 거절시 뷰모델의 receive value값 : \(String(describing: response))")
                let friend_idx = self.selected_friend_request_idx
                let result : String?
                if response["result"].string == "ok"{
                    
                    NotificationCenter.default.post(name: Notification.friend_request_event, object: nil, userInfo: ["friend_request_event" : "declined", "friend_idx": String(friend_idx) ])
                }else{
                    NotificationCenter.default.post(name: Notification.friend_request_event, object: nil, userInfo: ["friend_request_event" : "failed", "friend_idx": String(friend_idx) ])
                }
            })
    }
    
    //체크한 후 valid한지 확인하는 메소드
    func is_valid_phone_number(phone_number: String) -> Bool{
        
        let regular_expression_phone = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        let testPhone = NSPredicate(format:"SELF MATCHES %@", regular_expression_phone)
        let phone_number_check_result = testPhone.evaluate(with: self)
        return phone_number_check_result
    }
    //핸드폰 번호 양식 체크
    func validator_phonenumber(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let phone_format = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        let phone_predicate = NSPredicate(format:"SELF MATCHES %@", phone_format)
        return phone_predicate.evaluate(with: string)
    }
    
    //번호로 친구추가하기전 확인버튼 눌렀을 때 통신으로 체크 - 검색한 번호값은 텍스트필드값이 뷰모델에 저장돼있음. - add_friend_number_value
    func add_friend_number_check(){
        cancellation = APIClient.add_friend_number_check_api(friend_phone: self.add_friend_number_value)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result {
                case .failure(let error):
                    print("번호로 친구추가하기전 체크 에러 발생: \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {(response) in
                print("친구관리에서 번호로 친구추가하기전 체크 response : \(String(describing: response))")
                //가져온 데이터를 여기에서 모델에 넣지 않고 노티를 보낸 후 뷰에서 onreceive했을 때 넣어줌.
                if response.result == nil{
                    
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["check_friend_number" : "ok"])
                    
                    self.add_friend_check_struct.idx = response.idx
                    self.add_friend_check_struct.nickname = response.nickname
                    self.add_friend_check_struct.profile_photo_path = response.profile_photo_path
                    
                    self.request_result_alert = .find_ok
                    print("친구 번호로 찾기에서 뷰모델에 result nil 들어옴")
                    
                }else{
                    //다른 예외상황 발생했을때는 검색한 친구정보를 초기화 시켜야됨
                    self.add_friend_check_struct = FriendRequestListStruct()
                    
                    switch response.result {
                    case "no signed friends":
                        self.request_result_alert = .no_friends
                        print("없는 사용자")
                    case "자기자신" :
                        self.request_result_alert = .myself
                        print("내 번호 검색함")
                    case "친구요청대기" :
                        self.request_result_alert = .request_wait
                    case "친구요청받음" :
                        self.request_result_alert = .requested
                    case "차단당한 친구" :
                        self.request_result_alert = .no_friends
                    case "친구상태" :
                        self.request_result_alert = .already_friend
                    default :
                        self.request_result_alert = .no_friends
                    }
                    self.request_result_alert_func(self.request_result_alert)
                }
           
            })
    }
    
    //이메일 아이디로 친구추가하기전 체크
    func add_friend_email_check(){
        cancellation = APIClient.add_friend_email_check_api(friend_email: self.add_friend_id_value)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("메인에서 sink후 친구 이메일로 추가 체크에서 에러 발생: \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {(response) in
                print("메인에서 친구 이메일로 추가 체크에서 뷰모델의 receive value값 : \(String(describing: response))")
                //가져온 데이터를 데이터모델에 넣어줌.
                if response.result == nil{
                    self.add_friend_check_struct.idx = response.idx
                    self.add_friend_check_struct.nickname = response.nickname
                    self.add_friend_check_struct.profile_photo_path = response.profile_photo_path
                }
                else if response.result == "no signed friends"{
                    
                    print("없는 사용자")
                    
                }else if response.result == "자기자신"{
                    
                    print("내 번호 검색함")
                }
            })
    }
    
    //번호로 친구추가하기 최종
    func add_friend_number_last(){
        cancellation = APIClient.add_friend_number_last_api(f_idx: self.add_friend_check_struct.idx!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("sink후 번호로 친구추가하기 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("번호로 친구추가하기 뷰모델의 receive value값 : \(String(describing: response))")
                //친구 추가하기 성공후 친구 리스트 데이터에 어떻게 새롭게 데이터 넣을지 .......
                
                //번호로 친구추가하기가 성공한 경우
                if response["result"] == "ok"{
                    self.request_result_alert = .success
                    print("친구추가하기 성공")
                } else if response["result"]  == "no signed friends"{
                    print("친구추가하기 없는 사용자")
                    self.request_result_alert = .no_friends
                    
                }else if response["result"]  == "친구요청대기"{
                    print("친구 요청 대기중")
                    self.request_result_alert = .request_wait
                    
                }else if response["result"]  == "친구요청뱓음"{
                    print("친구 요청 대기중")
                    self.request_result_alert = .requested
                    
                }else if response["result"]  == "친구상태"{
                    print("이미 친구입니다")
                    self.request_result_alert = .already_friend
                    
                }else if response["result"]  == "자기자신"{
                    print("나자신")
                    self.request_result_alert = .myself
                    
                }else{
                    print("실패")
                    self.request_result_alert = .fail
                }
                
                //alert보내기 위해 사용
                self.request_result_alert_func(self.request_result_alert)
            })
    }
    
    func add_friend_email_last(){
        cancellation = APIClient.add_friend_email_last_api(f_idx: self.add_friend_idx_value)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("sink후 이메일로 친구추가하기 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("이메일로 친구추가하기 뷰모델의 receive value값 : \(String(describing: response))")
                //친구 추가하기 성공후 친구 리스트 데이터에 어떻게 새롭게 데이터 넣을지 .......
                
                //이메일로 친구추가하기가 성공한 경우
                if response["result"] == "ok"{
                    self.request_result_alert = .success
                    print("친구추가하기 성공")
                } else if response["result"]  == "no signed friends"{
                    print("친구추가하기 없는 사용자")
                    self.request_result_alert = .no_friends
                    
                }else if response["result"]  == "친구요청대기"{
                    print("친구 요청 대기중")
                    self.request_result_alert = .request_wait
                    
                }else if response["result"]  == "친구요청뱓음"{
                    print("친구 요청 대기중")
                    self.request_result_alert = .requested
                    
                }else if response["result"]  == "친구상태"{
                    print("이미 친구입니다")
                    self.request_result_alert = .already_friend
                    
                }else if response["result"]  == "자기자신"{
                    print("나자신")
                    self.request_result_alert = .myself
                }else{
                    print("실패")
                    self.request_result_alert = .fail
                }
                
            })
    }
    
    //관심친구 지정
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
                let friend_idx = String(f_idx)
                
                print("관심친구 설정 통신 response: \(response)")
                let result = response["result"].string
                
                if result == "ok"{
                    print("관심친구 설정 완료")
                    
                  
                    NotificationCenter.default.post(name: Notification.set_interest_friend, object: nil, userInfo: ["set_interest_friend" : "set_ok_\(action)", "friend_idx": friend_idx])
                    
                }else {
                    print("관심친구설정 오류")
                    
                    NotificationCenter.default.post(name: Notification.set_interest_friend, object: nil, userInfo: ["set_interest_friend" : "error", "friend_idx": friend_idx])
                }
            })
    }
    
    //친구 해제
    func delete_friend(f_idx: Int, action: String){
        cancellation = APIClient.delete_friend(f_idx: f_idx, action: action)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구 해제 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                
                print("친구 해제 통신 response: \(response)")
                let result = response["result"].string
                
                if result == "ok"{
                    print("친구 해제 완료")
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["remove_friend" : "ok", "friend": String(f_idx)])
                    
                   
                }else {
                    print("친구 해제 오류")
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["remove_friend" : "fail", "friend": String(f_idx)])
                    
                    self.active_friend_group_alert = .fail
                }
            })
    }
    
    @Published var enrolled_friends_model : [EnrolledFriendsModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //내 친구들 중 이미 앱에 가입한 친구리스트 가져오기
    func get_enrolled_friends(contacts: Array<Any>){
        cancellation = APIClient.get_enrolled_friends(contacts: contacts)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("이미 앱에 가입한 친구리스트 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("이미 앱에 가입한 친구리스트 가져오기 response: \(response)")
                self.contacts_model.removeAll()
                self.enrolled_friends_model.removeAll()
                
                let result = response["result"].string
                if result == "ok"{
                    print("가입된 친구 없음")
                }
                
                let list = response.array
                print("체크: \(String(describing: list))")
                if list?.count ?? 0 > 0{
                    print("가입된 친구가 있는 경우")
                    let friends = response.arrayValue
                    
                    for friend in friends{
                        
                        let idx = friend["idx"].intValue
                        let nickname = friend["nickname"].stringValue
                        let profile_img = friend["profile_photo_path"].stringValue
                        let phone_number = friend["phone_number"].stringValue
                        
                        self.enrolled_friends_model.append(EnrolledFriendsModel(idx: idx, nickname: nickname, profile_photo_path: profile_img, phone_number: phone_number, sent_rquest: false))
                    }
                    print("최종 저장한 등록된 친구들 모델: \(self.enrolled_friends_model)")
                }
                //내 주소록에 등록된 연락처 친구 리스트 가져오기
                self.fetchContacts()
            })
    }
    
    @Published var contacts_model : [FetchedContactModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //연락처가져오기
    func fetchContacts() {
                
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("주소록 권한 요청에 실패", error)
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        print("핸드폰 번호: \(contact.phoneNumbers.first?.value.stringValue ?? "")")
                        print("이름: \(contact.familyName)\(contact.givenName)")
                        
                        let my_friend_phone = contact.phoneNumbers.first?.value.stringValue.replacingOccurrences(of: "-", with: "")
                        print("형식 통일한 전화번호: \(String(describing: my_friend_phone))")
                        
                        let my_idx = UserDefaults.standard.string(forKey: "user_id")!
                        
                        //이미 초대 문자 보낸 친구 저장된 값 꺼내오기
                        let sent_invite_friends = UserDefaults.standard.array(forKey: "\(my_idx)_invited_friends") as? [String] ?? []
                  
                        //주소록에 등록된 정보중 전화번호가 없는 경우도 있음.
                        if my_friend_phone != nil{
                            print("쉐어드에 저장됐던 연락처: \(sent_invite_friends), 비교하는 전화번호: \(my_friend_phone!)")
                            //이미 초대 문자 보낸 친구 : sent invite msg값 true
                            if sent_invite_friends.contains(where: {
                                                                print("값 확이니ㅣㅣ: \($0)")
                                                              return  $0 == my_friend_phone!}){
                                
                                print("전화번호 포함하고 있음: \(my_friend_phone!)")

                                self.contacts_model.append(FetchedContactModel(firstName: contact.givenName, lastName: contact.familyName, telephone: my_friend_phone ?? "", profile_photo_path: "", sent_invite_msg: true))
                                print("데이터 바꼈는지: \(self.contacts_model)")
                                
                            }else{
                            
                            self.contacts_model.append(FetchedContactModel(firstName: contact.givenName, lastName: contact.familyName, telephone: my_friend_phone ?? "", profile_photo_path: "", sent_invite_msg: false))
                            }
                        }
                        
                        for enrolled_friend in self.enrolled_friends_model{
                            print("비교하는 친구 한 명: \(enrolled_friend.phone_number)")
                            
                            if my_friend_phone ?? "" == enrolled_friend.phone_number{
                                print("같은 전화번호")
                                self.contacts_model.removeAll(where: {$0.telephone == enrolled_friend.phone_number})
                            }
                        }
                    })
                    print("최종으로 분류한 모델 - 1. 새로 초대해야하는 친구 리스트 or 초대 문자 보낸 친구들 \(self.contacts_model)")
                    print("2.친구 요청할 수 있는 친구 리스트: \(self.enrolled_friends_model)")
                    
                } catch let error {
                    print("전화번호 가져오는데 실패", error)
                }
            } else {
                print("접근 거부됨.")
            }
        }
    }
    
    //회원가입시 친구들에게 초대 문자 보내기
    func send_invite_message(contacts: Array<String>){
        cancellation = APIClient.send_invite_message(contacts: contacts)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("회원가입시 친구들에게 초대 문자 보내기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue:{response in
                print("친구들에게 초대 문자 보내기 response: \(response)")
                
                let result = response["result"].string
                if result == "message sended"{
                    print("메세지 보내짐")
                    //userdefaults에서 저장된 데이터 꺼내오기 -> 다시 저장하기
                    let my_idx = UserDefaults.standard.string(forKey: "user_id")
                    let sent_addresses = UserDefaults.standard.array(forKey: "\(String(describing: my_idx))_invited_addresses") as? [String] ?? [String]()
                    var updated_data : [String] = []
                                
                    updated_data = sent_addresses
                    //한 번에 한사람에게만 초대 문자 보내기 가능하므로 0번째 값만 가져와서 저장하면 됨.
                    updated_data.append(contacts[0])
                    //새로 보낸 번호
                    UserDefaults.standard.set(updated_data,forKey: "\(String(describing: my_idx))_invited_addresses")
                    
                    //전화번호도 노티에 보내야 받아서 비교해서 뷰 변경 가능.
                    let contact = contacts[0] as! String
                    NotificationCenter.default.post(name: Notification.sent_invite_msg, object: nil, userInfo: ["sent_invite_msg": "ok", "contact": contact])
                    
                }else if result == "message send error"{
                    print("메세지 보내는데 에러 발생")
                    //전화번호도 노티에 보내야 받아서 비교해서 뷰 변경 가능.
                    let contact = contacts[0] as! String
                    
                    NotificationCenter.default.post(name: Notification.sent_invite_msg, object: nil, userInfo: ["sent_invite_msg": "fail", "contact": contact])
                    
                }else{
                    //전화번호도 노티에 보내야 받아서 비교해서 뷰 변경 가능.
                    let contact = contacts[0] as! String
                    
                    NotificationCenter.default.post(name: Notification.sent_invite_msg, object: nil, userInfo: ["sent_invite_msg": "fail", "contact": contact])
                    
                }
            })
    }
    
    //친구 신청하기
    func add_friend_request(f_idx: Int){
        cancellation = APIClient.add_friend_request(f_idx: f_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구관리 친구 요청 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구관리 친구 요청 통신 response: \(response)")
                let friend_idx = String(f_idx)
                if response["result"] == "ok"{
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "ok", "friend": friend_idx])
                    
                } else if response["result"]  == "no signed friends"{
                    print("친구관리 친구추가하기 없는 사용자")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "no signed friends", "friend": friend_idx])
                    
                }else if response["result"]  == "친구요청대기"{
                    print("친구관리 친구 요청 대기중")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "친구요청대기", "friend": friend_idx])
                    
                }else if response["result"]  == "친구요청뱓음"{
                    print("친구관리 친구 요청 대기중")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "친구요청뱓음", "friend": friend_idx])
                    
                }else if response["result"]  == "친구상태"{
                    print("친구관리 이미 친구입니다")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "친구상태", "friend": friend_idx])
                    
                }else if response["result"]  == "자기자신"{
                    print("친구관리 나자신")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "자기자신", "friend": friend_idx])
                    
                    
                }else{
                    print("친구관리 친구 요청 실패")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "fail"])
                }
                
            })
    }
    
    //친구 신청 취소
    func cancel_request_friend(f_idx: Int){
        cancellation = APIClient.cancel_request_friend(f_idx: f_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("회원가입 친구 요청 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구 신청 취소 응답: \(response)")
                
                let result : String?
                result = response["result"].string
                let friend_idx = String(f_idx)
                
                if result == "ok"{
                    print("친구 신청 취소 완료")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "canceled_ok", "friend": friend_idx])
                    
                }else{
                    print("친구 신청 취소 실패")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_manage": "canceled_fail", "friend": friend_idx])
                    
                }
            })
    }
}

