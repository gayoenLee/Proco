//
//  search_all_view.swift
//  proco
//
//  Created by 이은호 on 2020/11/16.
//

import SwiftUI

struct search_all_view: View {
    @State var searchText = ""
    //사용자가 현재 검색창에 텍스트를 입력중인가를 알 수 있는 변수
    @State var isSearching = false
    //키보드에서 엔터 버튼 클릭시 검색 완료를 알리기 위한 변수
    @State var end_search = false
    var body: some View {
        
            ScrollView {
                VStack{
                HStack{
                    Image(systemName: "chevron.right")
                        .padding()
                        
                SearchBar(searchText: $searchText, isSearching: $isSearching, end_search: $end_search)
                    
                }
                //최근 기록 보여주기, 사용자가 입력하는 값에 따라 실시간으로 리스트 보여줌
                    if end_search == false{
                HStack{
                    Text("최근")
                        .font(.system(size: UIScreen.main.bounds.width/20, weight: .heavy, design: .default))
                        .padding(.leading, UIScreen.main.bounds.width/20)
                    Spacer()
                    Text("전체 삭제")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                        .padding(.trailing, UIScreen.main.bounds.width/20)
                }
                        ForEach((0..<3).filter({ "\($0)".contains(searchText) || searchText.isEmpty }), id: \.self) { num in
                            
                            HStack {
                                Text("\(num)")
                                Spacer()
                                Image(systemName: "xmark")
                            }.padding()
                            
                            Divider()
                                .background(Color(.systemGray4))
                    }
                    }
                }
                if end_search {
                    //친구를 검색한 경우에는 프로필 이미지와 이름, 태그 검색 한 경우 태그명, 모임 이름을 보여주기도 함...if문으로 경우의 수 나누기
                HStack{
                      Text("친구")
                          .font(.system(size: UIScreen.main.bounds.width/20, weight: .heavy, design: .default))
                          .padding(.leading, UIScreen.main.bounds.width/20)
                      Spacer()
                  }
                ForEach((0..<3).filter({ "\($0)".contains(searchText) || searchText.isEmpty }), id: \.self) { num in
                    
                    HStack {
                        Text("\(num)")
                        Spacer()
                        Image(systemName: "xmark")
                    }.padding()
                    Divider()
                        .background(Color(.systemGray4))
                }
                HStack{
                    Spacer()

                Text("더보기")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .padding(.trailing, UIScreen.main.bounds.width/20)
                     Image(systemName: "chevron.right")
                        .padding()
                    }
                HStack{
                      Text("모임")
                          .font(.system(size: UIScreen.main.bounds.width/20, weight: .heavy, design: .default))
                          .padding(.leading, UIScreen.main.bounds.width/20)
                      Spacer()
                  }
                ForEach((0..<3).filter({ "\($0)".contains(searchText) || searchText.isEmpty }), id: \.self) { num in
                    
                    HStack {
                        Text("\(num)")
                        Spacer()
                        Image(systemName: "xmark")
                    }.padding()
                    
                    Divider()
                        .background(Color(.systemGray4))
                }
                HStack{
                    Spacer()
                Text("더보기")
                    .font(.caption)
                    .foregroundColor(Color.gray)
                    .padding(.trailing, UIScreen.main.bounds.width/20)
                    Image(systemName: "chevron.right")
                       .padding()
                    }
                HStack{
                      Text("채팅방")
                          .font(.system(size: UIScreen.main.bounds.width/20, weight: .heavy, design: .default))
                          .padding(.leading, UIScreen.main.bounds.width/20)
                      Spacer()
                  }
                ForEach((0..<3).filter({ "\($0)".contains(searchText) || searchText.isEmpty }), id: \.self) { num in
                    
                    HStack {
                        Text("\(num)")
                        Spacer()
                        Image(systemName: "xmark")
                    }.padding()
                    
                    Image(systemName: "chevron.right")
                       .padding()
            }
    }
            }}

//검색 바 뷰
struct SearchBar: View {
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
}
