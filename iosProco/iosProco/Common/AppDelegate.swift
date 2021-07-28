//
//  AppDelegate.swift
//  proco
//
//  Created by 이은호 on 2021/02/05.
//

import Foundation
import UIKit
import Firebase

//파이어베이스 fcm
import UserNotifications
import Alamofire

//카카오 로그인
import KakaoSDKCommon

//MessagingDelegate: 파이어베이스 fcm사용시 추가함.
class AppDelegate: UIResponder, UIApplicationDelegate,  UNUserNotificationCenterDelegate{
    
    var view_router = ViewRouter()
    let gcmMessageIDKey = "gcm.message_id"
    var sock_mgr = SockMgr.socket_manager
    /*
     FCM에서 중요 함수 1,2,3가지 주석에 포함.
     1.앱이 포그라운드에서 푸시를받았을 때
     2.앱이 켜져 있지 않지만 백그라운드로 돌고 있는 상태에서 푸시를 클릭했을 때
     3.앱이 꺼졌던 상태에서 푸시를 클릭하고 들어왔을 때
     */
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo as! [String: AnyObject]
        print("노티 받음 111 : \(userInfo)")
        let is_foreground_msg = userInfo["foreground_msg"] as? String
        print("포그라운드 메세지인지 : \(is_foreground_msg)")
        
        if is_foreground_msg == "ok"{
                    
                    let room_kind = userInfo["room_kind"] as! String
                    let chatroom_idx = userInfo["chatroom_idx"] as! String
                    SockMgr.socket_manager.enter_chatroom_idx = Int(chatroom_idx)!
                    print("포그라운드 메세지일 경우 클릭했을 때: \(chatroom_idx), \(room_kind)")
                    DispatchQueue.main.async {
                    switch room_kind {
                    case "친구":
                        print("친구 채팅방")
                        ViewRouter.get_view_router().current_page = .chat_tab
                        ViewRouter.get_view_router().fcm_destination = "friend_chat_room"
                    case "일반":
                        print("일반 채팅방")
                        ViewRouter.get_view_router().current_page = .chat_tab
                        ViewRouter.get_view_router().fcm_destination = "normal_chat_room"
                    case "모임":
                        print("모임 채팅방")
                        ViewRouter.get_view_router().current_page = .chat_tab
                        ViewRouter.get_view_router().fcm_destination = "group_chat_room"
                    default:
                        print("그 외")
                    }
                    }
                }else{
                    
                    let noti_type = userInfo["noti_type"] as? String
                
                switch noti_type{
                case "chat":
                    print("채팅 메세지인 경우")
                    let chatroom_idx_string = String(describing: userInfo["chatroom_idx"]!)
                    let chatroom_idx = Int(chatroom_idx_string)!
                    print("채팅방: \(chatroom_idx)")

                    let content = String(describing: userInfo["content"]!)
                    let created_at = String(describing: userInfo["created_at"]!)
                    let front_created_at = String(describing: userInfo["front_created_at"]!)
                    let chatting_idx_string = String(describing: userInfo["idx"]!)
                    let chatting_idx = Int(chatting_idx_string)!
                    let kinds = String(describing: userInfo["kinds"]!)
                    print("채팅 메세지 어떤 채팅방 종류인지: \(kinds)")
                    let user_idx_string = String(describing: userInfo["user_idx"]!)
                    let user_idx = Int(user_idx_string)
                    
                    //새로 받은 메세지 저장.
                    ChatDataManager.shared.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: chatting_idx, user_idx: user_idx!, content: content, kinds: kinds, created_at: created_at, front_created_at: front_created_at)
                    
                    //친구 채팅인 경우.
                    SockMgr.socket_manager.enter_chatroom_idx = chatroom_idx
                    
                    //2.chat_user테이블에서 데이터 꺼내오기(채팅방입장시 user read이벤트 보낼 때 사용.)
                    ChatDataManager.shared.get_info_for_unread(chatroom_idx: chatroom_idx)
                    //친구랑 볼래 - 채팅방 읽음 처리 위해서 해당 채팅방의 마지막 메세지의 idx 가져오기(채팅방 1개 클릭시 입장하기 전에)
                    ChatDataManager.shared.get_last_message_idx(chatroom_idx: chatroom_idx)
                    
                    DispatchQueue.main.async {
                        ChatDataManager.shared.read_chatroom(chatroom_idx: chatroom_idx)
                        let room_kinds = SockMgr.socket_manager.current_chatroom_info_struct.kinds
                        print("어떤 채팅방인지 확인: \(room_kinds)")
                        
                        if room_kinds == "친구"{
                        print("앱딜리게이트에서 친구 채팅룸으로 화면 변경.")
                        self.view_router.current_page = .chat_room
                            
                        }else if room_kinds == "일반"{
                            print("앱딜리게이트에서 일반 채팅룸으로 화면 변경.")
                            self.view_router.current_page = .normal_chat_room
                            
                        }else{
                            print("앱딜리게이트에서 모임 채팅룸으로 화면 변경.")
                            self.view_router.current_page = .group_chat_room
                            
                        }
                    }
                    break
                //4.친구 요청 도착시---no, 5.--- no
                case "friend_request":
                print("친구 요청 관련 노티")
                    self.view_router.current_page = .manage_friend_tab
                    break
                //6.친구가 좋아요 표시한 경우
                case "friend_card_like":
                print("친구가 좋아요 표시한 경우")
                    self.view_router.current_page = .notice_tab
                    break
                //7.내가 참가한 친구 카드 수정시
                case  "friend_card_updated":
                print("내가 참가한 친구 카드 수정시")
                    self.view_router.current_page = .notice_tab
                    break
                //8.내가 참가한 친구 카드 삭제시
                case "friend_card_deleted":
                print("내가 참가한 친구 카드 삭제시")
                    self.view_router.current_page = .notice_tab
                    break
                //9.내가 참가한 모임 카드 수정시
                case "meeting_card_updated":
                print("내가 참가한 모임 카드 수정시")
                    self.view_router.current_page = .notice_tab
                    break
                //10.내가 참가한 모임 카드 삭제시
                case "meeting_card_deleted":
                print("내가 참가한 모임 카드 삭제시")
                    self.view_router.current_page = .notice_tab
                    break
                //11.내가 만든 모임카드에 누군가 참가 신청시
                case "meeting_card_applied":
                print("")
                    self.view_router.current_page = .notice_tab
                    break
                //12.내가 신청한 모임 요청이 수락됨.
                case "meeting_card_admitted":
                print("내가 신청한 모임 요청이 수락됨.")
                self.view_router.current_page = .notice_tab
                    break
                //13.내가 신청한 모임카드 요청이 거절됨.
                case  "meeting_card_denied":
                print("내가 신청한 모임카드 요청이 거절됨.")
                self.view_router.current_page = .notice_tab
                    break
                //14.내가 만든 모임카드에서 유저가 나감...삭제됨
                
                //15.친구 카드 일정 당일 예약 미리알림
                case "friend_promise":
                print(".친구 카드 일정 당일 예약 미리알림")
                    self.view_router.current_page = .notice_tab
                    break
                //16.모임 카드 일정 당일 예약 미리 알림
                case "meeting_promise":
                print("모임 카드 일정 당일 예약 미리 알림")
                self.view_router.current_page = .notice_tab
                    break
                //17.내가 설정한 심심기간에 좋아요 표시
                case "calendar_interest":
                print("내가 설정한 심심기간에 좋아요 표시")
                self.view_router.current_page = .notice_tab
                    break
                //18.달력에 좋아요
               case "calendar_like":
                print("달력에 좋아요")
                self.view_router.current_page = .notice_tab
                break
                //19.내 관심친구가 친구카드 만듬
               case "interest_friend_card_created":
                print("내 관심친구가 친구카드 만듬")
                self.view_router.current_page = .notice_tab
                break
                //20.내 관심친구가 모임카드 만듬
                case "interest_meeting_card_created":
                    print("내 관심친구가 모임카드 만듬")
                    self.view_router.current_page = .notice_tab
                    break
                //21.내 관심친구가 달력 심심on 설정.
                case "interest_user_on":
                    print("내 관심친구가 달력 심심on 설정.")
                    break
                //22.내 관심친구가 심심기간 등록.
                case "interest_days_changed":
                    print("내 관심친구가 심심기간 등록.")
                    self.view_router.current_page = .notice_tab
                    break
                default:
                print("")
                    self.view_router.current_page = .notice_tab
                    break
            }
                
                    if let aps = userInfo["aps"] as? [String: AnyObject] {
                        // Do what you want with the notification
                        print("확인: \(aps)")
                        print("확인: \(userInfo["aps"])")
                    }

                }
                completionHandler()
                }
    
    //FCM1.앱이 포그라운드에 있을 때 푸시를 받은 경우 호출되는 함수 - 노티 클릭 이벤트와는 상관 없음.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("앱 포그라운드에서 푸시 받음: \(notification)")
      
            print("포그라운드 채팅 푸시일 때: \(notification.request.content)")
            
            let room_kind = notification.request.content.userInfo["room_kind"] as! String
            let chatroom_idx_str = notification.request.content.userInfo["chatroom_idx"] as! String
            print("포그라운드 노티 데이터 뺀 것 확인: \(room_kind), \(chatroom_idx_str)")
            
            let chatroom_idx = Int(chatroom_idx_str)
            
            DispatchQueue.main.async {
                ChatDataManager.shared.read_chatroom(chatroom_idx: chatroom_idx!)
                let room_kinds = room_kind
                print("포그라운드 어떤 채팅방인지 확인: \(room_kinds)")
                
                if room_kinds == "친구"{
                print("앱딜리게이트에서 친구 채팅룸으로 화면 변경.")
                self.view_router.current_page = .chat_room
                    
                }else if room_kinds == "일반"{
                    print("앱딜리게이트에서 일반 채팅룸으로 화면 변경.")

                }else{
                    print("앱딜리게이트에서 모임 채팅룸으로 화면 변경.")
                    self.view_router.current_page = .group_chat_room
                }
            }
      
        completionHandler([.badge, .sound, .alert])
        
        
    }
    
    /*
     앱이 처음 켜질 때 호출되는 함수.
     - 푸시 메시지 등록하거나, 업데이트 체크하는 등을 할 수 있음.
     - FCM3.푸시를 클릭하고 들어왔지만 앱이 완전히 종료된 상태나 꺼져 있었던 상태에서 클릭했을 때 호출되는 함수.
     ...launchOptions파라미터를 분석하면 푸시 메시지를 클릭하고 들어왔는지에 대한 컨트롤 가능.
     */
    // 사용자에게 푸시 권한을 요청..시뮬레이터 되는지 테스트하기 위해 추가함.
    func requestAuthorizationForRemotePushNotification() {
        let current = UNUserNotificationCenter.current()
        current.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // granted가 true로 떨어지면 푸시를 받을 수 있습닏.
        }
    }
    
    func  application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("did finish launching with options메소드 들어옴")
        //파이어베이스 등록
        FirebaseApp.configure()
        //파이어베이스 fcm, 동적링크 세팅시 추가
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        requestAuthorizationForRemotePushNotification()
        //이 토큰은 무슨 토큰인지...확인하기
        InstanceID.instanceID().instanceID { (result, error) in
                  if let error = error {
                    print(" FCM token 오류: \(error)")
                  } else if let result = result {
                    print("FCM token 있음: \(result.token)")
                    UserDefaults.standard.set(String(describing: result.token), forKey: "fcm_token")
                    print("토큰 저장했는지 확인: \(String(describing: UserDefaults.standard.string(forKey: "fcm_token")))")
                  }
                }
        
        
        //TODO 이것 푸시를 클릭해서 앱이 처음 켜진 경우에 작동함. 테스트해볼 것....log에 lauchoptions = nil나옴.
        if let notification = launchOptions?[.remoteNotification] as? [String:AnyObject]{
                        let aps = notification["userInfo"] as! [String : AnyObject]
                        
            print("앱딜리게이트에서 launchopions: \(aps)")
            }
        
        if #available(iOS 10.0, *) {
                  // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
                 
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .alert]
                  UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
            
                }else {
                    let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    application.registerUserNotificationSettings(settings)
                  }
            /*
            APNs 등록하는 것. 애플 푸시 노티피케이션 서비스
            - 이걸 등록하면 didRegisterForRemoteNotificationsWithDeviceToken 메소드 호출됨.
            */
                application.registerForRemoteNotifications()
        
        //카카오 로그인 키 등록
        KakaoSDKCommon.initSDK(appKey: "1aba7c49f02612303b52c65bee6a4f31", loggingEnable:false)
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
          // Called when a new scene session is being created.
          // Use this method to select a configuration to create the new scene with.
        //앱 실행하고 맨 처음에 여기로 들어왔음.
        print("앱 설치 됐을 때 여기로 들어오는지")
          return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
      }

      func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        print("didDiscardSceneSessions")
        print("앱 설치 됐을 때 여기로 들어오는지 discard scene sessions")

          // Called when the user discards a scene session.
          // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
          // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
      }

    //소켓 서버 연결 끊는 것.앱이 백그라운드로 들어가는 것.
    private func applicationDidEnterBackground(application: UIApplication) {
        print("앱딜리게이트 백그라운드")
        //SockMgr.socket_manager.close_connection()
    }

        //유니버셜 링크
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        print("앱 딜리게이트 - continue userActivity")
        if let incoming_url = userActivity.webpageURL{
            print("인커밍 url : \(incoming_url)")
            let link_handled = DynamicLinks.dynamicLinks().handleUniversalLink(incoming_url){(dynamicLink, error) in
                
                guard error == nil else{
                    print("에러 발생: \(error)")
                    return
                }
                if let dynamicLink = dynamicLink{
                    //self.handle_incoming_dynaminc_link(dynamicLink)
                    print("유니버셜 링크")
                    
                }
            }
            if link_handled{
                print("링크 핸들드")
                return true
            }else{
                return false
            }
        }
        return false
    }

    //동적 링크에 사용 - 2
    func application(_ app: UIApplication,
                          open url: URL,
                          options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        print("url 커스텀 스킴으로 받음: \(url)")
        print("url 커스텀 스킴으로 받음 options: \(options)")
        
        print("다이나믹 링크 조건: \(DynamicLinks.dynamicLinks().shouldHandleDynamicLink(fromCustomSchemeURL: url))")

             if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
                print("앱 설치 안됐을 때: \(dynamicLink)")
                
                return true
             }else{
                print("앱이 설치된 경우")

             return false
         }
    }
    
    //FCM2.앱이 백그라운드에 있을 때 푸시를 클릭하고 들어왔을 때 혹은 알림이 dismiss될 때 호출되는 함수
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        //앱 꺼진 상태에서 노티 클릭시 여기 아님.
        
      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }
        
        //TODO 푸시 메시지 분석하는 방법이라고 함. 테스트 해볼 것.
         
      // Print full message.
      print("앱딜리게이트 did recieve remote notification\(userInfo)")
    }
    //노티피케이션을 클릭했을 때 이 메소드가 실행됨.
    //노티의 데이터를 여기에서 처리하면 됨.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let test = userInfo
        print("백그라운드에서 노티 받음: \(test)")

      // If you are receiving a notification message while your app is in the background,
      // this callback will not be fired till the user taps on the notification launching the application.
      // TODO: Handle data of notification
      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)
      // Print message ID.
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
        print("앱딜리게이트 did recieve remote notification\(userInfo)")
       // socket_manager.
      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    // APNs 토큰이 없을 경우 디바이스 토큰으로 등록하는 것.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
      print("APNs token retrieved 디바이스 토큰으로 저장하기 : \(deviceToken)")

      // With swizzling disabled you must set the APNs token here.
      // Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate : MessagingDelegate {
    
  // [START refresh_token]
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    if fcmToken != nil {
        print("파이어베이스 토큰 확인: \(String(describing: fcmToken!))")
       // UserDefaults.standard.set(String(describing: fcmToken!), forKey: "fcm_token")
        print("파이어베이스 토큰: \(String(describing: UserDefaults.standard.string(forKey: "fcm_token")))")

        NotificationCenter.default.post(name: Notification.get_fcm_token, object: nil, userInfo: ["get_fcm_token": fcmToken!])
       
    }
    // TODO: api 서버에 토큰 여기서 보냄.
    //이 콜백은 앱이 실행되고 토큰이 생성됐을 때 실행됨.
    NotificationCenter.default.post(name: Notification.get_fcm_token, object: nil, userInfo: ["get_fcm_token": fcmToken!])
  }
  // [END refresh_token]
}
