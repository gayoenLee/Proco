//
//  SimSimFeedPage.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//

import SwiftUI
import ProcoCalendar
import Combine
import Alamofire
extension SimSimFeedPage{
    static var calendar_owner_idx : Int? = Int(ChatDataManager.shared.my_idx!)!
}
struct SimSimFeedPage: View {
    //캘린더에서 친구 정보를 다이얼로그 또는 탭 클릭시 미리 저장해놔야 해서 여기서 뷰모델 init하지 않음.
    @StateObject var main_vm :  CalendarViewModel
    
    //친구를 체크하는 통신이 진행된 후에 데이터를 가져오기 때문에 달력이 셋팅되기 전까지 보여줄 화면이 필요함.
    @State private var is_loading : Bool = true    
    
    @State private var previous_month : Date = Date()
    
    var body: some View {
        VStack{
            if !is_loading{
                
                //친구 체크 통신 결과에 따라 - 친구 또는 내 피드 화면일 때
                if main_vm.check_friend_result == "friend_allow"{
                    
                    ProcoMainCalendarView(ascSmallSchedules: main_vm.small_schedules, initialMonth: main_vm.initial_month, ascSchedules: main_vm.schedules_model, ascInterest: main_vm.interest_model, boring_days: main_vm.selections, main_vm: self.main_vm, ascSmallInterest: self.main_vm.small_interest_model, calendarOwner: self.main_vm.calendar_owner, go_mypage: false, previousMonth:  self.previous_month, go_setting_page: false)
                        .navigationBarTitle("", displayMode: .inline)
                        .navigationBarHidden(true)
                        .onAppear{
                            print("심심피드 페이지에서 프로코메인 캘린더뷰 나타남")
                        }
                }
                //카드만 공개할 때
                else if main_vm.check_friend_result == "friend_allow_card"{
                    
                    ProcoMainCalendarView(ascSmallSchedules: main_vm.small_schedules, initialMonth: main_vm.initial_month, ascSchedules: main_vm.schedules_model, ascInterest: main_vm.interest_model,boring_days: main_vm.selections, main_vm: self.main_vm, ascSmallInterest: self.main_vm.small_interest_model, calendarOwner: self.main_vm.calendar_owner, go_mypage: false, previousMonth:  self.previous_month, go_setting_page: false)
                    
                    //친구지만 비공개
                }else if main_vm.check_friend_result == "friend_disallow"{
                    
//                    FeedLimitedView(main_vm: self.main_vm, show_range: "friend_disallow")
                    Button(action: {
                        print("친구 신청 버튼 클릭")
                        self.main_vm.friend_request_result_alert_func(main_vm.friend_request_result_alert)
                        
                        //친구 요청 통신
                        self.main_vm.add_friend_request(f_idx: SimSimFeedPage.calendar_owner_idx!)
                        
                    }){
                                Text("친구 신청")
                                    .font(.system(size: 15))
                    }
                    
                }
                //친구 아닐 때
                else{
//                    FeedLimitedView(main_vm: self.main_vm, show_range: "not_friend")
                    Button(action: {
                        print("친구 신청 버튼 클릭")
                        self.main_vm.friend_request_result_alert_func(main_vm.friend_request_result_alert)
                        
                        //친구 요청 통신
                        self.main_vm.add_friend_request(f_idx: SimSimFeedPage.calendar_owner_idx!)
                    }){
                        
                                Text("친구 신청")
                                    .font(.system(size: 15))
                            
                    }
               
                }
            }else{
                ProgressView()
            }
            Spacer()
        }
        .alert(isPresented: $main_vm.show_friend_result_alert){
            switch main_vm.friend_request_result_alert{
            case .no_friends, .denied:
                return Alert(title: Text("친구 추가하기"), message: Text("없는 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    main_vm.show_friend_result_alert = false
                }))
                
            case .request_wait:
                return Alert(title: Text("친구 추가하기"), message: Text("친구 요청된 사용자입니다"), dismissButton:
                                Alert.Button.default(Text("확인"), action: {
                                    main_vm.show_friend_result_alert = false
                                }))
                
            case .requested:
                return Alert(title: Text("친구 추가하기"), message: Text("친구 요청된 사용자입니다"), dismissButton:Alert.Button.default(Text("확인"), action: {
                    main_vm.show_friend_result_alert = false
                }))
            case .already_friend:
                return Alert(title: Text("친구 추가하기"), message: Text("이미 친구 상태인 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    main_vm.show_friend_result_alert = false
                }))
            case .myself:
                return Alert(title: Text("친구 추가하기"), message: Text("내 번호입니다"), dismissButton:Alert.Button.default(Text("확인"), action: {
                    main_vm.show_friend_result_alert = false
                }))

            case .success:
                return Alert(title: Text("친구 추가하기"), message: Text("친구 신청이 완료됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                    main_vm.show_friend_result_alert = false
                }))
            case .fail:
                return Alert(title: Text("친구 추가하기"), message: Text("다시 시도해주세요"), dismissButton:Alert.Button.default(Text("확인"), action: {
                    main_vm.show_friend_result_alert = false
                }))
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear{
            
            self.previous_month = Calendar.current.startOfMonth(for:Date())
            
            print("순서1. 심심피드 페이지에서 initial month 확인: \(main_vm.initial_month) 이전 달: \(self.previous_month)")
            
            //이 페이지에 들어온 사람이 친구인지 체크하는 통신 -> true면 카드 공개범위 가져오는 통신 -> 카드 이벤트들 가져오기 -> small schedules 데이터 저장 -> 심심기간 데이터 가져옴
            main_vm.check_is_friend(friend_idx: SimSimFeedPage.calendar_owner_idx ?? Int(ChatDataManager.shared.my_idx!)!)
            
            //친구 체크 통신 시간이 걸리는 것을 감안해서 뷰 로딩시간 만듬
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
                self.is_loading = false
            }
            print("피드페이지 온어피어 \(main_vm.check_friend_result)")
        }
    }
    
}

extension Calendar{
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.month, .year], from: date)
        return self.date(from: components)!
    }
}
