//
//  SettingViewModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
//

import Foundation
import Combine
import Alamofire
import SwiftUI
import SwiftyJSON

//문의하기 생성 통신 후 알림 주기 위함.(생성, 수정, 삭제)
enum QuestionResultAlert{
    case make, edit, delete, fail
}

//이메일 인증하기 버튼 클릭후 전송했을 때 알림. 인증완료되면 알림
enum VerifyEmailAlert{
    case send, error, already_send, verified
}

class SettingViewModel: ObservableObject{
    
    public let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    private var cancellableSet: Set<AnyCancellable> = []
    
    @Published var my_idx = UserDefaults.standard.string(forKey: "user_id")
    @Published var nickname = UserDefaults.standard.string(forKey: "\(UserDefaults.standard.string(forKey: "user_id")!)_nickname")
    
    //친구 카드 모델
    @Published var friend_card_model : [FriendVollehCardStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //모임 카드 모델
    @Published var group_card_model : [GroupCardStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //관심친구 유저 모델
    @Published var friend_model : [GetFriendListStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //설정창에서 필요한 데이터 모두 가져오는 통신
    @Published var user_info_model : MyPageModel = MyPageModel(){
        didSet{
            objectWillChange.send()
        }
    }
    
    //문의하기 모델
    @Published var question_model : [MyQuestionModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //이메일 인증시 입력값
    @Published var email_value: String = ""
    
    //이메일 인증 요청 후 : sent, 다시 돌아왔을 때 체크 통신이 ok, no auth.
    @Published public var email_sent : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    //문의하기 통신 관련 alert창 띄우는데 사용.
    @Published var show_result_alert : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var request_result_alert :QuestionResultAlert  = .make{
        didSet{
            objectWillChange.send()
        }
    }
        
    func request_result_alert_func(_ active: QuestionResultAlert) -> Void {
        DispatchQueue.main.async {
            self.request_result_alert = active
            self.show_result_alert = true
        }
    }
    
    //이메일 인증 전송버튼 클릭시, 인증 완료 후 알림 위해 사용.
    @Published var show_email_result_alert : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var email_result_alert :VerifyEmailAlert  = .send{
        didSet{
            objectWillChange.send()
        }
    }
        
    func email_result_alert_func(_ active: VerifyEmailAlert) -> Void {
        DispatchQueue.main.async {
            self.email_result_alert = active
            self.show_email_result_alert = true
        }
    }
    
    
    //이메일 체크
    func validator_email(_ myemail: String) -> Bool {
        if myemail.count > 100 {
            return false
        }
        //영어 대소문자 , 특수문자 모두 가능, @가 무조건 있어야 함, @뒤에는 대문자, 소문자, 숫자만 됨.2~64글자만 허용
        let email_format = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let email_predicate = NSPredicate(format: "SELF MATCHES %@", email_format)
        return email_predicate.evaluate(with: myemail)
    }
    
    //이메일이 valid한가를 알기 위한 publisher
    private var email_is_valid_publisher: AnyPublisher<Bool, Never>{
        $email_value
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map{input in
                return input.count >= 2
            }
            .eraseToAnyPublisher()
    }
    //문의하기 생성 후 현재 시간을 일단 넣어줘서 보여준다.
    func make_created_at() -> String{
        let time = Date()
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = date_formatter.string(from: time)
        return date
    }
    
    //문의하기 생성
    func send_question_content(content: String){
        cancellation = APIClient.send_question_content(content: content)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("문의하기 생성 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("문의하기 생성 response:\(response)")
                
                let result = response["result"].string
                if result == result{
                    
                    if result ==  "ok"{
                        //ok일 때, 모델에 idx 저장.
                        let created_at = self.make_created_at()
                        let idx = response["question_idx"].intValue
                        self.question_model.append(MyQuestionModel(idx: idx, content: content, created_at: created_at, updated_at: "", process_content: "", processed_date: ""))
                        
                        self.request_result_alert = .make
                    }else{
                        self.request_result_alert = .fail
                    }
                }
            })
    }
    
    //내 문의내역 가져오기
    func get_my_questions(){
        cancellation = APIClient.get_my_questions()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("내 문의내역 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("내 문의내역 가져오기 response:\(response)")
                //문의 내역 리스트
                let question_list = response.arrayValue
                //response가 있다면이라는 조건.
                if question_list == question_list{
                    print("response가 있을 때")
                    //이렇게 해야 중복 저장 안됨.
                    self.question_model = []
                    for question in question_list{
                        
                        let idx = question["idx"].intValue
                        let content = question["content"].stringValue
                        let created_at = question["created_at"].stringValue
                        //아래 3가지는 답변이 아직 없거나 수정을 안했을 경우는 null로 옴.
                        let updated_at = question["updated_at"].string
                        let process_content = question["process_content"].string
                        let processed_date = question["processed_date"].string
                        //문의내역 모델에 저장.
                        self.question_model.append(MyQuestionModel(idx: idx, content: content, created_at: created_at, updated_at: updated_at ?? "", process_content: process_content ?? "", processed_date: processed_date ?? ""))
                    }
                    print("문의내역 저장한 것 확인: \(self.question_model)")
                }
            })
    }
    
    //문의 수정하기
    func edit_question(question_idx: Int, content: String){
        cancellation = APIClient.edit_question(question_idx: question_idx, content: content)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("내 문의 수정하기 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("문의 수정하기 response: \(response)")
                let result = response["result"].string
                if result == result{
                    if result == "ok"{
                        
                        let index = self.question_model.firstIndex(where: {
                            $0.idx == question_idx
                        })
                        //수정한 내용으로 모델에 다시 저장.
                        self.question_model[index!].content = content
                        //수정 완료 됐음 알림창 띄우기 위해 세팅.
                        self.request_result_alert = .edit
                    }else{
                        //수정 실패했을 때 알림창 셋팅.
                        self.request_result_alert = .fail
                    }
                }else{
                    self.request_result_alert = .fail
                }
            })
    }
    
    //문의 삭제하기
    func delete_question(question_idx: Int){
        cancellation = APIClient.delete_question(question_idx: question_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("내 문의 삭제하기 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("문의 삭제하기 response: \(response)")
                let result = response["result"].string
                if result == result{
                    if result == "ok"{
                        
                        let index = self.question_model.firstIndex(where: {
                            $0.idx == question_idx
                        })
                        //삭제한 문의 모델 업데이트
                        self.question_model.remove(at: index!)
                        
                        //삭제 완료 됐음 알림창 띄우기 위해 세팅.
                        self.request_result_alert = .delete
                    }else{
                        //삭제 실패했을 때 알림창 셋팅.
                        self.request_result_alert = .fail
                    }
                }else{
                    self.request_result_alert = .fail
                }
                
            })
    }
    
    //이메일 인증
    func verify_email(email: String){
        cancellation = APIClient.verify_email(email: email)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("이메일 인증 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("이메일 인증 response: \(response)")
                let result = response["result"].string
               if result == "Message sent"{
                    print("메세지 전송됨.")
                    self.email_result_alert = .send
                //어플 화면으로 돌아왔을 때 인증완료 처리 위함.
                    self.email_sent = "sent"

                }else if result == "already sent email"{
                    print("이미 인증메일 보냄.")
                    self.email_result_alert = .already_send
                    self.email_sent = "sent"

                }else{
                    print("이메일 인증 오류")
                    self.email_result_alert = .error
                }
                
            })
    }
    
    //이메일 확인 후 돌아왔을 때 체크
    func check_verify_email(){
        cancellation = APIClient.check_verify_email()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("이메일 확인 후 체크 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("이메일 확인 후 돌아왔을 때 체크 response: \(response)")
                let result = response["result"].string
               if result == "ok"{
                    print("이메일 인증 완료 확인")
                self.email_result_alert = .verified
                self.email_sent = "ok"


                }else{
                    print("이메일 인증 체크 오류")
                    self.email_sent = "no auth"

                }
                
            })
    }
    
    //회원 탈퇴 통신
    func delete_exit_user(user_idx: Int){
        cancellation = APIClient.delete_exit_user(user_idx: user_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("회원 탈퇴 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("회원 탈퇴 response: \(response)")
                let result = response["result"].string
               if result == "ok"{
                    print("이메일 인증 완료 확인")
                self.email_result_alert = .verified
                self.email_sent = "ok"


                }else{
                    print("이메일 인증 체크 오류")
                    self.email_sent = "no auth"

                }
            })
    }
    
    //마이페이지에서 유저 모든 정보를 가져와야 해서 통신.
    func get_detail_user_info(user_idx: Int){
        cancellation = APIClient.get_detail_user_info(user_idx: user_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("유저 모든 정보 가져오기 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("유저 모든 정보 가져오기 response: \(response)")
                
                let result = response.dictionaryValue
                
                if result["result"] == "no result"{
                    print("결과 없을 때")
                }else{
                
                
                let nickname = result["nickname"]?.stringValue
                let password_modify_at = result["password_modify_at"]?.stringValue
                let card_notify_state = result["card_notify_state"]?.intValue
                let chat_notify_state = result["chat_notify_state"]?.intValue
                let password = result["password"]?.stringValue
                let calendar_public_state = result["calendar_public_state"]?.intValue
                let feed_notify_state = result["feed_notify_state"]?.intValue
                let idx = result["idx"]?.intValue
                let phone_number = result["phone_number"]?.stringValue
                let profile_photo_path = result["profile_photo_path"]?.stringValue
               
                self.user_info_model = MyPageModel(nickname: nickname!, password_modify_at: password_modify_at!, card_notify_state: card_notify_state!, chat_notify_state: chat_notify_state!, password: password!, calendar_public_state: calendar_public_state!, feed_notify_state: feed_notify_state!, idx: idx!, phone_number: phone_number!, profile_photo_path: profile_photo_path ?? "")
                print("최종 저장한 유저 정보 모델: \(self.user_info_model)")
                
                NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["got_user_info" : "ok"])
                }
            })
    }
    
    //마이페이지에서 생년월일 수정시 필요.
    func string_to_date(expiration: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = formatter.date(from: expiration)
        return date!
    }
    
    func date_to_string(date: Date) -> String{
        
        let day = DateFormatter.dateformatter.string(from: date)
        print("date형식: \(date), 변환된 형식: \(day)")
        return day
    }
    
    //설정 - 마이페이지 정보 수정
    func edit_user_info(gender: Int, birthday: String, nickname: String){
        cancellation = APIClient.edit_user_info(gender: gender, birthday: birthday, nickname: nickname)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("마이페이지 정보 수정 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("마이페이지 정보 수정 response: \(response)")
                
                let result : String?
                result = response["result"].string
                if result == "ok"{
                //저장됐던 닉네임 수정한 것으로 다시 저장.
                UserDefaults.standard.set(nickname, forKey: "\(self.my_idx!)_nickname")
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.move_view, object: nil, userInfo: ["nickname_change" : "ok"])
                }else{
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.move_view, object: nil, userInfo: ["nickname_change" : "fail"])
                }
            })
    }
    
    //설정 - 캘린더 공개범위 설정
    func edit_calendar_disclosure_setting(calendar_public_state: Int){
        cancellation = APIClient.edit_calendar_disclosure_setting(calendar_public_state: calendar_public_state)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 공개범위 설정 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("캘린더 공개범위 설정 response: \(response)")
                
                let result = response["result"].stringValue
                if result == "ok"{
                    print("ok")
                    
                    //뒤로가기 시 설정 메인뷰에서 공개범위 텍스트 바꾸도록 설정하기 위해 사용
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["got_user_info" : "ok"])
                    //result ok 아닐 때 처리 필요한지 생각해보기.
                }else{
                    
                }
            })
    }
    
    //채팅알림 설정
    func edit_chat_alarm_setting(chat_notify_state: Int){
        cancellation = APIClient.edit_chat_alarm_setting(chat_notify_state: chat_notify_state)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("채팅알림 설정 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("채팅알림 설정 response: \(response)")
                
                let result = response["result"].stringValue
                if result == "ok"{
                    print("ok")
                    self.user_info_model.chat_notify_state = chat_notify_state
                    
                    if chat_notify_state == 0{
                        NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["alarm_changed" : "chat_alarm", "state" : "false"])
                    }else{
                        NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["alarm_changed" : "chat_alarm", "state" : "true"])
                    }
                //result ok 아닐 때 처리 필요한지 생각해보기.
                }else{
                    
                }
            })
    }
    
    //카드알림 설정
    func edit_card_alarm_setting(card_notify_state: Int){
        cancellation = APIClient.edit_card_alarm_setting(card_notify_state: card_notify_state)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카드알림 설정 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("카드알림 설정 response: \(response)")
                
                let result = response["result"].stringValue
                if result == "ok"{
                    print("ok")
                    
                    self.user_info_model.card_notify_state = card_notify_state
                    
                    if card_notify_state == 0{
                        NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["alarm_changed" : "card_alarm", "state" : "false"])
                    }else{
                        NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["alarm_changed" : "card_alarm", "state" : "true"])
                    }
                //result ok 아닐 때 처리 필요한지 생각해보기.
                }else{
                    
                }
            })
    }
    
    //내 관심친구 리스트 가져오기
    func get_interest_friends(friend_type: String){
        cancellation = APIClient.get_interest_friends(friend_type: "관심친구")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("관심친구 리스트 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("관심친구 리스트 가져오기 response: \(response)")
                
                let result : String? = ""
                if result == "no result"{
                    print("관심친구 없음")
                }else{
                    
                    let data = JSON(response)
                    let json_string = """
                        \(data)
                        """
                    print("관심친구 리스트 리스트 string변환: \(json_string)")
                    
                    let json_data = json_string.data(using: .utf8)
                    
                    let friend = try? JSONDecoder().decode([GetFriendListStruct].self, from: json_data!)
                    
                    self.friend_model = friend!
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
    
    //내가 좋아요한 카드 가져오기
    func get_liked_cards(){
        cancellation = APIClient.get_liked_cards()
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("관심친구 설정 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                
                print("좋아요한 카드 가져오기 response: \(response)")
                let result = response["result"].string
                
                if result == "no result"{
                    print("좋아요한 카드 없음")
                }else{
                    print("좋아요한 카드 있음")
                    let friend_card_array = response["friend"].array
                    print("친구 카드 배열 뽑은 것 확인: \(friend_card_array)")
                    
                    let group_card_array = response["meeting"].array
                    
                    if friend_card_array?.count ?? 0 > 0{
                    print("친구 카드 배열 1개 이상일 때")
                        let friend_card_array = response["friend"].arrayValue
                        let json_string = """
                                \(friend_card_array)
                                """
                        print("친구 카드 string변환")
                        
                        let json_data = json_string.data(using: .utf8)
                        
                        let card = try? JSONDecoder().decode([FriendVollehCardStruct].self, from: json_data!)
                        
                        print("친구랑 볼래 카드 리스트 디코딩한 값: \(String(describing: card))")
                        
                        self.friend_card_model = card!
                    }
                    
                    //모임 카드 저장
                    if group_card_array?.count ?? 0 > 0{
                        print("모임 카드 배열 1개 이상일 때")
                        let group_card_array = response["meeting"].arrayValue
                        let json_string = """
                                \(group_card_array)
                                """
                        print("모임 카드 string변환")

                        let json_data = json_string.data(using: .utf8)

                        let card = try? JSONDecoder().decode([GroupCardStruct].self, from: json_data!)

                        print("모임 카드 리스트 디코딩한 값: \(String(describing: card))")

                        self.group_card_model = card!
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
                        clicked_card =  self.friend_card_model.firstIndex(where: {
                           $0.card_idx == card_idx
                       }) ?? -1
                    if clicked_card != -1{
                       self.friend_card_model[clicked_card!].like_count += 1
                       self.friend_card_model[clicked_card!].like_state = 1
                    }else{
                        clicked_card =  self.friend_card_model.firstIndex(where: {
                           $0.card_idx == card_idx
                       })
                        
                        self.friend_card_model[clicked_card!].like_count += 1
                        self.friend_card_model[clicked_card!].like_state = 1
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
                    clicked_card =  self.friend_card_model.firstIndex(where: {
                           $0.card_idx == card_idx
                       }) ?? -1
                    if clicked_card != -1{
                       self.friend_card_model[clicked_card!].like_count -= 1
                       self.friend_card_model[clicked_card!].like_state = 0
                    }else{
                        clicked_card =  self.friend_card_model.firstIndex(where: {
                           $0.card_idx == card_idx
                       })
                        
                        self.friend_card_model[clicked_card!].like_count -= 1
                        self.friend_card_model[clicked_card!].like_state = 0
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
    
    /*
    친구 카드 리스트 보여줄 때 foreach안에 index이용하기 위해 사용
     */
    func get_index(item: FriendVollehCardStruct )->Int{
        
        return self.friend_card_model.firstIndex { (item1) -> Bool in
            return item.card_idx == item1.card_idx
        } ?? 0
    }
    
    //이미지 파일로 저장하기
    func send_profile_image(image_data : Data){
        APIClient.upload(image: image_data, to: APIRouter.send_profile_image(profile_image: image_data), completion: { result in
            if result.exists(){
                //프로필 이미지는 회원가입시 필수가 아님
                print("이미지 결과 확인 : \(result)")
                let result_string = result["result"].string
                if (result_string == "ok"){
                    
                    self.user_info_model.profile_photo_path = result["profile_photo_path"].stringValue
                    UserDefaults.standard.setValue(self.user_info_model.profile_photo_path, forKey: "\(self.my_idx!)_profile_photo_path")
                    
                }else{
                    print("이미지 변경 안됨")
                    
                }
                }else{
                    print("이미지 변경 통신 리스펀스 없음")

                }
            })
    }
    
    
    func get_group_card_index(item: GroupCardStruct )->Int{
        
        return self.group_card_model.firstIndex { (item1) -> Bool in
            return item.card_idx == item1.card_idx
        } ?? -1
    }
    
}
