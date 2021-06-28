//
//  LikeAndInterestCell.swift
//  proco
//
//  Created by 이은호 on 2021/03/03.
// 상세페이지 - 관심있어요 버튼, 갯수 1개 뷰

import SwiftUI

struct InterestCell: View {
    
    //관심있어요 버튼 클릭시 통신 위해서 뷰모델 필요함.
    @ObservedObject var main_vm: CalendarViewModel
    @State var interest_model: InterestModel
    //관심있어요 클릭한 유저 목록 페이지로 이동시 구분값.
    @State private var show_interest_users: Bool = false
    
    var body: some View {
        HStack{
            //클릭시 관심있어요를 클릭한 사람들 목록 페이지로 이동.
            NavigationLink("",destination: InterestUserListView(main_vm: self.main_vm, bored_date: interest_model.date!), isActive: self.$show_interest_users)
            
            Button(action: {
                
                let check_date = self.main_vm.date_to_string(date: interest_model.date!).split(separator: " ")[0]
                print("관심있어요 클릭 날짜: \(check_date)")
                
                //본래 상태가 관심있어요를 클릭한 상태였는지 여부에 따라 관심있어요 클릭 이벤트 처리
                if interest_model.clicked_interest_myself!{
                    print("관심있어요 취소")
                    self.main_vm.cancel_interest_calendar(user_idx: Int(main_vm.my_idx!)!, interest_idx: interest_model.interest_date_idx!)
                    
                    //관심있어요 이벤트가 진행된 후 현재 뷰에서 갖고 있는 모델이 즉각적으로 데이터를 받아 뷰를 변화시키지 못해서 직접 데이터를 바꿔준 것.
                    interest_model.clicked_interest_myself = false
                    interest_model.interest_num! -= 1
                    
                }else{
                    print("관심있어요 클릭")
                    self.main_vm.send_interest_calendar(user_idx: Int(self.main_vm.my_idx!)!, bored_date: String(check_date))
                    
                    interest_model.clicked_interest_myself = true
                    interest_model.interest_num! += 1
                    
                }
            }){
                
                Image(interest_model.clicked_interest_myself! ? "interest_icon" : "not_interest_icon")
                    .resizable()
                    .frame(width:21.84, height: 18.46)
            }
            
            Button(action: {
                
                self.show_interest_users = true

                print("관심있어요 유저 목록 뷰로 이동 값 토글")
            }){
                Text(interest_model.interest_num! > 0 ? "관심있어요 \(interest_model.interest_num!)개": "관심있어요")
                    .font(.custom(Font.n_extra_bold, size: 14))
                    .foregroundColor(Color.proco_black)
            }
            Spacer()
        }
        .frame(height: InterestPreviewConstants.cellHeight*0.2)
        .padding(.vertical,InterestPreviewConstants.cellPadding)
        .onAppear{
            print("InterestCell 온어피어")
            let date = self.interest_model.date
            let model_idx = self.main_vm.interest_model.firstIndex(where: {
                $0.date == date
            }) ?? -1
            
            if model_idx != -1{
                if self.main_vm.interest_model[model_idx].clicked_interest_myself != self.interest_model.clicked_interest_myself{
                    
                    self.interest_model.clicked_interest_myself = self.main_vm.interest_model[model_idx].clicked_interest_myself
                    
                    self.interest_model.interest_num = self.main_vm.interest_model[model_idx].interest_num
                    self.interest_model.interest_date_idx = self.main_vm.interest_model[model_idx].interest_date_idx
                }
            }
        }
    }
}


