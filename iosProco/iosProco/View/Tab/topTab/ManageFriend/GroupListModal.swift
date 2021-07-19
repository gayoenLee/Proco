//
//  GroupListModal.swift
//  proco
//
//  Created by 이은호 on 2021/05/27.
//

import SwiftUI

//친구 그룹에 추가시 나타나는 풀스크린 모달뷰
struct GroupListModal: View{
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var manage_viewmodel : ManageFriendViewModel
    
    @State var manage_group_struct : [ManageGroupStruct]
    @Binding var show_modal : Bool
    
    var body: some View{
        VStack{
            ScrollView{
            ForEach(self.manage_group_struct){group in
                //그룹1개 뷰
                GroupModalRow(manage_viewmodel: self.manage_viewmodel, manage_group_struct: group, show_modal: self.$show_modal)
            }
            }
            
            HStack{
                Button(action: {
                    
                    self.show_modal.toggle()
                    print("모달 닫기 버튼 클릭")
                    
                }){
                    
                    Text("취소")
                        .font(.custom(Font.t_regular, size: 18))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.proco_black)
                        .background(Color.proco_white)
                }
            }
            .padding()
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            print("***********모달 뷰 나타남*************")
        }
        .onDisappear{
            print("***********모달 뷰 사라짐*************")
            
        }
    }
}

struct GroupModalRow: View{
    //그룹 리스트를 보여주기 위해 사용하는 뷰모델과 데이터모델
    @ObservedObject var manage_viewmodel : ManageFriendViewModel
    @State var manage_group_struct : ManageGroupStruct
    @Binding var show_modal : Bool
    
    private func add_friend_to_group(){
        //선택한 그룹의 idx를 뷰모델에 저장해서 나중에 그룹 추가 통신시 사용(친구 이름은 모달 열때 미리 저장.)
        self.manage_viewmodel.selected_group_idx = self.manage_group_struct.idx!
        
        //그룹에 친구 추가하기 통신
        self.manage_viewmodel.add_friend_to_group()
        
        print("추가하려는 그룹 확인 : \(self.manage_viewmodel.selected_group_idx)")
        print("추가하려는 친구 확인 : \(self.manage_viewmodel.selected_friend_idx)")
        //추가한 후 통신 결과에 따라 alert창 띄우기 위함
        manage_viewmodel.show_ok_alert(manage_viewmodel.active_friend_group_alert)
        
        
    }
    
    var body: some View{
        HStack{
            Text(manage_group_struct.name!)
                .font(.custom(Font.n_bold, size: 20))
                .foregroundColor(Color.proco_black)
                .padding(.leading)
            Spacer()
        }
        .padding()
        .onTapGesture {
            print("그룹 한개 클릭: \(self.manage_group_struct.name!)")
            add_friend_to_group()
            self.show_modal.toggle()
        }
    }
}
