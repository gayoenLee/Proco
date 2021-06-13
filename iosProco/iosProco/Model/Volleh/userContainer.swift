//
//  userContainer.swift
//  proco
//
//  Created by 이은호 on 2020/11/24.
//

import Foundation
import Combine
import SwiftUI


struct user: Identifiable{
    let id = UUID()
    let name: String
    let image: String
    var status : String
}


class userContainer : ObservableObject{
    @Published var users = [user]()
    
    init() {
        self.users = [
            user(name: "가가나", image: "hardRockCafe", status: "yet"),
            user(name: "다나", image: "blackRingCoffee", status: "yet"),
            user(name: "아라", image: "laMoCafe", status: "yet"),
            user(name: "차니", image: "friendsCafe", status: "ok"),
            user(name: "마니", image: "camberCoffee", status: "ok"),

        ]
    }
    //서버 통신 코드 작성
    func fetch_from_server() {
        
    }
    
    func yet_status_filter(){
        
    }
}
