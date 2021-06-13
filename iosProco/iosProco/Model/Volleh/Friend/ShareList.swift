//
//  ShareList.swift
//  proco
//
//  Created by 이은호 on 2020/12/23.
//

import Foundation
import Combine

struct ShareList: Codable, Hashable, Identifiable{
    var idx_kinds: String = ""
    var unique_idx: Int = 99
    var name: String = ""
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        return self.unique_idx
    }
    
}
