//
//  TokenHandler.swift
//  proco
//
//  Created by 이은호 on 2020/12/10.
//

import Foundation
import Combine

class TokenHandler{
    
    enum TokenKeys : String {
        case access_token
        case refresh_token
    }
    static let shared: TokenHandler = {
        print("토큰 핸들러의 shared")
        return TokenHandler()
    }()
}

extension TokenHandler{
    func get_access_token() -> String? {
        print("토큰 핸들러의 액세스 토큰 가져오는 메소드 실행, 토큰 값 확인 : \(String(describing: UserDefaults.standard.string(forKey: "access_token")))")
        return UserDefaults.standard.string(forKey: "access_token")
    }
    func get_refresh_token() -> String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    func set_tokens(access_token: String, refresh_token: String) {
        UserDefaults.standard.set(access_token, forKey: "access_token")
        UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
    }
}

extension TokenHandler {
    var accessToken: String? {
        UserDefaults.standard.string(forKey: "access_token")
    }
}
