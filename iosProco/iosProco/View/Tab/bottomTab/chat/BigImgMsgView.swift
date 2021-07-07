//
//  BigImgMsgView.swift
//  proco
//
//  Created by 이은호 on 2021/07/06.
//

import SwiftUI
import Kingfisher

struct BigImgMsgView: View {
    
    @Binding var show_img_bigger : Bool
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width*0.7, height: UIScreen.main.bounds.height*0.7))
        |> RoundCornerImageProcessor(cornerRadius: 20)
    @Binding var img_url : String?
    
    var body: some View {
        VStack(alignment: .center){
            HStack{
                Button(action: {
                    print("돌아가기 클릭")
                    self.show_img_bigger = false
                    
                }){
                    Image("profile_close_btn")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
                
                Spacer()
            }.padding()
            
            Spacer()
            
            KFImage(URL(string: img_url!))
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
            
            Spacer()
        }
    }
}
