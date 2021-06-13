//
//  SmallInterestCell.swift
//  proco
//
//  Created by 이은호 on 2021/03/14.
//

import SwiftUI

struct SmallInterestCell: View {
    
    //관심있어요 버튼 클릭시 통신 위해서 뷰모델 필요함.
    @ObservedObject var main_vm: CalendarViewModel
    @State var small_interest_model: SmallInterestModel
    //관심있어요 클릭한 유저 목록 페이지로 이동시 구분값.
    @State private var show_interest_users: Bool = false
    
    var body: some View {
        HStack{
                Image( small_interest_model.clicked_interest_myself! ? "interest_icon" : "not_interest_icon")
                    .resizable()
                    .frame(width:10.41, height: 8.95)
            
                Text(small_interest_model.interest_num! > 0 ? String(small_interest_model.interest_num!) : "")
                    .font(.custom(Font.t_extra_bold, size: 8))
                    .foregroundColor(Color.proco_black)
        }
        .frame(height: SmallInterestPreviewConstants.cellHeight*0.2)
        .padding(.vertical, SmallInterestPreviewConstants.cellPadding)
        .onAppear{
            print("smallInterestCell on appear")
            let date = self.small_interest_model.date
            let model_idx = self.main_vm.small_interest_model.firstIndex(where: {
                $0.date == date
            }) ?? -1
            
            if model_idx != -1{
                if self.main_vm.small_interest_model[model_idx].clicked_interest_myself != self.small_interest_model.clicked_interest_myself{
                    
                    self.small_interest_model.clicked_interest_myself = self.main_vm.small_interest_model[model_idx].clicked_interest_myself
                    
                    self.small_interest_model.interest_num = self.main_vm.small_interest_model[model_idx].interest_num
                    self.small_interest_model.interest_date_idx = self.main_vm.small_interest_model[model_idx].interest_date_idx
                }
            }
        }
    }
}


