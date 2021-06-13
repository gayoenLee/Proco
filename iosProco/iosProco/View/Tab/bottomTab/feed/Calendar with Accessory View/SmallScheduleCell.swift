//
//  SmallScheduleCell.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//날짜 칸 한개에 보여지는 카드 리스트, 좋아요, 관심있어요 아이콘

import SwiftUI

struct SmallScheduleCell: View {
    
    @State var smallSchedule: SmallSchedule
    @ObservedObject var main_vm : CalendarViewModel
    
    var body: some View {
        VStack{
            VStack(alignment: .leading) {
                //카드 이름.변수명 바꿀 예정.
                ForEach(smallSchedule.schedule, id: \.id){schedule in
                    Text(schedule.locationName)
                        .font(.custom(Font.n_regular, size: 8))
                }
            }
            .frame(height: SmallSchedulePreviewConstants.cellHeight*0.6)
        .padding(.vertical, SmallSchedulePreviewConstants.cellPadding)
            /*
            좋아요
            - 1) 내가 좋아요를 누른 경우, 아닌 경우
            - 2) 좋아요 갯수가 있을 경우
                 */
            HStack{
                Button(action: {

                    print("좋아요 아이콘 클릭, 상태: \(smallSchedule.clicked_like_myself)")
                }){
                Image(smallSchedule.clicked_like_myself ? "heart_fill" : "heart")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/50, height: UIScreen.main.bounds.width/50)
                    .foregroundColor(Color.red)
                }

                if smallSchedule.like_num > 0{

                    Text(String(smallSchedule.like_num))
                        .font(.system(size: 6))
                        .foregroundColor(Color.red)
                }
            }
        }
        .onAppear{
            print("날짜 한 칸모델: \(self.smallSchedule)")
            let date = self.smallSchedule.arrivalDate
            let model_idx = self.main_vm.small_schedules.firstIndex(where: {
                $0.arrivalDate == date
            }) ?? -1
            
            if model_idx != -1{
                if
                    self.main_vm.small_schedules[model_idx].clicked_like_myself != self.smallSchedule.clicked_like_myself{
                    self.smallSchedule.clicked_like_myself =  self.main_vm.small_schedules[model_idx].clicked_like_myself
                    
                    self.smallSchedule.like_num = self.main_vm.small_schedules[model_idx].like_num
                    
                    self.smallSchedule.like_idx = self.main_vm.small_schedules[model_idx].like_idx
                }
            }
            
        }
//        .frame(width: UIScreen.main.bounds.width/30, height: UIScreen.main.bounds.width/40)
    }
}



