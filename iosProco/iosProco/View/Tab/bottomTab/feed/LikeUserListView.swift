//
//  LikeUserListView.swift
//  proco
//
//  Created by 이은호 on 2021/03/12.
// 캘린더 - 상세 페이지에서 좋아요한 사람들 목록 보여주는 뷰

import SwiftUI

struct LikeUserListView: View {
    
    @ObservedObject var main_vm : CalendarViewModel
    @State var searchText = ""
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @State var isSearching = false
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @State var end_search = false
    var schedule_date : Date
    @State private var is_loading = true
    
    var body: some View {
        VStack{
            ScrollView{
                
                Text("좋아요한 사람들")
                    .font(.custom(Font.n_bold, size: 25))
                    .foregroundColor(Color.proco_black)
                    .padding()
                
                HStack{
                    ClickUserSearchBar(searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
                }
                
                if is_loading{
                    Spacer()
                    ProgressView()
                    
                }else{
                    //검색할 경우에는 보여주지 않기
                    if (isSearching == false && end_search == false){
                        
                        ForEach(main_vm.calendar_like_user_model){user in
                            LikeUserCell(main_vm: self.main_vm, like_user_model: user)
                        }
                    }else{
                        
                        ForEach((main_vm.calendar_like_user_model).filter({"\($0)".contains(searchText)}), id: \.id){user in
                            
                            LikeUserCell(main_vm: self.main_vm, like_user_model: user)
                        }
                    }
                }
                Spacer()
            }
        }
        .onAppear{
            print("좋아요한 사람들 목록뷰 나옴.")
            let current_date_string = self.main_vm.date_to_string(date: schedule_date).split(separator: " ")[0]
            
            self.main_vm.get_like_user_list(user_idx: self.main_vm.calendar_owner.user_idx, calendar_date: String(current_date_string))
            
            //데이터를 가져오고 보여주는데 시간이 걸려서 로딩 추가
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.is_loading = false

            }
        }
    }
}

//검색 바 뷰
struct ClickUserSearchBar: View {
    //검색창에 입력되고 있는 텍스트
    @Binding var searchText: String
    @Binding var isSearching: Bool
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @Binding var end_search: Bool
    
    @State var text: String = ""
    @State private var log: String = "Logs: "
    var body: some View {
        HStack {
            HStack {
                TextField("검색", text: $searchText, onCommit: {
                    
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
                isSearching = true
            })
            .overlay(
                HStack {
                    //검색 바 이미지
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    
                    //x버튼 클릭시 사용자가 모두 입력한 텍스트 초기화해주는 것.
                    if isSearching {
                        Button(action: { searchText = "" }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
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

