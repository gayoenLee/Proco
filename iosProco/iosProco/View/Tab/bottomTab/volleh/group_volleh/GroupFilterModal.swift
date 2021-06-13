//
//  GroupFilterModal.swift
//  proco
//
//  Created by 이은호 on 2020/12/29.
//

import SwiftUI

struct GroupFilterModal: View {
    
    @ObservedObject var main_vm : GroupVollehMainViewmodel
    @Binding var show_filter : Bool
    //선택한 지역
    @State private var selected_location : String = ""
    //선택한 카테고리 종류
    @State private var selected_category : String = ""
    //선택한 모임 타입(채팅, 만나서)
    @State private var meeting_kind : String = ""
    
    
    var body: some View {
        VStack{
            //상단 제목 라인
            HStack{
                Button(action: {
                    show_filter = false
                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height:17)
                        .padding()
                }
                Spacer()
                Text("심심함 설정")
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .foregroundColor(.proco_white)
                        
                Spacer()
                Button(action: {
                    self.meeting_kind = "모두"
                    self.selected_location = "전체"
                    self.selected_category = ""
                    self.main_vm.filter_start_date = Date()
                    
                    print("리셋 아이콘 클릭")
                }){
                Image("reset_icon")
                    .resizable()
                    .frame(width: 20.9, height: 20.9)
                    .padding(.trailing)
                }
            }
            meeting_kinds_selection
            HStack{
                Text("심심태그")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                Text("최대 3개")
                    .font(.custom(Font.n_regular, size: 10))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding([.leading, .bottom])
            //태그 카테고리 뷰
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(0..<main_vm.category_tag_struct.count, id: \.self){ category_index in
                        //태그 카테고리 뷰
                        //1개 클릭시 뷰모델에 user_selected_tag_set에 저장됨.
                        TagCategoryView(vm: self.main_vm, tag_struct: self.main_vm.category_tag_struct[category_index], selected_category: self.$selected_category, is_for_filter: true)
                    }.padding(.leading, UIScreen.main.bounds.width/30)
                }
            }.frame(height: UIScreen.main.bounds.width/9)
            
            HStack{
                Text("지역")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                Spacer()
            }
            .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                    ForEach(self.main_vm.location_struct.indices, id: \.self){idx in
                        LocationCategoryView(main_vm: self.main_vm, location_model: self.main_vm.location_struct[idx], selected_location: self.$selected_location)
                    }.padding(.leading, UIScreen.main.bounds.width/60)
                }
            }.frame(height: UIScreen.main.bounds.width/9)
            
            DatePicker("", selection: $main_vm.filter_start_date, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
               
            Spacer()
            Button(action: {
                //date -> string변환
                self.main_vm.date_to_string()
                print("필터 적용한 지역\(self.selected_category), 모임 종류 : \(self.meeting_kind)")
                //필터 통신 진행
                self.main_vm.group_volleh_filter(address: self.selected_location, kinds: self.meeting_kind)
                
                show_filter.toggle()
                
            }, label: {
                Text("적용하기")
                    .font(.custom(Font.t_regular, size: 17))
                    .padding()
                    .foregroundColor(.proco_white)
            })
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color.main_green)
            .cornerRadius(25)
            .padding([.leading, .trailing, .bottom], UIScreen.main.bounds.width/20)
        }
        .padding()
        .onAppear{
            //모임 방법
            if self.main_vm.filter_kind == ""{
                self.meeting_kind =     "모두"
            }else{
                self.meeting_kind = self.main_vm.filter_kind!
            }
            //지역
            if self.main_vm.filter_location == ""{
                self.selected_location = "전체"
            }else{
                self.selected_location = self.main_vm.filter_location!
            }
        }
    }
}

extension GroupFilterModal {
    var meeting_kinds_selection: some View{
        HStack{
            Rectangle()
                .cornerRadius(5)
                .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.08)
                .foregroundColor(self.meeting_kind == "모두" ? .proco_mint : .proco_sky_blue )
                .overlay(
            Button(action: {
   
                self.meeting_kind = "모두"
                print("현재 모임 type: \(self.meeting_kind)")
                
            }){
                Text("모두")
                    .font(.custom(Font.t_extra_bold, size: 17))
                    .foregroundColor(self.meeting_kind == "모두" ? .proco_white : .inactive_blue )
            })
            
            RoundedRectangle(cornerRadius: 5)
                .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.08)
                .foregroundColor(self.meeting_kind == "채팅만" ? .proco_mint : .proco_sky_blue)
                .overlay(
            Button(action: {
                
                self.meeting_kind = "채팅만"
                print("현재 모임 type: \(self.meeting_kind)")
            }){
                Text("채팅만")
                    .font(.custom(Font.t_extra_bold, size: 17))
                    .foregroundColor(self.meeting_kind == "채팅만" ? .proco_white : .inactive_blue)
            })
            
            RoundedRectangle(cornerRadius: 5)
                .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.08)
                .foregroundColor(self.meeting_kind == "만나서" ? .proco_mint : .proco_sky_blue)
                .overlay(
            Button(action: {
                self.meeting_kind = "만나서"
                print("현재 모임 type: \(self.meeting_kind)")
            }){
                Text("만나서")
                    .font(.custom(Font.t_extra_bold, size: 17))
                    .foregroundColor(self.meeting_kind == "만나서" ? .proco_white : .inactive_blue)
            })
            
        }
    }
}

