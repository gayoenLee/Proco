//
//  friend_main.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/09.
//

import Foundation
import SwiftUI
import Alamofire
import Combine

struct TabbarView : View {
    //그룹 리스트 가져오기 위해 사용하는 뷰모델
    @ObservedObject private var request_group_list = ManageFriendViewModel()
    
//    @State private var go_to_manage : Bool = false
    
    @ObservedObject var view_router : ViewRouter
    
    //하단 탭바중에서 어떤 것을 선택했는지 알 수 있는 구분자.
    @State var tab_index = 0
    
    //친구랑 볼래, 모여볼래 선택 가능한 버튼에 주는 구분자.
    //false일 경우 친구랑 볼래, true일 때 모여볼래 탭이 나온다.
    @State private var selected_proco_tab = false
    
    var body: some View{

            VStack{
                //메인 뷰와 탭바 포함
                BottomTabView(view_router: view_router)
                  
            }
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea()
    }
}






