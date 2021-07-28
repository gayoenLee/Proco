//
//  GroupListMakeCard.swift
//  proco
//
//  Created by 이은호 on 2020/12/22.
// 카드 만들기, 편집시 알릴 친구들 중 그룹 리스트뷰

import SwiftUI

struct GroupListMakeCard: View {
    @ObservedObject var main_viewmodel : FriendVollehMainViewmodel
    @State var group_struct : ManageGroupStruct
    
    //친구 검색창에 사용하는 변수
    @Binding var search_text : String
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @Binding var is_searching: Bool
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @Binding var end_search: Bool
    
    var is_selected: Bool{
        main_viewmodel.show_card_group_set.contains(group_struct.idx ?? -1)
    }
    
    
    var body: some View {
        HStack{
            
            Text(group_struct.name!)
                .padding()
            
            Spacer()

            //체크박스 클릭시 뷰모델에 set에 저장하고 배열로 변환해서 바로 array에도 저장.
            //카드 추가 페이지에서 선택한 그룹 및 친구 리스트로 보여주기 위해 이름,
            Button(action: {
                
                //선택한 그룹이 이미 선택됐던 거라면 뷰모델에 저장한 선택 리스트 안에서 제거.
                if is_selected{
                    
                    main_viewmodel.show_card_group_set.remove(self.group_struct.idx!)
                    
                    print("이미 선택한 그룹 선택 후 리스트 확인 : \( main_viewmodel.show_card_group_array)")
                    
                }else if is_selected == false{
                    
                    main_viewmodel.show_card_group_set.insert(self.group_struct.idx!)
                  
                    print("처음 그룹 선택 후 리스트 확인 : \( main_viewmodel.show_card_group_array)")
                    
                    print("선택한 그룹 이름 딕셔너리에 저장했는지 확인 : \(String(describing: main_viewmodel.show_card_group_name[self.group_struct.idx!]))")
                }
                
            }){
                if self.is_selected{
                    
                    Image("checked_square")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                    
                }else{
                    Image("unchecked_square")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width/20 , height: UIScreen.main.bounds.width/20)
                    
                    
                }
            }
            .padding()
            
        }
    }
}

