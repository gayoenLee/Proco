//
//  TabBarIcon.swift
//  proco
//
//  Created by 이은호 on 2020/12/21.
//

import SwiftUI
import Combine

//탭바 1개 이미지
struct TabBarIcon: View {
    
    @StateObject var view_router: ViewRouter
    let assigned_page: Page
    
    let width, height: CGFloat
    let systemIconName, tabName, selected_icon: String

    var body: some View {
        VStack {
            Image(view_router.current_page == assigned_page ? selected_icon : systemIconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width, height: height)
                .padding(.top, 10)

            Spacer()
        }
            .onTapGesture {
                view_router.current_page = assigned_page
            }
        .foregroundColor(view_router.current_page == assigned_page ? Color.gray : .blue)
    }
}

