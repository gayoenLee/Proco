//
//  FriendFIlterModal.swift
//  proco
//
//  Created by 이은호 on 2020/12/27.
// 친구랑 볼래 필터 모달

import SwiftUI

struct FriendFilterModal: View {
    @Binding var show_filter_modal : Bool
    @ObservedObject var viewmodel: FriendVollehMainViewmodel
    
    @State private var selected_category : String = ""
    var body: some View {
        
        VStack{
            //상단 제목 라인
            HStack{
                Button(action: {
                    
                    show_filter_modal.toggle()
                    
                }, label: {
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                })
                .padding(.leading, UIScreen.main.bounds.width/20)
                
                Spacer()
                
                Text("필터")
                    .font(.custom(Font.t_extra_bold, size: 20))
                    .foregroundColor(.proco_black)
                    .padding(.trailing, UIScreen.main.bounds.width/20)
                
                Spacer()
                Image("rewind_btn")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                    .padding()
            }
            //            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*0.3)
            
            HStack{
                Text("심심태그")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                Text("최대 3개")
                    .font(.custom(Font.n_regular, size: 10))
                    .foregroundColor(.gray)
                Spacer()
                
            }
            .padding()
            //태그 카테고리 뷰
            tag_list
            
            //사용자가 선택한 태그값이 있을 때 이곳에 태그 리스트 보여줌.
            //이곳에서 다시 태그 클릭했을 때 삭제
            if viewmodel.user_selected_tag_list.count > 0{
                ScrollView(.horizontal, showsIndicators: false){
                    selected_tag_list
                }
            }
            HStack{
                Text("심심날짜")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                Spacer()
            }
            
            DatePicker("", selection: $viewmodel.filter_start_date, displayedComponents: [.date])
                .datePickerStyle(GraphicalDatePickerStyle())
            
            Button(action: {
                //date -> string변환
                self.viewmodel.date_to_string()
                self.viewmodel.friend_volleh_filter()
                show_filter_modal.toggle()
            }, label: {
                Text("확인")
            })
        }
        .padding(.all)
    }
}

extension FriendFilterModal {
    
    var tag_list : some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                
                ForEach(0..<viewmodel.volleh_category_tag_struct.count, id: \.self){ category_index in
                    //태그 카테고리 뷰
                    //1개 클릭시 뷰모델에 user_selected_tag_set에 저장됨.
                    VollehTagCategoryView(viewmodel: self.viewmodel, category_model: self.viewmodel.volleh_category_tag_struct[category_index], selected_category: self.$selected_category, is_for_filter: true)
                    
                }.padding(.leading, UIScreen.main.bounds.width/60)
            }
        }.frame(height: UIScreen.main.bounds.width/5)
    }
    var selected_tag_list : some View{
        HStack{
            
            ForEach(0..<viewmodel.user_selected_tag_list.count, id: \.self){ tag_index in
                Image("small_x")
                    .resizable()
                    .frame(width: 7, height: 7)
                
                Capsule()
                    .foregroundColor(viewmodel.user_selected_tag_list[tag_index] == "사교/인맥" ? .proco_yellow : viewmodel.user_selected_tag_list[tag_index] == "게임/오락" ? .proco_pink : viewmodel.user_selected_tag_list[tag_index] == "문화/공연/축제" ? .proco_olive : viewmodel.user_selected_tag_list[tag_index] == "운동/스포츠" ? .proco_green : viewmodel.user_selected_tag_list[tag_index] == "취미/여가" ? .proco_mint : viewmodel.user_selected_tag_list[tag_index] == "스터디" ? .proco_blue : .proco_red )
                    .frame(width: 90, height: 22)
                    .overlay(
                        Button(action: {
                            print("선택한 태그 리스트들 확인\(viewmodel.user_selected_tag_list) ")
                            
                            print("선택한 태그 리스트들 중 현재 선택한 것 확인 : \(viewmodel.user_selected_tag_list[tag_index])")
                            if viewmodel.user_selected_tag_set.contains(viewmodel.user_selected_tag_list[tag_index]){
                                print("이미 선택한 태그")
                                viewmodel.user_selected_tag_set.remove(viewmodel.user_selected_tag_list[tag_index])
                                self.viewmodel.user_selected_tag_list = Array(self.viewmodel.user_selected_tag_set)
                                
                            }else{
                                print("새로 선택한 태그")
                                viewmodel.user_selected_tag_set.insert(viewmodel.user_selected_tag_list[tag_index])
                                self.viewmodel.user_selected_tag_list = Array(self.viewmodel.user_selected_tag_set)
                            }
                        }){
                            
                            Text(viewmodel.user_selected_tag_list[tag_index])
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.custom(Font.n_bold, size: 14))
                                .foregroundColor(.proco_white)
                            
                        })
            }
        }
    }
}

