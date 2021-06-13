////
////  historyDetailView.swift
////  proco
////
////  Created by 이은호 on 2020/11/26.
////
//
//import SwiftUI
//
//struct historyDetailView: View {
//    @ObservedObject var viewmodel = GroupVollehMainViewmodel()
//
//    @ObservedObject var history_container = historyContainer()
//    var selected_feed_name : [String]
//
//    var body: some View {
//        NavigationView{
//            ScrollView(.vertical, showsIndicators : false){
//                VStack{
//
//            //상단바
//            HStack{
//                Image(systemName: "chevron.left")
//                    .resizable()
//                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
//                Spacer()
//                Text(selected_feed_name[0])
//                Spacer()
//            }
//            .padding(.top, UIScreen.main.bounds.width/20)
//            Spacer()
//                    Group{
//                HStack{
//                    Spacer()
//                    Text("지금 볼래")
//                        .padding(.trailing, UIScreen.main.bounds.width/20)
//                }
//
//                //주최자 프로필이미지, 이름, 티켓보기 버튼
//                HStack{
//                    //프로필 이미지
//                    Image(systemName: "person.circle")
//                        .resizable()
//                        .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
//                        .cornerRadius(50)
//                        .scaledToFit()
//                        .padding([.leading,.trailing], UIScreen.main.bounds.width/20)
//                    VStack{
//                        Text("주최자")
//                            .font(.caption2)
//                        Text("이은열")
//                            .font(.headline)
//                    }
//                    Spacer()
//                    Image(systemName: "ticket")
//                        .resizable()
//                        .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/10)
//                        .padding()
//                }
//                Spacer()
//              //  tags()
//                Spacer()
//               // gathering_date()
//                    .padding()
//                //gathering_time()
//                }
//                Group{
//                    NavigationLink(destination: ApplyPeopleListView(main_vm: self.viewmodel)){
//                    HStack{
//                Text("신청자, 참여자 목록")
//                    .foregroundColor(Color.black)
//                    .padding()
//                        Spacer()
//                        Text("더보기")
//                            .foregroundColor(Color.black)
//
//                        Image(systemName: "chevron.right")
//                            .padding()
//                            .foregroundColor(Color.black)
//                    }
//                }
//                }
//                    //지도 부분 시작
//                    // map()
//                //세부사항 부분
//                //detail_content()
//                    Button(action: {
//                        //****심심풀이 작성 페이지로 작성하는 심심풀이를 알 수 있는 변수 넘기기********
////                        writeFeedView(selected_feed_name: selected_feed_name)
//                    }){
//                       Text("내 심심풀이 작성")
//                        .padding()
//                        .background(Color.gray)
//                        .foregroundColor(Color.white)
//                    }
//                    .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width/10)
//                    .padding()
//
//
//                }.padding()
//            }
//        }  .navigationBarTitle("")
//        .navigationBarHidden(true)
//    }
//}
//
//struct detail : View{
//    var history : history
//
//    var body: some View{
//        Group{
//    HStack{
//        Spacer()
//        Text("지금 볼래")
//            .padding(.trailing, UIScreen.main.bounds.width/20)
//    }
//
//    //주최자 프로필이미지, 이름, 티켓보기 버튼
//    HStack{
//        //프로필 이미지
//        Image(systemName: "person.circle")
//            .resizable()
//            .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
//            .cornerRadius(50)
//            .scaledToFit()
//            .padding([.leading,.trailing], UIScreen.main.bounds.width/20)
//        VStack{
//            Text("주최자")
//                .font(.caption2)
//            Text("이은열")
//                .font(.headline)
//        }
//        Spacer()
//        Image(systemName: "ticket")
//            .resizable()
//            .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/10)
//            .padding()
//    }
//    Spacer()
//   // tags()
//    Spacer()
//   // gathering_date()
//        .padding()
//   // gathering_time()
//    }
//    }
//}
//
