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
           
            MyWebView(vm: vm, url: "https://withproco.com/notice")
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
   
        }
        .navigationBarTitle("공지사항")
    }
}
