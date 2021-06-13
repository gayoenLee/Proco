//
//  ContentView.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/09.
//

import SwiftUI

struct logo_view: View {

    
    var body: some View {
                VStack(alignment: .center){
                    
                Image("logo")
                    //핸드폰 넓이 기준으로 3/1길이를 한 변으로 잡음.
                    .frame(width: UIScreen.main.bounds.width*1/3, height: UIScreen.main.bounds.width*1/3, alignment: .center)
                    .background(Color.green)
                    //이미지 중앙정렬 위해 추가한 포지션 값.
                    .padding([.top], UIScreen.main.bounds.width*0.6)
                }
      
    }
}

struct logo_view_Previews: PreviewProvider {
    static var previews: some View {
        logo_view()
    }
}
