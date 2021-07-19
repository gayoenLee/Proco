//
//  APIClient.swift
//  proco
//
//  Created by 이은호 on 2020/12/04.
//

import Foundation
import Alamofire
import SwiftyJSON
import Combine

class APIClient {
    //아이디,비번찾기 시 핸드폰 인증문자 요청 통신
    static func find_id_pwd_phone_auth(phone_num: String, type:String, completion:@escaping(JSON) -> ()){
        AF.request(APIRouter.phone_auth(phone_num: phone_num, type: type))
            .responseData{response in
                guard let data = response.data else { return }
                let json = try? JSON(data: data)
                if let acc = json?["result"].string{
                    print("api client에서 비번찾기 핸드폰 인증 결과임\(acc) ")
                    //통신은 성공했지만 인증번호 불일치할 경우 alert 띄우기
                }
                completion(json!)
                print("api client에서 비번찾기 핸드폰 인증 결과\(response.result)")
            }
    }
    
    //메인에서 비번찾기
    static func change_password_api(password: String, phone_num: String, auth_num: String, completion: @escaping(JSON) -> ()){
        AF.request(APIRouter.change_password(password: password, phone_num: phone_num, auth_num: auth_num))
            .responseData{response in
                guard let data = response.data else { return }
                let json = try? JSON(data: data)
                if let acc = json?["result"].string{
                    print("api client에서 비번변경  결과임\(acc) ")
                    //통신은 성공했지만 인증번호 불일치할 경우 alert 띄우기
                }
                completion(json!)
                print("api client에서 비번변경 결과\(response.result)")
            }
    }
    
    //최초로 핸드폰 문자 인증시 인증문자 요청 통신
    static func phone_auth_api(phone_num: String, type:String, completion:@escaping(JSON) -> ()){
        AF.request(APIRouter.phone_auth(phone_num: phone_num, type: type))
            .responseData{response in
                guard let data = response.data else { return }
                let json = try? JSON(data: data)
                if let acc = json?["result"].string{
                    print("api client에서 첫번째 핸드폰 인증 결과임\(acc) ")
                    //통신은 성공했지만 인증번호 불일치할 경우 alert 띄우기
                }
                completion(json!)
                print("api client에서 첫번째 핸드폰 인증 결과\(response.result)")
            }
    }
    //유저가 핸드폰 인증문자 입력 후 다음 버튼 클릭시 인증문자가 맞는지 확인하는 통신
    static func check_phone_auth_api(phone_num:String, auth_num:String, type: String, completion: @escaping(JSON) -> ())
    
    {
        AF.request(APIRouter.check_phone_auth(phone_num: phone_num, auth_num: auth_num, type: type))
            .responseData{response in
                guard let data = response.data else { return }
                let json = try? JSON(data: data)
                if let acc = json?["result"].string{
                    print("api client에서 두번째 핸드폰 인증 결과임\(acc) ")
                    //통신은 성공했지만 인증번호 불일치할 경우 alert 띄우기
                }
                completion(json!)
                print("api client에서 두번째 핸드폰 인증 결과\(response.result)")
            }
    }
    //이미지 저장시 이미지 파일 이름을 현재 날짜로 만들기 위함
    static func get_date() -> String{
        let time = Date()
        let time_formatter = DateFormatter()
        time_formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss z"
        let string_date = time_formatter.string(from: time)
        return string_date
    }
    
    //회원가입시 이미지만 따로 보내는 전송코드
    static func upload(image: Data, to url: APIRouter, completion: @escaping (JSON) -> ()) {
        
        AF.upload(multipartFormData: { multiPart in
            
            multiPart.append(image, withName: "profile_file", fileName: "\(get_date()).png", mimeType: "image/png")
        }, with: url)
        .validate(statusCode: 200..<300)
        .responseJSON(completionHandler: { response in
            print("api client에서 이미지 리스폰스 확인 : \(response)")
            guard let data = response.data else { return }
            let json = try? JSON(data: data)
            print("리스폰스 확인 : \(String(describing: json))")
            completion(json!)
        })
    }
    
    //마지막으로 이미지를 제외한 모든 회원가입 정보 보내기
    static func send_user_info_api(phone: String, email: String, password: String, gender: Int, birthday: String, nickname: String, marketing_yn: Int, auth_num: String, sign_device: String?, update_version: String?, completion: @escaping(Result<ResponseSignup, AFError>) -> ()){
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.dateformatter)
        
        AF.request(APIRouter.send_signup_info(phone: phone, email: email, password: password, gender: gender, birthday: birthday, nickname: nickname, marketing_yn: marketing_yn, auth_num: auth_num, sign_device: sign_device ?? "디바이스", update_version: update_version ?? "업데이트 버전"))
            .validate(statusCode: 200..<300)
            .responseDecodable(decoder: jsonDecoder){(response: DataResponse<ResponseSignup, AFError>) in
                
                completion(response.result)
            }
    }
    //일반 로그인 통신
    static func check_login_api(id: String, password: String, fcm_token : String,device: String, completion: @escaping(Result<ResponseCheckLogin, AFError>)-> ()){
        
        AF.request(APIRouter.send_check_login(id: id, password: password, fcm_token: fcm_token, device: device))
            
            .responseDecodable{(response: DataResponse<ResponseCheckLogin, AFError>) in
                print("api client에서 일반 로그인 결과 확인 : \(response.result)")
                completion(response.result)
            }
    }
    
    //스플래쉬에서 토큰 확인 통신
    static func splash_token_api(refresh_token: String, completion: @escaping(JSON) -> ()){
        
        AF.request(APIRouter.splash_check(refresh_token: refresh_token))
            .responseData{response in
                guard let data = response.data else {return }
                let json = try? JSON(data: data)
                completion(json!)
                print("apiclient에서 스플래시 체크 응답 확인 : \(String(describing: json))")
            }
    }
    //친구 관리 페이지의 모든 그룹 리스트 가져오기
    static func get_all_manage_group() -> AnyPublisher<[ManageGroupStruct], AFError>{
        //.validate사용하지 말 것.
        let manage_group_publisher = AF.request(APIRouter.get_all_manage_group, interceptor: RequestInterceptorClass())
            .publishDecodable(type: [ManageGroupStruct].self)
        print("api client에서 결과 확인 : \(manage_group_publisher.value())")
        return manage_group_publisher.value()
        
    }
    
    //친구관리 - 그룹추가
    static func add_group_api(group_name: String, friends_idx: Array<Any>, completion: @escaping(Result<ResponseAddGroup ,AFError>)-> ()){
        
        AF.request(APIRouter.add_group(group_name: group_name, friends_idx: friends_idx), interceptor: RequestInterceptorClass())
            
            .responseDecodable{(response:DataResponse<ResponseAddGroup, AFError>) in
                print("ali client에서 그룹 추가 결과 확인 : \(response)")
                completion(response.result)
            }
    }
    
    //친구관리 - 친구 목록 가져오기
    static func get_friend_list_api(friend_type: String) -> AnyPublisher<[GetFriendListStruct], AFError>{
        
        let publisher = AF.request(APIRouter.get_friend_list(friend_type: "친구") , interceptor: RequestInterceptorClass())
            .publishDecodable(type:[GetFriendListStruct].self)
        
        print("친구 목록 가져오기의 value확인 : \(publisher.value())")
        print("친구 목록 가져오기의 result : \(publisher.result())")
        return publisher.value()
    }
    
    //친구관리 - 그룹 상세 페이지 정보 요청 통신
    static func get_group_detail_api(group_idx: Int) -> AnyPublisher<[GroupDetailStruct],AFError>{
        
        let publisher = AF.request(APIRouter.get_group_detail(group_idx: group_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: [GroupDetailStruct].self)
        print("그룹 상세 페이지 데이터 가져오기 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //친구관리 - 그룹이름 편집
    static func edit_group_name_api(group_idx: Int, group_name: String) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.edit_group_name(group_idx: group_idx, group_name: group_name), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        return publisher.value()
    }
    
    //친구관리 -그룹멤버 편집
    static func edit_group_member_api(group_idx: Int, friends_idx: Array<Any>) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.edit_group_member(group_idx: group_idx, friends_idx: friends_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        return publisher.value()
    }
    
    //친구관리-그룹삭제
    static func delete_group_api(group_idx: Int)-> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.delete_group(group_idx: group_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        return publisher.value()
    }
    
    //친구관리-친구를 그룹에 추가하기
    static func add_friend_to_group(group_idx: Int, friend_idx: Int) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.add_friend_to_group(group_idx: group_idx, friend_idx: friend_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        return publisher.value()
    }
    
    //친구관리 - 친구 요청 목록 가져오기
    static func get_friend_request_api(friend_type: String) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.get_request_friend(friend_type: "친구요청대기") , interceptor: RequestInterceptorClass())
            .publishDecodable(type:JSON.self)
        
        return publisher.value()
    }
    
    //친구관리 - 내가 친구 신청한 목록
    static func get_my_request_friend_list(friend_type: String) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.get_my_request_friend_list(friend_type: "친구요청중") , interceptor: RequestInterceptorClass())
            .publishDecodable(type:JSON.self)
        
        return publisher.value()
    }
    
    //친구 요청 수락
    static func accpet_friend_request_api(friend_idx: Int, action: String) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.accept_friend_request(friend_idx: friend_idx, action: "수락"), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        return publisher.value()
    }
    
    //친구 요청 거절
    static func decline_friend_request_api(friend_idx: Int, action: String) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.decline_friend_request(friend_idx: friend_idx, action: "거절"), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        return publisher.value()
    }
    
    //번호로 친구추가하기(체크)
    static func add_friend_number_check_api(friend_phone: String) -> AnyPublisher<AddFriendCheckStruct, AFError>{
        
        let publisher = AF.request(APIRouter.add_friend_number_check(friend_phone: friend_phone), interceptor: RequestInterceptorClass())
            .publishDecodable(type: AddFriendCheckStruct.self)
        
        return publisher.value()
    }
    //이메일로 친구추가하기 전 체크
    static func add_friend_email_check_api(friend_email: String) -> AnyPublisher<AddFriendCheckStruct, AFError>{
        
        let publisher = AF.request(APIRouter.add_friend_email_check(friend_email: friend_email), interceptor: RequestInterceptorClass())
            .publishDecodable(type: AddFriendCheckStruct.self)
        
        return publisher.value()
        
    }
    //번호로 친구추가하기 최종
    static func add_friend_number_last_api(f_idx: Int) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.add_friend_number_last(f_idx: f_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        return publisher.value()
    }
    
    //이메일로 친구추가하기 최종
    static func add_friend_email_last_api(f_idx: Int) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.add_friend_email_last(f_idx: f_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        return publisher.value()
    }
    
    //친구랑 볼래 카드 리스트 가져오기
    static func get_friend_volleh_card_list_api() ->
    
    AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.get_friend_volleh_card_list, interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        print("api client에서 response확인: \(publisher.result())")

        return publisher.value()
    }
    
    //친구랑 볼래 카드 만들기
    static func make_card_friend_volleh(type: String, time: String, tags: Array<Any>,share_list: [Dictionary<String , Any>] ) -> AnyPublisher<ResponseMakeCardStruct, AFError>{
        let publisher = AF.request(APIRouter.friend_volleh_make_card(type: "친구" , time: time, tags: tags, share_list: share_list), interceptor: RequestInterceptorClass())
            .publishDecodable(type: ResponseMakeCardStruct.self)
        print("친구랑 볼래 카드 만들기api client에서 데이터 확인 : \(publisher.value())")

        return publisher.value()
    }
    
    //친구랑 볼래 카드 정보 가져오기
    static func get_card_info_friend_volleh(card_idx: Int) -> AnyPublisher<FriendVollehCardDetailModel,AFError>{
        
        let publisher = AF.request(APIRouter.get_card_info_friend_volleh(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: FriendVollehCardDetailModel.self)
        print("친구랑 볼래 카드 상세 페이지 데이터 가져오기 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //볼래 카드 수정하기
    static func edit_friend_volleh_card(card_idx: Int, type: String, time: String, tags: Array<Any>,share_list: [Dictionary<String , Any>]) -> AnyPublisher<ResponseEditCard, AFError>{
        print("api client에서 데이터 확인 1 : \(share_list)")
        let publisher = AF.request(APIRouter.edit_friend_volleh_card(card_idx: card_idx, type: "친구" , time: time, tags: tags, share_list: share_list), interceptor: RequestInterceptorClass())
            .publishDecodable(type: ResponseEditCard.self)
        print("api client에서 데이터 확인 2 : \(share_list)")
        
        return publisher.value()
    }
    //친구랑 볼래 카드 삭제
    static func delete_friend_volleh_card(card_idx: Int)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.delete_friend_volleh_card(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        print("친구랑 볼래 카드 삭제 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //모여볼래 카드 리스트 가져오기
    static func get_group_volleh_card_list()->
    
    AnyPublisher<[GroupCardStruct], AFError>{
        let publisher = AF.request(APIRouter.get_group_volleh_card_list, interceptor: RequestInterceptorClass())
            .publishDecodable(type: [GroupCardStruct].self)
        return publisher.value()
    }
    
    //모여볼래 카드 만들기
    static func make_group_card(type: String, title: String,tags: Array<Any>, time: String, address: String, content: String, map_lat: String, map_lng: String)->
    AnyPublisher<ResponseMakeCardStruct, AFError>{
        let publisher = AF.request(APIRouter.make_group_card(type: type, title: title, tags: tags, time: time, address: address, content: content, map_lat: map_lat, map_lng: map_lng), interceptor: RequestInterceptorClass())
            .publishDecodable(type: ResponseMakeCardStruct.self)
        
        return publisher.value()
        
    }
    
    //모여볼래 카드 수정하기
    static func edit_group_card(card_idx: Int, type: String, title: String,tags: Array<Any>, time: String, address: String, content: String, map_lat: String, map_lng: String)->
    
    AnyPublisher<GroupCardStruct, AFError>{
        let publisher = AF.request(APIRouter.edit_group_card(card_idx: card_idx, type: type, title: title, tags: tags, time: time, address: address, content: content, map_lat: map_lat, map_lng: map_lng), interceptor: RequestInterceptorClass())
            .publishDecodable(type: GroupCardStruct.self)
        
        return publisher.value()
        
    }
    
    //모여볼래 카드 상세 데이터 가져오기
    static func get_group_card_detail(card_idx: Int) ->  AnyPublisher<GroupCardStruct, AFError>{
        let publisher = AF.request(APIRouter.get_group_card_detail(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: GroupCardStruct.self)
        
        return publisher.value()
        
    }
    
    //모여볼래 카드 삭제하기
    static func delete_group_card(card_idx: Int)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.delete_group_card(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        print("모여 볼래 카드 삭제 확인 : \(publisher.value())")
        return publisher.value()
    }
    //모여볼래 카드 참가 신청하기
    static func apply_group_card(card_idx: Int)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.apply_group_card(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("모여 볼래 카드 참가 신청 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //TODO 모여볼래 신청자 목록 가져오기
    static func get_apply_people(card_idx: Int) -> AnyPublisher<JSON,AFError>{
        
      let publisher =  AF.request(APIRouter.get_apply_people_list(card_idx: card_idx), interceptor: RequestInterceptorClass())
        .publishDecodable(type: JSON.self)
                print("모여볼래 카드 참가 신청 response확인 : \(publisher.value())")
        return publisher.value()

            }
    
    //모여볼래 참가 신청 수락하기
    static func apply_accept(card_idx: Int, meet_user_idx: Int)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.apply_accept(card_idx: card_idx, meet_user_idx: meet_user_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        print("api client에서 모여 볼래 카드 참가 신청 수락확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //모여볼래 참가 신청 거절하기
    static func apply_decline(card_idx: Int, meet_user_idx: Int)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.apply_decline(card_idx: card_idx, meet_user_idx: meet_user_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        print("api client에서 모여 볼래 카드 참가 신청 거절 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //모여볼래 신청 목록 가져오기
    static func get_my_apply_list(type: String)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.get_my_apply_list(type: "신청목록"), interceptor: RequestInterceptorClass())
            
            .publishDecodable(type: JSON.self)
        print("api client에서 모여 볼래 내 신청 모임 목록 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //친구랑 볼래 필터 적용하기
    static func friend_volleh_filter(date_start: String, date_end: String, tag: Array<Any>)-> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.friend_volleh_filter(date_start: date_start, date_end: date_end, tag: tag), interceptor: RequestInterceptorClass())
            
            .publishDecodable(type: JSON.self)
        print("api client에1서 친구랑 볼래 필터 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //모여 볼래 필터 적용하기
    static func group_volleh_filter(date_start: String, date_end: String, address: String,tag: Array<Any>, kinds: String)-> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.group_volleh_filter(date_start: date_start, date_end: date_end,address: address, tag: tag, kinds: kinds), interceptor: RequestInterceptorClass())
            
            .publishDecodable(type: JSON.self)
        print("api client에서 모여 볼래 필터 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //친구 내 카드에 초대하기 - 일반 채팅방
    static func get_all_my_cards(type: String) ->
    AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.get_all_my_cards(type: "both"), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        print("api client에서 내 모든 카드 리스트 가져온 것 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //동적링크 통해 카드 참여
    static func accept_dynamic_link(chatroom_idx: Int) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.accept_dynamic_link(chatroom_idx: chatroom_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        print("api client에서 동적 링크 통해 카드 참여 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    static func send_fcm_token(user_idxs: Array<Any>, noti_data: Dictionary<String , Any>) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.send_fcm_token(user_idxs: user_idxs, noti_data: noti_data), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 fcm 확인 : \(publisher.value())")
        
        return publisher.value()
    }
    //심심기간 정보 조회
    static func get_boring_period(user_idx: Int, date_start: String, date_end: String)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.get_boring_period(user_idx: user_idx, date_start: date_start, date_end: date_end), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 심심기간 정보 조회 값 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더에 보여줄 카드 리스트 가져오기
    static func get_card_for_calendar(user_idx: Int, date_start: String, date_end: String)-> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.get_card_for_calendar(user_idx: user_idx, date_start: date_start, date_end: date_end), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 캘린더 카드 이벤트들 가져온 값 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 좋아요 정보 가져오기
    static func get_like_for_calendar(user_idx: Int, date_start: String, date_end: String)-> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.get_like_for_calendar(user_idx: user_idx, date_start: date_start, date_end: date_end), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 캘린더 좋아요 정보 가져온 값 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 심심기간 생성, 수정, 삭제
    static func send_boring_period_events(date_array: [EditBoringDatesModel]) -> AnyPublisher<JSON,AFError>{
        
        print("api client에서 받은 파라미터: \(date_array)")
        let publisher =   AF.request("https://procotest.kro.kr/users/calendar/boring-time", method: .post, parameters: date_array, encoder: JSONParameterEncoder.default, interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 캘린더 심심기간 설정 이벤트 후 가져온 값 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //일자에 대한 좋아요 클릭했을 때
    static func send_like_in_calendar(user_idx: Int, like_date: String) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.send_like_in_calendar(user_idx: user_idx, like_date: like_date), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 캘린더 좋아요 클릭했을 때 확인 : \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 - 일자에 대한 좋아요 취소
    static func send_cancel_like_calendar(user_idx: Int, calendar_like_idx: Int) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.send_cancel_like_calendar(user_idx: user_idx, calendar_like_idx: calendar_like_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 좋아요 취소 했을 때 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 좋아요한 사람들 가져오기
    static func get_like_user_list(user_idx: Int, calendar_date: String) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.get_like_user_list(user_idx: user_idx, calendar_date: calendar_date), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 좋아요 취소 했을 때 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 관심있어요 이벤트
    static func send_interest_calendar(user_idx: Int, bored_date: String) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.send_interest_calendar(user_idx: user_idx, bored_date: bored_date), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 관심있어요 클릭 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 관심있어요 취소
    static func cancel_interest_calendar(user_idx: Int, interest_idx: Int) -> AnyPublisher<JSON, AFError>{
        
        let publisher = AF.request(APIRouter.cancel_interest_calendar(user_idx: user_idx, interest_idx: interest_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 관심있어요 취소 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //관심있어요 유저 리스트 가져오기
    static func get_interest_users(user_idx: Int, bored_date: String) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.get_interest_users(user_idx: user_idx, bored_date: bored_date), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 관심있어요 유저 목록 가져오기 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 - 내 일정 추가하기
    static func add_personal_schedule(title: String, content: String, schedule_date: String, schedule_start_time: String) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.add_personal_schedule(title: title, content: content, schedule_date: schedule_date, schedule_start_time: schedule_start_time), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 내 일정 추가하기 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 - 내 일정 리스트 가져오기
    static func get_personal_schedules(user_idx: Int, date_start: String, date_end: String) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.get_personal_schedules(user_idx: user_idx, date_start: date_start, date_end: date_end), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 내 일정 리스트 가져오기 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 - 내 일정 편집하기
    static func edit_personal_schedule(schedule_idx: Int, title: String, content: String, schedule_date: String, schedule_start_time: String) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.edit_personal_schedule(schedule_idx: schedule_idx, title: title, content: content, schedule_date: schedule_date, schedule_start_time: schedule_start_time), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 내 일정 편집하기 확인: \(publisher.value())")
        return publisher.value()
        
    }
    
    //캘린더 - 내 일정 삭제하기
    static func delete_personal_schedule(schedule_idx: Int) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.delete_personal_schedule(schedule_idx: schedule_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 내 일정 삭제하기 확인: \(publisher.value())")
        return publisher.value()
        
    }
    
    //캘린더 - 좋아요,관심있어요 유저 목록에서 친구인지 체크하는 통신
    static func check_is_friend(friend_idx: Int) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.check_is_friend(friend_idx: friend_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 캘린더 - 친구인지 체크하는 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //캘린더 - 피드에서 친구 요청 통신
    static func add_friend_request(f_idx: Int) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.add_friend_request(f_idx: f_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 친구 요청 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //문의하기 생성
    static func send_question_content(content: String) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.send_question_content(content: content), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 문의하기 생성 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //내 문의내역 가져오기
    static func get_my_questions() -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.get_my_questions, interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 내 문의내역 가져오기 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //내 문의내역 수정하기
    static func edit_question(question_idx: Int, content: String) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.edit_question(question_idx: question_idx, content: content), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 문의 수정하기 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //문의 삭제하기
    static func delete_question(question_idx: Int) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.delete_question(question_idx: question_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 문의 삭제하기 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //이메일 인증
    static func verify_email(email: String) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.verify_email(email: email), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 이메일 인증 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //이메일 인증 클릭 후 돌아왔을 때
    static func check_verify_email() -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.check_verify_email, interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 이메일 인증 클릭 후 돌아왔을 때 체크 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //설정 - 비밀번호 변경
    static func setting_change_pwd(current_password: String, new_password: String) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.setting_change_pwd(current_password: current_password, new_password: new_password), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 설정 - 비번 변경 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    //설정 - 회원탈퇴
    static func delete_exit_user(user_idx: Int) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.delete_exit_user(user_idx: user_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 설정 - 회원탈퇴 통신 확인: \(publisher.value())")
        return publisher.value()
    }
    //설정 - 마이페이지에서 유저 모든 정보 가져오기
    static func get_detail_user_info(user_idx: Int) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.get_detail_user_info(user_idx: user_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 설정 - 유저 모든 정보 가져오기 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //설정 - 마이페이지 정보 수정
    static func edit_user_info(gender: Int, birthday: String, nickname: String) -> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.edit_user_info(gender: gender, birthday: birthday, nickname: nickname), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 설정 - 마이페이지 정보 수정 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //설정 - 캘린더 공개범위
    static func edit_calendar_disclosure_setting(calendar_public_state: Int)-> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.edit_calendar_disclosure_setting(calendar_public_state: calendar_public_state), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 설정 - 캘린더 공개범위 수정 확인: \(publisher.value())")
        return publisher.value()
    }
    //설정 - 채팅알림
    static func edit_chat_alarm_setting(chat_notify_state: Int)-> AnyPublisher<JSON,AFError>{
        let publisher = AF.request(APIRouter.edit_chat_alarm_setting(chat_notify_state: chat_notify_state), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 설정 -채팅알림 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //설정 - 피드알림
    static func edit_card_alarm_setting(card_notify_state: Int)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.edit_card_alarm_setting(card_notify_state: card_notify_state), interceptor:  RequestInterceptorClass())
            
            .publishDecodable(type: JSON.self)
        
        print("api client에서 설정 -피드알림 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //신고하기
    static func send_reports(kinds: String, unique_idx: String, report_kinds: String, content: String) -> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.send_reports(kinds: kinds, unique_idx: unique_idx, report_kinds: report_kinds, content: content), interceptor: RequestInterceptorClass())
            
            .publishDecodable(type: JSON.self)
        
        print("api client에서 신고하기 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //애플로그인 - 1차
    static func send_apple_login(identity_token : String, authorization_code: String, device: String)-> AnyPublisher<JSON,AFError>{
        //애플로그인시 처음에는 access token이 없으므로 interceptor없앰.
        let publisher = AF.request(APIRouter.send_apple_login(identity_token: identity_token,authorization_code: authorization_code, device: device))
            
            .publishDecodable(type: JSON.self)
        
        print("api client에서 애플로그인 - 1차 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //애플로그인 - 회원가입 완료시
    static func join_member_apple_end(identity_token : String, fcm_token : String, device: String, phone: String, email: String, profile_url: String, gender: Int, nickname: String, marketing_yn: Int, latest_device: String, update_version: String)-> AnyPublisher<JSON,AFError>{
        //애플로그인시 처음에는 access token이 없으므로 interceptor없앰.
        let publisher = AF.request(APIRouter.join_member_apple_end(identity_token: identity_token, fcm_token: fcm_token, device: device, phone: phone, email: email, profile_url: profile_url, gender: gender, nickname: nickname, marketing_yn: marketing_yn, latest_device: latest_device, update_version: update_version))
            
            .publishDecodable(type: JSON.self)
        
        print("api client에서 애플로그인 - 회원가입 완료 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //카카오로그인 - 1차
    static func send_kakao_login(kakao_access_token: String, device: String) -> AnyPublisher<JSON,AFError>{

        let publisher = AF.request(APIRouter.send_kakao_login(kakao_access_token: kakao_access_token, device: device))
            .publishDecodable(type: JSON.self)
        
        print("api client에서 카카오로그인 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //카카오 로그인 회원가입 완료시
    static func join_member_kakao_end(kakao_access_token: String, fcm_token: String, device: String,phone: String, email: String, profile_url: String, gender: Int, nickname: String, marketing_yn: Int, latest_device: String, update_version: String)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.join_member_kakao_end(kakao_access_token: kakao_access_token, fcm_token: fcm_token, device: device, phone: phone, email: email, profile_url: profile_url, gender: gender, nickname: nickname, marketing_yn: marketing_yn, latest_device: latest_device, update_version: update_version))
            .publishDecodable(type: JSON.self)
        
        print("api client에서 카카오로그인 회원가입 완료 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //회원가입시 이미 가입한 친구들 가져오기
    static func get_enrolled_friends(contacts: Array<Any>) -> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.get_enrolled_friends(contatcts: contacts), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 회원가입시 이미 가입한 친구들 가져오기 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //카드 좋아요 클릭
    static func send_like_card(card_idx: Int) -> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.send_like_card(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 카드 좋아요 클릭 확인: \(publisher.value())")
        return publisher.value()
    }
    //카드 좋아요 취소
    static func cancel_like_card(card_idx: Int) -> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.cancel_like_card(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 카드 좋아요 취소 확인: \(publisher.value())")
        return publisher.value()
    }
    
    //카드 좋아요 유저 확인
    static func get_like_card_users(card_idx: Int) -> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.get_like_card_users(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
        
        print("api client에서 카드 좋아요 유저 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //오늘 심심기간인 친구들 가져오기
    static func get_today_boring_friends(bored_date: String) -> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.get_today_boring_friends(bored_date: bored_date), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 카드 좋아요 유저 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //오늘 심심한 날로 설정
    static func set_boring_today(action: Int, date: String) -> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.set_boring_today(action: action, date: date), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 오늘 심심한 날로 설정 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //관심친구 설정
    static func set_interest_friend(f_idx: Int, action: String)-> AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.set_interest_friend(f_idx: f_idx, action: action), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 관심친구 설정 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //회원가입시 친구들에게 초대 문자 보내기
    static func send_invite_message(contacts: Array<Any>)->AnyPublisher<JSON,AFError>{
        
        let publisher = AF.request(APIRouter.send_invite_message(contacts: contacts), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 친구들에게 초대 문자 보내기 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //친구 신청 취소
    static func cancel_request_friend(f_idx: Int) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.cancel_request_friend(f_idx: f_idx), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 친구 신청 취소 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //친구해제
    static func delete_friend(f_idx: Int, action: String) -> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.delete_friend(f_idx: f_idx, action: action), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 친구해제 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //관심친구 리스트 가져오기
    static func get_interest_friends(friend_type: String)-> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.get_interest_friends(friend_type: "관심친구"), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 관심친구 리스트 가져오기확인 \(publisher.value())")
        return publisher.value()
    }
    
    //내가 좋아요한 카드 가져오기
    static func get_liked_cards()-> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.get_liked_cards, interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 내가 좋아요한 카드 가져오기 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //알림탭 클릭시 노티 리스트 가져오기
    static func get_notis(page_idx: Int, page_size: Int)-> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.get_notis(page_idx: page_idx, page_size: page_size), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 알림탭 클릭시 노티 리스트 가져오기 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //카드 잠그기
    static func lock_card(card_idx: Int, lock_state: Int)-> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.lock_card(card_idx: card_idx, lock_state: lock_state), interceptor: RequestInterceptorClass())
        
            .publishDecodable(type: JSON.self)
    
        print("api client에서 카드 잠그기 확인 \(publisher.value())")
        return publisher.value()
    }
    
    //친구 카드 참여자 목록 가져오기
    static func get_friend_card_apply_people(card_idx: Int)-> AnyPublisher<JSON, AFError>{
        let publisher = AF.request(APIRouter.get_friend_card_apply_people(card_idx: card_idx), interceptor: RequestInterceptorClass())
            .publishDecodable(type: JSON.self)
    
        print("api client에서 친구 카드 참여자 목록 가져오기 확인 \(publisher.value())")
        return publisher.value()
    }
    
    static func make_card_with_img(param : [String: Any], photo_file: Data?, to url: APIRouter, completion: @escaping (Result<ResponseMakeCardStruct, AFError>) -> ()) {
        print("모임카드 파라미터 확인: \(param)")
        AF.upload(multipartFormData: {multipart in
            
            for (key, value) in param{
                if let temp = value as? String{
                    multipart.append((value as! String).data(using: .utf8)!, withName: key)
                }
                
                if let temp = value as? Int{
                    multipart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                
                if let temp = value as? [String]{
                    print("어레이인 경우: \(temp)")
                    let value = temp.joined(separator: ",")
                    multipart.append((value as! String).data(using: .utf8)!, withName: key)
                }
            
            }
            if photo_file != nil{
                    multipart.append(photo_file!, withName: "photo_file", fileName: "photo_file.png", mimeType: "image/png")
            }else{
                let value = ""
                multipart.append((value as! String).data(using: .utf8)!, withName: "photo_file")
            }
        },with: url)
        .responseDecodable(){(response: DataResponse<ResponseMakeCardStruct, AFError>) in
                    print("모임 카드 api client에서 이미지 리스폰스 확인 : \(response)")
                    guard let data = response.data else { return }
                    let json = try? JSON(data: data)
                    print("리스폰스 확인 : \(String(describing: json))")
            completion(response.result)
                }
    }
    
    static func edit_card_with_img(card_idx: Int,param : [String: Any], photo_file: Data?, to url: APIRouter, completion: @escaping (Result<ResponseEditGroupCardStruct, AFError>) -> ()) {
        print("모임카드 파라미터 확인: \(param)")
        AF.upload(multipartFormData: {multipart in
            
            for (key, value) in param{
                if let temp = value as? String{
                    multipart.append((value as! String).data(using: .utf8)!, withName: key)
                }
                
                if let temp = value as? Int{
                    multipart.append("\(temp)".data(using: .utf8)!, withName: key)
                }
                
                if let temp = value as? [String]{
                    print("어레이인 경우: \(temp)")
                    let value = temp.joined(separator: ",")
                    multipart.append((value as! String).data(using: .utf8)!, withName: key)
                }
            
            }
            if photo_file != nil{
                print("이미지 있을 때")

                    multipart.append(photo_file!, withName: "photo_file", fileName: "photo_file.png", mimeType: "image/png")
            }else{
                print("이미지 없을 때")
                let value = ""
                multipart.append((value as! String).data(using: .utf8)!, withName: "photo_file")
            }
            
            print("데이터 확인: \(multipart)")
        },with: url)
        .responseDecodable(){( response : DataResponse<ResponseEditGroupCardStruct, AFError>) in
                    print("모임 카드 수정 api client에서 이미지 리스폰스 확인 : \(response)")
                    guard let data = response.data else { return }
                    let json = try? JSON(data: data)
                    print("리스폰스 확인 : \(String(describing: response))")
                    completion(response.result)
                }
    }

    
    
}

