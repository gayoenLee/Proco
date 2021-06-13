//
//  LocationCategoryView.swift
//  proco
//
//  Created by 이은호 on 2021/05/05.
//

import SwiftUI

struct LocationCategoryView: View {
    
    @ObservedObject var main_vm : GroupVollehMainViewmodel
    @State var location_model : LocationCategoryStruct
    
    @State private var is_selected : Bool = false
    @Binding var selected_location : String

    var body: some View {
        HStack{
               
                    Button(action: {
                        print("선택한 지역 이름: \(location_model.name)")
                        self.selected_location = location_model.name
                        
                    }){
                        HStack{

                            Image(self.selected_location == location_model.name ? "category_checked" : "plus")
                                .resizable()
                                .frame(width: 6.49, height:6.49)
                                .padding(.leading, UIScreen.main.bounds.width/30)
                            
                            Text(location_model.name)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.custom(Font.t_extra_bold, size: 15))
                                .foregroundColor(self.selected_location == location_model.name ? .proco_white : .proco_black)
                                .padding(.trailing, UIScreen.main.bounds.width/60)
                        }
                        .frame(width: 75, height: 30)
                    }
                    .background(self.selected_location == location_model.name ? Color.proco_black : Color.proco_white)
                    .overlay(Capsule()
                                .stroke(Color.proco_black, lineWidth: 5)
                    )
                    .cornerRadius(27.0)
        }
    }
}
