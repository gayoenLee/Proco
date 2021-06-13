//
//  friendContainer.swift
//  proco
//
//  Created by 이은호 on 2020/11/24.
//

import Foundation

struct friend: Identifiable{
    let id = UUID()
    let name : String
    let image : String
}

class friend_container : ObservableObject{
    @Published var friends = [friend]()
    
    init(){
        self.friends = [
            friend(name: "가가나", image: "hardRockCafe"),
            friend(name: "다나", image: "blackRingCoffee"),
            friend(name: "아라", image: "laMoCafe"),
            friend(name: "차니", image: "friendsCafe"),
            friend(name: "마니", image: "camberCoffee")
        ]
    }
}
