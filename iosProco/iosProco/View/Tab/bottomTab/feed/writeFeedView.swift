//
//  writeFeedView.swift
//  proco
//
//  Created by 이은호 on 2020/11/26.
//내 심심풀이 작성 페이지

import SwiftUI

struct writeFeedView: View {
    //이전 뷰에서 받을 선택한 피드 정보
    var selected_feed_name = ""
    //심심풀이 피드 메모 내용 받는 변수
    @State var feed_memo = ""
    //심심풀이 피드 메모 내용 글자 수 제한위해 사용하는 변수
    @ObservedObject var input = text_limiter(limit: 10)
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    //상단바
                    HStack{
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                        Spacer()
                    }
                    .padding()
                    
                    Group{
                        HStack{
                            Text("2020.10.23")
                            Spacer()
                        }
                        HStack{
                            Text("지금 볼래")
                            Spacer()
                        }
                        HStack{
                            ZStack{
                                Text("#첫번째")
                                    .padding(UIScreen.main.bounds.width/40)
                                    .font(.caption)
                                    .foregroundColor(Color.white)
                            }.background(Color.orange)
                            .opacity(0.8)
                            .cornerRadius(25)
                            ZStack{
                                Text("#두번째")
                                    .padding(UIScreen.main.bounds.width/40)
                                    .font(.caption)
                                    .foregroundColor(Color.white)
                            }.background(Color.orange)
                            .opacity(0.8)
                            .cornerRadius(25)
                            Spacer()
                        }
                    }.padding()
                    
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*0.8)
                        .overlay(     Button(action: {
                            
                        }){
                            Image(systemName: "plus.square.on.square")
                                .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                        })
                    Group{
                        HStack{
                            Text("알릴 친구들")
                            Button(action: {
                                
                            }){
                                Image(systemName: "plus.circle.fill")
                                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                            }
                            Spacer()
                        }
                        
                        
                        HStack{
                            ZStack{
                                Text("#이가연")
                                    .padding(UIScreen.main.bounds.width/40)
                                    .font(.caption)
                                    .foregroundColor(Color.white)
                            }.background(Color.orange)
                            .opacity(0.8)
                            .cornerRadius(25)
                            ZStack{
                                Text("#이가은")
                                    .padding(UIScreen.main.bounds.width/40)
                                    .font(.caption)
                                    .foregroundColor(Color.white)
                            }.background(Color.orange)
                            .opacity(0.8)
                            .cornerRadius(25)
                            Spacer()
                        }
                    }
                    .padding()
                    HStack{
                        Text("입력 내용")
                            .padding()
                        Spacer()
                    }
                    //심심풀이에 작성할 메모 내용 - 글자 수 제한 필요
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width/2)
                        .foregroundColor(Color.gray)
                        .overlay(TextEditor(text: $feed_memo)
                                    .border(Color.black, width: $input.hasReachedLimit.wrappedValue ? 1: 0)
                                )
                    Button(action: {
                        
                    }){
                        Text("작성")
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }
        }
    }
}


