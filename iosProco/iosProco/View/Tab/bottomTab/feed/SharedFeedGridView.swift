//
//  SharedFeedGridView.swift
//  proco
//
//  Created by 이은호 on 2020/11/29.
//

import SwiftUI

struct SharedFeedGridView: View {
    @ObservedObject var shared_feed_container = SharedFeedContainer()
    @ObservedObject var report_checkbox_container = ReportCheckboxContainer()
    
    //lazyvgrid에 사용할 그리드아이템
    var columns : [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    //좋아요 버튼 클릭시 버튼이미지 변경 위해 사용하는 구분 변수
    @State var is_clicked : Bool = false
    //신고하기창 나타나는 모달 구분 변수
    @State var show_report_modal : Bool = false
    //신고하는 페이지에서 체크박스 선택 변수
    @State var show_check_modal = false
    
    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns){
                ForEach(shared_feed_container.shared_feeds){shared_feed in
                    //피드 카드 1개
                    shared_feed_row(shared_feed: shared_feed, is_clicked: is_clicked, show_check_modal: $show_check_modal)
                }
                //신고하기 클릭시 나타나는 모달
            }.overlay(checkbox_modal(show_check_modal: $show_check_modal)
                        .ignoresSafeArea()
            )
        }.foregroundColor(Color.black.opacity(show_check_modal ? 0.4 : 1))
        
    }
}

struct checkbox_modal : View{
    @ObservedObject var report_checkbox_container = ReportCheckboxContainer()
    @Binding var show_check_modal : Bool
    
    var body: some View{
        if show_check_modal{
            Rectangle()
                //아래 opacity를 설정해줘야 모달 창 뒤에 배경 설정 가능함.
                .foregroundColor(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack{
                        HStack{
                            Text("게시물 신고")
                                .fontWeight(.bold)
                            Spacer()
                        }
                        //신고 사유 리스트
                        ForEach(report_checkbox_container.items){checkbox_item in
                            HStack{
                                Button(action: {
                                    //체크박스 해결해야함
                                    
                                }){
                                    //체크박스 모양 만들기
                                    Circle()
                                        .stroke(checkbox_item.checked ? Color.green : Color.gray, lineWidth: 1)
                                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                                }
                                //체크했을 경우 체크박스 모양 변경하기 위함
                                if checkbox_item.checked{
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: UIScreen.main.bounds.width/20))
                                        .foregroundColor(Color.green)
                                }
                                Text(checkbox_item.title)
                                Spacer()
                                
                            }
                        }
                        
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .background(Color.white)
                    .cornerRadius(20))
        }
    }
  
}

//공유피드 한개 뷰 따로 뺌.
struct shared_feed_row : View{
    var shared_feed : shared_feed
    @State var is_clicked : Bool = false
    @State var show_report_modal : Bool = false
    @Binding var show_check_modal : Bool
    
    var body: some View{
        VStack{
            Image(shared_feed.image)
                .resizable()
                .frame(width: UIScreen.main.bounds.width*0.5, height: UIScreen.main.bounds.width*0.6)
                // .cornerRadius(10)
                .scaledToFit()
            Group{
                HStack{
                    Button(action: {
                        is_clicked.toggle()
                    }){
                        Image(self.is_clicked == true ? "heart_fill" : "heart")
                        
                    }
                    Spacer()
                    //신고하기 버튼
                    Menu {
                        Button(action: {
                            withAnimation{
                                //작은 신고하기 메뉴 버튼 나오는 것 구분 값
                                show_check_modal.toggle()
                                print("신고하기 버튼 클릭 값 : ", show_check_modal)
                            }
                        }) {
                            Label("신고하기", systemImage: "pencil.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    NavigationLink(
                        destination: logo_view(), isActive: $show_report_modal){
                    }
                }.padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            }
        }
    }
}


