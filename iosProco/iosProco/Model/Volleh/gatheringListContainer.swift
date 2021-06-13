//
//  gatheringListContainer.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//

import Foundation
import SwiftUI
import Combine

class gatheringListContainer : ObservableObject{
    @Published var gatherings_list = [gathering_list]()
    
    init() {
        self.gatherings_list = [
            gathering_list( category: "게임/오락", room_name: "모임이름", type: "지금 볼래", time: "오후 1:00", member_num: "2", location: "서울시 서초구", profile_image: "laPerlaCafe", name: "이은경"),
            gathering_list(category: "게임/오락", room_name: "모임이름", type: "지금 볼래", time: "오후 4:050", member_num: "2", location: "서울시 동작구", profile_image: "blackRingCoffee", name: "이은일"),    gathering_list(category: "게임/오락", room_name: "모임이름", type: "지금 볼래", time: "오후 5:00", member_num: "2", location: "서울시 강남구", profile_image: "blackRingCoffee", name: "이은정"),    gathering_list(category: "게임/오락", room_name: "모임이름", type: "지금 볼래", time: "오후 12:30", member_num: "2", location: "서울시 성북구", profile_image: "blackRingCoffee", name: "이은일"),    gathering_list( category: "게임/오락", room_name: "모임이름", type: "지금 볼래", time: "오후 1:00", member_num: "2", location: "서울시 동작구", profile_image: "theGoodLifeCoffee", name: "이은일"),    gathering_list(category: "게임/오락", room_name: "모임이름", type: "지금 볼래", time: "오후 1:00", member_num: "2", location: "서울시 동작구", profile_image: "blackRingCoffee", name: "이은나")
        ]
    }
    
}

struct gathering_list : Identifiable,Hashable{
    let id = UUID()
    let category : String
    let room_name : String
    let type : String
    let time : String
    let member_num : String
    let location : String
    let profile_image : String
    let name : String
}
