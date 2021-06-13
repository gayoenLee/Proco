//
//  LikeAndInterestView.swift
//  proco
//
//  Created by 이은호 on 2021/03/03.
//

import SwiftUI

struct InterestView: View {
    
    @ObservedObject var main_vm: CalendarViewModel

    @State var interestIndex = 0

    let intrest_total_model: [InterestModel]
    let numberOfCellsInBlock: Int = 1
    var height: CGFloat
    
    private var range: Range<Int> {
        let exclusiveEndIndex = interestIndex + numberOfCellsInBlock
        guard intrest_total_model.count > numberOfCellsInBlock &&
            exclusiveEndIndex <= intrest_total_model.count else {
            return interestIndex..<intrest_total_model.count
        }
        return interestIndex..<exclusiveEndIndex
    }
    
    var body: some View {
        interest_view
            .onAppear{
                print("상세 페이지 관심있어요 뷰 나타남: \(intrest_total_model)")
                //상세페이지에서 관심있어요 클릭시 뷰가 init되는 문제 해결 위해 만든 변수를 여기에서 true만듬.
                main_vm.interest_state_changed = false
            }
            .onDisappear{
                print("관심있어요 뷰 사라짐.")
                main_vm.interest_state_changed = true
            }
    }
    
    private var interest_view: some View{
        
        VStack(spacing: 0){
            
            ForEach(intrest_total_model[range]){interest in
                InterestCell(main_vm: self.main_vm, interest_model:  interest)
            }
        }
    }
}

