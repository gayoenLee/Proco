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
    case success, fail, already_sended, already_exist_user
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
    
    //아이디, 비밀번호 찾기에서 핸드폰 인증시 정규식 체크 했을 때 true인 경우
    @Published var phone_is_valid : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //회원가입시 작성하는 정보들 마지막에 넘겨주기 위해 이곳에 저장해 놓기
    @Published var marketing_term_ok : Int = 0
    @Published var phone_number : String = ""{
        didSet {
            phone_is_valid = validator_phonenumber(phone_number)
            objectWillChange.send()
        }
    }
    
    //인증번호 6개 제한
    let authnum_limit = 6
    @Published var auth_num: String = ""{
        didSet{
            if auth_num.count > authnum_limit && oldValue.count <= authnum_limit {
                auth_num = oldValue
            }
            objectWillChange.send()
        }
    }
    
    //첫번째 비밀번호가 정규식에 맞는지
    @Published var first_pwd_ok: Bool = false
    //두번째 비밀번호가 정규식에 맞는지
    @Published var second_pwd_ok: Bool = false
    
    @Published var phone_auth_ok: Bool = false
    
    @Published var password: String = ""
    
    @Published var change_pwd : String = ""{
        didSet{
            objectWillChange.send()
            self.first_pwd_ok = self.validator_password(change_pwd)
        }
    }
    @Published var change_pwd_again : String = ""{
        didSet {
            objectWillChange.send()
            self.second_pwd_ok = self.validator_password(change_pwd_again)
        }
    }
    
    //    @Published var confirmed_password : String = ""
    //
    //비밀번호 두번 입력시 두개가 같은지 확인하기 위함
    @Published var password_valid = false{
        didSet {
            objectWillChange.send()
        }
    }
    //비밀번호 불일치시 보여주는 메시지
    @Published var password_message = ""{
        didSet {
            objectWillChange.send()
        }
    }
    
    
    @Published var nickname: String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    
    //비밀번호, 이메일 모두 맞게 입력 했는지 구분 변수
    @Published var email_password_valid = false
    private var cancellable_set: Set<AnyCancellable> = []
    
    //회원가입시 핸드폰 번호 체크
    func validator_phonenumber(_ string: String) -> Bool {
        if string.count > 100 {
            return false
        }
        let phone_predicate = NSPredicate(format:"SELF MATCHES %@", Settings.regex.phone)
        return phone_predicate.evaluate(with: string)
    }
    
    //회원가입시 이메일 체크
    func validator_email(_ myemail: String) -> Bool {
        if myemail.count > 100 {
            return false
        }
        //영어 대소문자 , 특수문자 모두 가능, @가 무조건 있어야 함, @뒤에는 대문자, 소문자, 숫자만 됨.2~64글자만 허용
        let email_predicate = NSPredicate(format: "SELF MATCHES %@", Settings.regex.email)
        return email_predicate.evaluate(with: myemail)
    }
    
    //비밀번호 확인용 체크
    func validator_password(_ mypassword: String) -> Bool {
        if mypassword.count > 100 {
            return false
        }
        //비밀번호(숫자, 문자, 특수문자 모두 포함 8-20자)
        
        let password_predicate = NSPredicate(format: "SELF MATCHES %@", Settings.regex.password)
        return password_predicate.evaluate(with: mypassword)
    }
    //이메일이 valid한가를 알기 위한 publisher
    //    private var email_is_valid_publisher: AnyPublisher<Bool, Never>{
    //        $email
    //            .debounce(for: 0.8, scheduler: RunLoop.main)
    //            .removeDuplicates()
    //            .map{input in
    //                return input.count >= 2
    //            }
    //            .eraseToAnyPublisher()
    //    }
    //비밀번호가 일치하는지 여부를 알기 위한 publisher
    private var password_is_equal_publisher: AnyPublisher<Bool, Never>{
        Publishers.CombineLatest($change_pwd, $change_pwd_again)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map{change_pwd, change_pwd_again in
                return change_pwd == change_pwd_again
            }
            .eraseToAnyPublisher()
    }
    //비밀번호를 입력하지 않았을 경우를 알기 위한 publisher
    private var password_is_empty_publisher: AnyPublisher<Bool, Never> {
        $change_pwd
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
        case wrong_regex
    }
    
    //첫번째, 두번째 모두 정규식이 맞을 경우 publish true
    private var regex_is_ok_publisher : AnyPublisher<Bool,Never>{
        Publishers.CombineLatest($first_pwd_ok, $second_pwd_ok)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { first_pwd_ok, second_pwd_ok in
                // print("정규식 확인: \(first_pwd_ok), 두번째: \(second_pwd_ok)")
                if first_pwd_ok == true && second_pwd_ok == true
                {return true}
                else {
                    return false
                }
            }
            .eraseToAnyPublisher()
    }
    
    //비밀번호 입력칸이 빈칸이 아니고, 비밀번호 입력이 일치했을 경우 valid
    private var password_is_valid_publisher: AnyPublisher<password_check, Never>{
        Publishers.CombineLatest3(password_is_equal_publisher, password_is_empty_publisher,regex_is_ok_publisher )
            .map{ password_is_equal, password_is_empty, regex_is_ok in
                if password_is_empty{
                    return .empty
                }
                else if(!password_is_equal){
                    return .no_match
                }
                else if !regex_is_ok{
                    return .wrong_regex
                }
                else{
                    return .valid
                }
            }
            .eraseToAnyPublisher()
    }
    //이메일, 비밀번호 모두 맞게 입력했을 때
    //    private var form_is_valid_publisher:AnyPublisher<Bool, Never>{
    //        Publishers.CombineLatest(email_is_valid_publisher, password_is_valid_publisher)
    //            .map{ email_is_valid, password_is_valid in
    //                return true && (password_is_valid == .valid)
    //            }
    //            .eraseToAnyPublisher()
    //    }
    
    init(){
        password_is_valid_publisher
            .receive(on: RunLoop.main)
            .map{ check -> String in
                switch check{
                case .empty:
                    return "비밀번호를 입력해주세요"
                case .no_match:
                    return "비밀번호가 일치하지 않습니다"
                case .wrong_regex :
                    return "숫자, 문자, 특수문자를 포함한 8~20자 형식에 맞춰주세요"
                default:
                    return ""
                }
                
            }
            .assign(to: \.password_message, on: self)
            .store(in: &cancellable_set)
        //
        //        form_is_valid_publisher
        //            .receive(on: RunLoop.main)
        //            .assign(to: \.email_password_valid, on: self)
        //            .store(in: &cancellable_set)
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
                    UserDefaults.standard.set(nickname, forKey: "nickname")
                    UserDefaults.standard.set(profile_photo_path, forKey: "profile_photo_path")
                    self.kakao_join_end.toggle()
                }else{
                    print("카카오 회원가입 오류")
                }
            })
    }
    

    
    
    
}

