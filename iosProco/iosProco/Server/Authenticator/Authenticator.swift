//
//  Authenticator.swift
//  proco
//
//  Created by 이은호 on 2020/12/10.
// 액세스 토큰을 retrieving(검색, 구해 내다, 되찾다, 정보를 끌어내다), refreshing하는 프로토콜.

import Foundation
import Alamofire

//token handler안에 리프레시 토큰 저장돼 있음.
protocol Authenticator: class, TokenHandler {
  func update_token(completion: @escaping (_ isSuccess: Bool) -> Void)
}

// MARK: - Token Refresher
//액세스 토큰이 만료된 경우 리프레시 토큰을 보내 새로운 액세스 토큰을 받아와 저장한다.
extension Authenticator {
    
  func update_token(completion: @escaping (_ isSuccess: Bool) -> Void) {
    guard let access_token = TokenHandler.shared.get_access_token(),
    let refresh_token = TokenHandler.shared.get_refresh_token() else{return}
    print("authenticator클래스에서 받은 access 토큰 : \(access_token)")
    print("authenticator클래스에서 받은 refresh 토큰 : \(refresh_token)")

    AF.request(APIRouter.access_token(access_token: access_token))
      .validate()
        //************보내는 데이터인지 받는 데이터인지 확인
        .responseDecodable(of: AuthenticationData.self){[weak self] response in
            guard let self = self, let response = response.value else {
                return completion(false)
            }
            //받은 토큰 저장
            self.set_tokens(access_token: response.access_token, refresh_token: response.refresh_token ?? "")
            print("authenticator클래스에서 받은 토큰 저장함.")
            completion(true)
    }
  }
}

// MARK: - Error Code Checker
extension Int {
  func isAuthenticationErrorCode() -> Bool {
    [401, 403].contains(self)
  }
}
