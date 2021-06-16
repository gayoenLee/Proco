//
//  FriendCardApplyPeopleListView.swift
//  proco
//
//  Created by 이은호 on 2021/06/15.
//

import SwiftUI
import Kingfisher

struct FriendCardApplyPeopleListView: View {

    @ObservedObject var main_vm : FriendVollehMainViewmodel
    @Binding var card_idx: Int
    @Binding var show_view : Bool

    //이미지 원처럼 보이게 하기 위해 scale값을 곱함.
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 150, height: 150)) |> RoundCornerImageProcessor(cornerRadius: 40)
    
    var body: some View {
        VStack{
            //상단 돌아가기, 제목, 수정하기 버튼 탭
            HStack{
                //돌아가기 버튼
                Button(action: {

                    self.show_view.toggle()
                    print("돌아가기 클릭")
                    
                }){
                Image( "left")
                    .resizable()
                    .frame(width: 8.51 , height: 17)
                    .padding(.leading, UIScreen.main.bounds.width/20)
                  
                }
                .padding()
           
                Spacer()
                Text("신청자 목록")
                    .font(.custom(Font.t_extra_bold, size: 22))
                    .foregroundColor(.proco_black)
                    .padding()
                Spacer()
          
            }
            
            ScrollView{
                VStack{
                    
                    HStack{
                        Text("신청자")
                            .font(.custom(Font.n_extra_bold, size: 18))
                            .foregroundColor(.proco_black)
                        Spacer()
                    }
                    .padding(.leading)
                    
                    if main_vm.apply_user_struct.isEmpty{
                        Text("신청자가 없습니다")
                            .font(.custom(Font.n_extra_bold, size: 18))
                            .foregroundColor(.proco_black)
                        
                    }else{
                        
                        ForEach(main_vm.apply_user_struct){ user in
                            
                            HStack{
                                
                                if user.profile_photo_path == "" || user.profile_photo_path == nil{
                                    Image("main_profile_img")
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                                        .cornerRadius(50)

                                }else{
                                    
                                    KFImage(URL(string: user.profile_photo_path!))
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
                                
                                Text(user.nickname!)
                                    .font(.custom(Font.n_bold, size: 16))
                                    .foregroundColor(.proco_black)
                                
                                Spacer()
                            }
                            
                        }
                    }
                }
            }
            
            
        }
        .onAppear{
            self.main_vm.get_friend_card_apply_people(card_idx: card_idx)
        }
    }
}
