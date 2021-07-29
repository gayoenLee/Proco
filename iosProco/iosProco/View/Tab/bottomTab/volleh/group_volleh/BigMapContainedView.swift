//
//  BigMapContainedView.swift
//  proco
//
//  Created by 이은호 on 2021/05/04.
//

import SwiftUI

struct BigMapContainedView: View {
    @Environment(\.presentationMode) var presentation
    
    @StateObject var vm : GroupVollehMainViewmodel
    @State private var show_map : Bool = false
    
    var body: some View {
 
        VStack{
            
            HStack{
                Button(action: {
                    
                    print("뒤로 가기 버튼 클릭")
                    self.vm.is_making = false
                    self.presentation.wrappedValue.dismiss()
                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                }
                
                Spacer()
                
                Text("장소")
                    .font(.custom(Font.n_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
            }
            .padding()
            
            MyWebView(vm: self.vm, url: "https://withproco.com/map/search_map.html?device=ios")
            
            Spacer()
            Button(action: {
                self.presentation.wrappedValue.dismiss()
                
                //self.vm.map_edited =- true
                // self.show_map.toggle()
                //self.vm.is_editing_card = false
                self.vm.is_making = false
                
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
        //키보드 올라왓을 때 화면 다른 곳 터치하면 키보드 내려가는 것
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onAppear{
            
            print("지도 맵뷰 나타남:\(self.vm.map_data) ")
            
        }
        .background(Color.proco_white)
    }
    
}


