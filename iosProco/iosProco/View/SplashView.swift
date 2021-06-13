//
//  SplashView.swift
//  proco
//
//  Created by 이은호 on 2020/12/09.
//

import SwiftUI
import Combine

struct SplashView: View {
    //사용자의 토큰 저장하는 클래스로 토큰 값 가져오기 위해 선언.

    //토큰으로 서버와 통신 후 어디 뷰로 이동할지 결정하기 위해 주는 구분값
    @State private var go_to_login : Bool = false
    @State private var go_to_main : Bool = false
    
    //스플래시 뷰가 스레드로 작동하기 때문에 끝난 것을 알 수 있게 해주는 구분값.
    @State var end_splash_active : Bool = false
    
    //global_state에서 저장된 토큰 값을 가져와서 저장하는 변수
    @State private var refresh_token_value : String? = UserDefaults.standard.string(forKey: "refresh_token")
    @ObservedObject var view_router : ViewRouter
    
    var body: some View {
        VStack{
            //스플래시뷰가 끝난 후 response에 따라 이동하는 뷰를 다르게 설정.
            if self.end_splash_active{
                if go_to_login{
                    
                    LoginMenuView()
                    
                } else if go_to_main{
                    TabbarView(view_router: self.view_router)
                }
                //스플래시 뷰 화면 구성
            }else{
                Image("logo")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width*0.7, height: UIScreen.main.bounds.width*0.3, alignment: .center)
                    .scaledToFit()
                    
            }
            
            //스플래시 화면이 켜있는동안 토큰 만료일 확인할 통신 진행
            //셰어드에서 사용자의 토큰을 가져옴.
        }.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
                withAnimation{
                    self.end_splash_active = true
                    print("가져온 리프레시 토큰 값 확인 : \(String(describing: UserDefaults.standard.string(forKey: "refresh_token")))")
                    
                    //저장된 리프레시 토큰이 없을 경우
                    if UserDefaults.standard.string(forKey: "refresh_token")  == ""{
                        print("저장된 토큰 없음")
                        go_to_login.toggle()
                        
                        //토큰이 있으면 서버로 토큰 전송
                    }else if refresh_token_value != nil {
                        print("저장된 토큰 있음")
                    
                        check_refresh_token()
                    }else{
                        print("저장된 토큰 없는데 그 외 경우")
                        go_to_login.toggle()
                    }
                }
            }
        }
    }
    //서버에 리프레시 토큰 전송
    func check_refresh_token(){
        APIClient.splash_token_api(refresh_token: UserDefaults.standard.string(forKey: "refresh_token") ?? "", completion:{result in
            print("스플래시에서 리프레시 토큰 확인 통신 결과 : \(result)")
            
            //서버로부터 통신 response가 왔을 때
            if result.exists(){
                let result_json = result["result"].string
                print("스플래시 뷰에서 결과값 확인 : \(String(describing: result_json))")
                
                //액세스 토큰이 만료된 경우 다시 발급 후 메인화면으로 이동
                if result_json == "token_renew"{
                    
                    print("토큰 renew")
                    if let result_access = result["access_token"].string{
                        print("액세스토큰 받음")
                        UserDefaults.standard.set(result_access, forKey: "access_token")
                        SockMgr.socket_manager.establish_connection()

                        //토큰이 있으므로 메인화면으로 보내기
                        go_to_main.toggle()
                    }
                    
                    //리프레시 토큰의 기간이 얼마 남지 않았으면 다시 발급 받기
                    //리프레시 토큰과 액세스 토큰을 응답으로 받음
                    else if result_json == "token_refresh"{
                        
                        print("토큰 refresh")
                        if let result_access = result["access_token"].string{
                            UserDefaults.standard.set(result_access, forKey: "access_token")
                            go_to_main.toggle()
                            
                        }
                        if let result_refresh = result["refresh_token"].string{
                            UserDefaults.standard.set(result_refresh, forKey: "refresh_token")
                            go_to_main.toggle()
                            
                        }
                    }
                }else if(result_json == "token expired"){
                    print("토큰 expired ")
                    
                    self.go_to_login.toggle()
                }
                //리프레시 토큰이 만료된 경우 다시 로그인해서 발급 받도록 한다.
                // 일반/카카오/애플 회원인지 파악해 해당 api의 토큰도 확인
                else if result_json == "refresh token expired"{
                    go_to_login.toggle()
                    
                    print("refresh 토큰 expired")
                    let type = result["type"].string
                    if(type == "normal"){
                        
                    }
                    else if(type == "kakao"){
                        // 카카오 토큰 확인 후 재발급 필요
                    }
                    else if(type == "apple"){
                        // 애플 토큰 확인 후 재발급 필요
                    }
                }else{
                    print("토큰 그 외 오류 ")
                    go_to_login.toggle()
                    
                }
                //서버로부터 response도 안왔을 때
            }else{
                print("스플래시 통신 오류")
                go_to_login.toggle()

            }
        })
    }
}


