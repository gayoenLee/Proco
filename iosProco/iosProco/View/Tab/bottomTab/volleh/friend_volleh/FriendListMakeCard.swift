//
//  FriendListMakeCard.swift
//  proco
//
//  Created by 이은호 on 2020/12/22.
// 카드 만들 때 알릴 친구들 중 친구 리스트뷰

import SwiftUI

struct FriendListMakeCard: View {
    @ObservedObject var main_viewmodel : FriendVollehMainViewmodel
    @State var friend_model : GetFriendListStruct

    //친구 검색창에 사용하는 변수
    @Binding var search_text : String
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @Binding var is_searching: Bool
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @Binding var end_search: Bool
    
    var body: some View {
        HStack{
            //체크박스 클릭시 뷰모델에 set에 저장하고 배열로 변환해서 바로 array에도 저장.
            Button(action: {
                //선택한 그룹이 이미 선택됐던 거라면 뷰모델에 저장한 선택 리스트 안에서 제거.
                if main_viewmodel.show_card_friend_set.contains(self.friend_model.idx!){
                    main_viewmodel.show_card_friend_set.remove(self.friend_model.idx!)
                    main_viewmodel.show_card_friend_array = Array(main_viewmodel.show_card_friend_set)
                    print("이미 선택한 그룹 선택 후 리스트 확인 : \( main_viewmodel.show_card_friend_array)")
                    
                    //선택한 친구 카드 추가 메인에서 보여주기 위해 친구 idx를 키로 친구 이름도 삭제
                    main_viewmodel.show_card_friend_name.removeValue(forKey: self.friend_model.idx!)
                }else{
                    main_viewmodel.show_card_friend_set.insert(self.friend_model.idx!)
                    main_viewmodel.show_card_friend_array = Array(main_viewmodel.show_card_friend_set)
                    print("처음 그룹 선택 후 리스트 확인 : \( main_viewmodel.show_card_friend_array)")
                    
                    //선택한 친구 카드 추가 메인에서 보여주기 위해 친구 이름도 저장
                    main_viewmodel.show_card_friend_name.updateValue(self.friend_model.nickname!, forKey: self.friend_model.idx!)
                }
                
            }){
                if main_viewmodel.show_card_friend_set.contains(self.friend_model.idx!){
                    Image(systemName: "checkmark.circle.fill")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                    
                }else{
                    Image(systemName: "circle")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width/20 , height: UIScreen.main.bounds.width/20)
                    
                    
                }
            }
            .padding()
            
            Text(friend_model.nickname!)
                .padding()
            Spacer()
        }
    }
}

