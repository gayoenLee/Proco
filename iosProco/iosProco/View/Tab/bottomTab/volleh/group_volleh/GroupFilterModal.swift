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
    @State private var selected_category = Set<String>()
    //선택한 모임 타입(채팅, 만나서)
    @State private var meeting_kind : String = ""
    //추가하려는 태그의 갯수가 3개를 넘으면 값이 true
    @State private var tag_num_over_three : Bool = false
    
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
                    self.selected_category.removeAll()
                    self.main_vm.filter_start_date = Date()
                    self.main_vm.selected_filter_tag_list.removeAll()
                    self.main_vm.selected_filter_tag_set.removeAll()
                    
                    print("리셋 아이콘 클릭")
                }){
                    
                    Image("reset_icon")
                        .resizable()
                        .frame(width: 20.9, height: 20.9)
                        .padding(.trailing)
                }
            }
            meeting_kinds_selection
            
            if tag_num_over_three{
                
                HStack{
                    Text("태그는 최대 3개까지 적용할 수 있습니다.")
                        .font(.custom(Font.t_extra_bold, size: 16))
                        .foregroundColor(.proco_red)
                }
            }
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
                        GroupFilterCategoryView(viewmodel: self.main_vm, category_model: self.main_vm.category_tag_struct[category_index], tag_num_over_three: self.$tag_num_over_three, selected_category: self.$selected_category, is_for_filter: true)
                        
                    }.padding(.leading, UIScreen.main.bounds.width/30)
                }
            }.frame(height: UIScreen.main.bounds.width/9)
            
            //선택한 카테고리 리스트 뷰
            selected_tag_list
            
            if self.meeting_kind == "만나서"{
                
                HStack{
                    Text("지역")
                        .font(.custom(Font.t_extra_bold, size: 16))
                        .foregroundColor(.proco_black)
                    Spacer()
                }
                .padding([.leading, .top])
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        
                        ForEach(self.main_vm.location_struct.indices, id: \.self){idx in
                            
                            LocationCategoryView(main_vm: self.main_vm, location_model: self.main_vm.location_struct[idx], selected_location: self.$selected_location)
                            
                        }.padding(.leading, UIScreen.main.bounds.width/60)
                    }
                }.frame(height: UIScreen.main.bounds.width/9)
            }
            
            DatePicker("", selection: $main_vm.filter_start_date, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
                .environment(\.locale, Locale.init(identifier: "ko_KR"))
            
            Spacer()
            Button(action: {
                //date -> string변환
                self.main_vm.date_to_string()
                print("필터 적용한 지역\(self.selected_category), 모임 종류 : \(self.meeting_kind)")
                
                var kinds : String = ""
                if meeting_kind == "채팅만"{
                    kinds = "온라인 모임"
                }else if meeting_kind == "만나서"{
                    kinds = "오프라인 모임"
                }else{
                    kinds = "모두"
                }
                //필터 통신 진행
                self.main_vm.group_volleh_filter(address: self.selected_location, kinds: kinds, tag: main_vm.selected_filter_tag_list)
                
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
    
    var selected_tag_list : some View{
        HStack{
            
            ForEach(0..<main_vm.selected_filter_tag_list.count, id: \.self){ tag_index in
                
                Image("small_x")
                    .resizable()
                    .frame(width: 7, height: 7)
                
                Capsule()
                    .foregroundColor(main_vm.selected_filter_tag_list[tag_index] == "사교/인맥" ? .proco_yellow : main_vm.selected_filter_tag_list[tag_index] == "게임/오락" ? .proco_pink : main_vm.selected_filter_tag_list[tag_index] == "문화/공연/축제" ? .proco_olive : main_vm.selected_filter_tag_list[tag_index] == "운동/스포츠" ? .proco_green : main_vm.selected_filter_tag_list[tag_index] == "취미/여가" ? .proco_mint : main_vm.selected_filter_tag_list[tag_index] == "스터디" ? .proco_blue : .proco_red )
                    .frame(width: 90, height: 22)
                    .overlay(
                        Button(action: {
                            print("선택한 태그 리스트들 확인\(main_vm.selected_filter_tag_list) ")
                            
                            print("선택한 태그 리스트들 중 현재 선택한 것 확인 : \(main_vm.selected_filter_tag_list[tag_index])")
                            if main_vm.selected_filter_tag_set.contains(main_vm.selected_filter_tag_list[tag_index]){
                                print("이미 선택한 태그")
                                main_vm.selected_filter_tag_set.remove(main_vm.selected_filter_tag_list[tag_index])
                                
                                self.main_vm.selected_filter_tag_list = Array(self.main_vm.selected_filter_tag_set)
                                
                            }else{
                                print("새로 선택한 태그")
                                main_vm.selected_filter_tag_set.insert(main_vm.selected_filter_tag_list[tag_index])
                                self.main_vm.selected_filter_tag_list = Array(self.main_vm.selected_filter_tag_set)
                            }
                        }){
                            
                            Text(main_vm.selected_filter_tag_list[tag_index])
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.custom(Font.n_bold, size: 14))
                                .foregroundColor(.proco_white)
                            
                        })
            }
        }
        .padding([.leading, .trailing])
    }
    
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

