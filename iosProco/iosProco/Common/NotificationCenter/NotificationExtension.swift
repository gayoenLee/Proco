//
//  NotificationExtension.swift
//  proco
//
//  Created by 이은호 on 2021/01/07.
// 새로운 메세지 왔을 때 채팅창에서 새로운 메세지 바로 보여주기 위함.

import Foundation
import Combine

extension Notification{
    //친구랑 볼래
    //새로운 메세지 왔을 때 채팅창에서 사용
    static let new_message = Notification.Name.init("new_message")
    //새로운 메세지 왔을 때 채팅 방 목록에서 사용
    static let new_message_in_room = Notification.Name.init("new_message_in_room")
    //추방 당했을 경우 뷰 이동시키기
    static let move_view = Notification.Name.init("move_view")
    
    //일반 채팅방
    //새로운 메세지 왔을 때
    static let normal_new_message = Notification.Name.init("normal_new_message")
    //채팅방 목록에서 뷰 업데이트시 사용
    static let new_message_in_room_normal = Notification.Name.init("new_message_in_room_normal")
    //동적링크 수락시 뷰를 채팅방으로 이동시키기 위해 사용
    static let dynamic_link_move_view = Notification.Name.init("dynamic_link_move_view")
    //fcm 토큰 받았을 때 서버에 보내기 위함.
    static let get_fcm_token = Notification.Name.init("get_fcm_token")
    //알림 설정 변화 후 뷰 업데이트
    static let alarm_changed = Notification.Name.init("alarm_changed")
    //좋아요 클릭 통신 후 뷰 업데이트
    static let clicked_like = Notification.Name.init("like_clicked")
    //친구 메인에서 오늘 심심기간으로 설정 후 뷰 업데이트
    static let set_boring_today = Notification.Name.init("today_boring_event")
    //친구 카드 편집시 카테고리 태그를 뷰에 저장시키기 위함.
    static let send_selected_card_category = Notification.Name.init("selected_category")
    //카드 상세페이지에서 데이터 다 받아왔다는 것 알릴 때...후에 다른 통신에서도 사용할 수 있도록 변수명 지음.
    static let get_data_finish = Notification.Name.init("get_data_finish")
    //관심친구 설정 완료시
    static let set_interest_friend = Notification.Name.init("set_interest_friend")
    //참가 신청 클릭 후 통신 완료시
    static let apply_meeting_result = Notification.Name.init("apply_meeting_result")
    
    //에러난 메세지 다시 전송하기 클릭시 뷰 -> 다른 뷰에 데이터 전달하기 위해
    static let send_msg_again = Notification.Name.init("send_msg_again")
    
    //캘린더 - 좋아요 클릭 이벤트
    static let calendar_like_click = Notification.Name.init("calendar_like_click")
    
    //캘린더에서 주인 프로필 클릭시 마이 페이지 이동시키기 위한 값
    static let calendar_owner_click = Notification.Name.init("calendar_owner_click")
    
    //캘린더 심심기간 관심있어요 통신
    static let calendar_interest_click = Notification.Name.init("calendar_interest_click")
    
    //회원가입시 친구 요청 통신 완료 후
    static let request_friend = Notification.Name.init("request_friend")
    
    //동적링크 클릭 후 일반 채팅방에서 친구 또는 모임카드 상세페이지로 이동시키기 위함.
    static let clicked_invite_link = Notification.Name.init("clicked_invite_link")
    
    //회원가입시 초대문자 보내기 후
    static let sent_invite_msg = Notification.Name.init("sent_invite_msg")
    
    //친구 신청 수락 및 거절 이벤트 완료시
    static let friend_request_event = Notification.Name.init("friend_request_event")
    
    //카드 잠금 이벤트 완료시 + 다른 곳에서도 사용
    static let event_finished = Notification.Name.init("event_finished")
}
