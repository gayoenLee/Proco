//
//  manage_friend_list_view.swift
//  proco
//
//  Created by 이은호 on 2020/11/16.
// 그룹관리의 메인 페이지

import SwiftUI
import Combine
import Kingfisher

struct ManageFriendListView: View {
    @Environment(\.presentationMode) var presentation
    
    //친구 편집, 삭제시 나오는 action sheet 구분자
    @State var show_friend_action: Bool = false
    @ObservedObject  var viewmodel = AddGroupViewmodel()
    
    //그룹 데이터 가져오는 데 사용하는 뷰모델
    @ObservedObject  var manage_vm = ManageFriendViewModel()
    //그룹 상세 페이지에서 이용되는 뷰모델
    @ObservedObject  var detail_group_vm = GroupDetailViewmodel()
    
    @State var selected_group : String = ""
    @State var go_to_detail : Bool = false
    
    @State private var go_to_add_group: Bool = false
    
    //모든 친구 리스트를 가져오기 위해서 넘겨주는 친구 데이터 모델.(내 원래 친구 리스트를 가져올 때는 뷰모델 안의 친구 데이터 모델을 사용.)
    @State var friend_model = GetFriendListStruct()
    //친구 신청 목록 데이터 모델
    @State var friend_request_model = FriendRequestListStruct()
    
    //그룹 리스트 모달 구분값
    @State private var show_group_list_modal = false
    //친구 추가하기 뷰로 이동하는데 이용하는 구분값
    @State private var go_plus_friend = false
    //친구 해제 한 번 더 물어보는 알림창
    @State var ask_delete_friend_model: Bool = false
    
    @State private var total_friend_num : Int = 0
    
    //친구 삭제 기능 - 친구 리스트 데이터 모델이 state여야함.
    @State private var friend_list_model = [GetFriendListStruct]()
    
    //삭제하려는 친구 idx값
    @State private var delete_friend_idx: Int = -1
    
    //그룹 리스트를 모두 가져오기 전 로딩 이미지 띄우기 위함 - 그룹 추가 후 뷰가 띄워지는게 이상해서 그룹 리스트에만 로딩 뷰 추가함.
    @State private var got_all_groups: Bool = false
    
    @State private var got_all_friends : Bool = false
    
    var body: some View {
        
        VStack{
            title_bar
            
            ScrollView{
                VStack{
                    HStack{
                        Text("친구 신청 목록")
                            .font(.custom(Font.n_extra_bold, size: 16))
                            .foregroundColor(Color.proco_black)
                        
                        Spacer()
                    }
                    .padding()
                    
                    if manage_vm.friend_request_struct.count <= 0{
                        Text("친구 신청한 사람이 없습니다.")
                            .font(.custom(Font.t_regular, size: 13))
                            .foregroundColor(Color.proco_black)
                        
                    }else{
                        ForEach(0..<manage_vm.friend_request_struct.count, id: \.self){row_index in
                            
                            FriendRequestRow(manage_viewmodel: self.manage_vm, request_struct: self.manage_vm.friend_request_struct[row_index], row_index: row_index, friend_total_num: self.$total_friend_num)
                                .padding([.leading, .trailing])
                        }
                    }
                    Group{
                        HStack{
                            Text("그룹")
                                .font(.custom(Font.n_extra_bold, size: 16))
                                .foregroundColor(Color.proco_black)
                                .padding(.trailing)
                            
                            //그룹 추가하기 버튼
                            plus_group_btn
                            
                            Spacer()
                            
                            //뷰모델 값 사용하지 말 것.
                            NavigationLink("", destination: AddGroupView(viewmodel: self.viewmodel, main_viewmodel: self.manage_vm, friend_model: self.friend_model).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true), isActive: $go_to_add_group)
                            
                        }
                        .padding([.leading, .trailing])
                        
                        //그룹 상세 페이지로 이동
                        NavigationLink(
                            "", destination: GroupDetailView(detail_group_vm:  self.detail_group_vm, manage_vm: self.manage_vm, friend_model: self.friend_model).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true),
                            isActive: self.$go_to_detail)
                        
                        //그룹 리스트를 모두 가져왔을 때만 리스트 보여주기
                        if self.got_all_groups{
                         
                                ForEach(manage_vm.manage_groups, id: \.self){group in
                                    
                                    ManageGroupRowView(manage_viewmodel: self.manage_vm, detail_group_viewmodel: self.detail_group_vm, manage_group_struct: group, go_to_detail: self.$go_to_detail, idx: group.idx, name: group.name)
                                }
                        }else{
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                    }
                    
                    //친구 목록
                    Group{
                        HStack{
                           
                            NavigationLink("", destination: PlusFriendView(manage_vm: self.manage_vm).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true), isActive: self.$go_plus_friend)
                            
                            Text("친구 총\(total_friend_num)명")
                                .font(.custom(Font.n_extra_bold, size: 16))
                                .foregroundColor(Color.proco_black)
                            
                            //친구 추가 페이지로 이동.
                            plus_friend_btn
                            Spacer()
                        }
                        .padding()
                        
                        if self.got_all_friends{
                        //친구 리스트
                        ForEach(self.friend_list_model, id: \.self){friend in
                            
                            VStack(alignment: .leading){
                                
                                RoundedRectangle(cornerRadius: 25.0)
                                    .foregroundColor(.proco_white)
                                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                    .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.2)
                                    .overlay(
                                        ManageFriendRow(manage_viewmodel: self.manage_vm, friend_model: friend, show_group_list_modal: self.$show_group_list_modal, ask_delete_friend_model: self.$ask_delete_friend_model, delete_frined_idx: self.$delete_friend_idx)
                                            .padding()
                                    )
                            }
                        }
                        }else{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        Spacer()
                        
                    }
                    .popover(isPresented: self.$show_group_list_modal){
                        GroupListModal(manage_viewmodel: self.manage_vm, manage_group_struct: self.manage_vm.manage_groups, show_modal: self.$show_group_list_modal)
                    }
                }
                .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
                    
                    if let user_info = value.userInfo, let data = user_info["remove_friend"]{
                        print("친구 삭제 완료 받았음: \(data)")
                        
                        if data as! String == "ok"{
                            
                            let friend_idx = user_info["friend"] as! String
                            let model_idx =  self.friend_list_model.firstIndex(where: {
                                $0.idx == Int(friend_idx)
                            })
                            self.friend_list_model.remove(at: model_idx!)
                        }
                    }else{
                        print("친구 삭제 완료 노티 아님")
                    }
                }
                .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
                    
                    if let user_info = value.userInfo, let data = user_info["got_all_friend"]{
                        print("친구 리스트 모두 가져온 통신 완료 받았음: \(data)")
                                    
                        self.friend_list_model = self.manage_vm.friend_list_struct
                        
                        let friend_num = user_info["friend_num"] as! String
                        self.total_friend_num = Int(friend_num)!
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                            self.got_all_friends = true
                        }
                    }else{
                        print("친구 리스트 모두 가져온 노티 아님")
                    }
                })
                .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
                    
                    if let user_info = value.userInfo, let data = user_info["got_all_groups"]{
                        print("그룹 리스트 모두 가져온 통신 완료 받았음: \(data)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                            
                        self.got_all_groups = true
                        }
                    }else{
                        print("그룹 리스트 모두 가져온 노티  아님")
                    }
                })
                .alert(isPresented: $manage_vm.show_add_friend_group_alert){
                    switch manage_vm.active_friend_group_alert{
                    case .ok:
                        print("그룹 추가 알림 이벤트 들어옴")
                        return Alert(title: Text("그룹 추가"), message: Text("그룹에 추가되었습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .duplicated:
                        print("그룹 추가 알림 이벤트 들어옴")
                        return  Alert(title: Text("그룹 추가"), message: Text("이미 그룹에 있습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .fail:
                        print("그룹 추가 알림 이벤트 들어옴")
                        return Alert(title: Text("그룹 추가"), message: Text("그룹 추가에 실패했습니다. 다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    }
                }
                .alert(isPresented: self.$ask_delete_friend_model){
                    Alert(title: Text("친구 삭제"), message: Text("친구에서 삭제하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                        print("삭제 확인 클릭")
                        
                        //친구해제 통신 성공 완료시 모델에서 해당 친구 삭제
                        self.manage_vm.delete_friend(f_idx: self.delete_friend_idx, action: "친구해제")
                        
                    }), secondaryButton: Alert.Button.cancel(Text("취소"), action: {
                        print("삭제 취소 클릭")
                        self.ask_delete_friend_model = false
                    }))
                }
                .onAppear{
                    //그룹 가져와서 fetch 통신
                    print("********************************친구관리 메인 나타남*****************************")
                    manage_vm.get_manage_data_and_fetch()
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.5, execute: {
                        
                    })
                }
                .onDisappear{
                    print("********************************친구관리 메인 사라짐*****************************")
                    self.got_all_groups = false
                }
            }
            .animation(.easeOut(duration: 0.3), value: manage_vm.friend_list_struct)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
    }
}


//그룹 한 row뷰 - idx값 받아야 함.
struct ManageGroupRowView : View{
    //여기에서 observedobject들은 초기화하지 않아야 값 저장, 전달이 가능함. 이것 때문에 상세 페이지에 값 저장, 전달 안됐었음.
    @ObservedObject var manage_viewmodel : ManageFriendViewModel
    @ObservedObject  var detail_group_viewmodel : GroupDetailViewmodel
    
    @State var manage_group_struct : ManageGroupStruct
    @Binding var go_to_detail : Bool
    
    var idx: Int?
    var name: String?
    
    var body: some View{
        VStack{
            
            HStack{
                Text(manage_group_struct.name!)
                    .font(.custom(Font.n_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
                //클릭시 그룹 상세 페이지로 이동, 서버에 정보 요청 통신 코드, 뷰모델에 클릭한 그룹 이름 저장.
                Button(action: {
                    
                    //1. 그룹 이름 Groupdetailviewmodel의 published에 저장(그룹 이름은 서버에서 안줌)
                    detail_group_viewmodel.edit_group_name = self.manage_group_struct.name!
                    print("상세 페이지 이동시 뷰모델에 이름 저장하는 값 확인 : \(detail_group_viewmodel.edit_group_name)")
                    
                    //2.선택한 그룹 인덱스 상세 페이지 뷰모델의 published에 문자로 변환해서 저장.
                    manage_viewmodel.detail_group_idx = self.manage_group_struct.idx!
                    print("선택한 그룹 인덱스값 저장됐는지 확인 : \(manage_viewmodel.detail_group_idx)")
                    
                    
                    //3.상세 페이지 이동
                    go_to_detail.toggle()
                }){
                    Image("right_light")
                        .resizable()
                        .frame(width: 5.38, height: 9.09)
                }
                .frame(width: 10, height: 10)
            }
            .padding()
        }
    }
}

extension ManageFriendListView{
    
    var title_bar : some View{
        HStack{
            //돌아가기 버튼
            Button(action: {
                
                self.presentation.wrappedValue.dismiss()
            }){
                Image("left")
                    .resizable()
                    .frame(width: 8.51, height: 17)
            }
            
            Spacer()
            Text("친구 관리")
                .font(.custom(Font.n_extra_bold, size: 22))
                .foregroundColor(Color.proco_black)
            Spacer()
        }
        .padding()
    }
    
    var plus_group_btn : some View{
        Button(action: {
            self.go_to_add_group.toggle()
            
        }){
            Image("black_plus_circle")
                .resizable()
                .frame(width: 20, height: 20)
        }
    }
    
    var plus_friend_btn : some View{
        Button(action: {
            
            print("친구 추가하기 버튼 클릭")
            self.go_plus_friend.toggle()
        }){
            Image("black_plus_circle")
                .resizable()
                .frame(width: 20, height: 20)
                .padding()
        }
    }
}





