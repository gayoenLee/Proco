//
//  requestedListView.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
// 3-3 신청 목록 보기 페이지

import SwiftUI

struct gatheringRequestedListView: View {
    @ObservedObject var gathering_list_container = gatheringListContainer()
    
    var body: some View {
        VStack{
        //상단바
        HStack{
            Image(systemName: "chevron.left")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
            Spacer()
            Text("신청 목록 리스트")
            Spacer()
        }
        .padding()
            List{
                ForEach(gathering_list_container.gatherings_list){gathering_list in
                    gathering_list_row(gathering_list: gathering_list)
                }
            }
        }
    }
}

struct gathering_list_row : View{
   @ObservedObject var gathering_list_container = gatheringListContainer()
    var gathering_list : gathering_list
    
    var body : some View{
        
        //카드 1개
        HStack(alignment: .center){
            //카드 배경 위에 티켓 이미지, 모임 이름, 마지막 채팅 메세지, 시간, 알림
            VStack(alignment: .center){
                HStack(alignment: .center){
                    VStack{
                        //모임 카테고리, 이름, 타입 묶음 한칸
                        HStack{
                        //카테고리, 모임 제목
                        VStack{
                            Capsule()
                                .frame(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.width/20)
                                .foregroundColor(Color.black)
                                .overlay(Text(gathering_list.category)
                                            .foregroundColor(Color.white)
                                            .font(.callout))
                                .padding(.top, UIScreen.main.bounds.width/20)
                            
                            Text(gathering_list.room_name)
                                .font(.title)
                                .lineLimit(10)
                        }
                        
                            Spacer()
                        //타입, 시간
                        VStack{
                            Text(gathering_list.type)
                                .fontWeight(.bold)
                                .font(.title)
                                .padding(.top, UIScreen.main.bounds.width/25)
                            Text(gathering_list.time)
                                .font(.callout)
                        }
                    }
  
                        //인원, 위치, 프로필사진, 이름 표시 한 칸
                        Group{
                        HStack{
                            Group{
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/30, height: UIScreen.main.bounds.width/30)
                            Text(gathering_list.member_num+"명")
                                .font(.callout)
                            }
                            Spacer()
                            Group{
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/30, height: UIScreen.main.bounds.width/30)
                            Text(gathering_list.location)
                                .font(.callout)
                            }
                            Spacer()
                            Group{
                            //프로필 이미지
                            Image(gathering_list.profile_image)
                                .resizable()
                                .background(Color.gray.opacity(0.5))
                                .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                                .cornerRadius(50)
                                .scaledToFit()
                                .padding([.trailing], UIScreen.main.bounds.width/40)
                            Text(gathering_list.name)
                                .font(.callout)
                            }
                        }
                        .padding()
                        }
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
        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/2.5)
    }
}

