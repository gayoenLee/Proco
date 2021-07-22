//
//  app_login_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/09.
//

import Foundation
import SwiftUI
import Alamofire

struct NormalLoginView:View{
    @Environment(\.presentationMode) private var presentation
    
    @State private var login_id : String = ""
    @State private var login_pwd : String = ""
    @State private var login_ok : Bool = false
    //아이디, 비밀번호 잘못 입력시 경고 문구 나타내기 위해 주는 구분 값
    @State private var show_id_warn = false
    @State private var show_pwd_warn = false
    //로그인 오류시 alert창 띄우는데 사용하는 구분 변수
    @State private var show_alert = false;
    @State private var fcm_token : String = ""
    @State private var got_fcm_token : Bool = false
    
    //최상단 스택 변경 위함.
    @ObservedObject var view_router : ViewRouter = ViewRouter.get_view_router()
    
    var body: some View {
        NavigationView{
        VStack{
            top_nav_bar
                
            Spacer()
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundColor(Color.proco_white)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width*1.2, alignment: .center)
                .overlay(
                    VStack{
                        VStack(alignment: .center){
                            HStack{
                                Spacer()
                                Text("로그인")
                                    .font(.custom(Font.t_extra_bold, size: 20))
                                    .foregroundColor(Color.proco_black)
                                    .padding([.bottom, .top], UIScreen.main.bounds.width/10)
                                Spacer()
                            }
                            //통신 후 아이디가 잘못됐을 때
                            if(self.show_id_warn){
                                
                                id_input_txt_field
                                
                                wrong_id_guid_txt
                            }else{
                                id_input_txt_field
                                
                            }
                        }
                        VStack(alignment: .leading){
                            if self.show_pwd_warn{
                                
                                pwd_input_txt_field
                                wrong_pwd_guide_txt
                                
                            }else{
                                pwd_input_txt_field
                            }
                        }
                        Spacer()
                        login_btn
                   //뷰라우터 싱글톤 만들면서 주석처리
//                        NavigationLink("",destination: TabbarView(view_router: self.view_router).navigationBarHidden(true), isActive: $login_ok)
                        
                        find_id_pwd_btn
                        Spacer()
                    }
                )
                .padding(.bottom)
            
            Spacer()
        }
        .background(Image("login_bg").resizable().scaledToFill())
        .alert(isPresented: $show_alert){
            Alert(title: Text("로그인"), message: Text("로그인을 다시 시도해주세요"), dismissButton: .default(Text("확인")))
        }
        
        .onAppear{
            print("일반 로그인 화면 on appear: \(UserDefaults.standard.string(forKey: "fcm_token"))")
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_fcm_token), perform: {value in
            print("일반 로그인시 fcm 토큰 노티로 받음: \(value)")
            
            if let user_info = value.userInfo, let data = user_info["get_fcm_token"]{
                print("일반 로그인시 fcm 토큰 받았음: \(data)")
                
                self.fcm_token = data as! String
                print("fcm toekn설정 값: \(self.fcm_token)")
                self.got_fcm_token = true
            }else{
                print("일반 로그인시 fcm 토큰 못 받음")
            }
        })
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        //navigation view 끝
    }
    
    func send_check_login(){
        print("보낼 때 파라미터 값 확인 : \(self.login_id) 비번 : \(self.login_pwd )")
        APIClient.check_login_api(id: self.login_id, password:self.login_pwd, fcm_token : UserDefaults.standard.string(forKey: "fcm_token")!, device: "IOS", completion: {result in
            DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
                withAnimation{
                    switch result{
                    case .success(let result):
                        print("일반 로그인 통신 성공 결과 : \(result)")
                        //파라미터 값이 제대로 전달되지 않았을 때 -> 다시 시도해달라고 alert띄우기
                        if result.result == "invalid parameters set"{
                            self.show_alert.toggle()
                        }
                        //패스워드 잘못 입력 -> 안내 문구 보여주기
                        else if result.result == "wrong password"{
                            self.show_pwd_warn.toggle()
                        }
                        //아이디 잘못 입력(해당 아이디 유저 없음) -> 안내 문구 보여주기
                        else if result.result=="wrong id"{
                            self.show_id_warn.toggle()
                        }
                        //db오류 -> 다시 시도해달라고 alert띄우기
                        else if result.result == "DB error"{
                            self.show_alert.toggle()
                            //로그인 성공하면 access, refresh token 저장
                        }else{
                            
                            //TODO user_idx를 저장시에 넣어서 유저별로 다르게 저장되도록 하기.
                            let access_token = result.access_token
                            let refresh_token = result.refresh_token
                            let idx = result.idx!
                            let nickname = result.nickname!
                            print("일반 로그인시 저장하는 액세스 토큰값 : \(String(describing: access_token))")
                            UserDefaults.standard.set(access_token, forKey: "access_token")
                            UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
                            UserDefaults.standard.set(idx, forKey: "user_id")
                            UserDefaults.standard.set(nickname, forKey: "nickname")
                            print("일반 로그인시 저장하는 닉네임 : \(String(describing: nickname))")
                            
                            SockMgr.socket_manager.establish_connection()
                            self.view_router.init_root_view = true
                           // login_ok.toggle()
                        }
                        
                    //로그인 메뉴 화면으로 다시 보내기
                    case .failure(let error):
                        print("일반 로그인 통신 실패 : \(error)")
                        self.show_alert.toggle()
                    }
                }}
            
        })
    }
}

extension NormalLoginView{
    
    var top_nav_bar: some View{
        HStack{
            Button(action: {
                self.presentation.wrappedValue.dismiss()
                
            }){
                Image("left")
                    .resizable()
                    .frame(width: 8.51, height: 17)
            }
            Spacer()
        }
        .padding([.top, .bottom, .leading])
    }
    
    var id_input_txt_field: some View{
        TextField("아이디(핸드폰 번호)", text: $login_id)
            .font(.custom(Font.n_regular, size: 14))
            .foregroundColor(Color.gray)
            .padding()
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .cornerRadius(25.0)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            .keyboardType(.phonePad)
    }
    
    var pwd_input_txt_field: some View{
        SecureField("비밀번호", text: self.$login_pwd)
            .font(.custom(Font.n_regular, size: 14))
            .foregroundColor(Color.gray)
            .padding()
            .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
            .cornerRadius(25.0)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
    }
    
    var login_btn: some View{
        Button(action: {
            
            //if got_fcm_token{
            print("fcm 노티 받은 후 로그인 통신 진행")
            send_check_login()
            //  }
            print("로그인하기 클릭")
        }){
            Text("로그인")
                .font(.custom(Font.t_extra_bold, size: 15))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.proco_white)
                .background(Color.proco_black)
                .cornerRadius(25)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
        }
    }
    
    var find_id_pwd_btn: some View{
        NavigationLink(
            destination: FindIdPasswordView()){
            Text("아이디/비밀번호 찾기")
                .font(.custom(Font.n_regular, size: 11))
                .foregroundColor(.gray)
                .minimumScaleFactor(0.5)
                .padding(.horizontal)
        }
        .navigationBarTitle("")
    }
    
    var wrong_id_guid_txt: some View{
            HStack{
                Text("잘못된 아이디입니다")
                    .font(.custom(Font.n_regular, size: 10))
                    .foregroundColor(.proco_red)
                    //프레임 크기에 맞춰서 글자 크기 줄이기
                    .frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.height/40, alignment: .leading)
                    .minimumScaleFactor(0.5)
                    .padding([.leading], UIScreen.main.bounds.width/10)
                Spacer()
            }
        }
        
        var wrong_pwd_guide_txt: some View{
            HStack{
                Text("잘못된 비밀번호입니다")
                    .font(.custom(Font.n_regular, size: 10))
                    .foregroundColor(.proco_red)
                    //프레임 크기에 맞춰서 글자 크기 줄이기
                    .frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.height/40, alignment: .leading)
                    .minimumScaleFactor(0.5)
                    .padding([.leading], UIScreen.main.bounds.width/10)

                Spacer()
            }
        }
    
    
}






