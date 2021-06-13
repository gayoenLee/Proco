//
//  SelectFriendMakeCard.swift
//  proco
//
//  Created by 이은호 on 2020/12/22.
//

import SwiftUI
import Combine
import Alamofire

struct SelectFriendMakeCard: View {
    @Environment(\.presentationMode) var presentation
    
    @StateObject var main_viewmodel : FriendVollehMainViewmodel
    //---검색 관련해서 사용 변수들---
    //친구 검색창에 사용하는 변수
    @State var search_text = ""
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @State var is_searching = false
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @State var end_search = false
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    //request할 때 share_list 데이터 모델에 넣어서 보내기 위함.
                    self.presentation.wrappedValue.dismiss()
                    print("그룹 선택 후에 sharelist에 들어갔는지 확인 : \(main_viewmodel.pra)")
                    
                }){
                    Text("확인")
                    
                }
                
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }){
                    Text("취소")
                    
                }
            }            .padding(UIScreen.main.bounds.width/10)

            SearchFriendBarInVolleh(main_viewmodel: self.main_viewmodel, search_text: $search_text, is_searching: $is_searching, end_search: $end_search)
            if end_search{
                List{
                    Text("그룹")
                    ForEach((main_viewmodel.manage_groups).filter({"\($0)".contains(search_text)
                    }), id: \.self){ group in
                        GroupListMakeCard(main_viewmodel: self.main_viewmodel, group_struct: group, search_text: $search_text, is_searching: $is_searching, end_search: $end_search)
                    }
                    
                    Text("친구")
                    ForEach((main_viewmodel.friend_list_struct).filter({"\($0)".contains(search_text)
                    }), id: \.self){ friend in
                        FriendListMakeCard(main_viewmodel: self.main_viewmodel, friend_model: friend, search_text: $search_text, is_searching: $is_searching, end_search: $end_search)
                    }
                }
                //검색을 하지 않을 때 모든 리스트를 보여준다.
            }else if(is_searching == false && end_search == false){
                
                List{
                    Text("그룹")
                    if main_viewmodel.manage_groups.isEmpty{
                        ProgressView()
                    }else{
                        ForEach(0..<main_viewmodel.manage_groups.count, id: \.self){ group_index in
                            GroupListMakeCard(main_viewmodel: self.main_viewmodel, group_struct: self.main_viewmodel.manage_groups[group_index], search_text: $search_text, is_searching: $is_searching, end_search: $end_search)
                        }
                    }
                    Text("친구")
                    if main_viewmodel.friend_list_struct.isEmpty{
                        ProgressView()
                    }else{
                        ForEach(0..<main_viewmodel.friend_list_struct.count, id: \.self){friend_idx in
                            FriendListMakeCard(main_viewmodel: self.main_viewmodel, friend_model: self.main_viewmodel.friend_list_struct[friend_idx], search_text: $search_text, is_searching: $is_searching, end_search: $end_search)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear{
            main_viewmodel.get_all_people()
        }

        
    }
    
}

struct SearchFriendBarInVolleh: View{
    
    @ObservedObject var main_viewmodel : FriendVollehMainViewmodel
    
    @Binding var search_text: String
    @Binding var is_searching: Bool
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @Binding var end_search: Bool
    
    @State var text: String = ""
    @State private var log: String = "Logs: "
    
    
    
    var body: some View {
        HStack {
            HStack {
                TextField("검색", text: $search_text, onCommit: {
                    
                    self.log.append("\n COMITTED!")
                    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
                    end_search =  true
                })
                //검색 버튼이 있는 키보드 설정
                .keyboardType(.webSearch)
                .padding(.leading, UIScreen.main.bounds.width/20)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(50)
            .padding(.horizontal)
            //클릭시 isSearching이 true로 바뀌고 아래에 두가지 if문이 실행됨.
            .onTapGesture(perform: {
                is_searching = true
            })
            .overlay(
                HStack {
                    //검색 바 이미지
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    
                    //x버튼 클릭시 사용자가 모두 입력한 텍스트 초기화해주는 것.
                    if is_searching {
                        Button(action: { search_text = "" }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
                        })
                    }
                }.padding(.horizontal, 32)
                .foregroundColor(.gray)
            ).transition(.move(edge: .trailing))
            .animation(.spring())
            
            //사용자가 검색 창 클릭한 후 입력하려고 할 때 cancel버튼 나타나는 애니메이션
            if is_searching {
                Button(action: {
                    
                    is_searching = false
                    search_text = ""
                    //키보드를 숨기는 메소드
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                }, label: {
                    Text("Cancel")
                        .padding(.trailing)
                        .padding(.leading, 0)
                })
                .transition(.move(edge: .trailing))
                .animation(.spring())
            }
            
        }
    }
}

