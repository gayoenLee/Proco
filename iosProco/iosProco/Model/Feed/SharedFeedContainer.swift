//
//  SharedFeedContainer.swift
//  proco
//
//  Created by 이은호 on 2020/11/29.
//

import Foundation
import SwiftUI
import Combine

class SharedFeedContainer : ObservableObject{
    @Published var shared_feeds = [shared_feed]()
    
    init() {
        self.shared_feeds = [
        shared_feed(image: "hopStorkCoffee", like: "1"),
            shared_feed(image: "blackCoffee", like: "1"),
            shared_feed(image: "theGoodLifeCoffee", like: "1"),shared_feed(image: "thinkCoffee", like: "1"),
            shared_feed(image: "laPerlaCafe", like: "1"),
            shared_feed(image: "outpostCoffee", like: "1"),
            shared_feed(image: "sheepCoffee", like: "1"),
            shared_feed(image: "theGoodLifeCoffee", like: "1"),
            shared_feed(image: "thinkCoffee", like: "1"),
            
        ]
    }
}

struct shared_feed : Identifiable, Hashable{
    var id = UUID()
    var image : String
    var like : String
    
}
