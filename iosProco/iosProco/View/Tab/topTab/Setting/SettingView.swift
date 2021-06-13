//
//  SettingView.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
//

import SwiftUI

struct SettingView: View {
    
    @ObservedObject var main_vm: SettingViewModel = SettingViewModel()
    //문의하기 페이지로 이동 구분값.
    @State private var go_service_center: Bool = false
    //계정관리 페이지 이동 구분값.
    @State private var go_manage_accout: Bool = false
    //피드 공개범위 설정 페이지로 이동 구분값
    @State private var go_feed_setting: Bool = false
    //피드 공개범위 나타내주기 위한 텍스트 value값
    @State private var current_calendar_state: String = ""
    //채팅알림 on, off상태 나타내주기 위한 value
    @State private var chat_alarm_state: Bool = false
    //카드알림 on, off상태 나타내주기 위한 value
    @State private var feed_alarm_state: Bool = false
    //공지사항 이동
    @State private var go_notice = false
    
    var body: some View {
        
        VStack{
            
            List{
                NoticeMenuView
                
                Group{
                    
                    Section(header: Text("고객센터").font(.custom(Font.n_bold, size: 18)).foregroundColor(Color.proco_black).padding()){
                        ServiceCenterMenuView
                        ManageAccountMenuView
                        VersionInfoMenuView
                    }
                }
                
                Group{
                    //계정관리
                    
                    Section(header: Text("알림설정").font(.custom(Font.n_bold, size: 18)).foregroundColor(Color.proco_black).padding()){
                        
                        ChatAlarmSettingMenuView
                        FeedAlarmSettingMenuView
                        
                    }
                    
                    Section(header: Text("공개범위 설정").font(.custom(Font.n_bold, size: 18)).foregroundColor(Color.proco_black).padding()){
                        
                        FeedDisclosureSettingView
                    }
                }
            }
            NavigationLink("", destination: NoticeView(vm: GroupVollehMainViewmodel()), isActive: self.$go_notice)
            
            NavigationLink("",destination: ServiceCenterView(main_vm: self.main_vm).navigationBarBackButtonHidden(true), isActive: self.$go_service_center)
            
            NavigationLink("",destination: ManageAccountView(main_vm: self.main_vm), isActive: self.$go_manage_accout)
            
            NavigationLink("",destination: SettingFeedDisclousreView(main_vm: self.main_vm).navigationBarTitle("심심풀이 공개범위 설정").font(.custom(Font.n_extra_bold, size: 22)).foregroundColor(Color.proco_black), isActive: self.$go_feed_setting)
        }
        .navigationBarTitle(Text("설정"))
        .onAppear{
            print("설정 뷰 나옴.")
            //유저의 자세한 정보 가져오는 통신 -> MyPageModel에 저장해놓음.
            self.main_vm.get_detail_user_info(user_idx: Int(self.main_vm.my_idx!)!)
            
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["got_user_info"]{
                print("설정 - 유저 정보 노티 \(data)")
                
                if data as! String == "ok"{
                    
                    //채팅알림, 카드 알림 값 데이터 넣기
                    if self.main_vm.user_info_model.chat_notify_state == 0{
                        self.chat_alarm_state = false
                    }else {
                        self.chat_alarm_state = true
                    }
                    
                    if self.main_vm.user_info_model.card_notify_state == 1{
                        self.feed_alarm_state = false
                    }else{
                        self.feed_alarm_state = true
                    }
                    
                    //카드 공개 범위 유저가 설정해놓은 상태 보여주는 텍스트값 저장.
                    if self.main_vm.user_info_model.calendar_public_state == 0{
                        
                        self.current_calendar_state = "전체공개"
                        
                    }else if self.main_vm.user_info_model.calendar_public_state == 1{
                        
                        self.current_calendar_state = "카드만 공개"
                        
                    }else{
                        self.current_calendar_state = "비공개"
                    }
                }
            }else{
                print("그룹관리 - 친구 리스트 데이터 노티 아님")
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.alarm_changed), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["alarm_changed"]{
                print("설정 - 채팅 알림 변경 노티 \(data)")
                
                if data as! String == "chat_alarm"{
                    
                    let state = user_info["state"]
                    
                    //채팅알림값 데이터 넣기
                    if state as! String == "true"{
                        self.chat_alarm_state = true
                        
                    }else {
                        self.chat_alarm_state = false
                    }
                    
                }else if data as! String == "feed_alarm"{
                    print("설정 - 피드 알림 변경 노티")
                    
                    let state = user_info["state"]
                    
                    //피드 알림 값 데이터 넣기
                    if state as! String == "true"{
                        self.feed_alarm_state = true
                    }else {
                        self.feed_alarm_state = false
                    }
                }
            }else{
                print("설정에서 변경한 알림 아님")
            }
        })
    }
}

private extension SettingView{
    
    var NoticeMenuView: some View{
        
        HStack{
            Text("공지사항")
                .font(.custom(Font.n_bold, size: 18))
                .foregroundColor(Color.proco_black)
            
            Spacer()
        }
        .onTapGesture {
            print("공지사항 클릭")
            self.go_notice.toggle()
        }
    }
    
    var ServiceCenterMenuView: some View{
        
        HStack{
            Text("문의하기")
                .font(.custom(Font.n_bold, size: 18))
                .foregroundColor(Color.proco_black)
            
            Spacer()
            
            Image("right_light")
                .resizable()
                .frame(width: 5.62, height: 11.24)
        }
        .onTapGesture {
            print("문의하기 클릭")
            self.go_service_center.toggle()
        }
    }
    
    var ManageAccountMenuView: some View{
        
        HStack {
            Text("계정관리")
                .font(.custom(Font.n_bold, size: 18))
                .foregroundColor(Color.proco_black)
            
            Spacer()
            
            Image("right_light")
                .resizable()
                .frame(width: 5.62, height: 11.24)
            
        }
        .onTapGesture {
            print("계정관리 클릭")
            self.go_manage_accout.toggle()
        }
    }
    
    var VersionInfoMenuView: some View{
        
        HStack{
            Text("버전정보 1.0.0")
                .font(.custom(Font.n_bold, size: 18))
                .foregroundColor(Color.proco_black)
            
            Spacer()
        }
    }
    
    var ChatAlarmSettingMenuView: some View{
        
        HStack{
            
            Toggle("채팅 알림",isOn: self.$chat_alarm_state)
                .onChange(of: self.chat_alarm_state, perform: {state in
                    print("채팅 알림 상태 변경")
                    if self.chat_alarm_state == false{
                        print("현재: \(self.chat_alarm_state), 채팅 알림 on으로 상태 바꿈.")
                        self.main_vm.edit_chat_alarm_setting(chat_notify_state: 1)
                        
                    }else{
                        print("현재: \(self.chat_alarm_state), 채팅알림 off로 상태 바꿈.")
                        self.main_vm.edit_chat_alarm_setting(chat_notify_state: 0)
                    }
                    
                }).font(.custom(Font.n_bold, size: 18))
                .foregroundColor(Color.proco_black)
            
        }.padding(UIScreen.main.bounds.width/20)
    }
    
    var FeedAlarmSettingMenuView: some View{
        
        HStack{
            Text("피드 알림")
                .font(.custom(Font.n_bold, size: 18))
                .foregroundColor(Color.proco_black)
            Spacer()
            
            Toggle("피드 알림",isOn: self.$feed_alarm_state)
                .onChange(of: self.feed_alarm_state, perform: {state in
                    print("피드 알림 상태 변경")
                    if self.feed_alarm_state == false{
                        print("현재: \(self.feed_alarm_state), 피드 알림 on으로 상태 바꿈.")
                        self.main_vm.edit_feed_alarm_setting(feed_notify_state: 1)
                        
                    }else{
                        print("현재: \(self.feed_alarm_state), 피드알림 off로 상태 바꿈.")
                        self.main_vm.edit_feed_alarm_setting(feed_notify_state: 0)
                    }
                    
                }).font(.custom(Font.n_bold, size: 18))
                .foregroundColor(Color.proco_black)
        }.padding(UIScreen.main.bounds.width/20)
    }
    
    var FeedDisclosureSettingView: some View{
        
        HStack{
                Text("심심풀이")
                    .font(.custom(Font.n_bold, size: 18))
                    .foregroundColor(Color.proco_black)
            
            Spacer()

                HStack{
                    Text("\(self.current_calendar_state)")
                        .font(.custom(Font.n_extra_bold, size: 15))
                        .foregroundColor(Color.gray)
                    
                    Image("right_light")
                        .resizable()
                        .frame(width: 5.62, height: 11.24)
                }
        }
        .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
        .onTapGesture {
            self.go_feed_setting.toggle()
        }
    }
}
