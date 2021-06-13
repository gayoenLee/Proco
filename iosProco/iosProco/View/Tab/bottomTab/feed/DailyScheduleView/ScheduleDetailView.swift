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
    @State private var year: String = ""
    @State private var month: String = ""
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
            HStack{
                Button(action: {
                    print("닫기 버튼 클릭")
                    self.presentation.wrappedValue.dismiss()
                    
                }){
                    Image(systemName: "xmark")
                        .resizable()
                        .foregroundColor(Color.black)
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                        .padding(UIScreen.main.bounds.width/20)
                }
                Spacer()
                Text("일정")
                    .font(.system(size: 20))
                    .foregroundColor(Color.black)
                Spacer()
                //캘린더 주인이 나일 경우
                if Int(main_vm.my_idx!) == SimSimFeedPage.calendar_owner_idx{
                    if(.inactive == self.editMode?.wrappedValue){
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
                                .foregroundColor(Color.orange)
                                .background(Color.white)
                                .clipShape(Circle())
                                .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
                                .clipShape(Circle())
                            //일정 제목, 날짜, 시간을 입력해야만 활성화되도록 처리.
                        }
                    }
                    if (.active == self.editMode?.wrappedValue){
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
                            self.year = String(info_date.split(separator: "-")[0])
                            self.month = String(info_date.split(separator: "-")[1])
                            self.date = String(info_date.split(separator: "-")[2])
                            print("날짜, 시간 sring변환 확인: \(time), 날짜: \(date)")
                            //제목
                            self.info_model.schedule_name = self.title
                            //메모
                            self.info_model.memo = self.main_vm.schedule_memo
                            
                            //편집 모드 inactive로 전환.
                            self.editMode?.wrappedValue = .inactive == self.editMode?.wrappedValue  ? .active : .inactive
                            
                        }){
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.orange)
                                .background(Color.white)
                                .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
                                .clipShape(Circle())
                        }
                    }
                    //삭제 버튼
                    if (.inactive == self.editMode?.wrappedValue){
                        Button(action: {
                            print("삭제 버튼 클릭")
                            self.delete_ask_alert.toggle()
                            
                        }){
                            Image(systemName: "trash.circle.fill")
                                .resizable()
                                .foregroundColor(Color.orange)
                                .background(Color.white)
                                .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
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
                }
            }
            Spacer()
            //편집모드일 경우
            if (.active == self.editMode?.wrappedValue){
                TextField("일정을 입력해주세요", text: self.$title).padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                    .foregroundColor(Color.black)
                
            }else{
                HStack{
                    Text("일정 제목")
                        .font(.caption)
                        .foregroundColor(Color.black)
                    
                    Text("\(self.info_model.schedule_name)")
                        .foregroundColor(Color.black)
                        .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                }
                .padding()
            }
            //날짜 선택 칸
            //in: 은 미래 날짜만 선택 가능하도록 하기 위함. displayedComponents: 시간을 제외한 날짜만 캘린더에 보여주기 위함.
            HStack{
                if(.active == self.editMode?.wrappedValue){
                    DatePicker("날짜", selection: self.$main_vm.schedule_start_date, in: Date()..., displayedComponents: .date)
                        //다이얼로그식 캘린더 스타일
                        .datePickerStyle(CompactDatePickerStyle())
                    
                }else{
                    HStack
                    {
                        Text("날짜")
                            .font(.caption)
                            .foregroundColor(Color.black)
                        
                        Spacer()
                        Text("\(self.year)")
                            .foregroundColor(Color.black)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                        Text("년")
                            .foregroundColor(Color.black)
                        Text("\(self.month)")
                            .foregroundColor(Color.black)
                        Text("월")
                            .foregroundColor(Color.black)
                        Text("\(self.date)")
                            .foregroundColor(Color.black)
                        Text("일")
                            .foregroundColor(Color.black)
                    } .padding()
                }
            }
            //시간 입력 칸
            HStack{
                if(.active == self.editMode?.wrappedValue){
                    DatePicker("시간", selection: self.$main_vm.schedule_start_time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(GraphicalDatePickerStyle())
                }else{
                    Text("시간")
                        .font(.caption)
                        .foregroundColor(Color.black)
                    
                    Text("\(self.time)")
                        .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                }
            }
            Spacer()
            //메모 입력 필드
            HStack{
                if(.active == self.editMode?.wrappedValue){
                    TextEditor(text: self.$main_vm.schedule_memo)
                        .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width)
                        .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                    
                }else{
                    Text("설명")
                        .font(.caption)
                    Text("\(self.info_model.memo)")
                        .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width)
                        .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .onAppear{
            print("개인 스케줄 상세 페이지 나타남.: \(info_model)")
            //TODO 후에 삭제할 것.
            SimSimFeedPage.calendar_owner_idx = Int(main_vm.my_idx!)!
            //시간 -> string으로 변환해서 보여주기 위함.
            self.time = DateFormatter.time_formatter.string(from: info_model.start_time)
            //날짜 -> string으로 변환
            let info_date  = self.main_vm.date_to_string(date: info_model.schedule_date)
            self.year = String(info_date.split(separator: "-")[0])
            self.month = String(info_date.split(separator: "-")[1])
            self.date = String(info_date.split(separator: "-")[2])
            print("날짜, 시간 sring변환 확인: \(time), 날짜: \(date)")
            self.previous_date = info_date
        }
    }
}

