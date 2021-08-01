//
//  TestViewmodel.swift
//  proco
//
//  Created by 이은호 on 2021/07/29.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON
import SwiftUI


class TestViewmodel : ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    @Published var test_update_value : String = ""{
        didSet{
            objectWillChange.send()
        }
    }
    
    static var test_vm : TestViewmodel?
    
    static func get_test_vm()->TestViewmodel{
        if test_vm == nil{
            test_vm = TestViewmodel()
        }
        return test_vm!
    }
}
