//
//  ScheduleDetailView.swift
//  proco
//
//  Created by 이은호 on 2021/03/16.
// 일정 상세페이지에서 개인일정 클릭시 나타나는 개인일정 카드 상세 페이지

import SwiftUI

struct ScheduleDetailView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var main_vm: CalendarViewModel
    
    @State private var title: String = ""
    //편집 모드
    @Environment(\.editMode) var editMode
    //이전 뷰에서 받는 모델
    @State var info_model: ScheduleInfo
    //info model에서 date로 받은 후 string으로 변환해서 텍스트뷰에 보여줄 때 사용.
    @State private var time: String = ""
    //info model에서 date로 받은 후 string으로 변환해서 텍스트뷰에 보여줄 때 사용.
    @State private var date: String = ""
    
    //편집완료시 캘린더 화면으로 돌아가도록 binding값 사용.
    @Binding var back_to_calendar: Bool
    //편집 이전 날짜를 보관한 후 편집 완료 후 뷰모델에서 기존 데이터 삭제시 사용.
    @State private var previous_date: String = ""
    //삭제 버튼 클릭시 한 번 더 확인하는 문구 나타낼 alert창 구분값
    @State private var delete_ask_alert: Bool = false
    
    var body: some View {
        VStack{
            
            //상단에 닫기 버튼, 제목, 편집 버튼 또는 삭제 버튼(작성자가 아닐 경우에는 없음.)
            top_title_bar
            
            Spacer()
            
            schedule_title_guid_txt
            
            //편집모드일 경우
            if (.active == self.editMode?.wrappedValue){
                
                schedule_title_txtfield
                
            }else{
                schedule_title
                
            }
            //날짜 선택 칸
            //in: 은 미래 날짜만 선택 가능하도록 하기 위함. displayedComponents: 시간을 제외한 날짜만 캘린더에 보여주기 위함.
            
            HStack{
                date_guide_title
                
                Spacer()
                if(.active == self.editMode?.wrappedValue){
                    
                    date_picker
                    
                }else{
                    date_info
                }
            }
            //시간 입력 칸
            HStack{
                
                time_guide_txt
                
                Spacer()
                
                if(.active == self.editMode?.wrappedValue){
                    time_date_picker
                    
                }else{
                    time_info
                }
            }
            Spacer()
            //메모 입력 필드
            HStack{
                
                memo_guide_txt
                
                Spacer()
            }
            HStack{
                if(.active == self.editMode?.wrappedValue){
                    
                    memo_txt_field
                    
                }else{
                    
                    memo_info
                }
            }
        }
        .padding(.all)
        .onAppear{
            print("개인 스케줄 상세 페이지 나타남.: \(info_model)")
            //TODO 후에 삭제할 것.
            SimSimFeedPage.calendar_owner_idx = Int(main_vm.my_idx!)!
            //시간 -> 오전, 오후로 변환
            self.time = String.date_to_kor_time(date: info_model.start_time)
            print("변환한 시간: \(time)")
            
            //날짜 -> string으로 변환
            let info_date  = self.main_vm.date_to_string(date: info_model.schedule_date)
            
            self.date = String.kor_date_string(date_string: info_date)
            print("날짜, 시간 sring변환 확인: \(time), 날짜: \(date)")
            self.previous_date = info_date
        }
    }
}

extension ScheduleDetailView{
    
    var date_guide_title : some View{
        HStack{
            Text("날짜")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(Color.proco_black)
        }
    }
    
    var date_picker : some View{
        
        DatePicker("날짜", selection: self.$main_vm.schedule_start_date, in: Date()..., displayedComponents: .date)
            //다이얼로그식 캘린더 스타일
            .datePickerStyle(CompactDatePickerStyle())
            .font(.custom(Font.t_extra_bold, size: 16))
            .foregroundColor(Color.proco_black)
    }
    
    var date_info : some View{
        
        Rectangle()
            .frame(width: 241, height: 36)
            .cornerRadius(3)
            .foregroundColor(Color.light_gray)
            .overlay(
                Text("\(self.date)")
                    .font(.custom(Font.n_bold, size: 17))
                    .foregroundColor(Color.black)
            )
    }
    
    var time_guide_txt : some View{
        Text("시간")
            .font(.custom(Font.t_extra_bold, size: 16))
            .foregroundColor(Color.proco_black)
    }
    
    var time_date_picker : some View{
        DatePicker("시간", selection: self.$main_vm.schedule_start_time, displayedComponents: .hourAndMinute)
            .labelsHidden()
            .datePickerStyle(GraphicalDatePickerStyle())
            .font(.custom(Font.t_extra_bold, size: 16))
            .foregroundColor(Color.proco_black)
    }
    
    var time_info : some View{
        
        Rectangle()
            .frame(width: 241, height: 36)
            .cornerRadius(3)
            .foregroundColor(Color.light_gray)
            .overlay(
                Text(self.time)
                    .font(.custom(Font.n_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            )
    }
    
    var memo_guide_txt : some View{
        
        Text("메모")
            .font(.custom(Font.t_extra_bold, size: 16))
            .foregroundColor(Color.proco_black)
        
    }
    
    
    var memo_info : some View{
        VStack(alignment: .leading){
            
            Rectangle()
                .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width, alignment: .center)
                .cornerRadius(3)
                .foregroundColor(Color.light_gray)
                .overlay(
                    VStack{
                        
                        Text("\(self.info_model.memo)")
                            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                            .multilineTextAlignment(.leading)
                            .font(.custom(Font.n_bold, size: 16))
                            .foregroundColor(Color.proco_black)
                        Spacer()
                    }
                )
            
        }
    }
    
    var memo_txt_field: some View{
        
        TextEditor(text: self.$main_vm.schedule_memo)
            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            .font(.custom(Font.n_regular, size: 16))
            .foregroundColor(Color.proco_black)
            .colorMultiply(Color.light_gray)
            .cornerRadius(3)
            .background(Color.light_gray)
    }
    
    var schedule_title: some View{
        VStack(alignment: .leading){
            Text("\(self.info_model.schedule_name)")
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(Color.proco_black)
            Spacer()
        }
    }
    
    var schedule_title_txtfield : some View{
        
        VStack{
            
            TextField("일정을 입력해주세요", text: self.$title)
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(Color.proco_black)
            Divider()
                .frame(width: UIScreen.main.bounds.width*0.8, height: 1)
        }
    }
    
    
    var schedule_title_guid_txt: some View{
        
        HStack{
            
            Text("일정 제목")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(Color.proco_black)
            Spacer()
        }
    }
    
    var top_title_bar : some View{
        HStack{
            
            Button(action: {
                print("닫기 버튼 클릭")
                self.presentation.wrappedValue.dismiss()
                
            }){
                Image("small_x")
                    .resizable()
                    .frame(width:13.89, height: 13.89)
            }
            
            Spacer()
            
            Text("일정")
                .font(.custom(Font.t_extra_bold, size: 22))                    .foregroundColor(Color.proco_black)
                .padding(.leading)
            
            Spacer()
            
            //캘린더 주인이 나일 경우
            if Int(main_vm.my_idx!) == SimSimFeedPage.calendar_owner_idx{
                if(.inactive == self.editMode?.wrappedValue){
                    edit_btn
                }
                if (.active == self.editMode?.wrappedValue){
                    edit_end_btn
                }
                //삭제 버튼
                if (.inactive == self.editMode?.wrappedValue){
                    delete_btn
                }
            }
        }
        .padding([.leading, .trailing])
    }
    
    var delete_btn : some View{
        
        Button(action: {
            print("삭제 버튼 클릭")
            self.delete_ask_alert.toggle()
            
        }){
            Image(systemName: "trash.circle.fill")
                .resizable()
                .foregroundColor(Color.orange)
                .background(Color.white)
                .frame(width: 25, height: 25)
                .clipShape(Circle())
        }
        .alert(isPresented: self.$delete_ask_alert, content: {
            
            Alert(title: Text("일정 삭제"), message: Text("일정을 삭제하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                
                print("개인일정 삭제 확인")
                //서버 형식에 맞춰서 보내기 위해 date->string
                let schedule_date = main_vm.date_to_string(date: info_model.schedule_date).split(separator: " ")[0]
                //삭제 통신
                self.main_vm.delete_personal_schedule(schedule_date: String(schedule_date), schedule_idx: info_model.card_idx)
                
                self.presentation.wrappedValue.dismiss()
                
            }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                print("개인일정 삭제 취소")
                self.delete_ask_alert.toggle()
            }))
        })
    }
    
    var edit_btn : some View{
        Button(action: {
            
            print("편집 버튼 클릭")
            self.editMode?.wrappedValue = .active == self.editMode?.wrappedValue  ? .inactive : .active
            
            //이전 뷰에서 받았던 뷰모델에 있는 publish변수에 넣어서 데이터를 편집할 때 사용. - 날짜,시간,제목,메모
            main_vm.schedule_start_time = info_model.start_time
            main_vm.schedule_start_date = info_model.schedule_date
            self.title = info_model.schedule_name
            main_vm.schedule_memo = info_model.memo
            
        }){
            Image(systemName: "pencil.circle.fill")
                .resizable()
                .foregroundColor(Color.orange)
                .background(Color.white)
                .clipShape(Circle())
                .frame(width: 25, height: 25)
                .clipShape(Circle())
            //일정 제목, 날짜, 시간을 입력해야만 활성화되도록 처리.
        }
    }
    
    var edit_end_btn : some View{
        Button(action: {
            print("편집 완료 클릭")
            
            //서버 형식에 맞춰서 보내기 위해 date->string
            let schedule_date = main_vm.date_to_string(date: main_vm.schedule_start_date).split(separator: " ")[0]
            
            //시간
            let schedule_time = DateFormatter.time_formatter.string(from: self.main_vm.schedule_start_time)
            
            self.main_vm.edit_personal_schedule(previous_date: self.previous_date, schedule_idx: info_model.card_idx, title: self.title, content: main_vm.schedule_memo, schedule_date: String(schedule_date), schedule_start_time: schedule_time)
            
            //편집모드를 끝내기 - 서버에 보낸 수정된 데이터로 업데이트(날짜, 시간, 제목, 메모)
            //시간 -> string으로 변환해서 보여주기 위함.
            self.time = DateFormatter.time_formatter.string(from:main_vm.schedule_start_time)
            
            //날짜 -> string으로 변환
            let info_date  = self.main_vm.date_to_string(date: main_vm.schedule_start_date)
            
            self.date = String.kor_date_string(date_string: info_date)
            print("날짜, 시간 sring변환 확인: \(time), 날짜: \(date)")
            //제목
            self.info_model.schedule_name = self.title
            //메모
            self.info_model.memo = self.main_vm.schedule_memo
            
            //편집 모드 inactive로 전환.
            self.editMode?.wrappedValue = .inactive == self.editMode?.wrappedValue  ? .active : .inactive
        }){
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(Color.orange)
                .background(Color.white)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
    }
}

