//
//  EditGroupMemberView.swift
//  proco
//
//  Created by 이은호 on 2020/12/17.
//  친구관리 - 그룹 친구 편집하기 뷰

import SwiftUI
import Combine
import Kingfisher

struct EditGroupMemberView: View {
    //그룹 멤버 편집 완료 후 상세 페이지로 돌아갈 때 사용.
    @Environment(\.presentationMode) var presentationMode : Binding<PresentationMode>
    
    //아래 코드 필요 없는 것 같음 확인 필요****************presentaionmode사용해서 화면 이동하기 땜
    @ObservedObject  var manage_vm : ManageFriendViewModel
    @ObservedObject var detail_vm : GroupDetailViewmodel
    @State var friend_model : GetFriendListStruct
    
    //그룹에 속한 친구 저장하는 곳
    
    
    //이전 뷰로부터 group_idx값 전달 받음
    var current_group_idx: Int
    
    //----검색창 사용 변수들----
    //친구 검색창에 사용하는 변수
    @State private var searchText = ""
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @State private var isSearching = false
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @State private var end_search = false
    //추가를 한 친구인지 구분하기 위한 변수
    var is_selected: Bool {
        //선택했는지는 selected리스트 안에 담겨 있냐에 따라 결정됨.
        detail_vm.selected_friend_set.contains(friend_model.idx!)
    }
    //***********아래 코드 필요 없는 것 같음
    @State var end_add_group_member = false
    
    var body: some View {
        NavigationView{
        VStack {
            
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
                Text("친구 편집")
                    .font(.custom(Font.n_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
                
            }
            
            Group{
                
            EditGroupSearchFriendBar(detail_viewmodel: self.detail_vm, searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
                
                ScrollView{
                if end_search{
                    Text("검색 결과")
                        .font(.custom(Font.n_regular, size: 11))
                        .foregroundColor(.gray)
                
                        ForEach((detail_vm.friend_list_struct).filter({"\($0)".contains(searchText)}), id: \.self){
                            friend in
                            
                            EditFriendRow(viewmodel: self.detail_vm, friend_model: friend, searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
                        }
                    
                }else if (isSearching == false && end_search == false){
               
                        ForEach(0..<detail_vm.friend_list_struct.count, id: \.self){index in
                            VStack(alignment: .leading){
                                EditFriendRow(viewmodel: self.detail_vm, friend_model: self.detail_vm.friend_list_struct[index], searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
                            }
                        }
                }
            }
        }
            Button(action: {
                //뷰모델의 값에 선택한 친구들 배열 값 넣기
                self.detail_vm.updated_friend_list = Array(detail_vm.temp_selected_friend_set)
                
                //***************************편집 통신 편집하려는 그룹의 idx값은 상세 페이지 뷰모델에 저장했던 값 사용.
                detail_vm.edit_group_member(group_idx: self.current_group_idx, friends_idx: detail_vm.updated_friend_list)
                
                    print("그룹 멤버 편집 화면 전환 토글 값 true")
                    self.presentationMode.wrappedValue.dismiss()
              //통신 성공해서 ok가 아닐 경우 예외처리 해야함.**********************************
            }) {
                Text("확인")
                    .font(.custom(Font.t_regular, size: 21))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.proco_white)
                    .background(Color.proco_black)
                    .cornerRadius(25)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
            }
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .onAppear{
            print("********************************친구 편집뷰*****************************")
            //상세 페이지에서 받은 group idx값을 저장.
            self.detail_vm.edit_group_idx = self.current_group_idx
            print("친구 편집 뷰에서 이 그룹의 idx값 있는지 확인 : \(self.detail_vm.edit_group_idx)")
            
            //내 모든 친구 목록 가져오기 통신
            detail_vm.get_friend_list_and_fetch()
        }
        .onDisappear{
           // detail_vm.get_friend_list_and_fetch()
            
        }
        }
    }
}

struct EditFriendRow : View{
    
    @ObservedObject var viewmodel : GroupDetailViewmodel
    //친구 리스트 보여줄 때 사용하는 struct
    @State var friend_model : GetFriendListStruct
    @State var send_data : Bool = false
    
    //친구를 선택했는지 알 수 있는 변수 - selected_friend_set은 그룹 상세 데이터 가져왔을 때 저장해놓은 것.
    var is_selected: Bool {
        //선택했는지는 selected리스트 안에 담겨 있냐에 따라 결정됨.
        self.viewmodel.temp_selected_friend_set.contains(friend_model.idx ?? -1)
    }
    
    //친구 검색창에 사용하는 변수
    @Binding var searchText : String
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @Binding var isSearching: Bool
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @Binding var end_search: Bool
    
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: 38.23, height:38.23))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        VStack{
            if end_search{
                
                HStack {
                    HStack{
                        
                        if friend_model.profile_photo_path == "" || friend_model.profile_photo_path == nil{
                            
                            Image("main_profile_img")
                                .resizable()
                                .frame(width: 38.23,height:38.23 )
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
                        
                        HStack{
                            //친구 이름
                            Text(friend_model.nickname!)
                                .font(.custom(Font.n_bold, size: 14))
                                .foregroundColor(Color.proco_black)
                            
                            Spacer()
                        }
                        
                        HStack{
                            //선택 박스
                            Button(action: {
                                print("버튼 클릭: \(self.friend_model.idx)")
                                if self.is_selected{
                                    print("제거된 값 확인 : \(self.viewmodel.temp_selected_friend_set)")
                                    print("제거된 이름 확인 : \(String(describing: self.friend_model.nickname))")
                                    self.viewmodel.temp_selected_friend_set.remove(self.friend_model.idx ?? -1)
                                    
                                    let model_idx = self.viewmodel.group_details.firstIndex(where: {
                                        $0.idx! == self.friend_model.idx!
                                    }) ?? -1
                                    if model_idx != -1{
                                        self.viewmodel.group_details.remove(at: model_idx)
                                    }
                                }
                                else if self.is_selected == false{
                                    print("추가된 값 확인 : \(self.viewmodel.temp_selected_friend_set)")
                                    print("추가된 이름 확인 : \(String(describing: self.friend_model.nickname))")
                                    
                                    self.viewmodel.temp_selected_friend_set.insert(self.friend_model.idx ?? -1)
                                    
                                    self.viewmodel.group_details.append(GroupDetailStruct( idx: friend_model.idx!, nickname: friend_model.nickname!, profile_photo_path: friend_model.profile_photo_path ?? ""))
                                }
                            }){
                                if self.is_selected{
                                    
                                    Image("checked_small")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                                else{
                                    Image("check_small")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .frame(width: UIScreen.main.bounds.width*0.1, height: UIScreen.main.bounds.width*0.1)
                            .foregroundColor(Color.white)
                            .background(Color.white)
                        }
                    }
                }
                Divider()
                    .background(Color(.systemGray4))
                
            }else if (isSearching == false && end_search == false){
                HStack(alignment: .center){
                    if friend_model.profile_photo_path == "" || friend_model.profile_photo_path == nil{
                        
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 38.23,height:38.23 )
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
                    
                    HStack(spacing: UIScreen.main.bounds.width/10){
                        //친구 이름
                        Text(friend_model.nickname!)
                            .font(.custom(Font.n_bold, size: 14))
                            .foregroundColor(Color.proco_black)
                        Spacer()
                    }
                    
                    HStack{
                        //선택 박스
                        Button(action: {
                            print("버튼 클릭 친구 정보: \(self.friend_model.idx!)")
                            if self.is_selected{
                                self.viewmodel.temp_selected_friend_set.remove(self.friend_model.idx ?? -1 )
                                
                                let model_idx = self.viewmodel.group_details.firstIndex(where: {
                                    $0.idx! == self.friend_model.idx!
                                }) ?? -1
                                if model_idx != -1{
                                    self.viewmodel.group_details.remove(at: model_idx)
                                }
                            }
                            else if self.is_selected == false{
                                self.viewmodel.temp_selected_friend_set.insert(self.friend_model.idx ?? -1 )
                                
                                self.viewmodel.group_details.append(GroupDetailStruct( idx: friend_model.idx!, nickname: friend_model.nickname!, profile_photo_path: friend_model.profile_photo_path ?? ""))
                            }
                        }){
                            if self.is_selected{
                                Image("checked_small")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            else{
                                Image("check_small")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: UIScreen.main.bounds.width*0.1, height: UIScreen.main.bounds.width*0.1)
                        .foregroundColor(Color.white)
                        .background(Color.white)
                    }
                }
            }
        }
    }
    
}

struct EditGroupSearchFriendBar: View{//검색창에 입력되고 있는 텍스트
    @ObservedObject var detail_viewmodel : GroupDetailViewmodel
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @Binding var end_search: Bool
    
    @State var text: String = ""
    @State private var log: String = "Logs: "
    
    func get_count() -> Int{
        let search_result_count = detail_viewmodel.friend_list_struct.filter({"\($0)".contains(searchText)}).count
        return search_result_count
    }
    
    var body: some View {
        HStack {
            HStack {
                TextField("검색", text: $searchText, onCommit: {
                    
                    self.log.append("\n COMITTED!")
                    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
                    end_search =  true
                    self.get_count()
                })
                //검색 버튼이 있는 키보드 설정
                .keyboardType(.webSearch)
                .font(.custom(Font.n_regular, size: 14))
                .foregroundColor(self.searchText == "" ? Color.light_gray : Color.proco_black)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(25)
            .padding(.horizontal)
            //클릭시 isSearching이 true로 바뀌고 아래에 두가지 if문이 실행됨.
            .onTapGesture(perform: {
                isSearching = true
            })
            .overlay(
                HStack {
                    
                    //x버튼 클릭시 사용자가 모두 입력한 텍스트 초기화해주는 것.
                    if isSearching {
                        Button(action: { searchText = "" }, label: {
                            Image("x_btn")
                                .resizable()
                                .frame(width: 19, height: 19)
                        })
                    }
                }.padding(.horizontal, 32)
                .foregroundColor(.gray)
            ).transition(.move(edge: .trailing))
            .animation(.spring())
            
            //사용자가 검색 창 클릭한 후 입력하려고 할 때 cancel버튼 나타나는 애니메이션
            if isSearching {
                Button(action: {
                    
                    isSearching = false
                    searchText = ""
                    //키보드를 숨기는 메소드
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                }, label: {
                    Text("취소")
                        .font(.custom(Font.n_regular, size: 14))
                        .foregroundColor(Color.proco_black)
                })
                .transition(.move(edge: .trailing))
                .animation(.spring())
            }
            
        }
    }
}


