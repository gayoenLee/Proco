//
//  add_group_view.swift
//  proco
//
//  Created by 이은호 on 2020/11/19.
// 친구관리 - 그룹 추가뷰

import SwiftUI
import Combine
import Kingfisher

struct AddGroupView: View {
    //그룹 추가 완료 클릭시 이용해서 창 닫고 메인으로 돌아감.
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject  var viewmodel : AddGroupViewmodel
    //메인으로 돌아갈 때 추가한 친구 데이터 넘겨주기 위해 메인 뷰모델이 필요함.
    @ObservedObject var main_viewmodel : ManageFriendViewModel
    //모든 친구 리스트를 가져오기 위해서 넘겨주는 친구 데이터 모델.(내 원래 친구 리스트를 가져올 때는 뷰모델 안의 친구 데이터 모델을 사용.)
    @State var friend_model : GetFriendListStruct
    
    //그룹 추가 완료시 그룹 메인으로 이동
    @State private var add_group_ok : Bool = false
    //친구 추가 화면으로 이동
    @State private var go_to_add_friend : Bool = false
    //친구 추가 후 데이터 전달 구분 위한 변수
    @State private var send_data : Bool = false
    
    //그룹 추가 후 토스트 띄우기 위한 구분값
    @State private var show_add_result : Bool = false
    //그룹 추가 후 결과별로 토스트 띄우기 위해 결과 저장할 변수
    @State private var add_result_txt : String = ""
    
    var body: some View {
        
        //네비게이션 바 처럼 보이기 위해 커스텀. - 그룹 추가 완료 버튼 있음.
        VStack{
            HStack{
                //돌아가기 버튼
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    
                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                }
                .padding()
                
                Spacer()
                
                Text("그룹추가")
                    .font(.custom(Font.n_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
                //완료 버튼 클릭시 그룹 이름, 친구 목록 서버로 보내는 통신 시작, 그룹 관리 메인으로 이동.
                //그룹 추가 완료 클릭 후 result가 ok일 때 다음 화면으로 전환시키기
                //********************아래 코드 필요 없는 것 같음. 확인하기
                NavigationLink("",
                               destination: ManageFriendListView(),
                               isActive: $add_group_ok)
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 55, height: 37)
                    .foregroundColor(self.viewmodel.input_group_name == "" ? .gray: .proco_black)
                    .overlay(
                        Button(action: {
                            
                            print("그룹 추가 클릭,추가되는 친구들 리스트 확인 : \(self.viewmodel.added_friend_list)")
                            viewmodel.add_group()
                            /////////////
                            self.presentation.wrappedValue.dismiss()
                            
                        }){
                            Text("확인")
                                .font(.custom(Font.t_extra_bold, size: 15))
                                .foregroundColor(Color.proco_white)
                        }
                        //그룹 이름을 적지 않았을 경우 버튼 비활성화
                        .disabled(self.viewmodel.input_group_name == "")
                    )
            }
            .padding()
            
            Group{
                HStack{
                    Text("그룹 이름")
                        .font(.custom(Font.n_extra_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                    
                    Spacer()
                }
                .padding()
                
                HStack{
                    TextField("그룹 이름을 입력하세요", text: self.$viewmodel.input_group_name)
                        //IOS14부터 onchange사용 가능
                        .onChange(of: self.viewmodel.input_group_name) { value in
                            print("그룹 이름 편집 onchangee 들어옴")
                            if value.count > 15 {
                                print("그룹 이름 15글자 넘음")
                                self.viewmodel.input_group_name = String(value.prefix(15))
                            }
                        }
                        .padding(.leading, UIScreen.main.bounds.width/20)
                        .keyboardType(.default)
                        .font(.custom(Font.n_regular, size: 15))
                        .foregroundColor(self.viewmodel.input_group_name == "" ? .light_gray : .proco_black)
                    
                    Button(action: {
                        
                        print("엑스 버튼 클릭")
                        self.viewmodel.input_group_name = ""
                        
                    }){
                        Image("x_btn")
                            .resizable()
                            .frame(width: 8.69, height: 8.7)
                    }
                }
                .padding()
                Divider()
            }
            Group{
                HStack{
                    Text("친구 목록")
                        .font(.custom(Font.n_extra_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                    Spacer()
                }
                .padding()
                
                //친구 추가하기 아이콘 클릭시 친구 추가 화면으로 이동.
                HStack{
                    
                    Button(action: {
                        //친구 추가하기 버튼 클릭시 친구 추가 화면으로 넘기기 위해 toggle
                        
                        self.go_to_add_friend.toggle()
                        
                    }){
                        Image("black_plus_circle")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    
                    Text("친구 추가하기")
                        .font(.custom(Font.n_bold, size: 15))
                        .foregroundColor(Color.proco_black)
                    
                    Spacer()
                }
                .padding()
                
                ForEach(viewmodel.show_selected_member()){friend in
                    
                    GroupFriendListView(friend_model:friend)
                }
                Spacer()
                
            }
        }
        //키보드 올라왓을 때 화면 다른 곳 터치하면 키보드 내려가는 것
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .sheet(isPresented: self.$go_to_add_friend, content: {
            PlusGroupMemberView(viewmodel: self.viewmodel, friend_model: self.friend_model)
                .navigationBarHidden(true)
                .navigationBarTitle("", displayMode: .inline)
        })
        .overlay(overlayView: self.add_result_txt == "group_name duplicated" ? Toast.init(dataModel: Toast.ToastDataModel.init(title: "이미 존재하는 그룹 이름입니다.", image: "exclamationmark.triangle.fill"), show: $show_add_result)  : Toast.init(dataModel: Toast.ToastDataModel.init(title: "다시 시도해주세요", image: "exclamationmark.triangle.fill"), show: $show_add_result) , show: $show_add_result)
        .onReceive(NotificationCenter.default.publisher(for: Notification.event_finished), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["add_group"]{
                print("그룹 추가 이벤트 \(value)")
                
                if data as! String == "ok"{
                    add_result_txt = "ok"
                    self.show_add_result = true
                   
                }else if data as! String == "group_name duplicated"{
                    add_result_txt = "group_name duplicated"
                    self.show_add_result = true
                    
                }else if data as! String == "error"{
                    add_result_txt = "error"
                    self.show_add_result = true
                }
            }else{
                print("캘린더 주인 프로필 클릭 이벤트 노티 아님")
            }
        })
        //친구 리스트 끝
        .onAppear{
            print("********************************그룹 추가뷰 나타남*****************************")
            print("그룹관리 메인에서 선택한 친구 리스트들 확인 : \(viewmodel.selected_friend_set)")
        }
        .onDisappear{
            main_viewmodel.manage_groups.removeAll()
            viewmodel.selected_friend_set.removeAll()
            viewmodel.input_group_name = ""
            main_viewmodel.get_manage_data_and_fetch()
            print("********************************그룹 추가뷰 닫음*****************************")
        }
        //body끝
    }
}
//친구 목록 리스트 뷰
struct GroupFriendListView: View{
    //아래 identifiable 부분의 friend
    @State var friend_model : GetFriendListStruct
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: 44.86, height:45.25))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        VStack{
            HStack(alignment: .center){
                
                if friend_model.profile_photo_path == "" || friend_model.profile_photo_path == nil{
                    
                    Image("main_profile_img")
                        .resizable()
                        .frame(width: 44.86, height: 45.25)
                    
                }else{
                    
                    KFImage(URL(string: friend_model.profile_photo_path!))
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
                
                VStack(spacing: UIScreen.main.bounds.width/10){
                    HStack{
                        //친구 이름
                        Text(friend_model.nickname ?? "")
                            .font(.custom(Font.n_bold, size: 16))
                            .foregroundColor(Color.proco_black)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}


