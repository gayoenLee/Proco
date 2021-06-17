//
//  FilterCategoryView.swift
//  proco
//
//  Created by 이은호 on 2021/06/16.
//

import SwiftUI

struct FilterCategoryView: View {
    
    @ObservedObject var viewmodel: FriendVollehMainViewmodel
    @State var category_model: VollehTagCategoryStruct
    //추가하려는 태그의 갯수가 3개를 넘으면 값이 true
    @State private var tag_num_over_three : Bool = false
    //카테고리는 유저가 직접 작성한 태그와 구분해서 보내고 저장해야함.
    @Binding var selected_category : String
    var is_for_filter : Bool
    
    var body: some View {
        VStack{
            Capsule()
                        .foregroundColor(category_model.category_name == "사교/인맥" ? .proco_yellow : category_model.category_name == "게임/오락" ? .proco_pink : category_model.category_name == "문화/공연/축제" ? .proco_olive : category_model.category_name == "운동/스포츠" ? .proco_green : category_model.category_name == "취미/여가" ? .proco_mint : category_model.category_name == "스터디" ? .proco_blue : .proco_red )
                        .frame(width: 110, height: 50)
                .overlay(
            Button(action: {
                print("태그 카테고리 선택")
                //뷰모델에서 선택한 태그 갯수 체크하는 메소드의 결과값
                self.tag_num_over_three = viewmodel.limit_tag_num(tag_list: self.viewmodel.selected_filter_tag_list)
                
                //태그 최대 3개까지만 선택 가능하도록 예외처리
                if tag_num_over_three{
                    print("태그 카테고리 뷰에서 태그 3개넘음")
                    
                }else if self.selected_category != "" && self.is_for_filter == false{
                 print("태그 카테고리 이미 선택했음")
                    
                }
                else{
                    print("태그 카테고리 뷰에서 태그 3개안넘음")
                    
                    //검색창에 추가됨
                    viewmodel.selected_filter_tag_set.insert(category_model.category_name!)
                    
                    self.viewmodel.selected_filter_tag_list = Array(self.viewmodel.selected_filter_tag_set)
                    
                    //이 파라미터에 저장해서 카드 만들기 페이지에서 서버에 보내거나 보여줄 때 사용.
                    self.selected_category = category_model.category_name!
                    print("태그 카테고리 뷰모델에 넣어졌는지 확인 : \(self.viewmodel.selected_filter_tag_list)")
                }
            }){
                HStack{
                    Image(self.selected_category == category_model.category_name! ? "category_checked" : "tag_plus")
                        .resizable()
                        .frame(width: 8, height:9)
                        .padding(.leading, UIScreen.main.bounds.width/30)
                    
                    Text(category_model.category_name!)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(.custom(Font.t_extra_bold, size: 15))
                        .foregroundColor(.proco_white)
                        .padding(.trailing, UIScreen.main.bounds.width/60)
                }
            })
        }
        }
}
