//
//  SignupUserSetting.swift
//  proco
//
//  Created by 이은호 on 2020/12/03.
//

import Foundation
import Combine
import Alamofire
import Contacts

enum AlertMessage{
    case success, fail, already
}

class SignupViewModel : ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    var cancellation : AnyCancellable?
    
    //인증 요청 버튼 클릭 후 알림창 띄우는데 사용.
    @Published var request_result_alert :AlertMessage  = .success{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var show_result_alert : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    func request_result_alert_func(_ active: AlertMessage) -> Void {
        DispatchQueue.main.async {
            self.request_result_alert = active
            self.show_result_alert = true
        }
    }
    
    
    //회원가입시 작성하는 정보들 마지막에 넘겨주기 위해 이곳에 저장해 놓기
    @Published var marketing_term_ok : Int = 0
    @Published var phone_number : String = ""{
        willSet {
            objectWillChange.send()
        }
    }
    @Published var confirmed_phone : String = ""
    @Published var auth_num: String = ""
    
    @Published var phone_auth_ok: Bool = false
    @Published var email: String = ""{
        willSet {
            objectWillChange.send()
        }
    }
    //비밀번호 경고 문구 나타내기 위해 비교용 변수들
    @Published var password: String = ""{
        willSet {
            objectWillChange.send()
        }
    }
    @Published var password_again : String = ""{
        willSet {
            objectWillChange.send()
        }
    }
    @Published var confirmed_password : String = ""
    
    //비밀번호 두번 입력시 두개가 같은지 확인하기 위함
    @Published var password_valid = false{
        willSet {
            objectWillChange.send()
        }
    }
    //비밀번호 불일치시 보여주는 메시지
    @Published var password_message = ""{
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var gender: Int = 0
    @Published var birth: Date = Date()
    @Published var birth_string: String = ""
    
    @Published var nickname: String = ""{
        willSet {
            objectWillChange.send()
        }
    }
    
    //비밀번호, 이메일 모두 맞게 입력 했는지 구분 변수
    @Published var email_password_valid = false
    private var cancellable_set: Set<AnyCancellable> = []
    
    
    //핸드폰 번호 정규식 체크 메소드
    func is_valid_phone_number(phone_number: String) -> Bool{
        
        let regular_expression_phone = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        let testPhone = NSPredicate(format:"SELF MATCHES %@", regular_expression_phone)
        let phone_number_check_result = testPhone.evaluate(with: self)
        print("핸드폰 번호 정규식 체크 안: \(phone_number_check_result)")
        return phone_number_check_result
    }
    
    //회원가입시 핸드폰 번호 체크
    func validator_phonenumber(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let phone_format = "^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$"
        let phone_predicate = NSPredicate(format:"SELF MATCHES %@", phone_format)
        return phone_predicate.evaluate(with: string)
    }
    
    //회원가입시 이메일 체크
    func validator_email(_ myemail: String) -> Bool {
        if myemail.count > 100 {
            return false
        }
        //영어 대소문자 , 특수문자 모두 가능, @가 무조건 있어야 함, @뒤에는 대문자, 소문자, 숫자만 됨.2~64글자만 허용
        let email_format = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let email_predicate = NSPredicate(format: "SELF MATCHES %@", email_format)
        return email_predicate.evaluate(with: myemail)
    }
    
    //비밀번호 확인용 체크
    func validator_password(_ mypassword: String) -> Bool {
        if mypassword.count > 100 {
            return false
        }
        //비밀번호(숫자, 문자, 특수문자 모두 포함 8-18자)
        let passsword_format = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let password_predicate = NSPredicate(format: "SELF MATCHES %@", passsword_format)
        return password_predicate.evaluate(with: mypassword)
    }
    //이메일이 valid한가를 알기 위한 publisher
    private var email_is_valid_publisher: AnyPublisher<Bool, Never>{
        $email
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map{input in
                return input.count >= 2
            }
            .eraseToAnyPublisher()
    }
    //비밀번호가 일치하는지 여부를 알기 위한 publisher
    private var password_is_equal_publisher: AnyPublisher<Bool, Never>{
        Publishers.CombineLatest($password, $password_again)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map{password, password_again in
                return password == password_again
            }
            .eraseToAnyPublisher()
    }
    //비밀번호를 입력하지 않았을 경우를 알기 위한 publisher
    private var password_is_empty_publisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
                return password == ""
            }
            .eraseToAnyPublisher()
    }
    //비밀번호 일치 여부 확인 위한 enum
    enum  password_check {
        case valid
        case empty
        case no_match
    }
    //비밀번호 입력칸이 빈칸이 아니고, 비밀번호 입력이 일치했을 경우 valid
    private var password_is_valid_publisher: AnyPublisher<password_check, Never>{
        Publishers.CombineLatest(password_is_equal_publisher, password_is_empty_publisher )
            .map{ password_is_equal, password_is_empty in
                if password_is_empty{
                    return .empty
                }
                if(!password_is_equal){
                    return .no_match
                }
                
                else{
                    return .valid
                }
            }
            .eraseToAnyPublisher()
    }
    //이메일, 비밀번호 모두 맞게 입력했을 때
    private var form_is_valid_publisher:AnyPublisher<Bool, Never>{
        Publishers.CombineLatest(email_is_valid_publisher, password_is_valid_publisher)
            .map{ email_is_valid, password_is_valid in
                //return email_is_valid && (password_is_valid == .valid)
                return true && (password_is_valid == .valid)
            }
            .eraseToAnyPublisher()
    }
    
    init(){
        password_is_valid_publisher
            .receive(on: RunLoop.main)
            .map{ check -> String in
                switch check{
                case .empty:
                    return "비밀번호를 입력해주세요"
                case .no_match:
                    return "비밀번호가 일치하지 않습니다"
                default:
                    return ""
                }
                
            }
            .assign(to: \.password_message, on: self)
            .store(in: &cancellable_set)
        
        form_is_valid_publisher
            .receive(on: RunLoop.main)
            .assign(to: \.email_password_valid, on: self)
            .store(in: &cancellable_set)
    }
    /*
     애플 로그인 response를 받고 저장 한 후 메인 화면으로 이동시키기 위해 사용하는 구분값.
     이렇게 해야 user idx를 사용하는 곳에서 nil에러 발생 x
     */
    @Published var apple_join_end : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var kakao_join_end : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //apple 로그인에서 약관 동의 정보 + 부가 정보 보내는 것
    func join_member_end_apple(identity_token : String, fcm_token : String, device: String, phone: String, email: String, profile_url: String, gender: Int, nickname: String, marketing_yn: Int, latest_device: String, update_version: String){
        cancellation = APIClient.join_member_apple_end(identity_token: identity_token, fcm_token: fcm_token, device: "IOS", phone: phone, email: email, profile_url: profile_url, gender: gender, nickname: nickname, marketing_yn: marketing_yn, latest_device: latest_device, update_version: update_version)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("apple 로그인 회원가입 완료 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("애플 로그인 -> 회원가입 완료 response: \(response)")
                let result = response["result"].string
                
                if result == "signup_done"{
                    
                    let access_token = response["access_token"].stringValue
                    let refresh_token = response["refresh_token"].stringValue
                    let idx = response["idx"].intValue
                    let nickname = response["nickname"].stringValue
                    let profile_photo_path = response["profile_photo_path"].stringValue
                    
                    UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                    UserDefaults.standard.set(access_token, forKey: "access_token")
                    UserDefaults.standard.set(idx, forKey: "user_id")
                    UserDefaults.standard.set(nickname, forKey: "nickname")
                    
                    self.apple_join_end.toggle()
                }else{
                    
                }
            })
        
    }
    
    //카카오 로그인
    func join_member_kakao_end(kakao_access_token: String, fcm_token: String, device: String,phone: String, email: String, profile_url: String, gender: Int, nickname: String, marketing_yn: Int, latest_device: String, update_version: String){
        cancellation = APIClient.join_member_kakao_end(kakao_access_token: kakao_access_token, fcm_token: fcm_token, device: "IOS", phone: phone, email: email, profile_url: profile_url, gender: gender, nickname: nickname, marketing_yn: marketing_yn, latest_device: latest_device, update_version: update_version)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카카오 로그인 회원가입 완료 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("카카오 로그인 -> 회원가입 완료 response: \(response)")
                let result = response["result"].string
                
                if result == "signup_done"{
                    print("회원가입 완료")
                    let access_token = response["access_token"].stringValue
                    let refresh_token = response["refresh_token"].stringValue
                    let idx = response["idx"].intValue
                    let nickname = response["nickname"].stringValue
                    let profile_photo_path = response["profile_photo_path"].stringValue
                    
                    UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                    UserDefaults.standard.set(access_token, forKey: "access_token")
                    UserDefaults.standard.set(idx, forKey: "user_id")
                    UserDefaults.standard.set(nickname, forKey: "\(idx)_nickname")
                    
                    self.kakao_join_end.toggle()
                }else{
                    print("카카오 회원가입 오류")
                }
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
                        
                        //주소록에 등록된 정보중 전화번호가 없는 경우도 있음.
                        if my_friend_phone != nil{
                            self.contacts_model.append(FetchedContactModel(firstName: contact.givenName, lastName: contact.familyName, telephone: my_friend_phone ?? "", profile_photo_path: ""))
                        }
                        
                        for enrolled_friend in self.enrolled_friends_model{
                            print("비교하는 친구 한 명: \(enrolled_friend.phone_number)")
                            
                            if my_friend_phone! == enrolled_friend.phone_number{
                                print("같은 전화번호")
                                self.contacts_model.removeLast()
                            }
                        }
                    })
                    
                    //서버에서 가져온 친구 리스트, 내 주소록 기반 연락처 리스트 비교해서 서버에서 가져온 리스트에 포함이 안된 경우 -> contacts_model에 넣기.
                    
                } catch let error {
                    print("전화번호 가져오는데 실패", error)
                }
            } else {
                print("접근 거부됨.")
            }
        }
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
                        
                        self.enrolled_friends_model.append(EnrolledFriendsModel(idx: idx, nickname: nickname, profile_photo_path: profile_img, phone_number: phone_number))
                    }
                    print("최종 저장한 등록된 친구들 모델: \(self.enrolled_friends_model)")
                }
                //내 주소록에 등록된 연락처 친구 리스트 가져오기
                self.fetchContacts()
            })
    }
    
    //회원가입시 친구들에게 초대 문자 보내기
    func send_invite_message(contacts: Array<Any>){
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
                    print("회원가입 친구 요청 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
               print("회원가입 친구 요청 통신 response: \(response)")
                  let friend_idx = String(f_idx)
                if response["result"] == "ok"{
                   
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "ok", "friend": friend_idx])
                    
                } else if response["result"]  == "no signed friends"{
                    print("회원가입 친구추가하기 없는 사용자")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "no signed friends", "friend": friend_idx])
                    
                }else if response["result"]  == "친구요청대기"{
                    print("회원가입 친구 요청 대기중")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "친구요청대기", "friend": friend_idx])
                    
                }else if response["result"]  == "친구요청뱓음"{
                    print("회원가입 친구 요청 대기중")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "친구요청뱓음", "friend": friend_idx])
                    
                }else if response["result"]  == "친구상태"{
                    print("회원가입 이미 친구입니다")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "친구상태", "friend": friend_idx])
                    
                }else if response["result"]  == "자기자신"{
                    print("회원가입 나자신")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "자기자신", "friend": friend_idx])
                    
                    
                }else{
                    print("회원가입 친구 요청 실패")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "fail"])
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
                   
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "canceled_ok", "friend": friend_idx])
                    
                }else{
                    print("친구 신청 취소 실패")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "canceled_fail", "friend": friend_idx])
                    
                }
            })
    }

    
    
}

