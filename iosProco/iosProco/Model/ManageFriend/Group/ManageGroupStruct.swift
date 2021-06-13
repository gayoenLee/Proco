//
//  ManageGroupStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/13.
//

import Foundation
import Combine

//리스트이므로 identifiable추가
struct ManageGroupStruct : Codable, Identifiable, Hashable{
    var result : String? = nil
    var idx: Int? = nil
    var name: String? = nil
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        return self.idx ??  -1
    }
}
