//
//  APIRouter.swift
//  proco
//
//  Created by 이은호 on 2020/12/03.
//

import Alamofire
import Foundation
import Combine
//endpoint를 요청하는 api요청 빌더
//router : http메소드, http헤더, 경로 및 매개변수를 사용해 endpoint제공...enum을 사용해 api router만들기
enum APIRouter: URLRequestConvertible {
    //아이디,비번 찾기 때 인증문자 요청 통신
    case find_id_pwd_phone_auth(phone_num:String, type:String)
    
    //비밀번호 변경시 통신
    case change_password(password: String, phone_num: String, auth_num: String)
    
    //회원가입시 인증문자 요청 통신
    case phone_auth(phone_num:String, type:String )
    
    //인증문자 확인용 통신
    case check_phone_auth(phone_num: String, auth_num: String ,type: String)
    
    //회원가입 마지막 정보 보낼 때
    case send_profile_image(profile_image: Data)
    case send_signup_info(phone: String, email: String, password: String, gender: Int, birthday: String, nickname: String, marketing_yn: Int, auth_num: String, sign_device: String, update_version: String)
    //일반 로그인
    case send_check_login(id: String, password: String, fcm_token: String, device: String)
    
    //스플래시 액티비티에서 리프레시 토큰 보내서 확인하는 통신
    case splash_check(refresh_token: String)
    
    //TODO 변수명 수정할 것.
    //인터셉터
    case access_token(access_token: String)
    
    //친구관리 페이지 모든 그룹 데이터 가져오기
    case get_all_manage_group
    
    //친구관리 - 그룹추가
    case add_group(group_name: String, friends_idx: Array<Any>)
    
    //친구관리 - 친구 목록 가져오기
    case get_friend_list(friend_type: String)
    
    //친구관리 - 그룹 상세 페이지로 이동
    case get_group_detail(group_idx: Int)
    
    //친구관리 - 그룹 이름 편집 통신
    case edit_group_name(group_idx: Int, group_name: String)
    
    //친구관리- 그룹 멤버 편집 통신
    case edit_group_member(group_idx: Int,friends_idx: Array<Any>)
    
    //친구관리 - 그룹삭제
    case delete_group(group_idx: Int)
    //친구관리 - 친구 그룹에 추가하기
    case add_friend_to_group(group_idx: Int, friend_idx: Int)
    
    //친구관리 - 친구 신청 목록 가져오기
    case get_request_friend(friend_type: String)
    
    //친구 신청 수락
    case accept_friend_request(friend_idx: Int, action: String)
    //친구 신청 거절
    case decline_friend_request(friend_idx: Int, action: String)
    
    //번호로 친구추가하기(체크)
    case add_friend_number_check(friend_phone: String)
    
    //이메일로 친구추가하기(체크)
    case add_friend_email_check(friend_email: String)
    
    //번호로 친구추가하기(최종)
    case add_friend_number_last(f_idx: Int)
    
    //이메일로 친구추가하기(최종)
    case add_friend_email_last(f_idx: Int)
    
    //친구랑 볼래 카드 리스트 가져오기
    case get_friend_volleh_card_list
    
    //친구랑 볼래 카드 만들기
    case friend_volleh_make_card(type: String, time: String, tags: Array<Any>, share_list: [Dictionary<String , Any>])
    
    //친구랑 볼래 카드 정보 갖고 오기
    case get_card_info_friend_volleh(card_idx: Int)
    
    //친구랑 볼래 카드 수정 후 완료
    case edit_friend_volleh_card(card_idx: Int, type: String, time: String, tags: Array<Any>, share_list: [Dictionary<String , Any>])
    //친구랑 볼래 카드 삭제
    case delete_friend_volleh_card(card_idx: Int)
    //모여볼래 카드 가져오기
    case get_group_volleh_card_list
    //모여볼래 카드 만들기
    case make_group_card(type: String, title: String, tags: Array<Any>, time: String, address: String, content: String, map_lat: String, map_lng: String)
    //모여볼래 카드 수정
    case edit_group_card(card_idx: Int, type: String, title: String, tags: Array<Any>, time: String, address: String, content: String, map_lat: String, map_lng: String)
    //TODO 모여볼래 카드 상세 정보 가져오기
    case get_group_card_detail(card_idx: Int)
    
    //모여볼래 카드 삭제
    case delete_group_card(card_idx: Int)
    
    //모여볼래 카드 참가 신청하기
    case apply_group_card(card_idx: Int)
    //모여볼래 신청자 목록 가져오기
    case get_apply_people_list(card_idx: Int)
    //모여볼래 참가 신청 수락
    case apply_accept(card_idx: Int, meet_user_idx: Int)
    //모여볼래 참가 신청 거절
    case apply_decline(card_idx: Int, meet_user_idx: Int)
    //모여볼래 신청 목록 가져오기
    case get_my_apply_list(type: String)
    //친구랑 볼래 필터 적용
    case friend_volleh_filter(date_start: String, date_end: String, tag: Array<Any>)
    //모여볼래 필터 적용
    case group_volleh_filter(date_start: String, date_end: String, address:String, tag: Array<Any>, kinds: String)
    
    //내 모든 카드 리스트 가져오기(채팅방 - 친구 내 카드에 초대하기)
    case get_all_my_cards(type: String)
    //동적링크 통해 참여 수락 눌렀을 때
    case accept_dynamic_link(chatroom_idx: Int)
    //fcm token 이용해서 테스트
    case send_fcm_token(user_idxs: Array<Any>, noti_data: Dictionary<String , Any>)
    
    //심심기간 정보 조회 api 문서 v1.132
    //user_idx외에는 일반 파라미터로 전송.
    case get_boring_period(user_idx: Int, date_start: String, date_end: String)
    
    //캘린더에 보여줄 카드 이벤트들 가져오기
    case get_card_for_calendar(user_idx: Int, date_start: String, date_end: String)
    
    //캘린더에서 좋아요 정보 가져오기
    case get_like_for_calendar(user_idx: Int, date_start: String, date_end: String)
    
    //캘린더 좋아요 클릭했을 때 서버에 보내기
    case send_like_in_calendar(user_idx: Int, like_date: String)
    
    //캘린더 - 좋아요 취소했을 때
    case send_cancel_like_calendar(user_idx: Int, calendar_like_idx: Int)
    
    //캘린더 - 좋아요한 사람들 목록 가져오기
    case get_like_user_list(user_idx: Int, calendar_date: String)
    //캘린더 - 관심있어요 클릭
    case send_interest_calendar(user_idx: Int, bored_date: String)
    //캘린더 - 관심있어요 취소
    case cancel_interest_calendar(user_idx: Int, interest_idx: Int)
    
    //캘린더 - 관심있어요 유저리스트 가져오기
    case get_interest_users(user_idx: Int, bored_date: String)
    //캘린더 - 내 일정 추가하기
    case add_personal_schedule(title: String, content: String, schedule_date: String, schedule_start_time: String)
    //캘린더 내 일정 모든 리스트 가져오기
    case get_personal_schedules(user_idx: Int, date_start: String, date_end: String)
    
    //내 일정 수정하기
    case edit_personal_schedule(schedule_idx: Int
                                , title: String, content: String, schedule_date: String, schedule_start_time: String)
    
    //내 일정 삭제하기
    case delete_personal_schedule(schedule_idx: Int)
    //캘린더 - 좋아요, 관심있어요 유저 목록에서 피드로 이동전 친구인지 체크 통신
    case check_is_friend(friend_idx: Int)
    
    //캘린더 - 친구 아닌 사람 - 친구 신청하기 버튼 요청
    case add_friend_request(f_idx: Int)
    
    //문의하기 생성 통신
    case send_question_content(content: String)
    
    //내 문의내역 가져오기
    case get_my_questions
    
    //문의 수정하기
    case edit_question(question_idx: Int, content: String)
    
    //문의 삭제하기
    case delete_question(question_idx: Int)
    
    //이메일 인증
    case verify_email(email: String)
    
    //이메일 인증 후 돌아왔을 때 확인하는 통신
    case check_verify_email
    
    //설정 - 비밀번호 변경
    case setting_change_pwd(current_password: String, new_password: String)
    
    //회원탈퇴
    case delete_exit_user(user_idx: Int)
    
    //설정 - 마이페이지에서 유저 모든 정보 가져오기
    case get_detail_user_info(user_idx: Int)
    
    //설정 - 마이 페이지 정보 수정
    case edit_user_info(gender : Int, birthday: String, nickname: String)
    //설정 - 캘린더 공개범위 설정
    case edit_calendar_disclosure_setting(calendar_public_state: Int)
    //설정 - 채팅 알림 설정
    case edit_chat_alarm_setting(chat_notify_state: Int)
    //설정 - 피드 알림 설정
    case edit_feed_alarm_setting(feed_notify_state: Int)
    //신고하기
    case send_reports(kinds: String, unique_idx: String, report_kinds: String, content: String)
    
    //애플로그인 - 1차...fcm토큰 추가할 것
    case send_apple_login(identity_token : String, authorization_code: String, device: String)
    
    //애플로그인 회원가입
    case join_member_apple_end(identity_token : String, fcm_token : String,  device: String, phone: String, email: String, profile_url: String, gender: Int, nickname: String, marketing_yn: Int, latest_device: String, update_version: String)
    
    //카카오로그인 - 1차...fcm토큰 추가할 것
    case send_kakao_login(kakao_access_token: String, device: String)
    
    //카카오 로그인 - 회원가입 완료
    case join_member_kakao_end(kakao_access_token: String, fcm_token: String, device: String,phone: String, email: String, profile_url: String, gender: Int, nickname: String, marketing_yn: Int, latest_device: String, update_version: String)
    
    //회원가입시 앱에 이미 등록된 친구들 가져오기
    case get_enrolled_friends(contatcts: Array<Any> )
    
    //카드 좋아요 클릭
    case send_like_card(card_idx: Int)
    //카드 좋아요 취소
    case cancel_like_card(card_idx: Int)
    
    //카드 좋아요 유저 확인
    case get_like_card_users(card_idx: Int)
    
    //오늘 심심기간인 친구들 가져오기
    case get_today_boring_friends(bored_date : String)
    
    //오늘을 심심한 날로 설정
    case set_boring_today(action: Int, date: String)
    
    //관심친구 설정
    case set_interest_friend(f_idx: Int, action: String)
    
    //회원가입시 친구들에게 초대 문자 보내기
    case send_invite_message(contacts: Array<Any>)
    
    //친구 신청 취소
    case cancel_request_friend(f_idx: Int)
    
    //친구 해제(기존에 친구였지만 친구에서 삭제)
    case delete_friend(f_idx: Int,action: String)
    
    //관심친구 상태인 유저 목록 - 마이 페이지에서 보여줌
    case get_interest_friends(friend_type: String)

    //내가 좋아요한 카드 가져오기
    case get_liked_cards
    
    //알림 목록 가져오기
    case get_notis(page_idx: Int, page_size: Int)
    //카드 잠그기
    case lock_card(card_idx: Int,lock_state : Int)
    
    //친구 카드 참여자 목록 가져오기
    case get_friend_card_apply_people(card_idx: Int)
    
    //모임카드 이미지 업로드
    case upload_card_img(card_idx: Int, photo_file: Data)
    
    private var method: HTTPMethod{
        switch self{
        case .find_id_pwd_phone_auth:
            return .post
        case .change_password:
            return .put
        case .phone_auth:
            return .post
        case .check_phone_auth:
            return .post
        case .send_profile_image:
            return .post
        case .send_signup_info:
            return .post
        //일반 로그인
        case .send_check_login:
            return .post
        case .splash_check:
            return .post
        //테스트
        case .access_token:
            return .post
            
        //친구 관리 페이지 모든 그룹 리스트 가져오는 통신
        case .get_all_manage_group:
            return .get
        //친구관리 - 그룹추가
        case .add_group:
            return .post
            
        //친구관리 - 친구 목록 가져오기
        case .get_friend_list:
            return .get
            
        //친구관리 - 그룹 상세 페이지 정보 가져오기
        case .get_group_detail:
            return .get
            
        //친구관리 - 그룹 이름 편집
        case .edit_group_name:
            return .put
        //친구관리 - 그룹 멤버 편집
        case .edit_group_member:
            return .put
        case .delete_group:
            return .delete
        case .add_friend_to_group:
            return .post
            
        //친구관리 - 친구신청목록 가져오기
        case .get_request_friend:
            return .get
        //친구 신청 수락
        case .accept_friend_request:
            return .put
        //친구 신청 거절
        case .decline_friend_request:
            return .put
            
        //번호로 친구추가하기(체크)
        case .add_friend_number_check:
            return .post
            
        //이메일로 친구추가하기(체크)
        case .add_friend_email_check:
            return .post
            
        //번호로 친구추가
        case .add_friend_number_last:
            return .post
            
        //이메일로 친구추가
        case .add_friend_email_last:
            return .post
        //친구랑 볼래 카드 리스트 가져오기
        case .get_friend_volleh_card_list:
            return .get
            
        //친구랑 볼래 카드 만들기
        case .friend_volleh_make_card:
            return .post
            
        //친구랑 볼래 카드 정보 가져오기
        case .get_card_info_friend_volleh:
            return .get
            
        //친구랑 볼래 카드 수정
        case .edit_friend_volleh_card:
            return .put
        //친구랑 볼래 카드 삭제
        case .delete_friend_volleh_card:
            return .delete
        //모여볼래 카드 가져오기
        case .get_group_volleh_card_list:
            return .get
        //모여볼래 카드 만들기
        case .make_group_card:
            return .post
        //모여볼래 카드 수정하기
        case .edit_group_card:
            return .put
        //TODO 모여볼래 카드 상세 페이지 정보 가져오기
        case .get_group_card_detail:
            return .get
        //모여볼래 카드 삭제
        case .delete_group_card:
            return .delete
        //모여볼래 카드 참가 신청하기
        case .apply_group_card:
            return .post
        //모여볼래 카드 신청자 목록 가져오기
        case .get_apply_people_list:
            return .get
        //모여볼래 참가 신청 수락
        case .apply_accept:
            return .put
        //모여볼래 참가 신청 거절
        case .apply_decline:
            return .delete
        //모여볼래 내가 신청한 모임목록 가져오기
        case .get_my_apply_list:
            return .get
        //친구랑 볼래 필터 적용
        case .friend_volleh_filter:
            return .get
        //모여볼래 필터 적용
        case .group_volleh_filter:
            return .get
        //친구 내 카드에 초대하기 - 내 모든 카드 가져오기
        case .get_all_my_cards:
            return .get
        //동적링크 통해 카드 참여
        case .accept_dynamic_link:
            return .post
        //fcb
        case .send_fcm_token:
            return .post
        //심심기간 정보 조회
        case .get_boring_period:
            return .get
        //캘린더 - 카드 이벤트들 가져오기
        case .get_card_for_calendar:
            return .get
            
        //캘린더 - 좋아요 정보 가져오기
        case .get_like_for_calendar:
            return .get
            
        //날짜에 대한 좋아요 클릭
        case .send_like_in_calendar:
            return .post
            
        //캘린더 - 좋아요 취소
        case .send_cancel_like_calendar:
            return .delete
            
        //좋아요한 사람들 가져오기
        case .get_like_user_list:
            return .get
        //관심있어요 클릭 이벤트
        case .send_interest_calendar:
            return .post
        //관심있어요 취소 이벤트
        case .cancel_interest_calendar:
            return .delete
        case .get_interest_users:
            return .get
        //캘린더 내 일정 추가하기
        case .add_personal_schedule:
            return .post
        //캘린더 내 일정 리스트 가져오기
        case .get_personal_schedules:
            return .get
        //내 일정 수정하기
        case .edit_personal_schedule:
            return .put
        //내 일정 삭제하기
        case .delete_personal_schedule:
            return .delete
        //캘린더 - 좋아요 ,관심있어요 유저 친구인지 체크 통신
        case .check_is_friend:
            return .post
        
        //캘린더 - 친구 아닌 사람 - 친구 추가 요청
        case .add_friend_request:
            return .post
        //문의하기 생성 통신
        case .send_question_content:
            return .post
        //내 문의내역 가져오기
        case .get_my_questions:
            return .get
        //문의 수정하기
        case .edit_question:
            return .put
        //문의 삭제하기
        case .delete_question:
            return .delete
        //이메일 인증
        case .verify_email:
            return .post
        //이메일 확인 후 돌아왔을 때 통신
        case .check_verify_email:
            return .get
        //비밀번호 변경
        case .setting_change_pwd:
            return .patch
        //회원탈퇴
        case .delete_exit_user:
            return .delete
        //설정 - 마이페이지에서 유저 모든 정보 가져오기
        case .get_detail_user_info:
            return .get
        //설정 - 마이페이지 - 정보 수정
        case .edit_user_info:
            return .patch
        //설정 - 캘린더 공개범위 설정
        case .edit_calendar_disclosure_setting:
            return .patch
        //설정-채팅알림 변경시 통신
        case .edit_chat_alarm_setting:
            return .patch
        //설정 - 피드알림 변경시 통신
        case .edit_feed_alarm_setting:
            return .patch
        //신고하기
        case .send_reports:
            return .post
            
        //애플로그인 - 1차
        case .send_apple_login:
            return .post
        //애플로그인 - 회원가입 완료시
        case .join_member_apple_end:
            return .post
        //카카오로그인 - 1차
        case .send_kakao_login:
            return .post
        //카카오로그인 - 회원가입 완료시
        case .join_member_kakao_end:
            return .post
        //회원가입시 이미 등록된 친구들 가져오기
        case .get_enrolled_friends:
            return .post
        //카드에 좋아요 클릭
        case .send_like_card:
            return .post
        //카드 좋아요 취소
        case .cancel_like_card:
            return .delete
        //카드 좋아요 유저 확인
        case .get_like_card_users:
            return .get
        //오늘 심심기간인 친구들 가져오기(친구 메인에 보여줌.)
        case .get_today_boring_friends:
            return .get
        //오늘 심심한 날로 설정
        case .set_boring_today:
            return .patch
         //관심친구 설정
        case .set_interest_friend:
            return .put
            
        //회원가입시 친구들에게 초대 문자 보내기
        case .send_invite_message:
            return .post
        //친구 신청 취소
        case .cancel_request_friend:
            return .delete
        //친구해제
        case .delete_friend:
            return .put
            
        //관심친구 친구 목록 가져오기
        case .get_interest_friends:
            return .get
        //내가 좋아요한 카드 가져오기
        case .get_liked_cards:
            return .get
        //알림 목록 가져오기
        case .get_notis:
            return .get
        //카드 잠그기
        case .lock_card:
            return .put
        //카드 참여자 목록 가져오기
        case .get_friend_card_apply_people:
            return .get
        //모임카드 이미지 업로드
        case .upload_card_img:
            return .post
            
        }
    }
    private var path: String{
        
        switch self{
        //아이디,비번찾기 때 핸드폰 인증 문자 요청 통신
        case .find_id_pwd_phone_auth:
            return "/auth/phone-number"
        case .change_password:
            return "/users/password"
        //회원가입시 인증문자 요청 통신
        case .phone_auth:
            return "/auth/phone-number"
        case .check_phone_auth:
            return "/auth/phone-number"
        case .send_profile_image:
            return "/users"
        case .send_signup_info:
            return "/users"
        case .splash_check:
            return "/auth/token"
        case .send_check_login:
            return "/users/login"
        //액세스 토큰 만료시 인터셉터
        case .access_token:
            return "/auth/token"
        //친구관리 페이지에 모든 그룹 리스트 가져오기
        case .get_all_manage_group:
            return "/groups"
        //친구관리 - 그룹추가
        case . add_group:
            return "/groups"
        //친구관리 - 친구 추가
        case .get_friend_list:
            return "/users/friends"
        //친구관리 - 그룹 상세 페이지정보 요청 통ㅅ니.url에 group_idx를 추가하기 때문에 이곳에 파라미터 추가함.
        case .get_group_detail(let group_idx):
            return "/groups/\(group_idx)/friends"
        //친구관리 - 그룹이름 편집
        case .edit_group_name(let group_idx, _):
            return "/groups/\(group_idx)"
        //친구관리 - 그룹멤버 편집
        case .edit_group_member(let group_idx, _):
            return "/groups/\(group_idx)/friends"
        //친구관리-그룹 삭제
        case .delete_group(let group_idx):
            return "/groups/\(group_idx)"
        //친구관리 - 친구를 그룹에 추가하기
        case .add_friend_to_group(let group_idx, _):
            return "/groups/\(group_idx)/friends"
            
        //친구관리 - 친구 신청 목록 가져오기
        case .get_request_friend:
            return "/users/friends"
        //친구 신청 수락
        case .accept_friend_request(let friend_idx ,_):
            return "/users/friends/\(friend_idx)"
        //친구 신청 거절
        case .decline_friend_request(let friend_idx,_):
            return "/users/friends/\(friend_idx)"
            
        //이메일로 친구추가하기
        case .add_friend_email_check:
            return "/users/friends/check"
            
        //번호로 친구추가하기
        case .add_friend_number_check:
            return "/users/friends/check"
            
        //번호로 친구추가하기
        case .add_friend_number_last:
            return "/users/friends"
            
        //이메일로 친구추가
        case .add_friend_email_last:
            return "/users/friends"
        //친구랑 볼래 카드 리스트 가져오기
        case .get_friend_volleh_card_list:
            return "/cards/friends"
            
        case .friend_volleh_make_card:
            return "/cards/friends"
            
        //친구랑 볼래 카드 1개 정보 가져오기
        case .get_card_info_friend_volleh(let card_idx):
            return "/cards/\(card_idx)/friends"
            
        //친구랑 볼래 카드 수정
        case .edit_friend_volleh_card(let card_idx, _, _, _, _):
            return "/cards/\(card_idx)/friends"
        //친구랑 볼래 카드 삭제
        case .delete_friend_volleh_card(let card_idx):
            return "/cards/\(card_idx)/friends/"
            
        //모여볼래 카드 전체 리스트 가져오기
        case .get_group_volleh_card_list:
            return "/cards/meeting"
        //모여볼래 카드 만들기
        case .make_group_card:
            return "/cards/meeting"
        //모여볼래 카드 수정하기
        case .edit_group_card(let card_idx, _, _, _, _, _, _, _ , _):
            return "/cards/\(card_idx)/meeting"
            
        //TODO 모여볼래 카드 상세 페이지 데이터 가져오기
        case .get_group_card_detail(let card_idx):
            return "/cards/\(card_idx)/meeting"
        //모여볼래 카드 삭제
        case .delete_group_card(let card_idx):
            return "/cards/\(card_idx)/meeting"
        //모여볼래 카드 참가 신청하기
        case .apply_group_card(let card_idx):
            return "/cards/\(card_idx)/meeting/users"
        //모여볼래 카드 신청자 목록 가져오기
        case .get_apply_people_list(let card_idx):
            return "/cards/\(card_idx)/meeting/users"
        //모여볼래 참가 신청 수락
        case .apply_accept(let card_idx, let meet_user_idx):
            return "/cards/\(card_idx)/meeting/users/\(meet_user_idx)"
        //모여볼래 참가 신청 거절
        case .apply_decline(let card_idx, let meet_user_idx):
            return "/cards/\(card_idx)/meeting/users/\(meet_user_idx)"
        //모여볼래 신청 모임 목록 가져오기
        case .get_my_apply_list:
            return "/cards/meeting"
        //친구랑 볼래 필터 적용
        case .friend_volleh_filter:
            return "cards/friends"
        //모여볼래 필터 적용
        case .group_volleh_filter:
            return "/cards/meeting"
            
        //친구 내 카드에 초대하기(채팅방)
        case .get_all_my_cards:
            return "/cards"
        //동적링크 통해 카드 참여
        case .accept_dynamic_link(let chatroom_idx):
            return "/chatroom/\(chatroom_idx)/user"
        case .send_fcm_token:
            return "/notify/chat-message"
        //심심기간 정보 조회
        case .get_boring_period(let user_idx, _, _):
            return "/users/\(user_idx)/calendar/boring-time"
            
        //캘린더에 보여줄 카드들 가져오기
        case .get_card_for_calendar(let user_idx, _, _):
            return "/users/\(user_idx)/cards"
            
        //캘린더 좋아요 정보 가져오기
        case .get_like_for_calendar(let user_idx, _, _):
            return "/users/\(user_idx)/calendar"
            
        //일자에 대한 좋아요 클릭
        case .send_like_in_calendar(let user_idx, _):
            return "/users/\(user_idx)/calendar/like"
            
        //캘린더 - 일자에 대한 좋아요 취소
        case .send_cancel_like_calendar(let user_idx, let calendar_like_idx):
            return "/users/\(user_idx)/calendar/like/\(calendar_like_idx)"
            
        //캘린더 좋아요한 사람들 가져오기
        case .get_like_user_list(let user_idx, _):
            return "/users/\(user_idx)/calendar/like"
        //관심있어요 클릭
        case .send_interest_calendar(let user_idx, _):
        return "/users/\(user_idx)/calendar/boring-time/interest"
       
        //관심있어여 취소
        case .cancel_interest_calendar(let user_idx, let interest_idx):
            return "/users/\(user_idx)/calendar/boring-time/interest/\(interest_idx)"
        //캘린더 관심있어요 표시한 유저들 가져오기
        case .get_interest_users(let user_idx, _):
            return "/users/\(user_idx)/calendar/boring-time/interest"
        //캘린더 내 일정 추가하기
        case .add_personal_schedule:
            return "/users/calendar/schedule"
        //캘린더 내 모든 일정 리스트 가져오기
        case .get_personal_schedules(let user_idx, _, _):
            return "/users/\(user_idx)/calendar/schedule"
        
        //내 일정 수정하기
        case .edit_personal_schedule(let schedule_idx, _, _, _, _):
            return "/users/calendar/schedule/\(schedule_idx)"
        //내 일정 삭제하기
        case .delete_personal_schedule(let schedule_idx):
            return "/users/calendar/schedule/\(schedule_idx)"
        //캘린더 - 관심있어요, 좋아요 유저 목록에서 친구인지 체크
        case .check_is_friend(_):
            return "/users/friends/check"
        
        //캘린더 - 친구 추가 요청
        case .add_friend_request(_):
            return "/users/friends"
        //문의하기 생성
        case .send_question_content(_):
            return "/users/questions"
        //내 문의내역 가져오기
        case .get_my_questions:
             return "/users/questions"
        //문의 수정하기
        case .edit_question(let question_idx, _):
            return "/users/questions/\(question_idx)"
        //문의 삭제하기
        case .delete_question(let question_idx):
            return "/users/questions/\(question_idx)"
        //이메일 인증하기
        case .verify_email(_):
            return "/auth/email/verification"
        //이메일 인증 확인 후 돌아왔을 때 통신
        case .check_verify_email:
            return "/users/email-auth"
        //설정 - 비밀번호 변경
        case .setting_change_pwd(_, _):
            return "/users"
        //회원탈퇴
        case .delete_exit_user(let user_idx):
            return "/users/\(user_idx)"
        //설정 - 유저 모든 정보 가져오기
        case .get_detail_user_info(let user_idx):
            return "/users/\(user_idx)"
        //설정 - 유저 정보 수정
        case .edit_user_info(_, _, _):
            return "/users"
        //설정 - 캘린더 공개범위
        case .edit_calendar_disclosure_setting(_):
            return "/users/settings"
        //설정 - 채팅알림
        case .edit_chat_alarm_setting(_):
            return "/users/settings"
        //설정 - 피드알림
        case .edit_feed_alarm_setting(_):
            return "/users/settings"
        //신고하기
        case .send_reports(_,_,_, _):
            return "/users/reports"
        //애플로그인 - 1차
        case .send_apple_login(_,_,_):
            return "/auth/apple"
        //애플로그인 - 회원가입 완료시
        case .join_member_apple_end(_,_,_,_,_,_,_,_,_,_,_):
            return "/users/apple"
        //카카오로그인 -1차
        case .send_kakao_login(_,_):
            return "/auth/kakao"
         //카카오 로그인 - 회원가입 완료시
        case .join_member_kakao_end(_,_,_,_,_,_,_,_,_,_,_):
            return "/users/kakao"
        //회원가입시 이미 등록된 친구들 가져오기
        case .get_enrolled_friends(_):
            return "/users/contacts"
        //카드에 좋아요 클릭
        case .send_like_card(let card_idx):
            return "/cards/\(card_idx)/like-user"
        //카드 좋아요 취소
        case .cancel_like_card(let card_idx):
            return "/cards/\(card_idx)/like-user"
        //카드 좋아요 유저 확인
        case .get_like_card_users(let card_idx):
            return "/cards/\(card_idx)/like-user"
        //오늘 심심기간인 친구들 가져오기
        case .get_today_boring_friends(_):
            return "/users/friends/boring"
        //오늘 심심한 날로 설정
        case .set_boring_today(_, _):
            return "/users/calendar/boring-time"
        //관심친구 설정
        case .set_interest_friend(let f_idx, _):
            return "/users/friends/\(f_idx)"
        //회원가입시 친구들에게 초대 문자 보내기
        case .send_invite_message(_):
            return "/auth/contacts"
        //친구 신청 취소
        case .cancel_request_friend(let f_idx):
            return "/users/friends"
        //친구 해제
        case .delete_friend(let f_idx, _):
            return "/users/friends/\(f_idx)"
        //관심친구 친구 리스트 가져오기 - 마이 페이지에서 사용
        case .get_interest_friends(_):
            return "/users/friends"
        //내가 좋아요한 카드 가져오기
        case .get_liked_cards:
            return "/cards/like-checked"
        //알림 목록 가져오기
        case .get_notis:
            return "/users/notifications"
        //카드 잠그기
        case .lock_card(let card_idx, _):
            return "/cards/\(card_idx)/lock"
        //친구 카드 참여자 목록 가져오기
        case .get_friend_card_apply_people(let card_idx):
            return "/cards/\(card_idx)/friends/users"
        //모임카드 이미지 업로드
        case .upload_card_img(let card_idx, _):
            return "/cards/\(card_idx)/meeting"
        }
    }
    
    private var parameters: Parameters? {
        switch self{
        case .find_id_pwd_phone_auth(let phone_num, let type):
            return [Keys.FindIdPwdPhoneAuth.phone_num: phone_num, Keys.FindIdPwdPhoneAuth.type: type]
        case .change_password(let password,let phone_num ,let auth_num):
            return [Keys.ChangePwd.password: password, Keys.ChangePwd.phone_num: phone_num, Keys.ChangePwd.auth_num: auth_num]
        //회원가입시 핸드폰 인증 요청
        case .phone_auth(let phone_num, let type):
            return [Keys.PhoneAuthKey.phone_num: phone_num, Keys.PhoneAuthKey.type: type]
        //회원가입시 핸드폰 인증문자 확인 요청
        case .check_phone_auth(let phone_num, let auth_num, let type):
            return [Keys.CheckPhoneAuthKey.phone_num: phone_num, Keys.CheckPhoneAuthKey.auth_num: auth_num, Keys.CheckPhoneAuthKey.type: type]
            
        case .send_profile_image(let profile_image):
            return  [ Keys.SendProfileImageKey.profile_image: profile_image]
            
        case .send_signup_info(let phone, let email, let password, let gender, let birthday, let nickname, let marketing_yn, let auth_num, let sign_device, let update_version):
            return [Keys.SendSignupInfoKey.phone: phone, Keys.SendSignupInfoKey.email: email, Keys.SendSignupInfoKey.password: password, Keys.SendSignupInfoKey.gender: gender, Keys.SendSignupInfoKey.birthday: birthday, Keys.SendSignupInfoKey.nickname: nickname, Keys.SendSignupInfoKey.marketing_yn: marketing_yn, Keys.SendSignupInfoKey.auth_num: auth_num, Keys.SendSignupInfoKey.sign_device: sign_device, Keys.SendSignupInfoKey.update_version: update_version]
            
        //일반 로그인
        case .send_check_login(let id, let password, let fcm_token, let device):
            return [Keys.SendCheckLogin.id: id, Keys.SendCheckLogin.password: password, Keys.SendCheckLogin.fcm_token: fcm_token, Keys.SendCheckLogin.device: device]
            
        case .splash_check(let refresh_token):
            return [Keys.SplashCheck.refresh_token: refresh_token]
        //인터셉터
        case .access_token(let access_token):
            return [Keys.AccessToken.access_token : access_token]
            
        //친구 관리 페이지 모든 그룹 리스트(get) 파라미터 없음
        case .get_all_manage_group:
            return [:]
            
        //친구관리- 그룹추가
        case .add_group(let group_name, let friends_idx):
            return [Keys.AddGroup.group_name: group_name, Keys.AddGroup.friends_idx: friends_idx]
            
        //친구관리 - 친구 목록 가져오기
        case .get_friend_list(let friend_type):
            return [Keys.GetFriendList.friend_type: friend_type]
            
        case .get_group_detail:
            return nil
            
        //친구관리-그룹 이름 편집 통신 : 파라미터는 그룹 이름만 보냄
        case .edit_group_name(_, let group_name):
            return [Keys.EditGroupName.group_name: group_name]
            
        //친구관리 -그룹멤버 편집 통신
        case .edit_group_member(_ , let friends_idx):
            return [Keys.EditGroupMember.friends_idx: friends_idx]
        //친구관리-그룹삭제
        case .delete_group:
            return nil
            
        //친구관리-친구 리스트에서 그룹에 친구 추가하기
        case .add_friend_to_group(_ , let friend_idx):
            return [Keys.AddFriendToGroup.friend_idx: friend_idx]
            
        //친구관리 - 친구 신청 목록 가져오기
        case .get_request_friend( _):
            return [Keys.GetFriendRequest.friend_type: "친구요청대기"]
            
        //친구 신청 수락
        case .accept_friend_request(_, _):
            return [Keys.AcceptFriendRequest.action: "수락"]
            
        //친구 신청 거절
        case .decline_friend_request(_ , _):
            return [Keys.DeclineFriendRequest.action: "거절"]
            
        //번호로 친구추가하기(체크)
        case .add_friend_number_check(let friend_phone):
            return [Keys.AddFriendNumberCheck.friend_phone: friend_phone]
            
        //이메일로 친구추가하기(체크)
        case .add_friend_email_check(let friend_email):
            return [Keys.AddFriendEmailCheck.friend_email: friend_email]
            
        //번호로 친구 추가
        case .add_friend_number_last(let f_idx):
            return [Keys.AddFriendNumberLast.f_idx: f_idx]
            
        //이메일로 친구추가
        case .add_friend_email_last(let f_idx):
            return [Keys.AddFriendEmailLast.f_idx: f_idx]
            
        //친구랑 볼래 카드 리스트 가져오기
        case .get_friend_volleh_card_list:
            return [:]
            
        //친구랑 볼래 카드 만들기
        case .friend_volleh_make_card(let type, let time, let tags, let share_list):
            return [Keys.MakeCardFriendVolleh.type: type, Keys.MakeCardFriendVolleh.time : time, Keys.MakeCardFriendVolleh.tags: tags, Keys.MakeCardFriendVolleh.share_list: share_list]
            
        //친구랑 볼래 카드 정보 가져오기
        case .get_card_info_friend_volleh:
            return [:]
        //친구랑 볼래 카드 수정하기
        case .edit_friend_volleh_card(_,let type, let time, let tags, let share_list):
            return [Keys.MakeCardFriendVolleh.type: type, Keys.MakeCardFriendVolleh.time : time, Keys.MakeCardFriendVolleh.tags: tags, Keys.MakeCardFriendVolleh.share_list: share_list]
        //친구랑 볼래 카드 삭제
        case .delete_friend_volleh_card(_):
            return [:]
        //모여볼래 카드 가져오기
        case .get_group_volleh_card_list:
            return [:]
        //모여볼래 카드 만들기
        case .make_group_card(let type, let title , let tags , let time, let address, let content, let map_lat, let map_lng):
            return[Keys.MakeGroupCard.type: type, Keys.MakeGroupCard.title: title, Keys.MakeGroupCard.tags: tags, Keys.MakeGroupCard.time: time, Keys.MakeGroupCard.address: address, Keys.MakeGroupCard.content:content, Keys.MakeGroupCard.map_lat: map_lat, Keys.MakeGroupCard.map_lng: map_lng]
            
        //모여볼래 카드 수정하기
        case .edit_group_card(_, let type, let title , let tags , let time, let address, let content, let map_lat, let map_lng):
            return [Keys.EditGroupCard.type: type, Keys.EditGroupCard.title: title, Keys.EditGroupCard.tags: tags, Keys.EditGroupCard.time: time, Keys.EditGroupCard.address: address, Keys.EditGroupCard.content:content, Keys.EditGroupCard.map_lat: map_lat, Keys.EditGroupCard.map_lng: map_lng]
        //모여볼래 카드 상세 데이터 가져오기
        case .get_group_card_detail(_):
            return [:]
        //모여볼래 카드 삭제하기
        case .delete_group_card( _):
            return [:]
        case .apply_group_card( _):
            return [:]
        //모여볼래 카드 신청자 목록 가져오기
        case .get_apply_people_list( _):
            return  [:]
        case .apply_accept( _ ,  _):
            return [:]
        case .apply_decline( _ ,  _):
            return [:]
        //모여볼래 모임 신청목록 가져오기
        case .get_my_apply_list( _):
            return [Keys.GetMyApplyList.type: "신청목록"]
        //친구랑 볼래 필터 적용
        case .friend_volleh_filter(let date_start, let date_end, let tag):
            return [Keys.FriendVollehFilter.date_start: date_start, Keys.FriendVollehFilter.date_end: date_end, Keys.FriendVollehFilter.tag: tag]
        //모여볼래 필터 적용
        case .group_volleh_filter(let date_start, let date_end, let address ,let tag, let kinds):
            return [Keys.GroupVollehFilter.date_start: date_start, Keys.GroupVollehFilter.date_end: date_end, Keys.GroupVollehFilter.address: address, Keys.GroupVollehFilter.tag: tag, Keys.GroupVollehFilter.kinds: kinds]
            
        //친구 내 카드에 초대하기 - 일반 채팅방
        case .get_all_my_cards( _):
            return [Keys.GetAllMyCards.type: "both"]
        //동적링크통해서 카드 참여
        case .accept_dynamic_link( _):
            return [:]
        //fcm
        case .send_fcm_token(let user_idxs, let noti_data ):
            return [Keys.SendFCMTocken.user_idxs: user_idxs, Keys.SendFCMTocken.noti_data: noti_data]
        //심심기간 정보 조회
        case .get_boring_period( _, let date_start, let date_end):
            return [Keys.GetBoringPeriod.date_start: date_start, Keys.GetBoringPeriod.date_end: date_end]
        //캘린더 카드 이벤트들 가져오기
        case .get_card_for_calendar(_, let date_start, let date_end):
            return [Keys.GetCardForCanlendar.date_start: date_start, Keys.GetCardForCanlendar.date_end: date_end]
        //캘린더 좋아요 정보 가져오기
        case .get_like_for_calendar(_, let date_start, let date_end):
            return [Keys.GetLikeForCalendar.date_start: date_start, Keys.GetLikeForCalendar.date_end: date_end]
        //특정 일자에 대한 좋아요 클릭했을 때 서버에 보내는 것
        case .send_like_in_calendar(_, let like_date):
            return [Keys.SendLikeInCalendar.like_date: like_date]
        //캘린더 - 일자에 대한 좋아요 취소
        case .send_cancel_like_calendar(_, _):
            return [:]
        //캘린더 좋아요한 사람들 목록 가져오기
        case .get_like_user_list(_, let calendar_date):
            return [Keys.GetLikeUserList.calendar_date: calendar_date]
        //캘린더 - 관심있어요 클릭
        case .send_interest_calendar(_, let bored_date):
            return [Keys.SendInterestCalendar.bored_date: bored_date]
        //캘린더 - 관심있어요 취소
        case .cancel_interest_calendar(_, _):
            return [:]
        //캘린더 - 관심있어요 표시한 유저들 가져오기
        case .get_interest_users(_, let bored_date):
            return [Keys.GetInterestUsers.bored_date: bored_date]
        //캘린더 - 내 일정 추가하기
        case .add_personal_schedule(let title, let content, let schedule_date, let schedule_start_time):
            return [Keys.AddPersonalSchedule.title: title, Keys.AddPersonalSchedule.content: content, Keys.AddPersonalSchedule.schedule_date: schedule_date, Keys.AddPersonalSchedule.schedule_start_time: schedule_start_time]
        //캘린더 내 일정 리스트 가져오기
        case .get_personal_schedules(_, let date_start, let date_end):
            return [Keys.GetPersonalSchedule.date_start: date_start, Keys.GetPersonalSchedule.date_end: date_end]
            
        //캘린더 내 일정 수정하기
        case .edit_personal_schedule(_, let title, let content,let schedule_date,let schedule_start_time):
            return [Keys.EditPersonalSchedule.title: title, Keys.EditPersonalSchedule.content: content, Keys.EditPersonalSchedule.schedule_date: schedule_date, Keys.EditPersonalSchedule.schedule_start_time: schedule_start_time]
        //캘린더 내 일정 삭제하기
        case .delete_personal_schedule(_):
            return [:]
        //캘린더 - 좋아요,관심있어요 유저 목록에서 친구인지 체크하는 통신
        case .check_is_friend(let friend_idx):
            return [Keys.CheckIsFriend.friend_idx: friend_idx]
        //캘린더 친구 아닌 사람 친구 요청 통신
        case .add_friend_request(let f_idx):
            return [Keys.AddFriendRequest.f_idx: f_idx]
        //문의하기 생성
        case .send_question_content(let content):
            return [Keys.SendQuestionContent.content: content]
        //내 문의내역 가져오기
        case .get_my_questions:
            return nil
        //문의 수정하기
        case .edit_question(_,let content):
            return [Keys.EditQuestion.content: content]
        //문의 삭제하기
        case .delete_question(_):
            return nil
        //이메일 인증
        case .verify_email(let email):
            return [Keys.VerifyEmail.email: email]
        //이메일 확인 후 돌아왔을 때 통신
        case .check_verify_email:
            return nil
        //설정 - 비밀번호 변경
        case .setting_change_pwd(let current_password, let new_password):
        return [Keys.SettingChangePwd.current_password: current_password, Keys.SettingChangePwd.new_password: new_password]
        //회원탈퇴
        case .delete_exit_user(_):
            return [:]
        //설정 - 유저 모든 정보 가져오기
        case .get_detail_user_info(_):
            return [:]
        //설정 - 마이페이지 정보 수정
        case .edit_user_info(let gender, let birthday, let nickname):
            return [Keys.EditUserInfo.gender: gender, Keys.EditUserInfo.birthday: birthday, Keys.EditUserInfo.nickname: nickname]
        //설정 - 캘린더 공개범위
        case .edit_calendar_disclosure_setting(let calendar_public_state):
            return [Keys.EditCalendarDisclosureSetting.calendar_public_state: calendar_public_state]
        //설정 - 채팅알림
        case .edit_chat_alarm_setting(let chat_notify_state):
            return [Keys.EditChatAlarmSetting.chat_notify_state: chat_notify_state]
        //설정 - 피드알림
        case .edit_feed_alarm_setting(let feed_notify_state):
            return [Keys.EditFeedAlarmSetting.feed_notify_state: feed_notify_state]
        //신고하기
        case .send_reports(let kinds, let unique_idx, let report_kinds, let content):
            return [Keys.SendReports.kinds: kinds, Keys.SendReports.unique_idx: unique_idx, Keys.SendReports.report_kinds: report_kinds, Keys.SendReports.content: content]

        //애플로그인 - 1차
        case .send_apple_login(let identity_token, let authorization_code,let device):
            return [Keys.SendAppleLogin.identity_token: identity_token, Keys.SendAppleLogin.authorization_code :authorization_code, Keys.SendAppleLogin.device: device]
         
        //애플로그인 - 회원가입 완료시
        case .join_member_apple_end(let identity_token, let fcm_token, let device, let phone, let email, let profile_url, let gender, let nickname,let marketing_yn,let latest_device,let update_version):
            return [Keys.JoinMemberAppleEnd.identity_token: identity_token, Keys.JoinMemberAppleEnd.fcm_token : fcm_token, Keys.JoinMemberAppleEnd.device: device, Keys.JoinMemberAppleEnd.phone: phone, Keys.JoinMemberAppleEnd.email: email, Keys.JoinMemberAppleEnd.profile_url: profile_url, Keys.JoinMemberAppleEnd.gender: gender, Keys.JoinMemberAppleEnd.nickname: nickname, Keys.JoinMemberAppleEnd.marketing_yn: marketing_yn, Keys.JoinMemberAppleEnd.latest_device: latest_device, Keys.JoinMemberAppleEnd.update_version: update_version]
        
        //카카오로그인 -1차
        case .send_kakao_login(let kakao_access_token, let device):
            return [Keys.SendKakaoLogin.kakao_access_token: kakao_access_token, Keys.SendKakaoLogin.device: device]
        //카카오 로그인 - 회원가입 완료시
        case .join_member_kakao_end(let kakao_access_token, let fcm_token, let device,let phone, let email, let profile_url, let gender, let nickname, let marketing_yn, let latest_device, let update_version):
            return [Keys.JoinMemberKakaoEnd.kakao_access_token: kakao_access_token, Keys.JoinMemberKakaoEnd.fcm_token: fcm_token, Keys.JoinMemberKakaoEnd.device: device, Keys.JoinMemberKakaoEnd.phone: phone, Keys.JoinMemberKakaoEnd.email: email, Keys.JoinMemberKakaoEnd.profile_url: profile_url, Keys.JoinMemberKakaoEnd.gender: gender, Keys.JoinMemberKakaoEnd.nickname: nickname, Keys.JoinMemberKakaoEnd.marketing_yn: marketing_yn, Keys.JoinMemberKakaoEnd.latest_device: latest_device, Keys.JoinMemberKakaoEnd.update_version: update_version]
            //회원가입시 이미 등록된 친구들 가져오기
        case .get_enrolled_friends(let contacts):
            return [Keys.GetEnrolledFriends.contacts:contacts]
        
        //카드에 좋아요 클릭
        case .send_like_card(_):
            return [:]
        //카드 좋아요 취소
        case .cancel_like_card(_):
            return [:]
            
        //카드 좋아요 유저 확인
        case .get_like_card_users(_):
            return [:]
        //오늘 심심기간인 친구들 가져오기
        case .get_today_boring_friends(let bored_date):
            return [Keys.GetBoringFriends.bored_date : bored_date]
        //오늘 심심한 날로 설정
        case .set_boring_today(let action, let date):
            return [Keys.SetBoringToday.action: action, Keys.SetBoringToday.date: date]
        //관심친구 설정
        case .set_interest_friend(_, let action):
            return [Keys.SetInterestFriend.action: action]
        //회원가입시 친구들에게 초대 문자 보내기
        case .send_invite_message(let contacts):
            return [Keys.SendInviteMessage.contacts: contacts]
        //친구 신청 취소
        case .cancel_request_friend(let f_idx):
            return [Keys.CancelRequestFriend.f_idx: f_idx]
        //친구해제
        case .delete_friend(_, let action):
            return [Keys.DeleteFriend.action: action]
        //관심상태인 친구 리스트 가져오기
        case .get_interest_friends(let friend_type):
            return [Keys.GetInterestFriends.friend_type : friend_type]
            
        //내가 좋아요한 카드 가져오기
        case .get_liked_cards:
            return [:]
        //알림 목록 가져오기
        case .get_notis(let page_idx, let page_size):
            return [Keys.GetNotis.page_idx: page_idx, Keys.GetNotis.page_size: page_size]
        //카드 잠그기
        case .lock_card(_,let lock_state):
            return [Keys.LockCard.lock_state: lock_state]
        //친구 카드 참여자 목록 가져오기
        case .get_friend_card_apply_people(_):
            return [:]
        //모임카드 이미지 업로드
        case .upload_card_img(_, let photo_file):
            return [Keys.UploadCardImg.photo_file: photo_file]
        }
        
    }
    
    //이 메소드는 URLRequestConvertible 프로토콜 준수 할 때 작성해야만 하는 메소드
    func asURLRequest() throws -> URLRequest {
        //null일 경우를 대비해 ""추가
        let refresh_token = UserDefaults.standard.string(forKey: "refresh_token") ?? ""
        let access_token =  UserDefaults.standard.string(forKey: "access_token") ?? ""
        print("라우터에서 액세스 토큰 값 있는지 확인 : \(access_token)")
        
        let url = try Keys.ProductionServer.base_url.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        
        // Common Headers
        switch self{
        case .change_password,.find_id_pwd_phone_auth, .check_phone_auth, .phone_auth, .send_signup_info, .send_check_login, .add_group, .get_friend_list, .get_group_detail, .edit_group_name, .edit_group_member, .delete_group, .add_friend_to_group, .get_request_friend, .accept_friend_request, .decline_friend_request, .add_friend_number_check, .add_friend_email_check, .add_friend_number_last, .add_friend_email_last, .friend_volleh_make_card , .edit_friend_volleh_card, .make_group_card, .edit_group_card, .get_my_apply_list, .friend_volleh_filter, .group_volleh_filter , .get_all_my_cards, .send_fcm_token, .get_boring_period, .get_card_for_calendar, .get_like_for_calendar, .send_like_in_calendar, .get_like_user_list, .send_interest_calendar, .get_interest_users, .add_personal_schedule, .get_personal_schedules, .edit_personal_schedule, .check_is_friend, .send_question_content, .edit_question, .verify_email, .setting_change_pwd, .edit_user_info, .edit_calendar_disclosure_setting, .edit_chat_alarm_setting, .edit_feed_alarm_setting, .send_reports, .send_apple_login, .send_kakao_login, .join_member_apple_end, .join_member_kakao_end, .get_today_boring_friends, .set_boring_today, .set_interest_friend, .get_enrolled_friends, .send_invite_message, .cancel_request_friend, .delete_friend, .add_friend_request, .get_interest_friends, .get_liked_cards, .get_notis, .lock_card:
            print("라우터에서 프로필 이미지 아님")
            print("라우터에서 url확인 : \(String(describing: urlRequest.url))")
            // Common Headers
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
            urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        case .send_profile_image, .upload_card_img:
            print("라우터에서 프로필 이미지")
            urlRequest.setValue(ContentType.image.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
            urlRequest.setValue(ContentType.image.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
            urlRequest.setValue("Bearer \(access_token)", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            
        case .splash_check, .access_token:
            print("라우터 스플래시 체크")
            urlRequest.setValue("Bearer \(refresh_token)", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            
        case .get_all_manage_group, .get_friend_volleh_card_list, .get_card_info_friend_volleh, .delete_friend_volleh_card, .get_group_volleh_card_list, .get_group_card_detail, .delete_group_card, .apply_group_card, .get_apply_people_list, .apply_accept, .apply_decline, .accept_dynamic_link, .send_cancel_like_calendar, .cancel_interest_calendar, .delete_personal_schedule, .get_my_questions, .delete_question, .check_verify_email, .delete_exit_user, .get_detail_user_info, .send_like_card, .cancel_like_card, .get_like_card_users, .get_friend_card_apply_people:
            print("라우터 파라미터 없는 요청 url: \(String(describing: urlRequest.url))")
      
        }
        
        // Parameters
        if let parameters = parameters{
            switch self{
            //심심기간 생성,수정,삭제 통신의 경우 파라미터가 json object array이므로 다른 형태로 보내줬어야 함.
            case .change_password,.find_id_pwd_phone_auth, .check_phone_auth, .phone_auth, .send_signup_info, .send_check_login, .splash_check, .access_token, .add_group, .edit_group_name, .edit_group_member, .add_friend_to_group, .accept_friend_request, .decline_friend_request, .add_friend_number_check, .add_friend_email_check, .add_friend_number_last, .add_friend_email_last, .friend_volleh_make_card , .edit_friend_volleh_card, .make_group_card, .edit_group_card, .accept_dynamic_link, .send_fcm_token, .send_like_in_calendar, .send_cancel_like_calendar, .send_interest_calendar, .add_personal_schedule, .edit_personal_schedule, .delete_personal_schedule, .check_is_friend, .add_friend_request, .send_question_content, .edit_question, .delete_question, .verify_email, .setting_change_pwd, .delete_exit_user, .edit_user_info, .edit_calendar_disclosure_setting, .edit_chat_alarm_setting, .edit_feed_alarm_setting, .send_reports, .send_apple_login, .send_kakao_login, .join_member_apple_end, .join_member_kakao_end, .send_like_card, .cancel_like_card, .set_boring_today, .set_interest_friend, .get_enrolled_friends, .send_invite_message, .cancel_request_friend, .delete_friend, .lock_card:
                do {
                    print("라우터에서 파라미터 : \(parameters)")
                    let checker = JSONSerialization.isValidJSONObject(parameters)
                    print("라우터에서 체크 \(checker)")
                    
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                    print("헤더 전체 확인: \(String(describing: urlRequest.allHTTPHeaderFields))")
                }
                catch {
                    print("라우터 이미지 아닐 때 파라미터 오류")
                    throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
                }
                
            case .send_profile_image, .upload_card_img:
                let checker = JSONSerialization.isValidJSONObject(parameters)
                print("라우터에서 체크 \(checker)")
                print("이미지 라우터에서 access토큰 값 확인 : \(access_token)")
                
            //파라미터 없는 get 요청
            case .get_all_manage_group, .get_group_detail, .delete_group, .get_friend_volleh_card_list, .get_card_info_friend_volleh, .delete_friend_volleh_card, .get_group_volleh_card_list, .get_group_card_detail, .delete_group_card, .apply_group_card, .get_apply_people_list, .apply_accept, .apply_decline, .cancel_interest_calendar, .get_my_questions, .check_verify_email, .get_detail_user_info, .get_like_card_users, .get_liked_cards, .get_friend_card_apply_people:
                do {
                    print("라우터에서 파라미터 없는 get 요청")
                    let checker = JSONSerialization.isValidJSONObject(parameters)
                    print("라우터에서 제이슨인지 체크 \(checker)")
                }
                
            //파라미터가 아닌 배열로 전송.
            case .get_friend_list, .get_request_friend, .get_my_apply_list, .friend_volleh_filter, .group_volleh_filter, .get_all_my_cards, .get_boring_period, .get_card_for_calendar, .get_like_for_calendar, .get_like_user_list, .get_interest_users, .get_personal_schedules, .get_today_boring_friends, .get_interest_friends, .get_notis:
                do {
                    print("라우터에서 가져오기 get 요청")
                    let checker = JSONSerialization.isValidJSONObject(parameters)
                    print("라우터에서 체크 \(checker)")
                    
                    urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
                    
                    print("라우터에서 파라미터가 아닌 배열 값 확인 : \(parameters)")
                }
                catch {
                    print("라우터 파라미터가 아닌 배열 값일 때 오류")
                    throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
                }
            }
        }
        return urlRequest
    }
}




