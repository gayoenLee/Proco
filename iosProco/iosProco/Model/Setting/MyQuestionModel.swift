//
//  MyQuestionModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
//

import Foundation

struct MyQuestionModel: Identifiable{
    var id: Int{
        idx
    }
    var idx: Int = -1
    var content: String = ""
    var created_at: String? = ""
    var updated_at: String? = ""
    var process_content: String? = ""
    var processed_date: String? = ""
    
}
