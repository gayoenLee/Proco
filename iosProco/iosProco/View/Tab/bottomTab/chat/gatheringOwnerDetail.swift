//
//  gatheringOwnerDetail.swift
//  proco
//
//  Created by 이은호 on 2020/11/23.
// 3-4주최자가 세부사항 봤을 때

import SwiftUI

struct gatheringOwnerDetail: View {
    
    @ObservedObject var viewmodel = GroupVollehMainViewmodel()

    var body: some View {
        
        NavigationView{
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    Group{
                        HStack{
                            Image(systemName: "chevron.left")
                                .padding(.leading, UIScreen.main.bounds.width/20)
                            Spacer()
                            Text("여기모여라방")
                            Spacer()
                        }
                    }
                    .padding(.top, UIScreen.main.bounds.width/20)
                    Spacer()
                    Group{
                        HStack{
                            Spacer()
                            Text("지금 볼래")
                                .padding(.trailing, UIScreen.main.bounds.width/20)
                        }
                        
                        //주최자 프로필이미지, 이름, 티켓보기 버튼
                        HStack{
                            //프로필 이미지
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
                                .cornerRadius(50)
                                .scaledToFit()
                                .padding([.leading,.trailing], UIScreen.main.bounds.width/20)
                            VStack{
                                Text("주최자")
                                    .font(.caption2)
                                Text("이은열")
                                    .font(.headline)
                            }
                            Spacer()
                            Image(systemName: "ticket")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/10)
                                .padding()
                        }
                        Spacer()
                        tags()
                        Spacer()
                        gathering_date()
                            .padding()
                        gathering_time()
                    }
                    Group{
                        NavigationLink(destination: ApplyPeopleListView(main_vm: self.viewmodel)){
                            HStack{
                                Text("신청자, 참여자 목록")
                                    .foregroundColor(Color.black)
                                    .padding()
                                Spacer()
                                Text("더보기")
                                    .foregroundColor(Color.black)
                                
                                Image(systemName: "chevron.right")
                                    .padding()
                                    .foregroundColor(Color.black)
                            }
                        }
                    }
                    //지도 부분 시작
                    map()
                    //세부사항 부분
                    detail_content()
                    
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }
        }
    }
}
struct detail_content : View{
    var body: some View{
        Text("해외유입 확진자는 검역단계에서 나온 10명을 포함해 모두 29명이 확인됐습니다. 또 어제 사망자는 1명 늘어 누적 사망자는 510명입니다. 위중증 환자는 전날과 같은 79명입니다. 박능후 중대본 1차장은 우리가 경험해 보지 못했던 3차 유행의 새로운 양상은 한층 더 어렵고 힘든 겨울을 예고하고 있다고 우려했습니다.또 가족, 친지, 지인 간 모임에서의 감염이 전체 감염의 60%를 차지하는 등 일상에서의 연쇄 감염이 급증하고 있다고 말했습니다. 지금까지 사회부에서 YTN 김종균입니다.")
            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width/2)
    }
}
struct map : View{
    
    var body: some View{
        HStack{
            Text("장소")
                .padding()
            Spacer()
        }
        HStack{
            Image(systemName: "mappin")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
            Text("서울시 서초구 반포동 서래로10")
        }
        Image(systemName: "map")
            .resizable()
            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width/2)
            .padding()
        
    }
}
struct tags: View{
    var body: some View{
        Group{
            HStack{
                Text("#"+"산책갈 사람")
                    .padding(UIScreen.main.bounds.width/50)
                    .background(Color.gray)
                    .foregroundColor(.white)
                Text("#"+"강아지")
                    .padding(UIScreen.main.bounds.width/50)
                    .background(Color.gray)
                    .foregroundColor(.white)
                Text("#"+"호수공원")
                    .padding(UIScreen.main.bounds.width/50)
                    .background(Color.gray)
                    .foregroundColor(.white)
            }
            HStack{
                Text("#"+"산책갈 사람")
                    .padding(UIScreen.main.bounds.width/50)
                    .background(Color.gray)
                    .foregroundColor(.white)
                Text("#"+"강아지")
                    .padding(UIScreen.main.bounds.width/50)
                    .background(Color.gray)
                    .foregroundColor(.white)
                Text("#"+"호수공원")
                    .padding(UIScreen.main.bounds.width/50)
                    .background(Color.gray)
                    .foregroundColor(.white)
            }
        }
    }
}

struct gathering_date: View{
    var body: some View{
        HStack{
            Text("날짜")
            Spacer()
            Text("2020")
            Text("년")
            Text("12")
            Text("월")
            Text("22")
            Text("일")
        }
        .padding()
    }
}
struct gathering_time: View{
    var body: some View{
        HStack{
            Text("시간")
            Spacer()
            Text("오후")
            Text("07")
            Text(":")
            Text("00")
        }
        .padding()
    }
}
