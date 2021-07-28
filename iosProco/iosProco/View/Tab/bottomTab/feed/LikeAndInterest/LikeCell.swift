//
//  LikeCell.swift
//  proco
//
//  Created by 이은호 on 2021/03/09.
//

import SwiftUI

struct LikeCell: View {
    
    let like_total_model : LikeModel
    
    var body: some View {
        HStack{
            if like_total_model.clicked_like_myself{
                Image(systemName: "heart.fill" )
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/30, height: UIScreen.main.bounds.width/30)
                    .foregroundColor(Color.proco_red)

            }else{
                Image(systemName:  "heart")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/30, height: UIScreen.main.bounds.width/30)
                    .foregroundColor(Color.proco_red)

            }
           
            Text(like_total_model.like_num > 0 ? String(like_total_model.like_num) : "")
                .font(.system(size: 6))
            Spacer()
        }
        .frame(height: SmallSchedulePreviewConstants.cellHeight*0.2)
        .padding(.vertical, SmallSchedulePreviewConstants.cellPadding)
        .onAppear{
            print("LikeAndInterestCell에서 받은 모델: \(self.like_total_model)")
        }
    }
}

