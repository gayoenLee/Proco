//
//  LikeAndInterest.swift
//  proco
//
//  Created by 이은호 on 2021/03/03.
// 현재 관심있어요만 데이터 넣어서 사용함.

import SwiftUI
import Combine


struct InterestModel : Identifiable{
    var id = UUID()
    //***관심있어요가 있는 날짜
    var date: Date? = Date()

    //***관심있어요 클릭수
    var interest_num: Int? = -1
  
    //***내가 관심있어요 클릭했는지 여부 -
    var clicked_interest_myself: Bool? = false
    
    //관심있어요 클릭한 날짜의 idx
    var interest_date_idx: Int? = -1
}


extension InterestModel{
    
    //mock과 같은 메소드. 한개의 데이터 형태 형성하는 것.리턴값 보면 알 수 있음.
    static func make_buttons(withDate date: Date, interest_num: Int,  clicked_interest_myself: Bool, interest_date_idx: Int) -> InterestModel {
        
        InterestModel( date: date,  interest_num: interest_num, clicked_interest_myself: clicked_interest_myself, interest_date_idx: interest_date_idx)
    }
}

fileprivate extension DateComponents {

    static var everyDay: DateComponents {
        DateComponents(hour: 0, minute: 0, second: 0)
    }

}

