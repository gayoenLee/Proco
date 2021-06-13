//
//  CheckboxFieldView.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/10.
//

import SwiftUI

struct checkbox_field_view: View {
        let id: String
        let label: String
        let size: CGFloat
        let color: Color
        let callback: (String, Bool)->()
    
        init(
            id: String,
            label:String,
            size: CGFloat = 10,
            color: Color = Color.black,
            callback: @escaping (String, Bool)->()
            ) {
            self.id = id
            self.label = label
            self.size = size
            self.color = color
            self.callback = callback

        }
        
        @State var isMarked:Bool = false
        
        var body: some View {
            
            Button(action:{
               
                if id.contains("약관 전체 동의합니다") {
                    self.isMarked.toggle()
                }
            }) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: self.isMarked ? "checkmark.circle.fill" : "circle")
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: self.size, height: self.size)
                    Text(label)
                        .font(Font.system(size: size))
                    Spacer()
                }.foregroundColor(self.color)
            }
            .foregroundColor(Color.white)
            
            
        }
}


