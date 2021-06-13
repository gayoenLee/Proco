//
//  CheckValidatorViewModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/23.
//

import Foundation
import Combine
import Alamofire

enum PwdResultAlert{
    case wrong, ok
}

class CheckValidatorViewModel: ObservableObject{
    
    public let objectWillChange = ObservableObjectPublisher()
    private var cancellableSet: Set<AnyCancellable> = []
    var cancellation: AnyCancellable?

    /*
     비번 체크 메소드, 변수 시작
     */
    @Published var current_pwd: String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    //설정 - 비밀번호 재설정 - 새로운 비밀번호 첫번째
    @Published var new_pwd  = ""{
        willSet{
            objectWillChange.send()
            self.second_pwd_ok =  self.validator_password(new_pwd)
        }
        didSet{
            objectWillChange.send()
        }
    }
    
    //설정 - 비밀번호 재설정 - 새로운 비밀번호 확인용
    @Published var new_pwd_again = ""{
                willSet{
                    objectWillChange.send()
                    self.second_pwd_ok =  self.validator_password(new_pwd_again)
                }
        didSet{
            objectWillChange.send()
        }
    }
    //첫번째 비밀번호가 정규식에 맞는지
    @Published var first_pwd_ok: Bool = false
    //두번째 비밀번호가 정규식에 맞는지
    @Published var second_pwd_ok: Bool = false

    @Published var current_pwd_msg = ""{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var passwordMessage = ""{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var isValid : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }

    
    private var current_pwd_is_empty_publisher: AnyPublisher<Bool, Never>{
        $current_pwd
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { password in
              return password == ""
            }
            .eraseToAnyPublisher()
    }
    
    //비밀번호 체크
    //1.두 비밀번호가 일치
    //2.비밀번호 형식에 맞아야 함. -> didset에서 확인
    //3.모두 입력했는지
    //비밀번호 일치 여부 확인 위한 enum
    enum  password_check {
        case valid
        case empty
        case no_match
    }
    
    //2번 비밀번호 정규식 체크
    func validator_password(_ mypassword: String) -> Bool {
        if mypassword.count > 100 {
            return false
        }
        //비밀번호(숫자, 문자, 특수문자 모두 포함 8-18자)
        let passsword_format = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let password_predicate = NSPredicate(format: "SELF MATCHES %@", passsword_format)
        return password_predicate.evaluate(with: mypassword)
    }
    
    //3번. 비밀번호를 입력하지 않았을 경우를 알기 위한 publisher
    private var password_is_empty_publisher: AnyPublisher<Bool, Never> {
        //두번째 입력한 비밀번호만 체크됨.
        $new_pwd
          .debounce(for: 0.8, scheduler: RunLoop.main)
          .removeDuplicates()
          .map { password in
            return password == ""
          }
          .eraseToAnyPublisher()
      }
    
    //1번. 새로운 비밀번호 두 번 입력이 모두 일치하는지 체크
    private var password_is_equal_publisher: AnyPublisher<Bool, Never>{
        Publishers.CombineLatest($new_pwd, $new_pwd_again)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { new_pwd, new_pwd_again in
                print("패스워드 확인: \(new_pwd), 두번째: \(new_pwd_again)")
                return new_pwd == new_pwd_again
            }
            .eraseToAnyPublisher()
    }
    
    
    //위에서 1번, 3번 메소드를 아래에서 통합해서 publish함.
    private var password_is_valid_publisher: AnyPublisher<password_check, Never> {
        Publishers.CombineLatest(password_is_empty_publisher, password_is_equal_publisher )
            .map{ password_is_empty, password_is_equal in
                print("패스워드 같은지 받은 것: \(password_is_equal)")
                if password_is_empty{
                    print("비번이 empty로 나옴.")
                    return .empty
                }
                else if(!password_is_equal){
                    print("비밀번호 틀리다고 나옴.")
                    return .no_match
                }
                else{
                    print("엘스문임")
                    return .valid
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    private var all_is_valid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(current_pwd_is_empty_publisher, password_is_valid_publisher)
            .map { current_pwd_is_empty, new_pwd_is_valid in
                print("all is valid 나옴")
                return !current_pwd_is_empty && (new_pwd_is_valid == .valid)
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        current_pwd_is_empty_publisher
            .receive(on: RunLoop.main)
            .map{ valid in
                print("현재 비밀번호 체크 확인: \(valid)")
               return  valid ? "현재 비밀번호를 입력해주세요" : ""
            }
            .assign(to: \.current_pwd_msg, on: self)
            .store(in: &cancellableSet)
        
        password_is_valid_publisher
            .receive(on: RunLoop.main)
                 .map { passwordCheck in
                   switch passwordCheck {
                   case .empty:
                     return "비밀번호를 입력해주세요"
                   case .no_match:
                     return "비밀번호가 일치하지 않습니다."
                   default:
                     return ""
                   }
                 }
                 .assign(to: \.passwordMessage, on: self)
                 .store(in: &cancellableSet)
        
        all_is_valid
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellableSet)


    }
    //비밀번호 변경 후 알림창 띄우기 위한 변수, 메소드 아래 3개.
    @Published var show_result_alert : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var request_result_alert :PwdResultAlert  = .ok{
        didSet{
            objectWillChange.send()
        }
    }
        
    func request_result_alert_func(_ active: PwdResultAlert) -> Void {
        DispatchQueue.main.async {
            self.request_result_alert = active
            self.show_result_alert = true
        }
    }
    
    
    func setting_change_pwd(current_password: String, new_password: String) { cancellation = APIClient.setting_change_pwd(current_password: current_password, new_password: new_password)
    .receive(on: DispatchQueue.main)
    .sink(receiveCompletion: {result in
        switch result{
        case .failure(let error):
            print("설정-비번 변경 에러 발생 : \(error)")
        case .finished:
            break
        }
        
    }, receiveValue: {response in
        print("설정-비번 변경 response: \(response)")
        let result = response["result"].string
        
        if result == result{
            if result == "ok"{
                print("비밀번호 변경 완료됨.")
                
                self.request_result_alert = .ok
            }else{
                
                print("비밀번호 변경 오류 - : \(String(describing: result))")
                self.request_result_alert = .wrong
            }
        }
    })
    }
}
