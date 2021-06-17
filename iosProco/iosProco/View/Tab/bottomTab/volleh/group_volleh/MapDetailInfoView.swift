//
//  MapDetailInfoView.swift
//  proco
//
//  Created by 이은호 on 2021/06/16.
//

import SwiftUI

struct MapDetailInfoView: View {
    @Environment(\.presentationMode) var presentation

    @ObservedObject var vm : GroupVollehMainViewmodel
    
    var body: some View {
      
        VStack{
            HStack{
                
                Spacer()
                Text("모임 위치")
                    .foregroundColor(Color.proco_black)
                    .font(.custom(Font.t_extra_bold, size: 22))
                Spacer()
            }   
            .padding()
              
            MyWebView(vm: self.vm, url: "https://withproco.com/map/map.html?device=ios")
            Spacer()
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                print("지도 맵뷰 나타남:\(self.vm.map_data) ")
            }
        }
        .background(Color.proco_white)
        }
    
    
}
