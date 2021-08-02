//
//  iosProcoApp.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/09.
//

import SwiftUI
import UIKit
import Firebase
//파이어베이스 fcm
import UserNotifications

@main
struct iosProcoApp: App {
    @Environment(\.scenePhase) private var phase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var view_router : ViewRouter = ViewRouter.get_view_router()

    var body: some Scene {
        WindowGroup {

            SplashView(view_router: self.view_router)
                .onChange(of: phase) { newPhase in
                          switch newPhase {
                          case .active:
                            print("액티브")
                            print(appDelegate.view_router.current_page)
                            let app_page = appDelegate.view_router.current_page
                            
                            if appDelegate.view_router.current_page == .chat_room{
                                print("액티브 친구 채팅룸일 때")
                                view_router.current_page = .chat_tab
                                view_router.fcm_destination = "friend_chat_room"
                                
                            }else if appDelegate.view_router.current_page == .notice_tab{
                                print("액티브 알림탭 때")
                                view_router.current_page = .notice_tab
                                view_router.fcm_destination = "notice_tab"
                            }else if appDelegate.view_router.current_page == .normal_chat_room{
                                print("일반 채팅방일 때")
                                view_router.current_page = .chat_tab
                                view_router.fcm_destination = "normal_chat_room"
                                
                            }else if appDelegate.view_router.current_page == .group_chat_room{
                                print("모임 채팅방일 때")
                                view_router.current_page = .chat_tab
                                view_router.fcm_destination = "group_chat_room"
                                
                            }else if appDelegate.view_router.current_page == .manage_friend_tab{
                                print("친구관리일 때")
                                view_router.current_page = .friend_volleh
                                view_router.fcm_destination = "manage_friend"
                                
                            }else if appDelegate.view_router.current_page == .feed_tab{
                                print("피드 페이지인 경우")
                                view_router.current_page = .feed_tab
                                view_router.fcm_destination = "feed_tab"
                            }
                            
                           
                            break
                              // App became active
                          case .inactive:
                            print("인액티브")
                            
                            
                            break
                              // App became inactive
                          case .background:
                            print("백그라운드")
                            
                            if appDelegate.view_router.current_page == .chat_room{
                                print("액티브 채팅룸일 때")
                                view_router.current_page = .chat_room
                                
                            
                          }else if appDelegate.view_router.current_page == .notice_tab{
                              print("액티브 모임 채팅룸일 때")
                              view_router.current_page = .notice_tab
                              
                          }else if appDelegate.view_router.current_page == .chat_tab{
                              print("액티브 일반 채팅룸일 때")
                              view_router.current_page = .chat_tab
                          }else if appDelegate.view_router.current_page == .normal_chat_room{
                            print("일반 채팅방일 때")
                            view_router.current_page = .normal_chat_room
                            
                        }else if appDelegate.view_router.current_page == .group_chat_room{
                            print("모임 채팅방일 때")
                            view_router.current_page = .group_chat_room
                            
                        }else if appDelegate.view_router.current_page == .manage_friend_tab{
                            print("친구관리일 때")
                            view_router.current_page = .manage_friend_tab
                            
                        }else if appDelegate.view_router.current_page == .feed_tab{
                            print("피드 페이지인 경우")
                            view_router.current_page = .feed_tab
                        }
                            break
                              // App is running in the background
                          @unknown default: break
                              // Fallback for future cases
                          }
                      }
    
            }
        }
    }

