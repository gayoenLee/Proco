//
//  historyPage.swift
//  proco
//
//  Created by 이은호 on 2020/11/26.
//

import SwiftUI

struct historyPage: View {
    @ObservedObject var history_contianer = historyContainer()
    @State var navigated = false

    var body: some View {
        NavigationView{
            
        List{
            ForEach(history_contianer.histories){histories in
//                NavigationLink(destination: historyDetailView(selected_feed_name: [histories.date, histories.type, histories.owner_name, histories.time, histories.location]), label: {
//                    history_row(history: histories)
//                })
                Text("")
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        }
    }
}

struct history_row : View{
    @ObservedObject var history_contianer = historyContainer()
    @State var selected_row = ""
    
    var history : history
    var body: some View{
        //카드 1개
        HStack(alignment: .center){
            //카드 배경 위에 시간, 태그들, 타입
            VStack(alignment: .center){
                Group{
                    //카테고리, 모임 제목
                    HStack{
                        Text(history.date)
                            .font(.subheadline)
                            .lineLimit(10)
                            .padding([.leading, .trailing, .top],UIScreen.main.bounds.width/25)

                        Spacer()
                        //타입, 시간
                        Text(history.type)
                            .fontWeight(.bold)
                            .font(.headline)
                            .padding([.leading, .trailing, .top],UIScreen.main.bounds.width/25)
                    }
                }
                //태그들
                Group{
                    HStack{
                        ForEach(history.tags, id: \.self){tag in
                            ZStack{
                                Text("#"+tag)
                                    .padding(UIScreen.main.bounds.width/50)
                                    .font(.caption2)
                                    .foregroundColor(Color.white)
                            }.background(Color.orange)
                            .opacity(0.8)
                            .cornerRadius(25)
                        }
                        Spacer()
                    }
                   
                }
                .padding(UIScreen.main.bounds.width/40)
            }
            

            .background(Rectangle().fill(Color.white))
            .cornerRadius(10)
            .shadow(color: .gray, radius: 3, x: 2, y: 2)
        }
        .padding([.trailing], UIScreen.main.bounds.width/20)
        //화면 하나에 카드 여러개 보여주기 위해 조정하는 값
        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/4)
  
    }
}



