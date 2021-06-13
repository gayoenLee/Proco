//
//  historyContainer.swift
//  proco
//
//  Created by 이은호 on 2020/11/26.
//

import SwiftUI
import Foundation
import Combine

class historyContainer: ObservableObject {
 @Published var histories = [history]()
    init() {
        self.histories = [
            history(date: "2020.01.01", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee", owner_name: "이은아", time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.01.01", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee", owner_name: "이은열", time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.02.11", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee",owner_name: "이은열", time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.03.21", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee", owner_name: "이은열",time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.04.11", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee", owner_name: "이은열",time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.05.03", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee",owner_name: "이은열", time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.06.04", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee",owner_name: "이은열", time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.07.06", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee",owner_name: "이은열", time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.08.07", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee", owner_name: "이은열",time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
            history(date: "2020.09.14", type: "지금볼래", tags: ["첫번째", "두번째", "세번째"], owner_image: "outpostCoffee",owner_name: "이은열", time : "오후 9:00", location: "서울시 서초구", memo: "Then configure the KeyboardAdaptive modifier to move the view only as much as necessary so that the keyboard does not overlap the view"),
        ]
    }
    
}
//후에 티켓 이미지도 넣어야 함.
struct history :Identifiable, Hashable{
    let id = UUID()
    let date : String
    let type : String
    let tags : [String]
    let owner_image : String
    let owner_name : String
    let time : String
    let location : String
    let memo : String
    
}
