//
//  user_signup_terms_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/10.
// 회원가입시 첫페이지. 이용약관 동의 페이지

import SwiftUI
import Alamofire

struct SignupTermsView: View {
    @Environment(\.presentationMode) var presentation
    
    //약관 데이터 클래스
    @ObservedObject var signup_terms_container = SignupTermsListContainer()
    //동의한 약관 리스트 저장한 배열
    @State private var selected = Set<String>()
    //약관 내용 보는 모달 나타나는 구분값
    @State private var is_modal: Bool = false
    //약관 전체 동의 클릭했는지 여부 알 수 있는 변수
    @State private var select_all : Bool = false
    //필수 약관을 모두 선택 안했을 경우 다음 페이지로 못 넘어가도록 처리하기 위함
    @State private var go_to_next : Bool = false
    //필수 동의 선택해야 하는 약관들. 다음 뷰로 이동하는 버튼 disabled설정할 때 비교하기 위해사용
    let necessary: Set = ["이용약관(필수)", "개인정보 수집 및 이용 (필수)", "위치 정보 이용 약관 동의 (필수)"]
    //약관 선택 정보 임시로 저장해 놓기 위한 클래스
    @ObservedObject var signup_user_setting = SignupViewModel()
    //애플로그인인 경우
    @Binding var apple_login : Bool
    //카톡 로그인인 경우
    @Binding var kakao_login : Bool
    
    //애플, 카카오 로그인시 약관 동의 화면 -> 메인 화면으로 이동.
    @State private var kakao_login_end = false
    @State private var apple_login_end = false
    //일반 회원가입시 다음 뷰 이동값
    @State private var go_next_step_not_social = false
    
    //약관별로 웹뷰 띄울 때 사용할 구분값
    @State private var go_necessary_term_view: Bool = false
    @State private var go_collect_info_term_view: Bool = false
    @State private var go_location_term_view: Bool = false
    @State private var go_marketing_term_view: Bool = false
    
    var body: some View {
        
        VStack(alignment: .center){
            
            title_view
            
            Rectangle()
                .foregroundColor(Color.proco_white.opacity(Double(0.7)))
                .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width*1.3, alignment: .center)
                .clipped()
                .shadow( radius: 2)
                .overlay(
                    VStack{
                        all_agree_btn
                        Divider()
                            .foregroundColor(Color.proco_black)
                        
                        //selection을 이용해서 선택된 row의 값을 가져올 수 있음.
                        ForEach(signup_terms_container.terms_items){ terms_list in
                            HStack{
                                //하위 약관들 뷰
                                HStack{
                                    Agree(signup_terms_container: self.signup_terms_container, terms_list: terms_list, selected: self.$selected, select_all: $select_all,  go_to_next: $go_to_next, go_necessary_term_view: self.$go_necessary_term_view, go_collect_info_term_view: self.$go_collect_info_term_view, go_location_term_view: self.$go_location_term_view, go_marketing_term_view: self.$go_marketing_term_view)
                                }
                            }
                        }
                        Spacer()
                    })
            
            Spacer()
            //카카오 로그인 완료시 메인으로 이동.
            NavigationLink("", destination: TabbarView(view_router: ViewRouter()), isActive: self.$kakao_login_end)
            
            //애플로그인 완료시 약관동의 페이지로 이동.
            NavigationLink("",destination: PhoneAuthView(phone_viewmodel: self.signup_user_setting, apple_login: self.$apple_login_end), isActive: self.$apple_login_end)
            
            //일반 회원가입시 핸드폰 번호 인증 페이지로 이동
            NavigationLink("",destination: PhoneAuthView(phone_viewmodel: self.signup_user_setting, apple_login: self.$apple_login_end), isActive: self.$go_next_step_not_social)
            
            //TODO 모두 다 버튼으로 고쳐야 함.
            if kakao_login == true || apple_login == true {
                
                Button(action: {
                    let fcm_token = UserDefaults.standard.string(forKey: "fcm_token")!
                    var marketing_yn = 0
                    if self.selected.contains("마케팅 수신 동의 (선택)"){
                        marketing_yn = 1
                        print("마케팅 동의 여부 값 : \(marketing_yn)" )
                    }
                    
                    if apple_login{
                        let name = UserDefaults.standard.string(forKey: "apple_user_name")
                        
                        let email = UserDefaults.standard.string(forKey: "apple_email")
                        
                        let token = UserDefaults.standard.string(forKey: "apple_identityToken")
                        
                        //약관 동의 정보 서버에 보내기.
                        self.signup_user_setting.join_member_end_apple(identity_token: token!, fcm_token: fcm_token, device: "IOS", phone: "", email: email!, profile_url: "", gender: 0, nickname: name!, marketing_yn: marketing_yn, latest_device: "", update_version: "")
                        
                    }else if kakao_login{
                        let kakao_token = UserDefaults.standard.string(forKey: "kakao_access_token")
                        let kakao_email = UserDefaults.standard.string(forKey: "kakao_email")
                        let kakao_nickname = UserDefaults.standard.string(forKey: "kakao_nickname")
                        self.signup_user_setting.join_member_kakao_end(kakao_access_token: kakao_token!, fcm_token: fcm_token, device: "IOS", phone: "", email: kakao_email!, profile_url: "", gender: 0, nickname: kakao_nickname!, marketing_yn: marketing_yn, latest_device: "", update_version: "")
                    }
                    
                    if self.signup_user_setting.kakao_join_end{
                        
                        self.kakao_login_end.toggle()
                        print("소셜 로그인 완료.")
                        //애플로그인 경우 핸드폰 인증 추가로 해야함.
                    } else if self.signup_user_setting.apple_join_end{
                        print("애플 로그인 핸드폰 인증 페이지로 넘어가기")
                        self.apple_login_end.toggle()
                    }
                }){
                    Text("동의하고 가입하기")
                        .font(.custom(Font.t_extra_bold, size: 15))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.proco_white)
                        .background(Color.proco_black)
                        .cornerRadius(25)
                        .padding([.leading, .trailing, .bottom], UIScreen.main.bounds.width/25)
                }
            }else{
          
            Button(action: {
                
                if self.selected.contains("마케팅 수신 동의 (선택)"){
                    self.signup_user_setting.marketing_term_ok = 1
                    print("마케팅 동의 여부 값 : \(self.signup_user_setting.marketing_term_ok)" )
                }
                self.go_next_step_not_social = true
                
            }){
                Text("동의하고 가입하기")
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.proco_white)
                    //버튼 비활성화 색깔 지정.
                    .background(!self.selected.isSuperset(of: necessary) ? Color.light_gray : Color.proco_black)
                    .cornerRadius(25)
                    .padding([.leading, .trailing, .bottom], UIScreen.main.bounds.width/25)
            }
            //필수 약관을 모두 선택하지 않으면 넘어갈 수 없도록 처리
            .disabled(!self.selected.isSuperset(of: necessary))
            }
            
            //약관 5개 전체 vstack묶음 끝
        }
        //약관 내용 웹뷰
        .sheet(isPresented: self.$go_necessary_term_view){
            TermContentsView(url: "https://withproco.com/tos.html?view=tos")
        }
        .sheet(isPresented: self.$go_location_term_view){
            TermContentsView(url: "https://withproco.com/tos.html?view=location")
        }
        .sheet(isPresented: self.$go_collect_info_term_view){
            TermContentsView(url: "https://withproco.com/tos.html?view=personal")
        }
        .sheet(isPresented: self.$go_marketing_term_view, content: {
            TermContentsView(url: "https://withproco.com/tos.html?view=marketing")
        })
        .onDisappear(perform: {
           
            
        })
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background( Image("signup_first")
                        .resizable()
                        .scaledToFill())
    }
}

//약관들에 대한 뷰
struct Agree : View{
    //약관 리스트 데이터 클래스
    @ObservedObject var signup_terms_container : SignupTermsListContainer
    //약관 리스트 struct
    @State var terms_list : TermsItem
    //선택한 아이템들의 정보를 담고 있는 배열
    @Binding var selected : Set<String>
    //약관 전체 동의를 선택했는지 알 수 있는 변수
    @Binding var select_all : Bool
    //약관 row를 선택했는지 알 수 있는 변수
    var is_selected: Bool {
        //선택했는지는 selected리스트 안에 담겨 있냐에 따라 결정됨.
        selected.contains(terms_list.title)
    }
    //필수 약관 선택했는지에 따라서 다음 뷰로 넘어갈 수 있는지 구분 변수
    @Binding var go_to_next: Bool
    
    //약관별로 웹뷰 띄울 때 사용할 구분값
    @Binding var go_necessary_term_view: Bool
    @Binding var go_collect_info_term_view: Bool
    @Binding var go_location_term_view: Bool
    @Binding var go_marketing_term_view: Bool
    
    var body: some View{
     
            HStack{
                
                HStack{
                    Button(action:{
                        //이미 선택한 상태에서 다시 클릭했을 때
                        if  self.select_all == true && self.is_selected{
                            print("약관 1개만 취소함, 배열 확인 : \(selected)")
                            self.select_all.toggle()
                        }
                        if self.is_selected {
                            print("1개 클릭해서 제거, 배열 확인 : \(selected)")
                            self.selected.remove(self.terms_list.title)
                        }
                        
                        //약관 전체 동의 클릭 후 모두 체크된 상태에서 한 개만 취소할 때, els if라고 해야 오류 발생 안함.
                        else if self.select_all == true && self.is_selected{
                            print("전체 동의 클릭 후 한개만 취소하기, 배열 확인 : \(selected)")
                            //전체 선택된 상태가 false됨
                            self.select_all.toggle()
                            //취소한 것 set에서 빼기
                            selected.remove(self.terms_list.title)
                        }
                        //약관 한개씩 체크할 경우
                        else if self.is_selected == false {
                            self.selected.insert(self.terms_list.title)
                            print("1개만 체크, 배열 확인 : \(selected)")
                        }
                        
                    }) {
                        HStack(alignment: .center, spacing: 10) {
                            if self.is_selected || select_all{
                                Image("checked_small")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            //이미 체크된상태에서 다시 체크했을 때
                            else if !self.is_selected {
                                Image("check_small")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            else{
                                Image("circle")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            Text(terms_list.title)
                                .font(.custom(Font.n_regular, size: 10))
                                .foregroundColor(Color.proco_black)
                            Spacer()
                        }
                    }
                    //한 row에 버튼이 2개 있어서 모두가 클릭되는 오류 해결 -> button style Borderless나 PlainButton스타일 적용
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading, UIScreen.main.bounds.width/15)
                }.frame(width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.width*0.02)
                
                Spacer()
                
                //약관 내용 보는 웹뷰 띄우는 버튼 - 마케팅은 없음.
                    HStack{
                        Image("right")
                            .foregroundColor(Color.proco_black)
                            .frame(width: UIScreen.main.bounds.width*0.1, height: UIScreen.main.bounds.width*0.1)
                    }
                    .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.1)
            }
            .onTapGesture {
                print("약관 한 개 클릭 : \(terms_list.title)")
                if terms_list.title.contains("이용약관"){
                    self.go_necessary_term_view = true
                }else if terms_list.title.contains("개인정보"){
                    self.go_collect_info_term_view = true
                }else if terms_list.title.contains("위치"){
                    self.go_location_term_view = true
                }else if terms_list.title.contains("마케팅"){
                    self.go_marketing_term_view = true
                }
            }
            .padding(.leading)
        
    }
}

extension SignupTermsView{
    
    var title_view: some View{
        HStack{
            Button(action: {
                self.presentation.wrappedValue.dismiss()
                
            }){
                Image("left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
            }
            Spacer()
            Text("이용약관 동의")
                .font(.custom(Font.n_extra_bold, size: 20))
                .foregroundColor(Color.proco_black)
            Spacer()
        }
        .padding()
        .padding(.bottom, UIScreen.main.bounds.width/20)
    }
    
    var all_agree_btn: some View{
        //약관 전체 동의 버튼만 따로 뺌
        Button(action:{
            //약관 전체 동의합니다를 클릭했다가 취소했을 때
            if select_all == false{
                //처음에 약관 전체 동의 클릭했을 때 모두 데이터 리스트에 넣기
                selected.insert("이용약관(필수)")
                selected.insert("개인정보 수집 및 이용 (필수)")
                selected.insert("위치 정보 이용 약관 동의 (필수)")
                selected.insert("마케팅 수신 동의 (선택)")
                print("전체 동의 처음에 클릭",selected)
            }
            //전체 약관 동의 두번째 클릭했을 때는 전체 동의 상태만 바뀜
            if select_all == true{
                print("전체 동의 아님")
                selected.removeAll()
            }
            //select_all.toggle 놓는 위치 이곳에 놓아야 코드 진행 오류 없음.
            select_all.toggle()
            print(selected)
            
        }) {
            HStack(alignment: .center, spacing: 10) {
                if self.select_all{
                    Image("checked_big")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width:UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }else{
                    Image("check_big")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width:UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)                        }
                Text("약관 전체 동의합니다")
                    .font(.custom(Font.n_extra_bold, size: 17))
                Spacer()
            }.foregroundColor(Color.proco_black)
        }
        .padding(UIScreen.main.bounds.width/20)
    }
}


