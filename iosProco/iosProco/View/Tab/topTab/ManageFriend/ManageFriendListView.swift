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
    
    //친구 클릭시 다이얼로그 띄울 때 친구 정보 저장 후 보여줄 때 사용하기 위함.
    @ObservedObject var friend_vm = FriendVollehMainViewmodel()
    
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
    
    //친구 한 명 클릭시 다이얼로그 보여주기
    @State private var show_friend_profile: Bool = false
    //친구 한 명 클릭시 state 상태
    @State private var friend_state : Int? = nil
    
    //친구 요청 모아놓은 목록 페이지 이동값
    @State private var go_friend_request_list : Bool = false
    
    //잠금 이벤트 완료 후 토스트 띄우기 위해 사용하는 구분값
    @State private var show_interest_alert : Bool = false
    @State private var interest_event_kind : String = ""
    
    var body: some View {
        
        VStack{
            title_bar
            
            NavigationLink("",destination: AllFriendRequestView(manage_vm: self.manage_vm, friend_total_num: self.$total_friend_num), isActive: self.$go_friend_request_list)
            
            ScrollView{
                VStack{
                    HStack{
                        Text("친구 요청 목록")
                            .font(.custom(Font.n_extra_bold, size: 16))
                            .foregroundColor(Color.proco_black)
                            .padding(.trailing)
                        Spacer()
                        
                        Image("right_light")
                            .resizable()
                            .frame(width: 5.38, height: 9.09)
                    }
                    .padding()
                    .onTapGesture {
                        print("친구 요청 목록 가기 클릭")
                        self.go_friend_request_list = true
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
                            
                            if friend_list_model.count > 0{
                                //친구 리스트 - 온라인
                                ForEach(self.friend_list_model.filter({
                                    $0.state == 1
                                }), id: \.self){friend in
                                    
                                    VStack(alignment: .leading){
                                        
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .foregroundColor(.proco_white)
                                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                            .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.2)
                                            .overlay(
                                                ManageFriendRow(manage_viewmodel: self.manage_vm, friend_model: friend, show_group_list_modal: self.$show_group_list_modal, ask_delete_friend_model: self.$ask_delete_friend_model, delete_frined_idx: self.$delete_friend_idx, show_interest_alert : self.$show_interest_alert,interest_event_kind: self.$interest_event_kind )
                                                    .padding()
                                                    .onTapGesture {
                                                        self.friend_vm.friend_info_struct.profile_photo_path = friend.profile_photo_path ?? ""
                                                        self.friend_vm.friend_info_struct.nickname = friend.nickname!
                                                        
                                                        self.friend_vm.friend_info_struct.idx
                                                            = friend.idx
                                                        //state값을 오버레이시 뷰에 넘겨줘야 하므로 값 따로 저장
                                                        self.friend_state = friend.state
                                                        
                                                        self.friend_vm.friend_info_struct.state = friend.state
                                                        
                                                        self.friend_vm.friend_info_struct = GetFriendListStruct(idx: friend.idx, nickname: friend.nickname!, profile_photo_path: friend.profile_photo_path ?? "", state: friend.state, kinds: friend.kinds)
                                                        
                                                        self.show_friend_profile = true
                                                    }
                                            )
                                    }
                                }
                                
                                ForEach(self.friend_list_model.filter({
                                    $0.state == 0
                                }), id: \.self){friend in
                                    
                                    VStack(alignment: .leading){
                                        
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .foregroundColor(.proco_white)
                                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                            .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.2)
                                            .overlay(
                                                ManageFriendRow(manage_viewmodel: self.manage_vm, friend_model: friend, show_group_list_modal: self.$show_group_list_modal, ask_delete_friend_model: self.$ask_delete_friend_model, delete_frined_idx: self.$delete_friend_idx, show_interest_alert : self.$show_interest_alert,interest_event_kind: self.$interest_event_kind )
                                                    .padding()
                                                    .onTapGesture {
                                                        self.friend_vm.friend_info_struct.profile_photo_path = friend.profile_photo_path ?? ""
                                                        self.friend_vm.friend_info_struct.nickname = friend.nickname!
                                                        
                                                        self.friend_vm.friend_info_struct.idx
                                                            = friend.idx
                                                        //state값을 오버레이시 뷰에 넘겨줘야 하므로 값 따로 저장
                                                        self.friend_state = friend.state
                                                        
                                                        self.friend_vm.friend_info_struct.state = friend.state
                                                        
                                                        self.friend_vm.friend_info_struct = GetFriendListStruct(idx: friend.idx, nickname: friend.nickname!, profile_photo_path: friend.profile_photo_path ?? "", state: friend.state, kinds: friend.kinds)
                                                        
                                                        self.show_friend_profile = true
                                                    }
                                            )
                                    }
                                }
                            }
                            
                        }else{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        Spacer()
                        
                    }
                    
                }
                //친구의 온오프라인 상태가 변경되었을 경우
                .onReceive(NotificationCenter.default.publisher(for: Notification.update_user_state), perform: {value in
                    print("사용자 상태 업데이트")
                    
                    if let user_info = value.userInfo, let check_result = user_info["user_idx"]{
                        let user_idx = user_info["user_idx"] as! String
                        let state  = user_info["state"] as! String
                        
                        print("바꾸기 전 \(friend_list_model)")
                        var index = friend_list_model.firstIndex(where: {
                            $0.idx == Int(user_idx)
                        }) ?? -1
                        if index != -1{
                            friend_list_model[index].state = Int(state)}
                        print("바꾼 후 \(friend_list_model)")
                    }
                })
                .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
                    
                    if let user_info = value.userInfo, let data = user_info["remove_friend"]{
                        print("친구 삭제 완료 받았음: \(data)")
                        
                        if data as! String == "ok"{
                            
                            let friend_idx = user_info["friend"] as! String
                            let model_idx =  self.friend_list_model.firstIndex(where: {
                                $0.idx == Int(friend_idx)
                            })
                            withAnimation(.spring()) {
                                self.friend_list_model.remove(at: model_idx!)
                                self.total_friend_num -= 1
                            }
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
                .onReceive( NotificationCenter.default.publisher(for: Notification.set_interest_friend)){value in
                    
                    if let user_info = value.userInfo, let data = user_info["set_interest_friend"]{
                        print("친구 관심친구 설정 노티 받았음: \(value)")
                        
                        if data as! String == "set_ok_관심친구"{
                            let friend_idx = Int(user_info["friend_idx"] as! String)
                            let index =
                                self.friend_list_model.firstIndex(where: {$0.idx == friend_idx}) ?? -1
                            if index != -1 { self.friend_list_model[index].kinds = "관심친구"}
                        }else if data as! String == "set_ok_관심친구해제"{
                            let friend_idx = Int(user_info["friend_idx"] as! String)
                            let index =
                                self.friend_list_model.firstIndex(where: {$0.idx == friend_idx}) ?? -1
                            if index != -1 { self.friend_list_model[index].kinds = "관심친구해제"}
                        }else{
                            print("관심친구 이벤트 오류 발생")
                        }
                        
                    }else{
                        print("관심친구 설정 노티 아님")
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
        .sheet(isPresented: self.$show_group_list_modal){
            GroupListModal(manage_viewmodel: self.manage_vm, manage_group_struct: self.manage_vm.manage_groups, show_modal: self.$show_group_list_modal)
        }
        .overlay(FriendStateDialog(main_vm: self.friend_vm, group_main_vm: GroupVollehMainViewmodel(), calendar_vm: CalendarViewModel(),show_friend_info: self.$show_friend_profile, socket: SockMgr.socket_manager, state_on: self.$friend_state, is_friend : true))
        .overlay(overlayView: self.interest_event_kind == "관심친구해제" ?  Toast.init(dataModel: Toast.ToastDataModel.init(title: "관심 친구를 취소했습니다.", image: "checkmark"), show: self.$show_interest_alert) :  Toast.init(dataModel: Toast.ToastDataModel.init(title: "관심친구로 설정했습니다.", image: "checkmark"), show: self.$show_interest_alert), show: self.$show_interest_alert)
        .overlay(overlayView:
                    manage_vm.active_friend_group_alert ==
                    .ok ?
                    Toast.init(dataModel: Toast.ToastDataModel.init(title: "그룹에 추가되었습니다.", image: "checkmark"), show: $manage_vm.show_add_friend_group_alert)
                    :   manage_vm.active_friend_group_alert == .duplicated ?
                    Toast.init(dataModel: Toast.ToastDataModel.init(title: "이미 그룹에 있습니다.", image: "checkmark"), show: $manage_vm.show_add_friend_group_alert) :
                    manage_vm.active_friend_group_alert == .fail ?
                    Toast.init(dataModel: Toast.ToastDataModel.init(title: "오류가 발생했습니다. 다시 시도해주세요", image: "checkmark"), show: $manage_vm.show_add_friend_group_alert) : nil, show: $manage_vm.show_add_friend_group_alert)
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
        
        HStack{
            Text(manage_group_struct.name!)
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
            
            Spacer()
            //클릭시 그룹 상세 페이지로 이동, 서버에 정보 요청 통신 코드, 뷰모델에 클릭한 그룹 이름 저장.
            Image("right_light")
                .resizable()
                .frame(width: 5.38, height: 9.09)
            
        }
        .padding()
        .onTapGesture {
            //1. 그룹 이름 Groupdetailviewmodel의 published에 저장(그룹 이름은 서버에서 안줌)
            detail_group_viewmodel.edit_group_name = self.manage_group_struct.name!
            print("상세 페이지 이동시 뷰모델에 이름 저장하는 값 확인 : \(detail_group_viewmodel.edit_group_name)")
            
            //2.선택한 그룹 인덱스 상세 페이지 뷰모델의 published에 문자로 변환해서 저장.
            manage_viewmodel.detail_group_idx = self.manage_group_struct.idx!
            print("선택한 그룹 인덱스값 저장됐는지 확인 : \(manage_viewmodel.detail_group_idx)")
            
            
            //3.상세 페이지 이동
            go_to_detail.toggle()
        }
        
    }
}

extension ManageFriendListView{
    
    var title_bar : some View{
        HStack{
            //돌아가기 버튼
            Button(action: {
                ViewRouter.get_view_router().fcm_destination = ""
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





