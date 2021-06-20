//
//  TermContentsView.swift
//  proco
//
//  Created by 이은호 on 2021/05/23.
// 회원가입 약관동의 웹뷰 띄우는 뷰

import SwiftUI
import WebKit

struct TermContentsView: View {
    @Environment(\.presentationMode) var presentation

    let url : String
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.presentation.wrappedValue.dismiss()

                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                }
            }
        SignupTermsWebView(url: URL(string: url)!)
        }
    }
}
