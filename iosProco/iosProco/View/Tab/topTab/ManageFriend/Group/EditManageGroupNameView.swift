//
//  EditManageGroupNameView.swift
//  proco
//
//  Created by 이은호 on 2020/12/17.
// 친구관리 - 그룹관리 - 그룹 이름 변경

import SwiftUI
import Combine

struct EditManageGroupNameView: View {
    
    //그룹 이름 편집 후 상세 페이지로 돌아갈 때 사용.
    @Environment(\.presentationMode) var presentationMode
    //그룹 상세 페이지 관련해 모두 사용하는 뷰모델
    @ObservedObject var main_vm: GroupDetailViewmodel
    //**중요 : 선택한 그룹 위해 전달받은 뷰모델, 편집 완료 후 메인 페이지로 넘어갈 때 정보를 담아 보내줌. 그래야 메인 업데이트 가능함.
    @ObservedObject  var manage_vm : ManageFriendViewModel
    //이전 뷰로부터 group_idx값 전달 받음
    @State  var current_group_idx: Int
    
    //친구 데이터 모델
    @State var friend_model : GetFriendListStruct
    
    //편집하려는 그룹 이름
    @State private var group_name : String = ""
     
    //편집 후 메이뷰로 화면 이동값
   // @State private var edit_group_name_ok : Bool = false
    @State private var edit_group_name_error : Bool = false
    
    @Binding var edit_group_name_ok : Bool
    
    var body: some View {
        VStack{
            //네비게이션바처럼 보이도록 커스텀. - 그룹 편집 완료 버튼 있음.
            Group{
                HStack{
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }){
                        Image("left")
                            .resizable()
                            .frame(width: 8.51, height: 17)
                    }
                    .padding()
                    
                    Spacer()
                    Text("그룹 이름")
                        .font(.custom(Font.n_extra_bold, size: 22))
                        .foregroundColor(Color.proco_black)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 55, height: 37)
                        .foregroundColor(self.group_name == self.main_vm.edit_group_name || self.group_name == "" ? .gray : .proco_black)
                        .overlay(
                            Button(action: {
                                print("그룹 이름 편집 통신")
                                main_vm.edit_group_name_and_fetch(group_idx: main_vm.edit_group_idx, group_name: self.group_name)
                       
                            }, label: {
                                Text("확인")
                                    .font(.custom(Font.t_extra_bold, size: 15))
                                    .foregroundColor(Color.proco_white)
                            })
                            //원래 그룹 이름과 같거나 입력한 이름이 없으면 확인 버튼 비활성화
                            .disabled(self.group_name == self.main_vm.edit_group_name || self.group_name == ""))
                }
            }
            .padding()
            HStack{
            //처음에 들어갔을 때는 원래 그룹 이름을 보여준다.
            TextField(self.group_name, text: self.$group_name)
                //IOS14부터 onchange사용 가능
                .onChange(of: self.group_name) { value in
                    print("그룹 이름 편집 onchangee 들어옴")
                    if value.count > 15 {
                        print("그룹 이름 15글자 넘음")
                        self.group_name = String(value.prefix(15))
                    }
                }
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(Color.proco_black)
                .padding([.leading, .trailing])
                Spacer()
                
                Button(action: {
                    self.group_name = ""
                }){
                Image("x_btn")
                    .resizable()
                    .frame(width: 9.69, height: 9.7)
                    .padding(.trailing)
                }
            }
            Divider()
                .foregroundColor(Color.proco_black)
            Spacer()
            
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            
            print("그룹 이름 편집 통신 완료 노티 받음")
            if let user_info = value.userInfo, let data = user_info["edited_group_name"]{
                
                if data as! String == "ok"{
                    
                    self.main_vm.edit_group_name = self.group_name
                    print("편집한 그룹 이름 뷰모델에 저장했는지 확인: \(self.main_vm.edit_group_name)")
                    self.edit_group_name_ok = false
                    print("그룹 이름 편집 후 페이지 이동값 변경하기")
                    
                }else{
                    print("그룹 이름 편집 실패 다시 시도 알림창 띄우기")
                    self.edit_group_name_error = true
                }
            }else{
                print("그룹 이름 편집 노티 아님")
            }
        })
        .alert(isPresented: self.$edit_group_name_error, content: {
            Alert(title: Text("알림"), message: Text("다시 시도해주세요"), dismissButton: .default(Text("확인")))
        })
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear{
            print("*******************그룹 이름 편집 뷰 나타남*********************")
            //현재 그룹 이름을 편집하고 있는 그룹의 idx값을 뷰모델에 저장해야 그룹 이름 저장 통신시 사용 가능함.
            self.main_vm.edit_group_idx = self.current_group_idx
            self.group_name = main_vm.edit_group_name
            
        }
        .onDisappear{
            print("*******************그룹 이름 편집 뷰 사라짐*********************")
            manage_vm.manage_groups.removeAll()
        }
    }
}


