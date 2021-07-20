//
//  login_viewmodel.swift
//  proco
//
//  Created by 이은호 on 2020/11/15.
//

import Foundation
import Combine
import Alamofire
import SwiftUI


//카카오 로그인인지, 회원가입 단계인지 구분해야함.
enum Kakao_step{
    case login, join
}

class login_viewmodel: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    private let mode: Mode
    @Published var email_value = ""
    @Published var password_value = ""
    @Published var nickname_value = ""
    @Published var phone_number_value = ""
    @Published var auth_number_value = ""
    @Published var card_tag_value = ""
    @Published var is_valid = false
    @Published var group_name_value =  ""
    @Published var location_value =  ""

    init(mode: Mode){
        self.mode = mode
    }
    //kakao로그인 완료 후 ui에서 화면 이동시키는데 사용.
    @Published var kakao_enter_end : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    @Published var kakao_enter_result : Kakao_step = .login{
        didSet{
            print("카카오 로그인 kakao enter result didset")
            objectWillChange.send()
        }
    }
    func send_kakao_result_func(_ active: Kakao_step) -> Void{
        DispatchQueue.main.async {
            self.kakao_enter_result = active
            self.kakao_enter_end = true

        }
    }
    
    //카카오로그인 - 1차
    func send_kakao_login(kakao_access_token: String, device: String){
        cancellation = APIClient.send_kakao_login(kakao_access_token: kakao_access_token, device: device)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카카오로그인 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                
                print("카카오로그인 resopnse: \(response)")
                let result = response["result"].stringValue
                if result == "kakao_confirm_ok"{
                    print("카카오로 회원가입 1차 성공")
                    self.kakao_enter_result = .join
                    
                }else if result == "kakao_login_ok"{
                    print("카카오로 로그인하기 성공")
                    
                    let access_token = response["access_token"].stringValue
                    let refresh_token = response["refresh_token"].stringValue
                    let idx = response["idx"].intValue
                    let nickname = response["nickname"].stringValue
                    let profile_photo_path = response["profile_photo_path"].stringValue
                    
                    //user defaults
                    UserDefaults.standard.set(access_token, forKey: "access_token")
                    UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                    UserDefaults.standard.set(idx, forKey: "user_id")
                    UserDefaults.standard.set(nickname, forKey: "nickname")
                    UserDefaults.standard.set(profile_photo_path, forKey: "profile_photo_path")
                    self.kakao_enter_result = .login

                }else{
                    print("카카오로 로그인하기 실패")

                }
           
            })
    }
    
}

extension login_viewmodel{
    enum Mode {
        case login
        case signup
        case find_info
        case nickname
        case change_password
        case phone_auth
        case card_tag
        case add_group
        case location
        
        
    }
}
