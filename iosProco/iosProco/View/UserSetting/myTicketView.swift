//
//  myTicketView.swift
//  proco
//
//  Created by 이은호 on 2020/11/26.
//

import SwiftUI

struct myTicketView: View {
    var body: some View {
        VStack{
            //상단바
            HStack{
                Image(systemName: "chevron.left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                Spacer()
                Text("내 티켓 보기")
                Spacer()
                Circle()
                    .foregroundColor(Color.orange)
                    .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                    .overlay(Text("5개")
                                .foregroundColor(Color.white)
                                .fontWeight(.bold))
            }
            .padding()
            
            List{
                ForEach(0..<15){index in
                    ticket_row()
                }
            }
            Button(action: {
                
            }){
                Text("티켓 추가하기")
                    .foregroundColor(Color.white)
                    .fontWeight(.bold)
                    .padding()
            }
            .frame( maxWidth: .infinity)
            .background(Color.gray)
            .padding()
        }
        
    }
}
//티켓 1개 뷰
struct ticket_row: View{
    var body: some View{
        Rectangle()
            .foregroundColor(Color.gray)
            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width/4)
            .padding()
    }
}
struct myTicketView_Previews: PreviewProvider {
    static var previews: some View {
        myTicketView()
    }
}
