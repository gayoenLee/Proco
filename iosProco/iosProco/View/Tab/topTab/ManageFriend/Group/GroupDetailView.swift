//
//  group_detail_view.swift
//  proco
//
//  Created by 이은호 on 2020/11/19.
// 친구관리 - 그룹리스트중 1개 그룹 상세 페이지

import SwiftUI
import Combine
import Alamofire
import Kingfisher

//이전 뷰에서 그룹 이름을 받는다 > 친구 데이터중 받은 그룹 이름이 포함된 친구 목록만 보여준다.
struct GroupDetailView: View {
    @Environment(\.presentationMode) var presentation

    //상세페이지 뷰모델, 그룹 이름 편집시 현재 그룹 이름을 저장할 때도 사용
    @ObservedObject var detail_group_vm : GroupDetailViewmodel
    //그룹 idx값을 갖고 오기 위해 전달받은 뷰모델
    @ObservedObject  var manage_vm : ManageFriendViewModel
    
    //그룹 멤버 편집시 넘겨주는 모델
    @State var friend_model : GetFriendListStruct
    
    /*
         해당 그룹에 속한 친구 리스트 - 처음에 데이터 통신시 noti로 받아서 데이터 넣어줌.
     -> 그룹 멤버 편집시 넘겨주는 모델이므로 편집 데이터가 바로 반영돼야하기 때문
    */
    @State var group_detail_friends : [GroupDetailStruct]  = []
    
    //----화면 이동 사용 변수들----
    //친구관리 메인 페이지로 이동시 사용하는 구분값
    @State private var go_to_manage_main : Bool = false

    @State private var go_to_edit_name : Bool = false
    @State private var go_to_edit_member : Bool = false
    
    //그룹 삭제 실패시 알림창 띄우기
    @State private var delete_group_fail : Bool = false
    
    @State private var ask_delete_group : Bool = false
    
    //친구 목록 보여주는데 텀 주기 위해 사용.
    @State private var show_friends_list : Bool = false
    
    var body: some View {
        VStack{
            
            HStack{
                //돌아가기 버튼
                Button(action: {
                    withAnimation{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
                        
                    self.presentation.wrappedValue.dismiss()
                    }
                    }
                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                }
                Spacer()
            }
            .padding([.leading])

            NavigationLink("",destination:
                EditGroupMemberView(manage_vm: self.manage_vm, detail_vm: self.detail_group_vm, friend_model: friend_model, current_group_idx: manage_vm.detail_group_idx), isActive: self.$go_to_edit_member)
            
                HStack{
                    Text(detail_group_vm.edit_group_name+" 입니다")
                        .font(.custom(Font.n_extra_bold, size: 22))
                        .foregroundColor(Color.proco_black)
                    
                        //수정하기 버튼
                    Button(action: {
                        self.go_to_edit_name.toggle()
                    }){
                        Image("pencil_line_icon")
                            .resizable()
                            .frame(width: 16.49, height: 16.62)
                    }
                    
                    //그룹 삭제하기 버튼
                    Button(action: {
                        print("그룹 삭제하기 버튼 클릭")
                        self.ask_delete_group = true
                       
                    }){
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 16.49, height: 16.62)
                            .foregroundColor(Color.proco_black)
                    }
                    Spacer()
                }
                .padding()
                
                Divider()
            
            //그룹 멤버 리스트들
                    if (detail_group_vm.group_details.count <= 0){
                        
                        Text("아직 멤버가 없습니다.")
                            .font(.custom(Font.n_bold, size: 16))
                            .foregroundColor(.gray)
                        
                    }else{
                        if show_friends_list{
                            if detail_group_vm.selected_friend_set.count > 0{
                            //그룹에 속한 친구들의 데이터 갯수만큼 foreach반복
                            ForEach(detail_group_vm.show_selected_member()){ friend in
                                
                                GroupMemberRowView(group_detail_struct: friend)
                                    .padding(.leading)
                            }
                            }else{
                                Text("아직 멤버가 없습니다.")
                                    .font(.custom(Font.n_bold, size: 16))
                                    .foregroundColor(.gray)
                            }
                        }else{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
             
                    }
            
            //그룹 멤버 편집하기로 이동하는 버튼
            HStack{
                    Button(action: {
                        //친구 추가하기 버튼 클릭시 친구 추가 화면으로 넘기기 위해 toggle
                        self.go_to_edit_member.toggle()
                        
                    }){
                        HStack{
                            Image("black_plus_circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                                Text("친구 추가하기")
                                    .font(.custom(Font.n_bold, size: 15))
                                    .foregroundColor(Color.proco_black)
                        }
                    }
                    .alert(isPresented: self.$delete_group_fail, content: {
                        Alert(title: Text("알림"), message: Text("다시 시도해 주세요"), dismissButton: .default(Text("확인")))
                    })
                    .alert(isPresented: self.$ask_delete_group) {
                        Alert(title: Text("그룹 삭제"), message: Text("그룹을 삭제하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                            
                            detail_group_vm.delete_group(group_idx: manage_vm.detail_group_idx)
                        }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                            self.ask_delete_group = false
                        }))
                    }
                
                Spacer()
            }
            .padding(.leading)
            Spacer()
        }
        .popover(isPresented: self.$go_to_edit_name, content: {
            
            EditManageGroupNameView(main_vm: self.detail_group_vm, manage_vm: self.manage_vm, current_group_idx: self.manage_vm.detail_group_idx, friend_model: self.friend_model, edit_group_name_ok: self.$go_to_edit_name)
        })
    
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            print("그룹관리 - 친구 리스트 가져온 이벤트 받음")
            
            if let user_info = value.userInfo, let data = user_info["get_group_friend"]{
                print("그룹관리 - 친구 리스트 데이터 \(data)")
                
                if data as! String == "ok"{
                    
                    //선택한 친구들 set
            
                    
                    self.group_detail_friends = self.detail_group_vm.group_details
                    
                }
            }else{
                print("그룹관리 - 친구 리스트 데이터 노티 아님")
            }
        })
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            print("그룹관리 - 그룹 삭제 완료 이벤트 받음")
            
            if let user_info = value.userInfo, let data = user_info["delete_group"]{
                print("그룹 삭제 완료 노티 받음")
                
                if data as! String == "ok"{
                
                    self.presentation.wrappedValue.dismiss()
                    
                }else{
                    print("그룹 삭제 실패")
                    self.delete_group_fail = true
                }
            }else{
                print("그룹관리 - 친구 리스트 데이터 노티 아님")
            }
        })
        //네비게이션바 bottom margin없애기 위한 코드
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear{
            print("*******그룹 상세 페이지 나타남****이전 페이지에서 받은 그룹 이름: \(detail_group_vm.edit_group_name)********************************, 모든 친구 리스트: \(self.detail_group_vm.friend_list_struct)")
            
            self.detail_group_vm.get_friend_list_and_fetch()
        }
        .onDisappear{
            print("*******그룹 상세 페이지 사라짐****************************************************")
            //친구 추가하기 뷰를 네비게이션 링크로 변경하면서 아래 코드를 실행하면 데이터가 없어져서 주석처리.
//            self.detail_group_vm.selected_friend_set.removeAll()
//            self.detail_group_vm.temp_selected_friend_set.removeAll()
//            self.detail_group_vm.group_details.removeAll()
        }
        .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["got_all_friend_detail"]{
                print("그룹 상세 페이지에서 친구 리스트 모두 가져온 통신 완료 받았음: \(data)")
                            //그룹 상세 페이지 데이터 - 해당 그룹에 속한 친구 리스트 가져오는 통신
                            detail_group_vm.get_group_detail_and_fetch(group_idx: manage_vm.detail_group_idx)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    self.show_friends_list = true
                }
            }else{
                print("친구 리스트 모두 가져온 노티 아님")
            }
        })
    }
    
}

struct GroupMemberRowView: View{
    
    @State var group_detail_struct : GroupDetailStruct
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: 44.86, height: 44.86))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        
        HStack{
                    if group_detail_struct.profile_photo_path == nil || group_detail_struct.profile_photo_path == ""{
                        
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 44.86, height: 44.86)
                           
                    }else{
                   
                        KFImage(URL(string: group_detail_struct.profile_photo_path!))
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .fade(duration: 0.25)
                            .setProcessor(img_processor)
                            .onProgress{receivedSize, totalSize in
                                print("on progress: \(receivedSize), \(totalSize)")
                            }
                            .onSuccess{result in
                                print("성공 : \(result)")
                            }
                            .onFailure{error in
                                print("실패 이유: \(error)")
                            }
                    }
                
                Text(group_detail_struct.nickname!)
                    .foregroundColor(Color.proco_black)
                    .font(.custom(Font.n_bold, size: 16))
                
                Spacer()
            }
    }
}



