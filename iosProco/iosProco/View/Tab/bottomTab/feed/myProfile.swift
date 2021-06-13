//
//  myFeedGridView.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//

import SwiftUI

struct myProfile: View {
    //심심풀이, 발자취 탭 선택 구분하기 위한 변수
    @State var chosen_tab = true
    var body: some View {
        Group{
        HStack{
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .background(Color.gray.opacity(0.5))
                .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                .cornerRadius(50)
                .scaledToFit()
                .padding([.leading, .trailing], UIScreen.main.bounds.width/30)
            VStack{
                HStack{
                Text("이아영")
                    .font(.caption)
                    Spacer()
                }
                HStack{
                Button(action: {
                    //myPage()
                }){
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.width/12)
                        .border(Color.black)
                        .foregroundColor(Color.white)
                        .overlay(Text("마이 페이지")
                                    .font(.caption)
                                    .padding(UIScreen.main.bounds.width/20)
                                    .foregroundColor(Color.black)
                        )
                }
                    Spacer()
            }
                
            }
            Spacer()
        }.padding()
        }
        Divider().frame(height: 2).background(Color.black)
        //내 심심풀이, 발자취 선택 탭
        HStack{
            Spacer()
            Button(action: {
                chosen_tab = true
                print(chosen_tab)
            }){
                if chosen_tab{
                    Text("내 심심풀이")
                        .overlay(Rectangle()
                                    .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/40)
                                    .foregroundColor(Color.gray)
                                    .offset(x: 2, y: 20)
                                    .animation(.easeInOut(duration: 2)))
                }else{
                    Text("내 심심풀이")
                }
            }
            
            Spacer()
            Button(action: {
                chosen_tab = false
                print(chosen_tab)
                
            }){
                if chosen_tab==false{
                    Text("발자취")
                        .overlay(Rectangle()
                                    .frame(width: UIScreen.main.bounds.width/8, height: UIScreen.main.bounds.width/40)
                                    .offset(x: 10, y: 20)
                                    .foregroundColor(Color.gray)
)
                }else{
                Text("발자취")
                }
            }
            Spacer()
        }.frame(height: UIScreen.main.bounds.width/6)
        //친구랑 볼래 탭을 택했을 때 값=0, 모여볼래 탭은 값이 1
        if chosen_tab {
            myFeedGridView()
        }else{
            historyPage()
        }
        
    }
}

