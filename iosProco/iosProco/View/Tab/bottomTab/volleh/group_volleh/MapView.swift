//
//  MapView.swift
//  proco
//
//  Created by 이은호 on 2021/01/01.
//

import SwiftUI

struct MapView: View {
    @Environment(\.presentationMode) var presentation
    
    @ObservedObject var vm : GroupVollehMainViewmodel
    @State private var show_map : Bool = false
    
    var body: some View {
        VStack{
            
            MyWebView(vm: self.vm, url: "https://withproco.com/map/search_map.html?device=ios")
            
            ZStack{
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    
                    print("--------지도 위치 선택 후 확인 클릭 : \(self.vm.map_data)--------")
                }){
                    Text("확인")
                        .font(.custom(Font.t_regular, size: 17))
                        .padding()
                        .foregroundColor(.proco_white)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.proco_black)
                .cornerRadius(25)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            }
        }
        .onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                
                print("지도 맵뷰 나타남:\(self.vm.map_data) ")
            }
            
            
        }
    }
    
}

