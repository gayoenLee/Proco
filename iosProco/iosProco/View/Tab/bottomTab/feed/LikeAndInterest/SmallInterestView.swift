//
//  SmallInterestView.swift
//  proco
//
//  Created by 이은호 on 2021/03/14.
//

import SwiftUI

struct SmallInterestView: View {
    @StateObject var main_vm: CalendarViewModel

    @State var interestIndex = 0

    let small_intrest_model: [SmallInterestModel]
    let numberOfCellsInBlock: Int = 1
    var height: CGFloat
    
    private var range: Range<Int> {
        let exclusiveEndIndex = interestIndex + numberOfCellsInBlock
        guard small_intrest_model.count > numberOfCellsInBlock &&
            exclusiveEndIndex <= small_intrest_model.count else {
            return interestIndex..<small_intrest_model.count
        }
        return interestIndex..<exclusiveEndIndex
    }
    
    var body: some View {
        small_interest_view
            .onAppear{
                print("날짜 칸안 관심있어요 뷰 나타남: \(small_intrest_model)")
            }
            .onDisappear{
                print("관심있어요 뷰 사라짐.")
            }
    }
    
    private var small_interest_view: some View{
        
        VStack{
            
            ForEach(small_intrest_model[range]){interest in

                SmallInterestCell(main_vm: self.main_vm, small_interest_model:  interest)
            }
        }
    }
}

