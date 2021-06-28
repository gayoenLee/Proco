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
    
    //친구 신청 후 뷰 변경시키기 위함
    @State private var friend_requested: Bool = false
    
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
                    Spacer()

                    //                    FeedLimitedView(main_vm: self.main_vm, show_range: "friend_disallow")
                        Text("비공개 피드입니다")
                            .font(.custom(Font.n_bold, size: 15))
                            .foregroundColor(Color.proco_white)
                            .foregroundColor(.proco_white)
                            .background(Color.main_orange)
                            .cornerRadius(25)
                            .frame(width: 150, height: 70)
                    Spacer()

                }
                //친구 아닐 때
                else{
                    Spacer()

                    if friend_requested{
                        HStack{
                     
                                Text("요청됨")
                                    .padding()
                                    .font(.custom(Font.n_bold, size: 16))
                                    .foregroundColor(Color.proco_white)
                                    .foregroundColor(.proco_white)
                                    .background(Color.main_orange)
                                    .cornerRadius(25)
                                    .frame(width: 100, height: 70)
                            
                            Button(action: {
                                print("친구 취소 버튼 클릭")
                                
                                self.main_vm.cancel_request_friend(f_idx: SimSimFeedPage.calendar_owner_idx!)
                            }){
                                Text("취소")
                                    .padding()
                                    .font(.custom(Font.n_bold, size: 16))
                                    .frame(width: 100, height: 70)
                                    .foregroundColor(Color.gray)
                                    .background(Color.light_gray)
                                    .cornerRadius(25)
                                    .border(Color.main_orange, width: 1)
                            }
                        }
                    }else{
                        
                        HStack{
                            Spacer()
                            Text("친구가 아닌 경우")
                                .font(.custom(Font.n_bold, size: 15))
                                .foregroundColor(Color.proco_black)
                            Spacer()

                        }
                        HStack{
                            Spacer()

                            Text("심심풀이를 볼 수 없어요.")
                                .font(.custom(Font.n_bold, size: 15))
                                .foregroundColor(Color.proco_black)
                            Spacer()

                        }
                        HStack{
                            Spacer()

                            Text("친구가 된후에 즐겨보세요")
                                .font(.custom(Font.n_bold, size: 15))
                                .foregroundColor(Color.proco_black)
                            Spacer()

                        }
                        Button(action: {
                            print("친구 신청 버튼 클릭")
                            self.main_vm.friend_request_result_alert_func(main_vm.friend_request_result_alert)
                            
                            //친구 요청 통신
                            self.main_vm.add_friend_request(f_idx: SimSimFeedPage.calendar_owner_idx!)
                        }){
                            Text("친구신청")
                                .padding()
                                .font(.custom(Font.n_bold, size: 16))
                                .foregroundColor(Color.proco_white)
                                .foregroundColor(.proco_white)
                                .background(Color.main_orange)
                                .cornerRadius(25)
                                .frame(width: 150, height: 70)
                        }
                    }
                    //                    FeedLimitedView(main_vm: self.main_vm, show_range: "not_friend")
                }
            }else{
                ProgressView()
            }
            Spacer()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.request_friend), perform: {value in
            
            if let user_info = value.userInfo{
                let check_result = user_info["request_friend_feed"]
                print("친구 요청 데이터 확인: \(String(describing: check_result))")
                
                //친구 신청 취소한 경우
                 if check_result as! String == "canceled_ok"{
                    let friend_idx = user_info["friend"] as! String
                    
                    if SimSimFeedPage.calendar_owner_idx! == Int(friend_idx){
                       friend_requested = false
                    }
                }else if check_result as! String == "canceled_fail"{
                    let friend_idx = user_info["friend"] as! String
                    
                    //실패 알림창 띄움
                    if  SimSimFeedPage.calendar_owner_idx! == Int(friend_idx){
                      
                    }
                }
            }
        })
        .alert(isPresented: $main_vm.show_friend_result_alert){
            switch main_vm.friend_request_result_alert{
            case .no_friends, .denied:
                return Alert(title: Text("친구 추가하기"), message: Text("없는 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    main_vm.show_friend_result_alert = false
                    
                }))
                
            case .request_wait:
                return Alert(title: Text("친구 추가하기"), message: Text("친구 요청된 사용자입니다"), dismissButton:
                                Alert.Button.default(Text("확인"), action: {
                                    friend_requested = true
                                    main_vm.show_friend_result_alert = false
                                }))
                
            case .requested:
                return Alert(title: Text("친구 추가하기"), message: Text("친구 요청된 사용자입니다"), dismissButton:Alert.Button.default(Text("확인"), action: {
                    friend_requested = true
                    main_vm.show_friend_result_alert = false
                }))
            case .already_friend:
                return Alert(title: Text("친구 추가하기"), message: Text("이미 친구 상태인 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    friend_requested = true
                    main_vm.show_friend_result_alert = false
                }))
            case .myself:
                return Alert(title: Text("친구 추가하기"), message: Text("내 번호입니다"), dismissButton:Alert.Button.default(Text("확인"), action: {
                    
                    main_vm.show_friend_result_alert = false
                }))
                
            case .success:
                return Alert(title: Text("친구 추가하기"), message: Text("친구 신청이 완료됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                    friend_requested = true
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
            print("심심피드 페이지에서 친구 체크하기 전 캘린더 모델 데이터 확인: \(main_vm.calendar_owner.user_idx)")
            
            main_vm.check_is_friend(friend_idx: self.main_vm.calendar_owner.user_idx)
            
            //친구 체크 통신 시간이 걸리는 것을 감안해서 뷰 로딩시간 만듬
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
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
