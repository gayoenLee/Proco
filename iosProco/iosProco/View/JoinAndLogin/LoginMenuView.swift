//
//  login_menu_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/09.
//

import Foundation
import SwiftUI
import Alamofire
import Combine
//애플로그인
import AuthenticationServices
//카톡 로그인
import KakaoSDKAuth
import KakaoSDKUser

struct LoginMenuView:View{
    
    @State var appleSignInDelegate: SignInWithAppleDelegate! = nil
    @ObservedObject var login_vm  = login_viewmodel(mode: .signup)
    private let fcm_token = UserDefaults.standard.string(forKey: "fcm_token") ?? ""
    //애플로그인 - 1차
    @State private var apple_join_ok = false
    
    //카카오로그인
    @State var kakao_join_ok :Bool = false
    
    @State var kakao_login_ok : Bool = false
    @ObservedObject var view_router : ViewRouter = ViewRouter.get_view_router()
    
    var body: some View{
        
        if self.view_router.init_root_view{
            TabbarView()
        }else{
        NavigationView{
            VStack{
                //서브 타이틀 위의 공백 추가
                VStack{
                    HStack(alignment: .lastTextBaseline){
                        Spacer()
                        //서브 타이틀 왼쪽 공백 추가
                        Text("심심할 땐")
                            .font(.custom(Font.t_regular, size: 20))
                            .foregroundColor(Color.main_orange)
                            .minimumScaleFactor(1)
                        //서브 타이틀 오른쪽 공백 추가
                        Spacer()
                    }
                    HStack{
                        //이미지 왼쪽 공백 추가
                        Spacer()
                        Image("logo")
                            //resizable안하면 이미지가 초록색 배경에 맞춰서 나오지 않고 작게 나옴.
                            .resizable()
                            .frame(width: 221, height: 85, alignment: .center)
                            .scaledToFit()
                        //이미지 오른쪽 공백 추가
                        Spacer()
                    }
                }
                .padding([.top], UIScreen.main.bounds.width*0.4)
                .padding([.bottom], UIScreen.main.bounds.width*0.45)
                Spacer()
                //이미지 아래 공백 추가
                VStack(alignment: .center){
                    
                    NavigationLink(destination: NormalLoginView()){
                        
                        Text("프로코로 로그인하기")
                            .font(.custom(Font.t_extra_bold, size: 15))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.proco_white)
                            .background(Color.orange)
                            .cornerRadius(25)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
                    }
                    .navigationBarTitle("")
                    
                    NavigationLink("", destination: SignupTermsView(apple_login: self.$apple_join_ok, kakao_login: self.$kakao_join_ok), isActive: self.$kakao_join_ok)
                    
                    Button(action: {
                        
                        //로그인 페이지로 이동하는 액션 작성하기
                        print("카카오톡으로 로그인하기")
                        //카카오톡이 깔려 있는지 확인하는 함수
                        if (UserApi.isKakaoTalkLoginAvailable()){
                            //연결 끊는 것
                            //                            UserApi.shared.unlink {(error) in
                            //                                if let error = error {
                            //                                    print(error)
                            //                                }
                            //                                else {
                            //                                    print("unlink() success.")
                            //                                }
                            //                            }
                            
                            //카카오톡이 설치돼 있다면 카카오톡을 통한 로그인 진행
                            UserApi.shared.loginWithKakaoTalk(completion: {
                                (OAuthToken, error) in
                                print("카카오톡이 설치돼 있을 때: \(String(describing: OAuthToken?.accessToken))")
                                let token = String(describing: OAuthToken!.accessToken)
                                
                                
                                UserDefaults.standard.set(token, forKey: "kakao_access_token")
                                
                                UserApi.shared.me() {(user, error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    else {
                                        print("me() success.")
                                        
                                        //유저 정보와 함께 서버에 전송. - 1차
                                        _ = user
                                        print("\(String(describing: user))")
                                        let email = String(describing: user?.kakaoAccount!.email)
                                        let nickname = String(describing: user?.kakaoAccount?.profile!.nickname)
                                        print("이메일: \(String(describing: user?.kakaoAccount?.email))")
                                        
                                        UserDefaults.standard.set(email, forKey: "kakao_email")
                                        UserDefaults.standard.set(nickname, forKey: "kakao_nickname")
                                        login_vm.send_kakao_login(kakao_access_token: token, device: "ios")
                                        
                                        login_vm.send_kakao_result_func(login_vm.kakao_enter_result)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                            print("0.2초 후")
                                            if login_vm.kakao_enter_end{
                                                print("카카오 로그인 결과값 true")
                                                switch login_vm.kakao_enter_result {
                                                case .login:
                                                    print("로그인하는 경우")
                                                    self.kakao_login_ok = true
                                                case .join:
                                                    print("회원가입 과정중인 경우")
                                                    self.kakao_join_ok = true
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            })
                        }else{
                            //카카오톡이 설치돼 있지 않다면 사파리를 통한 로그인 진행.
                            UserApi.shared.loginWithKakaoAccount { (OAuthToken, error) in
                                print("카카오톡이 설치 안돼 있을 때: \(String(describing: OAuthToken?.accessToken))")
                                let token = String(describing: OAuthToken!.accessToken)
                                
                                UserApi.shared.me() {(user, error) in
                                    if let error = error {
                                        print(error)
                                        
                                    }
                                    else {
                                        print("me() success.")
                                        
                                        //유저 정보와 함께 서버에 전송. - 1차
                                        _ = user
                                        print("\(String(describing: user))")
                                        
                                        print("이메일: \(String(describing: user?.kakaoAccount?.email))")
                                        
                                        
                                        print("닉네임: \(String(describing: user?.kakaoAccount?.profile?.nickname))")
                                        
                                        login_vm.send_kakao_login(kakao_access_token: token, device: "ios")
                                        
                                        login_vm.send_kakao_result_func(login_vm.kakao_enter_result)
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                                            print("0.2초 후")
                                            if login_vm.kakao_enter_end{
                                                print("카카오 로그인 결과값 true")
                                                switch login_vm.kakao_enter_result {
                                                case .login:
                                                    print("로그인하는 경우")
                                                    self.kakao_login_ok = true
                                                case .join:
                                                    print("회원가입 과정중인 경우")
                                                    self.kakao_join_ok = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }){
                        Image("kakao")
                            
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15, alignment: .center)
                            .cornerRadius(25)
                            .padding()
                        
                    }
                    //ios가 버전이 올라감에 따라 sceneDelegate를 더이상 사용하지 않게되었다
                    //그래서 로그인을 한후 리턴값을 인식을 하여야하는데 아래 코드를 적어주지않으면 리턴값을 인식되지않는다
                    //swiftUI로 바뀌면서 가장큰 차이점이다.
                    .onOpenURL(perform: { url in
                        if (AuthApi.isKakaoTalkLoginUrl(url)) {
                            _ = AuthController.handleOpenUrl(url: url)
                            
                            print("카톡 로그인 open url")
                        }
                    })
                    
                    VStack{
                        //애플 계정으로 회원가입 -> 약관 동의 화면으로 이동.
                        NavigationLink("",destination: SignupTermsView(apple_login: self.$apple_join_ok, kakao_login: self.$kakao_login_ok), isActive: self.$apple_join_ok)
                        
                        SignInWithAppleButtonView()
                            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15, alignment: .center)
                            .cornerRadius(25)
                            .signInWithAppleButtonStyle(.black).onTapGesture {
                                self.showAppleLogin()
                                
                            }
                    }
                    
                    //                    NavigationLink(
                    //                        destination: InviteFriendsView(vm: SignupUserSetting())){
                    NavigationLink(
                        destination: SignupTermsView(apple_login: self.$apple_join_ok, kakao_login: self.$kakao_join_ok)){
                        
                        Text("프로코의 더 많은 서비스를 즐기고 싶으신가요?")
                            .font(.custom(Font.n_regular, size: 10))
                            .foregroundColor(Color.proco_black)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                    }
                    .navigationBarTitle("login")
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom, UIScreen.main.bounds.width*0.3)
                    
                }
                
                //VStack끝
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .background(Image("login_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaledToFill())
            .onAppear{
                print("로그인 화면 on appear : \(UserDefaults.standard.string(forKey: "fcm_token"))")
            }
        }
        }
    }
    
    private func showAppleLogin() {
        
        appleSignInDelegate = SignInWithAppleDelegate{
            print("로그인 성공: \($0)")
            self.apple_join_ok = true
        }
        //모든 로그인 요청에 ASAuthorizationAppleIDRequest가 필요하다고 함.
        let request = ASAuthorizationAppleIDProvider().createRequest()
        //알고자 하는 최종 사용자 데이터의 타입을 지정한 것.
        request.requestedScopes = [.email, .fullName]
        //로그인 다이얼로그를 보여주기 위한 컨트롤러 생성.
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = appleSignInDelegate
        controller.presentationContextProvider = appleSignInDelegate
        controller.performRequests()
    }
    
}

