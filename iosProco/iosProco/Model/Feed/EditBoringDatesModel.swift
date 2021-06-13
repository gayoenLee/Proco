//
//  EditBoringDatesModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/07.
// 심심기간 생성, 수정, 삭제시 서버에 보낼 때 사용하는 모델

import Foundation
import Combine

struct EditBoringDatesModel: Codable,Identifiable{
   
    var bored_date: String = ""
    //서버에서 response받을 떄는 string으로 받아서 BoredDatesModel과 형식 다름.
    var bored_date_days: [Int]? = []
    var id: Int{
        return self.id ?? -1
    }

}
