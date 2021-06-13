//
//  GlobalState.swift
//  proco
//
//  Created by 이은호 on 2020/12/02.
// 엑세스 토큰 저장. 로그인시 받은 엑세스 토큰, 리프레시 토큰 저장.

import SwiftUI
import Combine
//
//final class GlobalState: ObservableObject {
//    let objectWillChange = ObservableObjectPublisher()
//
//    @Published var access_token: String =
//        //userdefaults에 저장된 access token 가져오기 저장은 set메소드 사용함.
//        UserDefaults.standard.string(forKey: "access_token") ?? ""{
//        willSet {
//                    objectWillChange.send()
//                }
//    }
//    @Published var refresh_token: String =
//        //userdefaults에 저장된 access token 가져오기 저장은 set메소드 사용함.
//        UserDefaults.standard.string(forKey: "refresh_token") ?? ""{
//        willSet {
//                    objectWillChange.send()
//                }
//    }
//    @Published var user_id : String =
//        UserDefaults.standard.string(forKey: "id") ?? ""{
//        willSet {
//                    objectWillChange.send()
//                }
//    }
//    @Published var user_nickname : String =
//        UserDefaults.standard.string(forKey: "nickname") ?? ""{
//        willSet {
//                    objectWillChange.send()
//                }
//    }
//}
