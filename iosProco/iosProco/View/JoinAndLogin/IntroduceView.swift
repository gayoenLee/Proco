//
//  IntroduceView.swift
//  proco
//
//  Created by 이은호 on 2021/07/21.
//

import SwiftUI

struct IntroduceView: View {
   

    let url : String
    //@State private var go_main : Bool = false
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                   // self.go_main = true
                    //루트뷰 메인으로 변경
                    ViewRouter.get_view_router().init_root_view = "tab_main"
                }){
                    Image("card_dialog_close_icon")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
                
                Spacer()
            }
            .padding([.top, .leading, .trailing])
        SignupTermsWebView(url: URL(string: url)!)
//            NavigationLink("",destination: TabbarView(view_router: ViewRouter()).navigationBarHidden(true), isActive: self.$go_main)
        }
        .navigationBarHidden(true)
    }
}

