//
//  MyCardDialog.swift
//  proco
//
//  Created by 이은호 on 2020/12/29.
//

import SwiftUI
import Combine

struct MyCardDialog: View {
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    @Binding var showModal: Bool
    
    var body: some View {
      
            Group {
            if showModal {
                Rectangle()
                    .foregroundColor(Color.black.opacity(0.5))
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            //모달 컨텐츠를 포함하고 있는 큰 사각형. 색깔 투명하게 하기 위함.
                            .foregroundColor(.clear)
                            .frame(width: min(UIScreen.main.bounds.width - 100, 300), height: min(UIScreen.main.bounds.width - 100, 200))
                            .overlay(DialogContents(main_vm: self.main_vm,showModal: $showModal)
                                        .aspectRatio(contentMode: .fill))
                   
            )
            }
            }
    }
}

//모달창 내용
struct DialogContents : View{
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    @Binding var showModal: Bool

    var body: some View{
        VStack(alignment: .leading, spacing: 15){
            Image(systemName: "xmark.circle")
                .onTapGesture {
                    withAnimation{
                        self.showModal.toggle()
                    }
                }
            HStack{
                HStack{
                    
                Image((self.main_vm.my_card_detail_struct.creator?.profile_photo_path ?? ""))
                    .padding()
                Text(self.main_vm.my_card_detail_struct.creator!.nickname)
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
                Button(action: {
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
