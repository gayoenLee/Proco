//
//  FriendStateRow.swift
//  proco
//
//  Created by 이은호 on 2020/12/30.
//

import SwiftUI

struct FriendStateRow: View {
    @ObservedObject var main_vm : FriendVollehMainViewmodel
    @State var card_struct : GetFriendListStruct

    
    var body: some View {
        VStack{
            HStack{
                ZStack{
                   
                    if (card_struct.profile_photo_path == "" || card_struct.profile_photo_path == nil){
                    Image(systemName: "person")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                            .cornerRadius(50)
                            .overlay( Circle()
                                        .frame(width: UIScreen.main.bounds.width/20)
                                        .foregroundColor(card_struct.state == 1 ? Color(.green) : Color(.gray))
                                        .offset(x:  UIScreen.main.bounds.width*0.08 - 1, y: UIScreen.main.bounds.width*0.08 - 1)
                            )
                    }else{
                   
                        Image(card_struct.profile_photo_path!)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                            .cornerRadius(50)
                            .overlay(Circle()
                                        .frame(width: UIScreen.main.bounds.width/20)
                                        .foregroundColor(.green)
                                        .offset(x:  UIScreen.main.bounds.width*0.08 - 1, y: UIScreen.main.bounds.width*0.08 - 1)
                            )
                    }
                }
                Spacer()
                Text(card_struct.nickname!)
                    .font(.caption2)
                    .padding()
            }
        }
}
}
