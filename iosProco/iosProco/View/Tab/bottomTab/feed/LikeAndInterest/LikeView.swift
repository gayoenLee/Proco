//
//  LikeView.swift
//  proco
//
//  Created by 이은호 on 2021/03/09.
//

import SwiftUI

struct LikeView: View {
    @ObservedObject var main_vm: CalendarViewModel

    @State private var like_idx = 0

    let like_total_model: [LikeModel]
    let numberOfCellsInBlock: Int
    
    init(like_total_model: [LikeModel], height: CGFloat ,main_vm : CalendarViewModel){
        self.like_total_model = like_total_model
        numberOfCellsInBlock = 1
        self.main_vm = main_vm
    }
    //한 셀에 보여줄 범위를 계산하는 변수.
    private var range: Range<Int> {
        let exclusiveEndIndex = like_idx + numberOfCellsInBlock
        guard like_total_model.count > numberOfCellsInBlock &&
            exclusiveEndIndex <= like_total_model.count else {
            return like_idx..<like_total_model.count
        }
        return like_idx..<exclusiveEndIndex
    }
    
    var body: some View {
        
        like_view
            .onAppear{
                print("좋아요 뷰 나타남: \(like_total_model)")
            }
    }
    
    private var like_view: some View{
        
        VStack{
            
            ForEach(like_total_model[range]){like in

                LikeCell(like_total_model: like)
            }
        }
    }
}

