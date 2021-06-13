//
//  myFeedGridView.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//

import SwiftUI

struct myFeedGridView: View {
    @ObservedObject var my_feed_container = myFeedContainer()
    //lazyVgrid에 사용할 그리드아이템
    var columns : [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        ScrollView{
            LazyVGrid(columns: columns){
                ForEach(my_feed_container.my_feeds){my_feed in
                    VStack{
                        Image(my_feed.image)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/3, height: UIScreen.main.bounds.width/3)
                            .scaledToFit()
                            .overlay(
                        Text(my_feed.time)
                            .foregroundColor(Color.white)
                            .fontWeight(.bold)
                            .font(.caption)
                            .offset(x: UIScreen.main.bounds.width*0.05, y: UIScreen.main.bounds.width*0.09)
                            )
                        
                    }
                    
                }
            }
          
            
            
            
        }    }
}

struct myFeedGridView_Previews: PreviewProvider {
    static var previews: some View {
        myFeedGridView()
    }
}
