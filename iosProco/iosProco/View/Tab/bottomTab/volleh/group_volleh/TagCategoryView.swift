//
//  TagCategoryView.swift
//  proco
//
//  Created by 이은호 on 2020/12/27.
//

import SwiftUI

struct TagCategoryView: View {
    @ObservedObject var vm: GroupVollehMainViewmodel
    @State var tag_struct: VollehTagCategoryStruct

    //추가하려는 태그의 갯수가 3개를 넘으면 값이 true
    @State private var tag_num_over_three : Bool = false
    //카테고리는 한개만 선택할 수 있도록 예외처리 위해서 사용.
    @Binding var selected_category : String
    var is_for_filter : Bool

    var body: some View {
        //태그 3개 초과해서 추가하려고 할 경우 나타나는 경고 문구
        VStack{
            
            Capsule()
                        .foregroundColor(tag_struct.category_name == "사교/인맥" ? .proco_yellow : tag_struct.category_name == "게임/오락" ? .proco_pink : tag_struct.category_name == "문화/공연/축제" ? .proco_olive : tag_struct.category_name == "운동/스포츠" ? .proco_green : tag_struct.category_name == "취미/여가" ? .proco_mint : tag_struct.category_name == "스터디" ? .proco_blue : .proco_red )
                        .frame(width: 110, height: 40)
                .overlay(
        
        Button(action: {
            print("태그 카테고리 선택")
            
            //뷰모델에서 선택한 태그 갯수 체크하는 메소드의 결과값
            self.tag_num_over_three = vm.limit_tag_num(tag_list: self.vm.user_selected_tag_list)
            
            //태그 최대 3개까지만 선택 가능하도록 예외처리
            if tag_num_over_three{
                print("태그 카테고리 뷰에서 태그 3개넘음")
                
            }else if self.selected_category != "" && self.is_for_filter == false{
                print("태그 카테고리 이미 선택했음")
                   
               }
               else{
                print("태그 카테고리 뷰에서 태그 3개안넘음")
                
            //검색창에 추가됨
            vm.user_selected_tag_set.insert(tag_struct.category_name!)
                
            self.vm.user_selected_tag_list = Array(self.vm.user_selected_tag_set)
                
                self.selected_category = tag_struct.category_name!
            print("태그 카테고리 뷰모델에 넣어졌는지 확인 : \(self.vm.user_selected_tag_list)")
            }
        }){
            HStack{
                Image(self.selected_category == tag_struct.category_name! ? "category_checked" : "tag_plus")
                    .resizable()
                    .frame(width: 8, height:9)
                    .padding(.leading, UIScreen.main.bounds.width/30)
                
                Text(tag_struct.category_name!)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .foregroundColor(.proco_white)
                    .padding(.trailing, UIScreen.main.bounds.width/60)
            }
        })

        }
        
    }
}
