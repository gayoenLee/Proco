//
//  ScheduleCell.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//

import SwiftUI

struct ScheduleCell: View {
    //친구랑 볼래 카드 상세 페이지로 이동시 필요함.
    @StateObject var friend_main_vm  =  FriendVollehMainViewmodel()
    //모여 볼래 카드 상세 페이지 이동시 필요함.
    @StateObject var group_main_vm =  GroupVollehMainViewmodel()
    
    @ObservedObject var main_vm: CalendarViewModel
    @State var schedule_info: [ScheduleInfo]
    //친구카드 클릭시
    @State private var show_friend_card: Bool = false

    //그룹카드 클릭시
    @State private var show_group_card: Bool = false

    //개인일정 클릭시
    @State private var show_personal_card: Bool = false
    //개인일정 클릭시 넘겨줄 schedule_idx
    @State var schedule_idx: Int = -1
    @State private var clicked_info_model : ScheduleInfo = ScheduleInfo()
    
    var body: some View {

        HStack{
            //개인일정 상세페이지
            NavigationLink("", destination: ScheduleDetailView(main_vm: self.main_vm,  info_model: clicked_info_model, back_to_calendar: self.$show_personal_card), isActive: self.$show_personal_card)
                .isDetailLink(false)
            
            //친구카드 상세페이지
            NavigationLink("", destination:FriendVollehCardDetail(main_vm: self.friend_main_vm, group_main_vm: self.group_main_vm, socket: SockMgr.socket_manager, calendar_vm: self.main_vm), isActive: self.$show_friend_card)
                .isDetailLink(false)
                
            //그룹카드 상세페이지
            NavigationLink("",destination: GroupVollehCardDetail(main_vm: self.group_main_vm, socket: SockMgr.socket_manager, calendar_vm: self.main_vm), isActive: self.$show_group_card)
          
            VStack(alignment: .leading){

                ForEach(schedule_info, id: \.id){info in
                    HStack{
                        TypeView(schedule_info: info)
                    
                    VStack(alignment: .leading){

                    //개인일정일 경우 카테고리 태그 없음.
                    if info.type != "personal"{

                        CalendarCardCategoryView(info: info)
                    }
                    CalendarCardNameView(info: info)

                    CalendarCardTimeView(info: info)
                    //친구 카드일 경우 태그들 보여줌.
                    if info.type == "friend"{
                        CalendarCardTagsView(info: info)
                    }
                    //모임일 경우는 카드에 참가 인원, 모임 장소
                    if info.type == "group"{
                        CalendarCardLocationPeopleView(info: info)
                    }
                }
                    }
                    .onTapGesture {
                        print("스케줄 한개 클릭: \(info.type)")

                        if info.type == "friend"{
                        //카드 상세페이지에서 데이터 가져오는 통신시 필요한 카드idx
                            self.friend_main_vm.selected_card_idx = info.card_idx
                        
                            self.main_vm.from_calendar = true
                            
                            self.show_friend_card.toggle()
                        }else if info.type == "group"{
                            print("그룹 카드 선택한 경우")
                            
                            //카드 상세페이지에서 데이터 가져오는 통신시 필요한 카드idx
                            group_main_vm.selected_card_idx = info.card_idx
 
                            self.main_vm.from_calendar = true
                            

                            self.show_group_card.toggle()

                        //개인일정인 경우
                        }else{
                            print("개인 일정 카드 클릭")
                            self.schedule_idx = info.card_idx
                            //나중에 스케줄 시작날짜와 끝날짜 개념이 생기면 수정필요함. 현재는 하루만 스케줄로 등록하기 때문에 사용 가능.
                            var date = info.schedule_date
                            clicked_info_model = info
                            self.show_personal_card.toggle()

                        }
                    }
                }
            }
            .padding(UIScreen.main.bounds.width/40)
            //Spacer()
        }
        //.overlay(TypeView(schedule_info: schedule_info))
        .padding(.vertical, SchedulePreviewConstants.cellPadding)
        .onDisappear{
            print("날짜 상세페이지 schedule cell 사라짐.")
        }
        
    }
}
struct TypeView: View{
    
    @State var schedule_info : ScheduleInfo
    
    var body: some View{
        Group{
        HStack{
            Rectangle()
                .fill(schedule_info.type == "friend" ? Color.main_orange : schedule_info.type == "mine" ? Color.proco_yellow : Color.main_green)
                //height를 지정하면 옆에 태그 높이가 dynamic으로 변하지 않음.
                .frame(width: 5)
        }
    }
    }
}

struct CalendarCardCategoryView: View{
    
    @State var info : ScheduleInfo
    
    var body: some View{
        Group{
            Capsule()
                .foregroundColor(info.category == "사교/인맥" ? .proco_yellow :info.category == "게임/오락" ? .proco_pink : info.category == "문화/공연/축제" ? .proco_olive : info.category == "운동/스포츠" ? .proco_green : info.category == "취미/여가" ? .proco_mint : info.category == "스터디" ? .proco_blue : .proco_red )
                        .frame(width: 43, height: 16)
            .overlay(Text(info.category)
                        .foregroundColor(.white)
                        .font(.custom(Font.t_extra_bold, size: 8))
                        .foregroundColor(Color.proco_white))
        
    }
    }
}

struct CalendarCardNameView : View{
    @State var info : ScheduleInfo
    
    var body: some View{
        Group{
        Text(info.schedule_name)
            .font(.custom(Font.n_extra_bold, size: 15))
            .foregroundColor(.proco_black)
        }
    }
}

struct CalendarCardTimeView : View{
    @State var info : ScheduleInfo
    
    var body: some View{
        Group{
            Text(String.date_to_kor_time(date: info.start_time))
                .font(.custom(Font.n_bold, size: 12))
            .foregroundColor(Color.gray)
        }
    }
}

struct CalendarCardTagsView : View{
    @State var info : ScheduleInfo
    
    var body: some View{
        Group{
        HStack{
            ForEach(info.tags!, id: \.id){ tag in
                Image("tag_sharp")
                    .resizable()
                    .frame(width: 15.99, height: 15.99)
                
                Text(tag.tag_name)
                    .font(.custom(Font.n_bold, size: 12))
                    .foregroundColor(Color.proco_black)
            }
            Spacer()
        }
        }
    }
}
struct CalendarCardLocationPeopleView : View{
    @State var info : ScheduleInfo
    
    var body: some View{
        Group{
        HStack{
           
            Image("meeting_user_num_icon")
                .resizable()
                .frame(width: 11, height: 11.75)
            
            Text(String(info.current_people))
                .font(.custom(Font.n_bold, size: 12))
                .foregroundColor(Color.proco_black)
                .padding(.trailing)
            
            if info.type.split(separator: " ")[0] == "오프라인"{
            Image("marker_icon")
                .resizable()
                .frame(width: 9.88, height: 11.75)
            
            Text(info.location_name)
                .font(.custom(Font.n_bold, size: 10))
                .foregroundColor(Color.proco_black)
            Spacer()
            }else{
               Image("small_chat_bubble_icon")
                .resizable()
                .frame(width: 12.37, height: 10)
                
                Text("온라인 채팅")
                    .font(.custom(Font.n_bold, size: 10))
                    .foregroundColor(Color.proco_black)
                
            }
        }
        }
    }
}

