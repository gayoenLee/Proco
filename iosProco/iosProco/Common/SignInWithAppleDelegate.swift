//
//  SignInWithAppleDelegate.swift
//  proco
//
//  Created by 이은호 on 2021/03/28.
// 사용자가 애플 로그인을 탭한 후에 실행하는 코드를 구현하는 곳.

import Foundation
import SwiftUI
import AuthenticationServices
import Alamofire
import Combine

class SignInWithAppleDelegate: NSObject{
    var cancellation : AnyCancellable?


  private let signInSucceeded: (Bool) -> Void
    
   private let fcm_token = UserDefaults.standard.string(forKey: "fcm_token")!
    
    
  init(onSignedIn: @escaping (Bool) -> Void) {
    signInSucceeded = onSignedIn
  }
}

extension SignInWithAppleDelegate: ASAuthorizationControllerDelegate {
    
    //로그인 성공시 호출됨.
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    //credential을 검사해서 애플 id또는 저장된 icloud암호를 통해 사용자가 인증되었는지 결정한다고 함.
    switch authorization.credential {
    case let appleIdCredential as ASAuthorizationAppleIDCredential:
     //전달받은 authorization에는 이메일, 이름과 같은 요청한 모든 프로퍼티가 담겨 있으므로 그 값이 존재하는지로 첫 로그인인지 여부 확인...재로그인시에는 정보를 애플에서 안주기 때문.
        if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
        print("111111 ================= 첫 로그인")
        displayLog(credential: appleIdCredential)
            
            /*
             세부 사항을 받았으므로 새로운 등록 -> 등록 메소드 호출
             */
            
            let userIdentifier = appleIdCredential.user
            UserDefaults.standard.set(userIdentifier, forKey: "apple_user_identifier")

            let given_name = appleIdCredential.fullName!.givenName
            let family_name = appleIdCredential.fullName!.familyName

            let name_info = family_name! + given_name!

            UserDefaults.standard.set(name_info, forKey: "apple_user_name")
            
            let email = appleIdCredential.email!
            UserDefaults.standard.set(email, forKey: "apple_email")

           let authorizationCode = appleIdCredential.authorizationCode

            let identityToken = appleIdCredential.identityToken
            
            let authString = String(data: authorizationCode!, encoding: .utf8)
            UserDefaults.standard.set(authString, forKey: "apple_auth")
            print("auth string저장한 것 확인: \(authString)")
            let tokenString = String(data: identityToken!, encoding: .utf8)
            UserDefaults.standard.set(tokenString, forKey: "apple_identityToken")
            
            print("authorizationCode: \(String(describing: authorizationCode))")
            print("identityToken: \(String(describing: identityToken))")
            print("authString: \(String(describing: authString))")
            print("tokenString: \(String(describing: tokenString))")
            
            //회원가입 전 서버에 데이터 전송.
            send_apple_login(identity_token: tokenString!, authorization_code: authString!, device: "IOS")
            
      } else {
        print("222222 ================== 로그인 했었음")
        displayLog(credential: appleIdCredential)
        
        let fullName = UserDefaults.standard.string(forKey: "apple_user_name")
        
        let email = UserDefaults.standard.string(forKey: "apple_email")
        
        let authString = UserDefaults.standard.string(forKey: "apple_auth")!
        let tokenString = UserDefaults.standard.string(forKey: "apple_identityToken")
        /*
         세부 사항 받지 않은 경우 -> 기존 계정 메소드 호출.
         */
        
        //회원가입 전 서버에 데이터 전송.
        send_apple_login(identity_token: tokenString!, authorization_code: authString, device: "IOS")
        
      }
      signInSucceeded(true)
      
    default:
      break
    }
  }

    //로그인 에러 처리하는 것.
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {}

    
    //애플로그인 - 1차
    func send_apple_login(identity_token : String, authorization_code: String, device: String){
        
        cancellation = APIClient.send_apple_login(identity_token: identity_token,authorization_code: authorization_code, device: device)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("애플로그인 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("애플로그인 response: \(response)")
                let result_first = response["result"].dictionary
                print("result_first: \(result_first)")
                let result = result_first!["result"]?.stringValue
                print("result: \(result)")

                //회원가입 전 애플로그인에서 우선 success한 경우 -> 약관 동의 화면으로 보내기
                if result == "apple_confirm_ok"{
                    print("애플계정으로 회원가입 성공")
                    
                    //받은 토큰 저장.
                    let refresh_token = response["refresh_token"].stringValue
                    UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                    
                //기존 애플 계정으로 로그인에 성공한 경우 -> main으로 보내기
                }else if result == "apple_login_ok"{
                    print("애플계정으로 로그인 성공")

                    
                    
                //그 외 경우는 에러
                }else{
                 print("애플계정으로 로그인 에러")
                    
                }
            })
    }
    
  private func displayLog(credential: ASAuthorizationAppleIDCredential) {
    print("identityToken: \(String(describing: credential.identityToken))\nauthorizationCode: \(credential.authorizationCode!)\nuser: \(credential.user)\nemail: \(String(describing: credential.email))\ncredential: \(credential)")
  }
}

extension SignInWithAppleDelegate: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return UIApplication.shared.windows.last!
  }
}

extension SignInWithAppleDelegate{
    private func register_new_user(credential: ASAuthorizationAppleIDCredential){
        
    }
    
    private func sign_in_existing_user(credential: ASAuthorizationAppleIDCredential){
        
    }
    
    
    
}
