//
//  ViewRouter.swift
//  proco
//
//  Created by 이은호 on 2020/12/21.
//

import Foundation
import Combine
import SwiftUI

class ViewRouter:  ObservableObject {
    static var view_router : ViewRouter?
    static func get_view_router() -> ViewRouter{
        if view_router == nil {
            view_router = ViewRouter()
        }
        
        return view_router!
    }
    public let objectWillChange = ObservableObjectPublisher()
    @Published var init_root_view : String = "origin" {
        didSet{
            objectWillChange.send()
        }
    }
    @Published var current_page: Page = .friend_volleh{
        didSet{
            print("첫 화면 변경")
            objectWillChange.send()
        }
    }
}

enum Page {

    case chat_tab
    case feed_tab
    case friend_volleh
    case people_volleh
    case notice_tab
    //친구 채팅방
    case chat_room
    //모임채팅방
    case group_chat_room
    //일반 채팅방
    case normal_chat_room
    //친구관리탭
    case manage_friend_tab
}

