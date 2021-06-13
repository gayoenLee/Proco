//
//  AddScheduleView.swift
//  proco
//
//  Created by 이은호 on 2021/03/15.
//

import SwiftUI

struct AddScheduleView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var main_vm: CalendarViewModel
    @Binding var back_to_calendar: Bool
    @State private var title: String = ""
    //메모 글자 수
    @State private var txt_count = "0"
    
    var add_schedule_ok: Bool{
        return !self.title.isEmpty
    }
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    print("닫기 버튼 클릭")
                    self.presentation.wrappedValue.dismiss()
                }){
                    Image("card_dialog_close_icon")
                        .resizable()
                        .frame(width:13.89, height: 13.89)
                       
                }
                Spacer()
                Text("일정추가")
                    .font(.custom(Font.t_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                Spacer()
                Button(action: {
                    
                    print("완료 버튼 클릭")
                    
                    let schedule_date = main_vm.date_to_string(date: main_vm.schedule_start_date).split(separator: " ")[0]
                    //시간만 string으로 변환하는데 사용하는 메소드. 생각보다 간단함.
                    let schedule_start_time = DateFormatter.time_formatter.string(from: self.main_vm.schedule_start_time)
                    
                    print("시간 정보 date: \(main_vm.schedule_start_time)")
                    print("시간 정보 string: \(schedule_start_time)")
                    print("제목 정보 입력한 것: \(title)")
                    
                    self.main_vm.add_personal_schedule(title: self.title, content: self.main_vm.schedule_memo, schedule_date: String(schedule_date), schedule_start_time: String(schedule_start_time))
                    
                    //캘린더뷰로 돌아감.
                    self.back_to_calendar = false
                    
                }){
                    Image("check_end_btn")
                        .resizable()
                        .frame(width: 40, height: 40)
                      
                    //일정 제목, 날짜, 시간을 입력해야만 활성화되도록 처리.
                }
                .disabled(!self.add_schedule_ok)
                
                
            }
            .padding()
            
            TextField("일정을 입력해주세요", text: self.$title)
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(Color.light_gray)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                .overlay(VStack{Divider().offset(x: 0, y: 15)})
            //날짜 선택 칸
            //in: 은 미래 날짜만 선택 가능하도록 하기 위함. displayedComponents: 시간을 제외한 날짜만 캘린더에 보여주기 위함.
            HStack{
                Text("날짜")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                DatePicker("", selection: self.$main_vm.schedule_start_date, in: Date()..., displayedComponents: .date)
                    .font(.custom(Font.n_bold, size: 17))
                    .foregroundColor(Color.proco_black)
                    //다이얼로그식 캘린더 스타일
                    .datePickerStyle(CompactDatePickerStyle())
            }
            .padding()
            //시간 입력 칸
            HStack{
                Text("시간")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                DatePicker("시간", selection: self.$main_vm.schedule_start_time, displayedComponents: .hourAndMinute)
                    .font(.custom(Font.n_bold, size: 17))
                    .foregroundColor(Color.proco_black)
                    .labelsHidden()
                    .datePickerStyle(GraphicalDatePickerStyle())
            }
            .padding()
            //메모 입력 필드
            HStack{
            Text("메모")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(Color.proco_black)
                
                Text("\(self.txt_count)")
                    .foregroundColor(Color.gray)
                    .font(.custom(Font.n_regular, size: 10))
                
                Spacer()
            }
            .padding()
             
            HStack{
                TextEditor(text: self.$main_vm.schedule_memo)
                    .font(.custom(Font.n_regular, size: 12))
                    .foregroundColor(Color.proco_black)
                    .foregroundColor(self.main_vm.schedule_memo == "내용을 입력해주세요" ? .gray : .primary)
                    .colorMultiply(Color.light_gray)
                    .cornerRadius(3)
                    .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.4)
                    .onChange(of: self.main_vm.schedule_memo) { value in
                        print("메모 onchange 들어옴")
                        //현재 몇 글자 작성중인지 표시
                        self.txt_count = "\(value.count)/255"
                       if value.count > 255 {
                        print("255글자 넘음")
                        self.main_vm.schedule_memo = String(value.prefix(255))
                      }
                  }
                
            }
            .font(.custom(Font.t_extra_bold, size: 16))
            .foregroundColor(Color.proco_black)
            Spacer()
        }
        .onAppear{
            self.main_vm.schedule_state_changed = false
        }
        .onDisappear{
            //스케줄 모델 objectwillchange 보내는 것.
            self.main_vm.schedule_state_changed = true
        }
    }
}

