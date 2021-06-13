//
//  LikeModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/09.
//

import Foundation
import SwiftUI
import Alamofire
import Combine

struct LikeModel : Identifiable{
    var id = UUID()
    //**좋아요가 있는 날짜
    var date: Date? = Date()
    //좋아요 클릭수
    var like_num: Int = 0
    //내가 좋아요 클릭했는지 여부
    var clicked_like_myself: Bool = false
    var clicked_like_idx: Int = -1
}

extension LikeModel{
    
    
    static func make_like_buttons(withDate date: Date, like_num: Int, clicked_like_myself: Bool, clicked_like_idx: Int) -> LikeModel {
    
        LikeModel(date: date, like_num: like_num, clicked_like_myself: clicked_like_myself, clicked_like_idx: clicked_like_idx)
    }
    
}

fileprivate extension DateComponents {

    static var everyDay: DateComponents {
        DateComponents(hour: 0, minute: 0, second: 0)
    }

}


