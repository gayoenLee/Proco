//
//  plusFriendModal.swift
//  proco
//
//  Created by 이은호 on 2020/11/22.
// 친구관리 - 그룹추가 - 친구 추가 버튼 클릭시 친구 목록 나오는 뷰.

import SwiftUI
import Combine
import Alamofire
import Kingfisher

struct PlusGroupMemberView: View {
    //친구 추가 완료 후 아래 코드 이용해 닫음.
    @Environment(\.presentationMode) var presentation
    //그룹관리 - 그룹 추가뷰모델
    @ObservedObject var viewmodel : AddGroupViewmodel
    
    //친구 선택했는지 여부 값에 친구의 idx값 저장할 때 사용
    @State var friend_model : GetFriendListStruct

    //친구 선택시 사용하는 변수
    var is_selected: Bool {
        //친구를 선택했는지는 selected리스트 안에 담겨 있냐에 따라 결정됨.
        viewmodel.selected_friend_set.contains(friend_model.idx!)
    }
    
    //---검색 관련해서 사용 변수들---
    //친구 검색창에 사용하는 변수
    @State var searchText = ""
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @State var isSearching = false
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @State var end_search = false

    var body: some View {
        
        VStack {
            
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
            Text("친구 편집")
                .font(.custom(Font.t_extra_bold, size: 18))
                .foregroundColor(.proco_black)
                Spacer()
            }
            .padding()
            //친구 검색바.
            SearchFriendBarInManage(viewmodel: self.viewmodel, searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
          
            //검색바에서 완료 버튼을 누른 경우의 뷰
            if end_search{
                HStack{
                Text("검색 결과")
                    .font(.custom(Font.n_regular, size: 11))
                    .foregroundColor(.gray)
                    
                    Spacer()
                }.padding()
                    ForEach((viewmodel.friend_list_struct).filter({"\($0)".contains(searchText)}), id: \.self){
                        friend in
                        PlusFriendRow(viewmodel: self.viewmodel, friend_model: friend, searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
                            .padding()
                    }
                
                //검색을 하지 않을 때 뷰. 모든 친구 리스트를 보여준다.
            }else if (isSearching == false && end_search == false){
                
                Text("친구")
                    .font(.custom(Font.n_regular, size: 11))
                    .foregroundColor(.gray)

                    ForEach(self.viewmodel.friend_list_struct){friend in
                        VStack(alignment: .leading){
                            
                            PlusFriendRow(viewmodel: self.viewmodel, friend_model: friend, searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
                        }
                    }
                
            }
            Spacer()
            //그룹 추가하는 통신이 성공하면 뷰모델의 add_group에서 add_group_ok값을 true로 바꿈.
            //값이 트루가 되면 버튼이 활성화되고 그룹관리 메인페이지로 이동함. 따라서 button의 액션 안에서 값 toggle해줄 필요 없음.
            Button(action: {
                print("확인 클릭함")
                self.presentation.wrappedValue.dismiss()
                self.viewmodel.added_friend_list = Array(self.viewmodel.selected_friend_set)
                print("친구 추가 뷰에서 저장한 친구 리스트 확인 : \(self.viewmodel.added_friend_list)")
                
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
            .padding()

        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .onAppear{
            print("********************************친구 추가뷰 나타남*****************************")
            self.viewmodel.fetch_friend_list()
        }
        .onDisappear{
            print("********************************친구 추가뷰 사라짐*****************************")
            print(" 선택된 친구들 닉네임 확인 : \( viewmodel.show_selected_member())")
            print("친구 추가 화면에서 선택한 친구 set들 확인 : \(viewmodel.selected_friend_set)")
            print("친구 추가 화면에서 선택한친구 set> 배열 변환확인 : \(viewmodel.added_friend_list) ")
        }
        .padding(.bottom, 50)
        
    }
}


struct PlusFriendRow : View{
    
    @ObservedObject var viewmodel : AddGroupViewmodel
    @State var friend_model : GetFriendListStruct
    @State var send_data : Bool = false
    //row를 선택했는지 알 수 있는 변수
    var is_selected: Bool {
        //선택했는지는 selected리스트 안에 담겨 있냐에 따라 결정됨.
        viewmodel.selected_friend_set.contains(friend_model.idx ?? 99)
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
                    HStack(alignment: .center){
                        
                        if friend_model.profile_photo == "" || friend_model.profile_photo == nil{
                            
                            Image("main_profile_img")
                                .resizable()
                                .frame(width: 38.23,height:38.23 )
                        }else{
                            
                            KFImage(URL(string: friend_model.profile_photo!))
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
                                print("버튼 클릭")
                                if self.is_selected{
                                    print("제거된 값 확인 : \(self.viewmodel.selected_friend_set)")
                                    self.viewmodel.selected_friend_set.remove(self.friend_model.idx ?? 88)
                                }
                                else if self.is_selected == false{
                                    print("추가된 값 확인 : \(self.viewmodel.selected_friend_set)")
                                    self.viewmodel.selected_friend_set.insert(self.friend_model.idx ?? 77)
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
                        }
                    }
                }
                Divider()
                
            }else if (isSearching == false && end_search == false){
                
                HStack(alignment: .center){
                    
                    if friend_model.profile_photo == "" || friend_model.profile_photo == nil{
                        
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 38.23,height:38.23 )
                    }else{
                        
                        KFImage(URL(string: friend_model.profile_photo!))
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
                        Text(friend_model.nickname ?? "")
                            .font(.custom(Font.n_bold, size: 14))
                            .foregroundColor(.proco_black)
                            .lineLimit(1)
                            
                        Spacer()
                    }
                    
                    HStack{
                        //선택 박스
                        Button(action: {
                            
                            print("버튼 클릭")
                            if self.is_selected{
                                self.viewmodel.selected_friend_set.remove(self.friend_model.idx ?? 0 )
                            }
                            else if self.is_selected == false{
                                self.viewmodel.selected_friend_set.insert(self.friend_model.idx ?? 0 )
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
                    }
                }
            }
        }
    }
}

struct SearchFriendBarInManage: View{
    
    @ObservedObject var viewmodel : AddGroupViewmodel
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @Binding var end_search: Bool
    
    @State var text: String = ""
    
    func get_count() -> Int{
        let search_result_count =   viewmodel.friend_list_struct.filter({"\($0)".contains(searchText)}).count
        return search_result_count
    }
    
    var body: some View {
        HStack {
            HStack {
                TextField("검색", text: $searchText, onCommit: {
                    
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
                , alignment: .trailing)
            .transition(.move(edge: .trailing))
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
