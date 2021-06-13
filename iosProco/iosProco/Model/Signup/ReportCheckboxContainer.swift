//
//  reportCheckboxContainer.swift
//  proco
//
//  Created by 이은호 on 2020/11/29.
//

import Foundation
import Combine
import SwiftUI

class ReportCheckboxContainer : ObservableObject{
    @Published var checkbox_items = [checkbox_item]()
    //체크박스 선택 여부
    @Published var selected_item : checkbox_item? {
        didSet{
            if self.selected_item != nil{
                self.selected_item!.checked.toggle()
                
            }
        }
    }
    
    var items = [
        checkbox_item(item_id : 0, title: "성적인 콘텐츠", checked: false)
        ,checkbox_item(item_id : 1,title: "저작권 침해 및 위반 콘텐츠",checked: false),
        checkbox_item(item_id : 2,title: "개인정보의 침해, 유포, 노출 콘텐츠", checked: false)
        ,checkbox_item(item_id : 3,title: "불법물 홍보 및 부적절한 홍보 노출", checked: false)
        ,checkbox_item(item_id : 4,title: "욕설, 명예훼손", checked: false)
        ,checkbox_item(item_id : 5,title: "기타(직접 입력)", checked: false)
    ]
    func change_select(id: Int){
        objectWillChange.send()
        
    }
}

struct checkbox_item: Identifiable, Hashable{
    var id = UUID()
    var item_id : Int
    var title : String
    var checked : Bool
}
