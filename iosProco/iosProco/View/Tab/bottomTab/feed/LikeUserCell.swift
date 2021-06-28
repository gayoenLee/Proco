//
//  LikeUserCell.swift
//  proco
//
//  Created by 이은호 on 2021/03/12.
//

import SwiftUI
import Kingfisher

struct LikeUserCell: View {
    @StateObject var main_vm : CalendarViewModel

    @State var like_user_model: LikeUserListModel
    //좋아요한 사람 한명 클릭시 피드페이지로 이동하는 값.
    @State private var show_friend_feed: Bool = false
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 50)) |> RoundCornerImageProcessor(cornerRadius: 40)
    
    var body: some View {
        
        HStack{
            NavigationLink("",destination: SimSimFeedPage(main_vm: self.main_vm), isActive: self.$show_friend_feed)
            
            if like_user_model.profile_photo_path == "" || like_user_model.profile_photo_path == nil{
                
                Image("main_profile_img" )
                    .resizable()
                    .frame(width: 50, height:50)
            }else{
                
                KFImage(URL(string: like_user_model.profile_photo_path!))
                    .loadDiskFileSynchronously()
                    .cacheMemoryOnly()
                    .fade(duration: 0.25)
                    .setProcessor(img_processor)
                    .onProgress{receivedSize, totalSize in
                        print("on progress: \(receivedSize), \(totalSize)")
                    }
                    .onSuccess{result in
                        print("성공 : \(result)")
                    }
                    .onFailure{error in
                        print("실패 이유: \(error)")
                    }
            }
        
            Text(like_user_model.nickname)
                .font(.custom(Font.n_bold, size: 12))
                .foregroundColor(Color.proco_black)
                      Spacer()
        }
        .padding()
        .onTapGesture {
            print("유저 클릭 이벤트: \(like_user_model.idx)")
            
            self.main_vm.calendar_owner.profile_photo_path = like_user_model.profile_photo_path ?? ""
            self.main_vm.calendar_owner.user_idx = like_user_model.idx
            self.main_vm.calendar_owner.watch_user_idx = Int(self.main_vm.my_idx!)!
            
           //피드 페이지로 이동하는 값 변경.
            self.show_friend_feed.toggle()
        }
        
    }
}
