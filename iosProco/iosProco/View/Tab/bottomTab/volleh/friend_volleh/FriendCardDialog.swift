//
//  FriendCardDialog.swift
//  proco
//
//  Created by 이은호 on 2020/12/30.
//

import SwiftUI
import Combine

struct FriendCardDialog: View {
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    @Binding var showModal: Bool
    @ObservedObject var socket : SockMgr
    
    //채팅하기 클릭시 채팅화면으로 이동.
    @State private var go_to_chat: Bool = false
    
    var body: some View {
      

            if showModal {
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            //모달 컨텐츠를 포함하고 있는 큰 사각형. 색깔 투명하게 하기 위함.
                            .foregroundColor(.clear)
                            .frame(width: min(UIScreen.main.bounds.width - 100, 300), height: min(UIScreen.main.bounds.width - 100, 300))
                            .overlay(FriendDialogContents(main_vm: self.main_vm,showModal: $showModal, socket: socket, go_to_chat: self.$go_to_chat)
                                        .offset(x: UIScreen.main.bounds.width*0.1, y: UIScreen.main.bounds.height * 0.1))
                                       // .aspectRatio(contentMode: .fill))
            )
            }
    }
}

//모달창 내용
struct FriendDialogContents : View{
    
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    @Binding var showModal: Bool
    @ObservedObject var socket : SockMgr
    //일대일 채팅하기 화면 이동 구분값
    @Binding var go_to_chat: Bool
    
    var body: some View{
        VStack(alignment: .leading, spacing: 15){
            
            //친구 카드 주인과 1대1 채팅방 화면으로 이동.
            NavigationLink("",
                           destination: NormalChatRoom(main_vm: self.main_vm, group_main_vm: GroupVollehMainViewmodel(),socket: self.socket).navigationBarTitle("", displayMode: .inline)
                            .navigationBarHidden(true),
                isActive: self.$go_to_chat)
            Image(systemName: "xmark.circle")
                .onTapGesture {
                    withAnimation{
                        self.showModal.toggle()
                    }
                }
            HStack{
                HStack{
                    
                Image((self.main_vm.card_detail_struct.creator?.profile_photo_path ?? ""))
                    .padding()
                Text(self.main_vm.card_detail_struct.creator!.nickname)
                    .font(.callout)
                    
                }
                Spacer()
                HStack{
                    Text(verbatim: "\(self.main_vm.year)년 \(self.main_vm.month)월 \(self.main_vm.date)일")
                        .font(.callout)
                        .padding()
                }
            }
            HStack{
                ForEach(self.main_vm.user_selected_tag_list.indices){tag in
                    Text("#\(self.main_vm.user_selected_tag_list[tag])")

                }
            }
            HStack{
                Button(action: {
                }){
                    Text("심심풀이 보기")
                        .foregroundColor(Color.black)
                        .font(.system(size: 18))
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                }
                //카드 주인과 채팅하기
                Button(action: {
                    
                    print("일대일 채팅하기 클릭 내 idx: \(Int(main_vm.my_idx!)!)")
                    print("일대일 채팅하기 클릭 친구 idx: \(String(describing: main_vm.card_detail_struct.creator!.idx))")
                    //채팅하려는 친구의 idx값 저장해두기
                    socket.temp_chat_friend_model = UserChatInListModel(idx: main_vm.friend_volleh_card_detail.creator.idx, nickname: main_vm.friend_volleh_card_detail.creator.nickname, profile_photo_path: main_vm.friend_volleh_card_detail.creator.profile_photo_path ?? "")
                    
                    //일대일 채팅방이 기존에 존재했는지 확인하는 쿼리문
                    ChatDataManager.shared.check_chat_already(my_idx: Int(main_vm.my_idx!)!, friend_idx: main_vm.card_detail_struct.creator!.idx!)
                    
                    self.go_to_chat.toggle()
                    
                }){
                    Text("채팅하기")
                        .foregroundColor(Color.black)
                        .font(.system(size: 18))
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.orange, lineWidth: 2)
                        )
                }
            }
            .padding()
        }.padding()
        .background(Color.red)
        .cornerRadius(15)
    }
}

