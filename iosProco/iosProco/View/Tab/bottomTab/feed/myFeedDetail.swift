//
//  myFeedDetail.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//
//피드 상세 페이지
import SwiftUI

struct myFeedDetail: View {
    //피드 데이터 갖고 있는 모델
    @ObservedObject var my_feed_container = myFeedContainer()
  @State var comment = ""
    //댓글창에서 textfield선택시 키보드 올라가면서 뷰 올리기 위한 이벤트시 사용

    var body: some View {
        NavigationView{
            VStack{
        //캐러셀로 이미지 보여주기
        //현재 프로필의 유저 이름
        TabView{
            ForEach(my_feed_container.my_feeds.filter{
                $0.name == "가나" && $0.time == "2020.01.01"
            }){index in
                feed_detail_image(my_feed: index)
            }
        }.tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
//        .clipShape(RoundedRectangle(cornerRadius: 5))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        .edgesIgnoringSafeArea(.top)
                Group{
        //프로필 이미지, 이름, 태그 3개, 좋아요, 더보기 버튼
        HStack{
            //내 프로필
            Image("blackRingCoffee")
                .resizable()
                .background(Color.gray.opacity(0.5))
                .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                .cornerRadius(50)
                .scaledToFit()
                .padding(UIScreen.main.bounds.width/30)
            
        VStack{
                HStack{
                Text("이은일")
                    .font(.headline)
                    .fontWeight(.bold)
                    Spacer()
                //좋아요 버튼
                Button(action: {
                    
                }){
                    Image(systemName: "suit.heart")
                }
                Button(action: {
                    
                }){
                    Image(systemName: "pause")
                }
                }
            //태그 부분
            HStack{
                ForEach(my_feed_container.my_feeds.filter{
                    $0.name == "가나" && $0.time == "2020.01.01"
                }){feed in
                    feed_tags(my_feed: feed)
                }
                Spacer()
            }
            }
     
        }.padding()
        .frame(height: UIScreen.main.bounds.width/4)
                }

                Rectangle()
            .foregroundColor(Color.gray)
            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width/3, alignment: .center)
            .overlay(Text("😀 😃 😄 😁 😆 😅 😂 🤣 ☺️ 😊 😇 🙂 🙃 😉 😌 😍 🥰 😘 😗 😙 😚 😋 😛 😝 😜 🤪 🤨 🧐 🤓 😎 🤩 🥳 😏 😒 😞 😔 😟 😕 🙁 ☹️ 😣 😖 😫 😩 🥺 😢 😭 😤 😠 😡 🤬 🤯 😳 🥵 🥶 😱 😨 😰 😥 😓 🤗 🤔 🤭 🤫 🤥 😶 😐 😑 😬 🙄"))
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
                    .padding(.bottom, 0)

                    Button(action: {
                        
                    }){
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                            .foregroundColor(Color.black)
                    }
                }
                .padding()
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
    }
    }
}
    
    //피드 이미지 케러셀 뷰
    struct feed_detail_image : View{
        var my_feed : my_feed
        
        var body: some View{
            
            ForEach(my_feed.feed_image, id: \.self){feed_image in
                Image(feed_image)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
    
    struct feed_tags : View{
        var my_feed : my_feed
        var body: some View{
            
            ForEach(my_feed.tags, id: \.self){ feed_tag in
                ZStack{
                    Text("#"+feed_tag)
                        .padding(UIScreen.main.bounds.width/40)
                        .font(.caption)
                        .foregroundColor(Color.white)
                }.background(Color.orange)
                .opacity(0.8)
                .cornerRadius(25)
            }
        }
    }



