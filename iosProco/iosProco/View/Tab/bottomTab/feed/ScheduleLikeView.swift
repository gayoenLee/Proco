//
//  ScheduleLikeView.swift
//  proco
//
//  Created by 이은호 on 2021/03/09.
// 일자 상세 페이지에 보여지는 좋아요버튼, 좋아요 갯수 뷰

import SwiftUI

struct ScheduleLikeView: View {
    
    @State var schedule : Schedule
    @ObservedObject var main_vm : CalendarViewModel
    @State private var show_like_users: Bool = false
    
    var body: some View {
        HStack{
            Button(action: {
                
                //이미 좋아요를 누른 상태였으므로 좋아요 취소 이벤트
                if schedule.liked_myself{
                    
                    print("일정 상세 페이지의 좋아요 취소 : 좋아요 idx \(schedule.like_idx!)")
                    self.main_vm.send_cancel_like_calendar(user_idx: self.main_vm.calendar_owner.user_idx, calendar_like_idx: schedule.like_idx!)
                    
                }else{
                    //좋아요 +1 이벤트
                    //좋아요를 클릭한 날짜 string 형태로 보내야 함.
                    let like_date = main_vm.date_to_string(date: schedule.date)
                    print("일정 상세 페이지의 좋아요 클릭: \(like_date)")
                    
                    self.main_vm.send_like_in_calendar(user_idx: self.main_vm.calendar_owner.user_idx, like_date: like_date)
                    
                }
            }){
                //좋아요 버튼을 누르고 취소함에 따라 동적으로 뷰가 안바뀌어서 state변수로 true,false값을 통해 뷰 변경하도록 함.
                Image(schedule.liked_myself == true ? "heart_fill" :  "heart" )
                    .resizable()
                    .frame(width: 19.95, height: 17.44)
                    .foregroundColor(Color.red)
            }
            
            NavigationLink("", destination: LikeUserListView(main_vm: self.main_vm, schedule_date: schedule.date), isActive: self.$show_like_users)
            
            //좋아요를 클릭한 사람들의 목록을 보는 페이지로 이동.
            Button(action: {
                
                //좋아요 목록 뷰로 이동시키기
                self.show_like_users.toggle()
                print("좋아요 유저 목록 뷰로 이동시키는 값 토글.")
                
            }){
                HStack{
                    
                    if schedule.like_num!  > 0{
                        
                        Text("좋아요\(schedule.like_num!)개")
                            .font(.custom(Font.n_extra_bold, size: 14))
                            .foregroundColor(Color.proco_black)
                    }
                    Spacer()
                }
            }
            Spacer()
        }
        .onAppear{
            print("캘린더 일자 좋아요한 데이터 확인: \(schedule)")
        }
        .onReceive(NotificationCenter.default.publisher(for:Notification.calendar_like_click), perform: {value in
            print("캘린더 일자 상세페이지에서 좋아요 클릭 이벤트 노티: \(value)")
            
            if let user_info = value.userInfo{
                let check_result = user_info["calendar_like_click"]
                print("좋아요 데이터 : \(String(describing: check_result))")
                
                if check_result as! String == "ok"{
                    //좋아요 클릭한 idx가 옴.
                    let like_idx = user_info["like_idx"] as! String
                    let like_date = user_info["like_date"] as! String
                    let schedule_date = self.main_vm.date_to_string(date: schedule.date)
                    
                    if like_date == schedule_date{
                        print("좋아요한 날짜에 해당")
                        
                        //1. 상세페이지 뷰 데이터 변경하기
                        //좋아요 클릭한 날짜가 저장된 모델의 배열 idx값을 찾아와서 저장.
                        schedule.like_num! += 1
                        schedule.like_idx = Int(like_idx)
                        schedule.liked_myself = true
                        
                        print("뷰에서 좋아요 하고 작은 날짜뷰 데이터 변경 확인: \(main_vm.small_schedules)")
                        print("뷰에서 좋아요 후 상세 페이지뷰 데이터 변경 확인: \(main_vm.schedules_model)")
                    }
                    self.main_vm.calendar_like_changed = true
                    
                }else if check_result as! String == "canceled"{
                    print("좋아요 취소 데이터: \(check_result)")
                    //취소한 idx가 옴.
                    let like_idx = user_info["like_idx"] as! String
                    
                    if Int(like_idx) == schedule.like_idx!{
                        print("좋아요 취소한 날짜")
                        
                        //1.Schedules모델 : 상세 페이지 뷰의 데이터 모델
                        schedule.like_num! -= 1
                        schedule.like_idx = Int(like_idx)
                        schedule.liked_myself = false
                        
                        self.main_vm.calendar_like_changed = true
                        print("뷰에서 좋아요 취소하고 데이터 변경 확인: \(main_vm.small_schedules)")
                        
                        print("뷰에서 좋아요 취소하고 큰 날짜 뷰 데이터 변경 확인: \(main_vm.schedules_model)")
                    }
                    
                }
            }
        })
        .onAppear{
            print("일정 상세 페이지 좋아요 뷰 나타남: \(schedule)")
            
            let date = self.schedule.date
            let model_idx = self.main_vm.schedules_model.firstIndex(where: {
                $0.date == date
            }) ?? -1
            
            if model_idx != -1{
                if
                    self.main_vm.schedules_model[model_idx].liked_myself != self.schedule.liked_myself{
                    self.schedule.liked_myself =  self.main_vm.schedules_model[model_idx].liked_myself
                    
                    self.schedule.like_num = self.main_vm.schedules_model[model_idx].like_num
                    
                    self.schedule.like_idx = self.main_vm.schedules_model[model_idx].like_idx
                }
            }
            
        }
        
    }
}

