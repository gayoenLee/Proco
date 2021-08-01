//
//  Constants.swift
//  proco
//
//  Created by 이은호 on 2020/12/03.
//

import Foundation
import Alamofire

struct Keys{

    struct ProductionServer{
        
        //static let base_url = "https://api.withproco.com"
        static let base_url = "https://procotest.kro.kr"
    }

    //메인에서 아이디/비번 찾기
    struct FindIdPwdPhoneAuth{
        static let phone_num = "phone_num"
        static let type = "type"
    }

    //메인에서 비밀번호 찾기시
    struct ChangePwd{
        static let password = "password"
        static let phone_num = "phone_num"
        static let auth_num = "auth_num"
    }
    //회원가입시 핸드폰 인증 요청시
    struct PhoneAuthKey{
        static let phone_num = "phone_num"
        static let type = "type"
    }
    //회원가입시 핸드폰 인증문자 확인용
    struct CheckPhoneAuthKey{
        static let phone_num = "phone_num"
        static let auth_num = "auth_num"
        static let type = "type"
    }
    //회원가입 이미지 전송
    struct SendProfileImageKey{
        static let access_token = "access_token"
        static let profile_image = "profile_file"
    }
    //회원가입 모든 정보 보내기
    struct SendSignupInfoKey{
        static let phone = "phone"
        static let email = "email"
        static let password =  "password"
        static let gender = "gender"
        static let birthday =  "birthday"
        static let nickname = "nickname"
        static let marketing_yn =  "marketing_yn"
        static let auth_num =  "auth_num"
        static let sign_device =  "sign_device"
        static let update_version =  "update_version"
        static let fcm_token = "fcm_token"
    }
    
    //일반 로그인시 체크하기 위해 정보 보내기
    struct SendCheckLogin{
        static let id = "id"
        static let password = "password"
        static let fcm_token = "fcm_token"
        static let device = "device"
    }
    
    //스플래시 액티비티에서 토큰 전송
    struct SplashCheck{
        static let refresh_token = "refresh_token"
    }
    
    //인터셉터
    struct AccessToken{
        static let access_token = "access_token"
    }
    //get요청 파라미터 없음
    struct GetAllManageGroup{
    }
    
    //친구관리 - 그룹 추가
    struct AddGroup{
        static let group_name = "group_name"
        static let friends_idx = "friends_idx"
    }
    
    //친구관리 - 그룹추가시 친구 리스트 가져오기
    struct GetFriendList{
        static let friend_type = "friend_type"
    }
    
    //친구관리 - 그룹 상세 페이지 정보 요청 통신 : 파라미터는 없음, group_idx는 url에 추가됨.
    struct GetGroupDetail{
        static let group_idx = "group_idx"
    }
    
    //친구관리 - 그룹 이름 편집시 통신 : group_idx는 url에 추가됨.
    struct EditGroupName{
        static let group_idx = "group_idx"
        static let group_name = "group_name"
    }
    
    //친구관리 - 그룹 멤버 편집
    struct EditGroupMember{
        static let group_idx = "group_idx"
        static let friends_idx = "friends_idx"
    }
    //친구관리 - 그룹삭제
    struct DeleteGroup{
        static let group_idx = "group_idx"
    }
    //친구관리 - 메인 친구 리스트에서 바로 그룹에 친구 추가하기
    struct AddFriendToGroup{
        static let group_idx = "group_idx"
        static let friend_idx = "friend_idx"
    }
    
    //친구관리 - 친구신청 목록 가져오기
    struct GetFriendRequest{
        static let friend_type = "friend_type"
    }
    
    //친구 신청 수락
    struct AcceptFriendRequest{
        static let friend_idx = "friend_idx"
        static let action = "action"
    }
    //친구 신청 거절
    struct DeclineFriendRequest{
        static let friend_idx = "friend_idx"
        static let action = "action"
    }
    
    //연락처로 친구 추가하기(체크)
    struct AddFriendNumberCheck{
        static let friend_phone = "friend_phone"
    }
    
    //이메일로 친구 추가하기(체크)
    struct AddFriendEmailCheck{
        static let friend_email = "friend_email"
    }
    
    //연락처로 친구 추가
    struct AddFriendNumberLast{
        static let f_idx = "f_idx"
    }
    
    //이메일 , 아이디로 친구추가
    struct AddFriendEmailLast{
        static let f_idx = "f_idx"
    }
    
    //친구랑 볼래 카드 리스트 가져오기. 파라미터 없음
    struct GetFriendVollehCardList{
    }
    
    //친구랑 볼래 카드 만들기
    struct MakeCardFriendVolleh{
        static let type = "type"
        static let time = "time"
        static let tags = "tags"
        static let share_list = "share_list"
        static let unique_idx = "unique_idx"
    }
    
    //특정 심심카드 정보 보기(내 카드 수정 위한 통신). get으로 파라미터 없이 보냄.
    struct GetCardInfoFriendVolleh{
        static let card_idx = "card_idx"
    }
    //심심카드 수정 후 완료 버튼 클릭
    struct EditCardFriendVolleh{
        static let card_idx = "card_idx"
        static let type = "type"
        static let time = "time"
        static let tags = "tags"
        static let share_list = "share_list"
        static let unique_idx = "unique_idx"
    }
    //친구랑 볼래 카드 삭제하기
    struct DeleteFriendVolleh{
        static let card_idx = "card_idx"
    }
    //모여볼래 카드 가져오기
    struct GetGroupVollehCardList{
    }
    //모여볼래 카드 만들기
    struct MakeGroupCard{
        static let type = "type"
        static let title = "title"
        static let tags = "tags"
        static let time = "time"
        static let address = "address"
        static let content = "content"
        static let map_lat = "map_lat"
        static let map_lng = "map_lng"
    }
    
    //모여볼래 카드 수정, card_idx는 url에 사용.
    struct EditGroupCard{
        static let card_idx = "card_idx"
        static let type = "type"
        static let title = "title"
        static let tags = "tags"
        static let time = "time"
        static let address = "address"
        static let content = "content"
        static let map_lat = "map_lat"
        static let map_lng = "map_lng"
    }
    
    //TODO!!모여볼래 카드 상세 페이지 정보
    struct GetGroupCardDetail{
    }
    //모여볼래 내 카드 삭제하기, 파라미터 없이 url에 card_idx만 전달.
    struct DeleteGroupCard{
    }
    //모여볼래 카드 참가 신청하기
    struct ApplyGroupCard{
        static let card_idx = "card_idx"
    }
    //모여볼래 참가자, 신청자 목록 가져오기
    struct GetApplyPeopleList{
        static let card_idx = "card_idx"
    }
    //모여볼래 참가 신청 수락
    struct ApplyAccept{
        static let card_idx = "card_idx"
        static let meet_user_idx = "meet_user_idx"
    }
    //모여볼래 참가 신청 거절
    struct ApplyDecline{
        static let card_idx = "card_idx"
        static let meet_user_idx = "meet_user_idx"
    }
    //내가 신청한 모임목록 가져오기
    struct GetMyApplyList {
        static let type = "type"
    }
    //친구랑 볼래 필터 통신
    struct FriendVollehFilter{
        static let date_start = "date_start"
        static let date_end = "date_end"
        static let tag = "tag"
    }
    //모여볼래 필터 통신
    struct GroupVollehFilter{
        static let date_start = "date_start"
        static let date_end = "date_end"
        //지역
        static let address = "address"
        static let tag = "tag"
        //온라인, 오프라인 모임
        static let kinds = "kinds"
    }
    //채팅방에서 친구 카드에 초대하기 - 내 모든 카드 리스트
    struct GetAllMyCards{
        static let type = "type"
    }
    
    //동적링크에서 참가하기 눌렀을 때
    struct DynamicLinkApply{
    static let chatroom_idx = "chatroom_idx"
    }
    
    //fcm 토큰 전송
    struct SendFCMTocken{
        static let user_idxs = "user_idxs"
        static let noti_data =  "noti_data"
        static let idx = "idx"
        static let user_idx = "user_idx"
        static let chatroom_idx = "chatroom_idx"
        static let kinds = "kinds"
        static let content = "content"
        static let front_created_at = "front_created_at"
        static let created_at = "created_at"
    }

    //api 문서 v1 132번째 줄
    //심심기간 정보 조회
    struct GetBoringPeriod{
        static let user_idx = "user_idx"
        //json 전송 아닌 일반 파라미터
        static let date_start = "date_start"
        static let date_end = "date_end"
    }
    
    //api문서 v1, 142번째 줄
    //특정 유저가 만든, 참여한 카드 정보 필터링 구분해서 출력.
    struct GetCardForCanlendar{
        static let user_idx = "user_idx"
        //json 전송 아닌 일반 파라미터
        static let date_start = "date_start"
        static let date_end = "date_end"
    }
    
    //api문서 v1, 137번째 줄
    //일정 좋아요 갯수, 내가 좋아요한 날짜 정보
    struct GetLikeForCalendar{
        static let user_idx = "user_idx"
        //json 전송 아닌 일반 파라미터
        static let date_start = "date_start"
        static let date_end = "date_end"
    }
    //일정에 좋아요 클릭했을 때 통신
    struct SendLikeInCalendar{
        static let user_idx = "user_idx"
        static let like_date = "like_date"
    }
    
    //일정에 좋아요 취소했을 때
    struct SendCancelLikeInCalendar{
        static let user_idx = "user_idx"
        static let calendar_like_index = "calendar_like_index"
    }
    //캘린더 좋아요한 사람들 목록 가져오기
    struct GetLikeUserList{
        static let user_idx = "user_idx"
        static let calendar_date = "calendar_date"
    }
    
    //관심있어요 클릭
    struct SendInterestCalendar{
        static let user_idx = "user_idx"
        static let bored_date = "bored_date"
    }
    
    //관심있어요 취소
    struct CancelInterestCalendar{
        static let user_idx = "user_idx"
        static let interest_idx = "interest_idx"
    }
    
    //관심있어요 유저 리스트 가져오기
    struct GetInterestUsers{
        static let user_idx = "user_idx"
        static let bored_date = "bored_date"
    }
    
    //캘린더 - 내 일정 추가하기
    struct AddPersonalSchedule{
        static let title = "title"
        static let content = "content"
        static let schedule_date = "schedule_date"
        static let schedule_start_time = "schedule_start_time"
    }
    
    //캘린더 - 내 일정 정보 가져오기
    struct GetPersonalSchedule{
        static let user_idx = "user_idx"
        //json 전송 아닌 일반 파라미터
        static let date_start = "date_start"
        static let date_end = "date_end"
    }
    
    //캘린더 - 내 일정 수정하기
    struct EditPersonalSchedule{
        static let schedule_idx = "schedule_idx"
        static let title = "title"
        static let content = "content"
        static let schedule_date = "schedule_date"
        static let schedule_start_time = "schedule_start_time"
        
    }
    
    //캘린더 - 내 일정 삭제
    struct DeletePersonalSchedule{
        static let schedule_idx = "schedule_idx"
    }
    
    //좋아요, 관심있어요 유저 목록에서 피드로 이동할 경우 친구인지, 아닌지 확인하는 통신
    struct CheckIsFriend{
        static let friend_idx = "friend_idx"
    }
    
    //피드 친구가 아닌 사람 - 친구 추가 버튼 통신
    struct AddFriendRequest{
        static let f_idx = "f_idx"
    }
    
    //문의하기 생성 통신
    struct SendQuestionContent{
        static let content = "content"
    }
    
    //내 문의내역 가져오기 - 필요한 파라미터 없음.
    struct GetMyQuestions{
    }
    
    //문의 수정하기
    struct EditQuestion{
        static let question_idx = "question_idx"
        static let content = "content"
    }
    
    //문의 삭제하기
    struct DeleteQuestion{
        static let question_idx = "question_idx"
    }
    
    //설정 - 이메일 인증
    struct VerifyEmail{
        static let email = "email"
    }
    
    //이메일 확인 후 돌아왔을 때 통신
    struct CheckVerifyEmail{
    }
    //설정 - 비밀번호 변경
    struct SettingChangePwd{
        static let current_password = "current_password"
        static let new_password = "new_password"
    }
    //설정 - 회원탈퇴
    struct DeleteExitUser{
        static let user_idx = "user_idx"
    }
    
    //유저 모든 정보 얻는 통신 - 설정 마이 페이지에서 필요.
    struct GetDetailUserInfo{
        static let user_idx = "user_idx"
    }
    
    //설정 - 마이페이지 - 유저 정보 수정
    struct EditUserInfo{
        static let gender = "gender"
        static let birthday = "birthday"
        static let nickname = "nickname"
    }
    //설정 - 캘린더 공개범위 통신 추가
    struct EditCalendarDisclosureSetting{
        static let calendar_public_state = "calendar_public_state"
    }
    
    //설정 - 채팅 알림 통신 추가
    struct EditChatAlarmSetting{
        static let chat_notify_state = "chat_notify_state"
    }
    
    //설정 - 피드 알림
    struct EditCardAlarmSetting{
        static let card_notify_state = "card_notify_state"
    }
    //신고하기
    struct SendReports{
        static let kinds = "kinds"
        static let unique_idx = "unique_idx"
        static let report_kinds = "report_kinds"
        static let content = "content"
    }
    
    //애플로그인 - 1차
    struct SendAppleLogin{
        static let identity_token = "identity_token"
        static let authorization_code = "authorization_code"
        static let device = "device"

    }
        
    //애플로그인 - 회원가입 완료시
    struct JoinMemberAppleEnd{
        static let identity_token = "identity_token"
        static let fcm_token = "fcm_token"
        static let device = "device"
        static let phone = "phone"
        static let email = "email"
        static let profile_url = "profile_url"
        static let gender = "gender"
        static let nickname = "nickname"
        static let marketing_yn = "marketing_yn"
        static let latest_device = "latest_device"
        static let update_version = "update_version"
    }

    //카카오로그인 - 1차
    struct SendKakaoLogin{
        static let kakao_access_token = "kakao_access_token"
        static let device = "device"
    }
    
    //카카오 로그인 회원가입 완료
    struct JoinMemberKakaoEnd{
        static let kakao_access_token = "kakao_access_token"
        static let fcm_token = "fcm_token"
        static let device = "device"
        static let phone = "phone"
        static let email = "email"
        static let profile_url = "profile_url"
        static let gender = "gender"
        static let nickname = "nickname"
        static let marketing_yn = "marketing_yn"
        static let latest_device = "latest_device"
        static let update_version = "update_version"
    }
    
    //회원가입시 내 주소록에 등록된 사람중 앱에 가입된 사람들 목록 가져오기
    struct GetEnrolledFriends{
        static let contacts = "contacts"
    }
    
    //카드 좋아요 클릭
    struct SendLikeCard{
        static let card_idx = "card_idx"
    }
    
    //카드 좋아요 취소
    struct CancelLikeCard{
        static let card_idx = "card_idx"
    }
    
    //카드 좋아요 유저 확인
    struct GetLikeCardUsers{
        static let card_idx = "card_idx"
    }
    
    //오늘 심심기간인 친구들 리스트 가져오기
    struct GetBoringFriends{
        static let bored_date = "bored_date"
    }
    
    //오늘을 메인에서 심심한 날로 설정
    struct SetBoringToday{
        static let action = "action"
        static let date = "date"
    }
    
    //관심친구 설정
    struct SetInterestFriend{
        static let f_idx = "f_idx"
        static let action = "action"
    }
    
    //회원가입시 새로운 친구에게 초대 문자 보내기
    struct SendInviteMessage{
        static let contacts = "contacts"
    }
    
    //친구 신청 취소
    struct CancelRequestFriend{
        static let f_idx = "f_idx"
    }
    
    //친구 해제
    struct DeleteFriend{
        static let f_idx = "f_idx"
        static let action = "action"
    }
    
    //관심친구 상태인 유저 목록
    struct GetInterestFriends{
        static let friend_type = "friend_type"
    }
    
    //내가 좋아요한 카드 가져오기
    struct GetLikedCards{
    }
    
    //알림탭 클릭시
    struct GetNotis{
        static let page_idx = "page_idx"
        static let page_size = "page_size"
    }
    
    //카드 잠그기
    struct LockCard{
        static let lock_state = "lock_state"
        static let card_idx = "card_idx"
    }
    
    //친구 카드 참여자 목록 가져오기
    struct GetFriendCardApplyPeople{
        static let card_idx = "card_idx"
    }
    
    //모임카드 이미지 업로드
    struct UploadCardImg{
        static let card_idx = "card_idx"
        static let photo_file = "photo_file"
    }
 // 이미지랑 카드 업로드
    struct MakeCardWithImg{
        static let param = "param"
        static let photo_file = "photo_file"

    }
    
    //모임 - 이미지랑 카드 수정
    struct EditCardWithImg{
        static let card_idx = "card_idx"
        static let param = "param"
        static let photo_file = "photo_file"
    }
    
    //친구관리 - 내가 친구 신청한 친구 목록
    struct  GetMyRequestFriendList {
        static let friend_type = "friend_type"
    }
    
    //로그아웃
    struct LogOut{
    }
}

enum HTTPHeaderField: String{
    case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case cookie = "Cookie"
    
}

enum ContentType: String {
    case json = "application/json"
    case image = "multipart/form-data"
}
