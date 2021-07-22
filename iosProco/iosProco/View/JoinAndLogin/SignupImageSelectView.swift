//
//  SignupImageSelectView.swift
//  proco
//
//  Created by 이은호 on 2021/07/21.
//

import SwiftUI

struct SignupImageSelectView: View {
    @Environment(\.presentationMode) var presentation

    //선택한 이미지 보여주기
    @Binding var selected_image: Image?
    @Binding var image_url : String?
    @Binding var ui_image : UIImage?
    //이미지 선택 sheet 보여줄지 구분하는 변수
    @Binding var show_image_picker : Bool
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.presentation.wrappedValue.dismiss()

                }){
                Image("left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
            Spacer()
            }
            ImagePicker(image: self.$selected_image, image_url: self.$image_url, ui_image: self.$ui_image)
        }
    }
}
