//
//  feedCommentView.swift
//  proco
//
//  Created by 이은호 on 2020/11/26.
//

import SwiftUI

struct feedCommentView: View {
    //댓글 내용에 대한 데이터 모델 클래스
    @ObservedObject var feed_comment_container = feedCommentContainer()
    //댓글 창 textfield값을 가질 변수
    @State var comment = ""
    //키보드 올라올 때 댓글 입력창 가리지 않게 하기 위해 사용하는 변수
    @State  var keyboardHeight : CGFloat = 0
    var body: some View {
        VStack{
            //뒤로 가기 버튼
            HStack{
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/25, height: UIScreen.main.bounds.width/25)
                    .padding()
                Spacer()
                //상단 네비게이션 바 위치 메뉴들
            }
            //댓글 리스트
            List{
                //해당 게시물의 댓글만 보여주기
                ForEach(feed_comment_container.feed_comments.filter{
                    $0.title == "가"
                }){comment in
                    comment_row(feed_comment: comment)
                }
            }
            //댓글 입력창
            //댓글 창
            HStack{
                Image("hopStorkCoffee")
                    .resizable()
                    .background(Color.gray.opacity(0.5))
                    .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)
                    .cornerRadius(50)
                    .scaledToFit()
                    .padding(UIScreen.main.bounds.width/30)
                VStack{
                    TextField("댓글을 입력해주세요", text: $comment)
                    Divider()
                        .frame(height: 1)
                        .padding(.horizontal, 30)
                        .background(Color.orange)
                }
                
                Button(action: {
                    
                }){
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                        .foregroundColor(Color.black)
                }
            }
            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width/10)
        }
        .offset(y: -self.keyboardHeight)
        .animation(.spring())
        .onAppear{
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main){(notification) in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?CGRect else{
                    return
                }
                self.keyboardHeight = keyboardFrame.height
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main){
                (notification) in
                
                self.keyboardHeight = 0
            }
        }
    }
}

struct comment_row: View{
    @ObservedObject var feed_comment_container = feedCommentContainer()
    var feed_comment : feed_comment
    
    var body: some View{
        //댓글 내용 리스트 부분
        HStack{
            VStack{
                Image(feed_comment.image)
                    .resizable()
                    .background(Color.gray.opacity(0.5))
                    .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)
                    .cornerRadius(50)
                    .scaledToFit()
                    .padding(UIScreen.main.bounds.width/50)
                Spacer()
            }
            VStack{
                HStack{
                    Capsule()
                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/20)
                        .foregroundColor(Color.gray)
                        .overlay(Text(feed_comment.commentor)
                                    .foregroundColor(Color.white)
                                    .padding([.top, .bottom], UIScreen.main.bounds.width/20))
                    
                    Spacer()
                }
                HStack{
                    Text(feed_comment.comment)
                    Spacer()
                }
            }
        }
    }
}
struct feedCommentView_Previews: PreviewProvider {
    static var previews: some View {
        feedCommentView()
    }
}
