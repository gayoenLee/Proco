//
//  NoticeView.swift
//  proco
//
//  Created by 이은호 on 2021/03/25.
//

import SwiftUI

struct NoticeView: View {
    @ObservedObject var vm : GroupVollehMainViewmodel

    var body: some View {
        VStack{
            Button(action: {
                print("클릭")
            }){
                Image(systemName: "arrowshape.turn.up.right")
            }
           
            MyWebView(vm: vm, url: "https://218.101.130.126:5336/notices/client")
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.7)
   
        }
    }
}
