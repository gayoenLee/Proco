//
//  CalendarViewModel.swift
//  proco
//
//  Created by 이은호 on 2021/02/28.
//

import Foundation
import Combine
import Alamofire
import SwiftUI
import ElegantPages

//친구 요청 통신에 따른 alert창 띄워줄 때 사용함.
enum AskFriendRequestAlert{
    case no_friends, request_wait, requested, already_friend, denied, myself, success, fail
}

public class CalendarViewModel: ObservableObject{
    let currentCalendar = Calendar.current
    
    public let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    //상세페이지뷰에서 좋아요 클릭시 날짜 한칸 뷰 안의 좋아요 데이터도 변경시키기 위해 이용
    @Published var calendar_like_changed : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //캘린더 주인 프로필 데이터 저장할 모델
    @Published var calendar_owner : CalendarOwnerModel = CalendarOwnerModel(){
        didSet{
            objectWillChange.send()
        }
    }
    @Published var initial_month : Date = Date(){
        didSet{
            print("캘린더 뷰모델에 initial month didset 들어옴: \(self.initial_month).")
          
            self.get_card_for_calendar(user_idx: self.calendar_owner.user_idx, date_start: self.date_to_string(date: self.calendar_start_date), date_end: self.date_to_string(date: self.calendar_end_date))
        }
    }
    
    //심심기간 데이터 모델
    @Published var boring_period_model: BoredDaysModel = BoredDaysModel(){
        didSet{
            objectWillChange.send()
        }
    }
    
    //캘린더 카드 이벤트 모델
    @Published var card_block_model: CalendarCardBlockModel = CalendarCardBlockModel(){
        didSet{
            objectWillChange.send()
        }
    }
    //카드 데이터 가져오는 통신이 끝난 후 날짜별로 데이터 넣어주기 위해 동기처리에 사용.
    private var get_card_ok: Bool = false
    @Published var schedule_state_changed : Bool = false
    //관심있어요 상세페이지에서 변경시 뷰 전체가 init되지 않도록 하기 위해 만든 구분 변수.
    @Published var interest_state_changed : Bool = false
    
    //날짜 한 칸에 보여줄 일정 리스트 모델
    @Published var small_schedules : [SmallSchedule] = []{
        willSet{
                objectWillChange.send()
        }
    }
    
    //단일 일자 상세 페이지 뷰에서 보여줄 일정 리스트 모델
    @Published var schedules_model : [Schedule] = []{
        willSet{
            print("schedules model 디드셋 안")
                objectWillChange.send()
        }
    }
    
    //캘린더 좋아요 데이터 모델(날짜 한 칸에 보여줄 때 사용하는 데이터 모델)
    @Published var calendar_like_model : CalendarLikeModel = CalendarLikeModel(){
        didSet{
            objectWillChange.send()
        }
    }
    
    //관심있어요 데이터 모델
    @Published var interest_model : [InterestModel] = []
    //날짜 한 칸 관심있어요 모델
    @Published var small_interest_model : [SmallInterestModel] = []{
        didSet{
            if interest_state_changed == true{
                print("날짜 한 칸 관심있어요 데이터 모델 안 didset")
                objectWillChange.send()
            }
        }
    }
    
    //일정 상세 페이지에서 사용하는 데이터 모델
    @Published var like_model : [LikeModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //날짜 한 칸 뷰에서 일정 리스트 저장할 모델
    @Published var small_schedule_info_model : [SmallScheduleInfo] = []{
        didSet{
            objectWillChange.send()
        }
    }

    //좋아요한 유저 리스트 모델
    @Published var calendar_like_user_model : [LikeUserListModel] = []
    //관심있어요 유저 리스트 모델
    @Published var calendar_interest_user_model : [InterestUsersModel] = []
    
    //서버에서 데이터 갖고 와서 이곳에 저장한 후 메인에 연결시켜주기 위함.
    @Published var selections : [Date] = []{
        willSet{
            objectWillChange.send()
        }
    }
    
    @Published var my_idx = UserDefaults.standard.string(forKey: "user_id"){
        willSet{
            objectWillChange.send()
        }
    }
    
    //일정 추가 - 날짜 입력 정보
    @Published var schedule_start_date:  Date = Date(){
        didSet{
            objectWillChange.send()
        }
    }
    //일정 추가 -  시간 입력 정보
    @Published var schedule_start_time : Date = Date(){
        didSet{
            objectWillChange.send()
        }
    }
    //일정 추가 - 메모 텍스트 필드
    @Published var schedule_memo : String = ""

    //캘린더 -> 카드 상세페이지로 이동하는 것을 알기 위해 사용.
    @Published var from_calendar: Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //친구인지 아닌지 통신 후 결과값(카드 공개 범위 포함) -> 뷰 예외처리 위해서 사용.
    //not_friend: 친구 아님, friend_disallow: 비공개(친구지만), friend_allow: 공개 또는 나인 경우, friend_allow_card: 카드만 공개
    @Published var check_friend_result: String = ""{
        didSet{
            objectWillChange.send()
            print("뷰모델에서 check friend result didset: \(self.check_friend_result)")
        }
    }
    //아래 3가지 변수 및 메소드: 친구 요청 통신 결과값에 따라서 alert창 띄워주기 위해 사용.
    @Published var show_friend_result_alert : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var friend_request_result_alert :AskFriendRequestAlert  = .success{
        didSet{
            objectWillChange.send()
        }
    }
    
    func friend_request_result_alert_func(_ active: AskFriendRequestAlert) -> Void {
        DispatchQueue.main.async {
            self.friend_request_result_alert = active
            self.show_friend_result_alert = true
        }
    }
    //-------------------------------------------------
    
    //캘린더 데이터 가져올 때 시작, 끝 날짜 지정
    @Published var calendar_start_date: Date = Date()
    @Published var calendar_end_date: Date = Date()
    
    //캘린더 -> 친구 카드 상세페이지로 이동시 사용하는 모델
    @Published var friend_card_detail_model : CalendarFriendCardDetailModel = CalendarFriendCardDetailModel()
    //캘린더 -> 그룹 카드 상세페이지로 이동시 사용하는 모델
    @Published var group_card_detail_model : CalendarGroupCardDetailModel = CalendarGroupCardDetailModel()
    
    
    //심심기간 통신
    func get_boring_period(user_idx: Int, date_start: String, date_end: String){
        cancellation = APIClient.get_boring_period(user_idx: user_idx, date_start: date_start, date_end: date_end)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("심심기간 정보 조회 에러 발생 : \(error)")
                case .finished:
                    
                    break
                }
            }, receiveValue: {response in
                print("심심기간 정보 조회 receive값: \(response)")
                let result: String? = response["result"].string
                if result == result{
                    print("심심기간 결과값 있을 때")
                    self.small_interest_model.removeAll()
                    self.interest_model.removeAll()
                    let data  = response.dictionaryValue
                    print("심심기간 데이터 확인: \(data)")
                    
                    //1.심심기간
                    //TODO 심심기간 지정 안했어도 빈 배열이라도 리턴 오는지 확인
                    let bored_dates = data["bored_dates"]!.arrayValue
                    //2.관심있어요가 있는 날짜들
                    let bored_days_count = data["bored_days_count"]!.arrayValue
                    //3.내가 관심있어요 체크한 날짜들(내 캘린더, 다른 사람들 캘린더에서)
                    let my_bored_check_dates = data["bored_check_dates"]!.arrayValue
                    
                    print("심심기간 데이터 종류별로 뽑았는지 확인: 심심기간: \(bored_dates), 관심있어요 날짜들: \(bored_days_count), 내가 관심있어요 체크한 날짜들: \(my_bored_check_dates)")
                    
                    //임시로 심심기간 정보 저장할 변수
                    var temp_bored_dates_model: [BoredDatesModel] = []
                    //날짜 한 칸에 보여주기 위해 모델에 임시 저장(LikeAndInterest)
                    var temp_boring_period_selections : [String] = []
                    //1)심심기간 - 월, 일 정보 빼내서 임시 저장
                    for bored in bored_dates{
                        print("심심기간 월, 일, 날짜 정보 1개: \(bored)")
                        let bored_date = bored["bored_date"].stringValue
                        let bored_date_days = bored["bored_date_days"].stringValue
                        
                        temp_bored_dates_model.append(BoredDatesModel(bored_date: bored_date, bored_date_days: bored_date_days))
                        
                        let date_array = bored_date_days.split(separator: ",")
                        print("날짜들 배열로 다시 만든 것: \(date_array)")
                        //selections에는 날짜로 저장하기 위함.
                        for date in date_array{
                            if String(date).count == 1{
                                let new = "0\(date)"
                                let bored_day_form = bored_date.replacingOccurrences(of: "01", with: String(new))
                                print("다시 만든 심심기간 날짜 정보: \(bored_day_form)")
                                
                                //03.04추가 날짜 한 칸에 관심있어요 보여줄 때 사용하기 위해 저장.
                                temp_boring_period_selections.append(bored_day_form)
                                
                                //date형식으로 바꾸기
                                let bored_period_date = self.make_date(expiration: bored_day_form)
                                print("날짜 형식으로 바꾼 \(bored_period_date)")
                                
                                self.selections.append(bored_period_date)
                                
                            }else{
                                print("현재 날짜: \(bored)")
                                let bored_day_form = bored_date.replacingOccurrences(of: "01", with: String(date))
                                print("다시 만든 심심기간 날짜 정보: \(bored_day_form)")
                                
                                //03.04추가 날짜 한 칸에 관심있어요 보여줄 때 사용하기 위해 저장.
                                temp_boring_period_selections.append(bored_day_form)
                                
                                //date형식으로 바꾸기
                                let bored_period_date = self.make_date(expiration: bored_day_form)
                                print("날짜 형식으로 바꾼 \(bored_period_date)")
                                //심심기간 지정한 날짜들(라이브러리 안 selections에서 사용)
                                self.selections.append(bored_period_date)
                            }
                            print("최종으로 카드 뷰모델에서 만든 selections:\(self.selections)")
                            print("최종으로 날짜 한 칸 관심있어요 위해 저장한 selections: \(temp_boring_period_selections)")
                        }
                    }
                    
                    //임시로 관심있어요 정보 저장할 변수
                    var temp_bored_days_count_model: [BoredDaysCountModel] = []
                    //2)심심기간에 있는 관심있어요 정보 임시 저장
                    for interest in bored_days_count{
                        let interest_checked_date = interest["interest_checked_date"].stringValue
                        let interest_count = interest["interest_count"].intValue
                        temp_bored_days_count_model.append(BoredDaysCountModel( interest_checked_date: interest_checked_date, interest_count: interest_count))
                    }
                    print("관심있어요 임시 저장한 데이터 모델 확인: \(temp_bored_days_count_model)")
                    
                    //내가 체크한 관심있어요 날짜들 임시 저장할 변수
                    var temp_bored_check_dates : [BoredCheckDatesModel] = []
                    //3)내가 체크한 관심있어요 날짜들 임시 저장
                    for my_checked in my_bored_check_dates{
                        let idx = my_checked["idx"].intValue
                        let checked_date = my_checked["checked_date"].stringValue
                        temp_bored_check_dates.append(BoredCheckDatesModel(idx: idx, checked_dates: checked_date))
                    }
                    
                    //publish 변수에 최종 저장.
                    self.boring_period_model = BoredDaysModel( bored_dates: temp_bored_dates_model, bored_days_count: temp_bored_days_count_model, bored_check_dates: temp_bored_check_dates)
                    
                    print("최종 저장한 심심기간 데이터: \(self.boring_period_model)")
                    
                    ///날짜 한 칸에 보여줄 관심있어요 데이터 보여주기 위해 저장.
                    ///심심기간으로 지정한 날짜들을 순서대로 for문 돌림.
                    for day in temp_boring_period_selections{
                        print("날짜 한 칸 관심있어요 데이터 저장에서 비교하려는 날짜: \(day)")
                        
                        //1.관심있어요 총 갯수 찾기 - 저장된 모델 중 index찾기
                        var total_interest_idx: Int = -1
                        total_interest_idx = temp_bored_days_count_model.firstIndex(where: {
                            return  $0.interest_checked_date == day
                        }) ?? -1
                        print("같은 날짜 index: \(String(describing: total_interest_idx))")
                        
                        //2.관심있어요 총 갯수 찾기 - 위에서 가져온 index를 가지고 관심있어요 갯수 가져오기
                        var total_interest_num: Int = -1
                        if total_interest_idx != -1{
                            print("관심있어요 갯수가 있을 때 idx: \(total_interest_idx)")
                            total_interest_num = temp_bored_days_count_model[total_interest_idx].interest_count!
                            print("총 관심있어요 개수: \(total_interest_num)")
                        }
                        
                        //3.내가 관심있어요 클릭했는지, 클릭한 idx 찾기 - 저장된 모델의 index찾기
                        var clicked_interest_idx: Int = -1
                        clicked_interest_idx = temp_bored_check_dates.firstIndex(where: {
                            $0.checked_dates == day
                        }) ?? -1
                        print("내가 관심있어요 클릭한 날짜 idx: \(clicked_interest_idx)")
                        
                        //4.내가 관심있어요 클릭했는지& 클릭한 idx 찾기 - 위에서 가져온 index를 가지고 데이터 가져오기
                        //1)내가 클릭했는지
                        var clicked_interest: Bool = false
                        if clicked_interest_idx != -1{
                            clicked_interest = true
                        }else{
                            clicked_interest = false
                        }
                        //2)관심있어요 클릭한 날짜idx
                        //서버에서 관심있어요 클릭시 받은 idx
                        var interest_idx: Int = -1
                        if clicked_interest_idx != -1{
                            interest_idx = temp_bored_check_dates[clicked_interest_idx].idx!
                        }
                        //5.관심있어요 모델에 데이터 저장 - 상세페이지, 날짜 한 칸에 사용하는 모델 다름.
                        let current_day = self.make_date(expiration: day)
                        //상세페이지
                        self.interest_model.append(InterestModel(date: current_day,  interest_num: total_interest_num, clicked_interest_myself: clicked_interest, interest_date_idx: interest_idx))
                        //날짜 한 칸
                        self.small_interest_model.append(SmallInterestModel(date: current_day,  interest_num: total_interest_num, clicked_interest_myself: clicked_interest, interest_date_idx: interest_idx))
                    }
                    
                    print("최종 저장한 날짜 한 칸 관심있어요 모델: \(self.interest_model)")
                    //****좋아요 정보 가져오는 통신
                    self.get_like_for_calendar(user_idx: self.calendar_owner.user_idx, date_start: self.date_to_string(date: self.calendar_start_date), date_end: self.date_to_string(date: self.calendar_end_date))
                }
            })
    }
    
    //캘린더에 보여줄 카드 이벤트 가져오는 통신 - 날짜 한칸 일정 리스트, 일자 하나 상세 페이지에서의 일정 리스트 모두 사용.(내가 만든 일정은 다른 곳에 가져옴.)
    func get_card_for_calendar(user_idx: Int, date_start: String, date_end: String) {
        cancellation = APIClient.get_card_for_calendar(user_idx: user_idx, date_start: date_start, date_end: date_end)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 카드 정보 조회 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("캘린더 카드 정보 조회 receive값: \(response)")
                let result: String? = response["result"].string
                self.get_card_ok = false
                
                if result == result{
                    print("카드가 있을 때")
                    self.small_schedules = []
                    self.schedules_model.removeAll()
                    self.card_block_model.friend.private_type.removeAll()
                    self.card_block_model.meeting.removeAll()
                    self.card_block_model.friend.public_type.removeAll()
                    
                    /*
                     날짜 칸에 보여줄 리스트 저장 & 일자에 대한 상세 페이지의 일정 리스트 저장
                     두가지 모델에 저장해야 함.
                     */
                    //결과값이 딕셔너리 형태임을 정의
                    let data = response.dictionaryValue
                    print("데이터 확인: \(data)")
                    //일자 상세 페이지 뷰의 일정 리스트 임시 저장할 모델
                    var temp_schedules_model : [Schedule] = []
                    var temp_schedules_info_model : [ScheduleInfo] = []
                    
                    //친구, 모임 딕셔너리 형태로 따로 빼기
                    let friend_cards = data["friend"]!.dictionaryValue
                    let meeting_cards = data["meeting"]!.arrayValue
                    print("friend_cards 확인: \(friend_cards)")
                    
                    //1.친구 카드 데이터 집어넣기
                    //친구 카드 public, private(모임은 public만 있음.), 데이터가 없어도 빈 배열이라도 들어옴.
                    let friend_public = friend_cards["public"]!.arrayValue
                    let friend_private = friend_cards["private"]!.arrayValue
                    print("친구 카드 public 확인: \(friend_public)")
                    
                    //날짜 칸 일정 리스트 - 친구 카드 데이터 넣을 새로운 변수 생성. -> 합쳐서 published변수로 만들어진 friend모델에 저장해야 함.
                    var friend_public_card : [FriendCardBlockPublicModel] = []
                    var friend_private_card : [FriendCardBlockPrivateModel] = []
                    
                    if friend_public.count > 0{
                        //friend데이터 저장 시작
                        for card in friend_public{
                            let card = card.dictionaryValue
                            print("friend 퍼블릭 카드 저장 중 card 한 개: \(card)")
                            let creator = card["creator"]?.dictionaryValue
                            let tags = card["tags"]!.arrayValue
                            var tag_data : [Tags] = []
                            
                            //단일자 일정 리스트의 태그 저장할 변수
                            var temp_tags: [ScheduleTags] = []
                            //태그는 따로 또 포문 돌려야 함.
                            for tag in tags{
                                //날짜 한칸 일정 리스트 태그 저장
                                tag_data.append(Tags(idx: tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                                //단일자 일정 리스트의 태그 저장
                                temp_tags.append(ScheduleTags(idx:tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                                
                            }
                            
                            friend_public_card.append(FriendCardBlockPublicModel( card_idx: card["card_idx"]?.intValue, kinds: (card["kinds"]?.stringValue), expiration_at: card["expiration_at"]?.stringValue, lock_state: card["lock_state"]!.intValue, like_count: card["like_count"]!.intValue,like_state: card["like_state"]!.intValue, creator: Creator(idx: creator!["idx"]?.intValue, nickname: creator!["nickname"]!.stringValue, profile_photo_path: creator!["profile_photo_path"]!.stringValue), tags: tag_data))
                            
                            let expiration_at = card["expiration_at"]?.stringValue
                            let date = self.string_to_date(expiration: expiration_at!)
                            
                            //날짜 한 칸에 small schedule에 저장할 일정정보 모델.SmallScheduleInfo
                            self.small_schedule_info_model.append(SmallScheduleInfo(date: date, locationName: "\(creator!["nickname"]!.stringValue)님과의약속", tagColor: Color.orange, type: "friend"))
                            
                            //단일자 일정 리스트 - 친구카드 일정 저장하기
                            temp_schedules_info_model.append(ScheduleInfo(card_idx: card["card_idx"]!.intValue, type: "friend", schedule_date: date, schedule_name: "\(creator!["nickname"]!.stringValue)님과의약속", tag_color: Color.orange, start_time: date, end_time: date, category: temp_tags[0].tag_name, tags: temp_tags, current_people: "0", location_name: "", is_private: false, memo: ""))
                            
                            temp_schedules_model.append(Schedule(date: date, like_num: 0, liked_myself: false, like_idx: -1, schedule: temp_schedules_info_model))
                            //여기에서 한 번 삭제해줘야 앞에 저장한 데이터가 중복 저장되지 않음.
                            temp_schedules_info_model.removeAll()
                        }
                    }
                    
                    print("public친구 카드 저장 확인: \(friend_public_card)")
                    
                    //friend private은 private을 지정한 카드에만 존재.
                    if !friend_private.isEmpty{
                        for card in friend_private{
                            let card = card.dictionaryValue
                            print("friend 프라이빗 카드 데이터 저장 중 card 한 개: \(card)")
                            
                            friend_private_card.append(FriendCardBlockPrivateModel(idx: card["idx"]?.intValue, expiration_at: card["expiration_at"]?.stringValue))
                            
                            let expiration_at = card["expiration_at"]?.stringValue
                            let date = self.string_to_date(expiration: expiration_at!)
                            
                            //날짜 한 칸에 small schedule에 저장할 일정정보 모델.SmallScheduleInfo
                            self.small_schedule_info_model.append(SmallScheduleInfo(date: date, locationName: "", tagColor: Color.orange, type: "friend_private"))
                            
                            //단일자 일정 리스트에 저장할 private카드
                            temp_schedules_info_model.append(ScheduleInfo(card_idx: card["idx"]!.intValue, type: "friend", schedule_date: date, schedule_name: "", tag_color: Color.orange, start_time: date, end_time: date, category: "", tags: [], current_people: "0", location_name: "", is_private: true, memo: ""))
                        }
                        
                        //일정 정보를 저장해 놓은 배열을 다시 schedule모델에 저장.
                        //for문 안에 넣으면 중복돼서 저장됨.
                        for schedule in temp_schedules_info_model{
                            let date = schedule.schedule_date
                            //이미 같은 날짜로 데이터가 저장돼 있는지 확인.
                            var is_already_stored_check_idx : Int? = -1
                            is_already_stored_check_idx = temp_schedules_model.firstIndex(where: {$0.date == date}) ?? -1
                            //같은 날짜로 저장돼 있는 데이터가 있었다면
                            if is_already_stored_check_idx != -1{
                                temp_schedules_model[is_already_stored_check_idx!].schedule.append(schedule)
                                
                                //이미 이 날짜로 저장된 데이터가 없었던 경우
                            }else{
                                var schedule_info_model : [ScheduleInfo] = []
                                schedule_info_model.append(ScheduleInfo(card_idx: schedule.card_idx, type: schedule.type, schedule_date: schedule.schedule_date, schedule_name: schedule.schedule_name, tag_color: schedule.tag_color, start_time: schedule.start_time, end_time: schedule.end_time, category: schedule.category, current_people: schedule.current_people, location_name: schedule.location_name, is_private: schedule.is_private, memo: ""))
                                
                                temp_schedules_model.append(Schedule(date: date, like_num: 0, liked_myself: false, like_idx: -1, schedule: schedule_info_model))
                            }
                        }
                    }
                    print("private친구 카드 저장 확인: \(friend_private_card)")
                    
                    //meeting데이터 저장 시작
                    //임시로 저장할 모임 카드 데이터 모델
                    var temp_meeting_card : [GroupCardStruct] = []
                    
                    if !meeting_cards.isEmpty{
                        for card in meeting_cards{
                            let card = card.dictionaryValue
                            let creator = card["creator"]?.dictionaryValue
                            let tags = card["tags"]!.arrayValue
                            var tag_data : [Tags] = []
                            //단일자 일정 리스트의 태그 저장할 변수
                            var temp_tags: [ScheduleTags] = []
                            //태그는 따로 또 포문 돌려야 함.
                            for tag in tags{
                                tag_data.append(Tags(idx: tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                                
                                //단일자 일정 리스트의 태그
                                temp_tags.append(ScheduleTags(idx: tag["idx"].intValue, tag_name: tag["tag_name"].stringValue))
                            }
                            
                            temp_meeting_card.append(GroupCardStruct(card_idx: card["card_idx"]?.intValue, title: card["title"]?.stringValue, kinds: card["kinds"]?.stringValue, expiration_at: card["expiration_at"]?.stringValue, address: card["address"]?.stringValue, map_lat: card["map_lat"]?.stringValue, map_lng: card["map_lng"]?.stringValue, cur_user: card["cur_user"]?.intValue, apply_user: card["apply_user"]?.intValue, introduce: card["introduce"]?.stringValue, lock_state: card["lock_state"]!.intValue, like_state: card["like_state"]!.intValue, like_count: card["like_count"]!.intValue, tags: tag_data, creator: Creator(idx: creator!["idx"]?.intValue, nickname: creator!["nickname"]!.stringValue, profile_photo_path: creator?["profile_photo_path"]?.string), offset: 0.0))
                            
                            let expiration_at = card["expiration_at"]?.stringValue
                            let date = self.string_to_date(expiration: expiration_at!)
                            
                            //날짜 한 칸에 small schedule에 저장할 일정정보 모델.SmallScheduleInfo
                            self.small_schedule_info_model.append(SmallScheduleInfo(date: date, locationName: card["title"]!.stringValue, tagColor: Color.green, type: "group"))
                            
                            //단일자 일정 리스트 모임 데이터 저장
                            temp_schedules_info_model.append(ScheduleInfo(card_idx: card["card_idx"]!.intValue, type: "group", schedule_date: date, schedule_name: card["title"]!.stringValue, tag_color: Color.green, start_time: date, end_time: date, category: tag_data[0].tag_name, current_people: card["cur_user"]?.stringValue ?? "1",  location_name: card["address"]?.stringValue ?? "", is_private: false, memo: ""))
                            
                        }
                        //일정 정보를 저장해 놓은 배열을 다시 schedule모델에 저장.
                        //for문 안에 넣으면 중복돼서 저장됨.
                        for schedule in temp_schedules_info_model{
                            let date = schedule.schedule_date
                            //이미 같은 날짜로 데이터가 저장돼 있는지 확인.
                            var is_already_stored_check_idx : Int? = -1
                            is_already_stored_check_idx = temp_schedules_model.firstIndex(where: {$0.date == date}) ?? -1
                            //같은 날짜로 저장돼 있는 데이터가 있었다면
                            if is_already_stored_check_idx != -1{
                                temp_schedules_model[is_already_stored_check_idx!].schedule.append(schedule)
                                
                                //이미 이 날짜로 저장된 데이터가 없었던 경우
                            }else{
                                var schedule_info_model : [ScheduleInfo] = []
                                schedule_info_model.append(ScheduleInfo(card_idx: schedule.card_idx, type: schedule.type, schedule_date: schedule.schedule_date, schedule_name: schedule.schedule_name, tag_color: schedule.tag_color, start_time: schedule.start_time, end_time: schedule.end_time, category: schedule.category, current_people: schedule.current_people, location_name: schedule.location_name, is_private: schedule.is_private, memo: ""))
                                
                                temp_schedules_model.append(Schedule(date: date, like_num: 0, liked_myself: false, like_idx: -1, schedule: schedule_info_model))
                            }
                        }
                    }
                    
                    //친구 카드private, public + 모임카드 데이터 합쳐서 저장.
                    self.card_block_model = CalendarCardBlockModel(friend: FriendCardBlockModel(public_type: friend_public_card, private_type: friend_private_card), meeting: temp_meeting_card)
                    print("캘린더에 보여줄 카드 데이터 넣었는지 확인: \(self.card_block_model)")
                    
                    //단일자 일정 리스트 temp_schedule_model에 있던거 publish변수로 된 모델에 제대로 저장. -> 좋아요 정보는 아직 저장 안했음. 좋아요 통신에서 날짜 비교해서 저장.
                    self.schedules_model = temp_schedules_model
                    print("단일자 일정 리스트 모델 schedules에 저장됐는지 확인: \(self.schedules_model)")
                    
                    //심심기간 가져오기 -> 안에 좋아요 정보 가져오는 통신 있음.
                    self.get_boring_period(user_idx: self.calendar_owner.user_idx, date_start: self.date_to_string(date: self.calendar_start_date), date_end: self.date_to_string(date: self.calendar_end_date))
                    
                }else{
                    print("캘린더 카드 리스트 조회 결과값 없음")
                }
            })
    }
    
    func string_to_date(expiration: String) -> Date{
        print("변환하기 위해 받은 날짜: \(expiration)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        let date = formatter.date(from: expiration)
        print("변환날짜: \(String(describing: date))")
        return date!
    }
    
    //서버에서 받은 심심기간의 경우 time이 없어서 이 메소드로 변환.
    func make_date(expiration: String) -> Date{
        print("변환하기 위해 받은 날짜: \(expiration)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "UCT")
        let date = formatter.date(from: expiration)
        print("변환날짜: \(String(describing: date))")
        return date!
    }
    
    func date_to_string(date: Date) -> String{
        print("캘린더 뷰모델 date to string")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let day = formatter.string(from: date)
        print("date형식: \(date), 변환된 형식: \(day)")
        return day
    }
    
    //내 일정 추가하기에서 시간만 string만들기 위함.
    func make_time_string(time: Date) -> String{
        let formatter = DateFormatter()
        let string_time = formatter.string(from: time)
        print("받은 시간: \(time), 변환된 시간: \(string_time)")
        return string_time
        
    }
    
    //내 일정 추가하기 완료 후 시간만 데이터 저장시 string-> date형태로 저장하기 위함.
    func make_time_date(time: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let date_time = formatter.date(from: time)
        print("받은 시간: \(time), 변환한 시간: \(String(describing: date_time))")
        return date_time!
    }
    
    //캘린더 좋아요 정보 가져오기
    func get_like_for_calendar(user_idx: Int, date_start: String, date_end: String){
        cancellation = APIClient.get_like_for_calendar(user_idx: user_idx, date_start: date_start, date_end: date_end)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 좋아요 정보 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue:{response in
                print("캘린더 좋아요 정보 receive: \(response)")
                
                if response == response{
                    print("좋아요 정보 조회값 있을 때")
                    
                    let data = response.dictionaryValue
                    /*
                     데이터 종류 크게 2가지 옴.like_user_checked, calendar_like_count
                     1. 내가 체크한 좋아요 날짜들
                     2. 날짜별 좋아요 갯수
                     */
                    let like_user_checked = data["like_user_checked"]!.arrayValue
                    let calendar_like_count = data["calendar_like_count"]!.arrayValue
                    print("내가 좋아요한 날짜들 데이터 빼낸 것 확인: \(like_user_checked)")
                    
                    //1.내가 체크한 좋아요 날짜들 저장하기
                    //임시로 저장할 변수
                    var temp_like_user_checked : [LikeUserCheckedModel] = []
                    //빈 배열일 경우는 저장하지 않도록 하기 위함.
                    if !like_user_checked.isEmpty{
                        
                        //내가 좋아요한 정보 배열 데이터
                        for info in like_user_checked{
                            
                            let info = info.dictionaryValue
                            let idx = info["idx"]!.intValue
                            let like_checked_date = info["like_checked_date"]!.stringValue
                            print("좋아요 날짜 한 개: \(like_checked_date) ")
                            
                            temp_like_user_checked.append(LikeUserCheckedModel(idx: idx, like_checked_date: like_checked_date))
                            
                            let date_form = self.make_date(expiration: like_checked_date)
                            
                            //좋아요 뷰를 따로 보여주려고 만들었던 것. - 사용하는지 확인하기.
                            self.like_model.append(LikeModel(date: date_form, like_num: 0, clicked_like_myself: true, clicked_like_idx: idx))
                            
                            //단일자 상세 페이지 모델에 저장하기 위해 저장할 index찾기
                            var schedule_model_idx : Int? = -1
                            
                            schedule_model_idx = self.schedules_model.firstIndex(where: {
                                let string_date = self.date_to_string(date: $0.date)
                                return string_date == like_checked_date
                            }) ?? -1
                            
                            if schedule_model_idx != -1{
                                self.schedules_model[schedule_model_idx!].liked_myself = true
                                self.schedules_model[schedule_model_idx!].like_idx = idx
                            }
                        }
                    }
                    print("최종 저장한 내가 좋아요한 정보: \(temp_like_user_checked)")
                    
                    //2.나 + 다른 유저들이 누른 총좋아요 갯수 일별로 정보 저장하기
                    //임시로 저장할 변수
                    var temp_calendar_like_count:[CalendarLikeCountModel] = []
                    //빈 배열일 경우는 저장하지 않도록 하기 위함.
                    if !calendar_like_count.isEmpty{
                        
                        for info in calendar_like_count{
                            let info = info.dictionaryValue
                            let like_checked_date = info["like_checked_date"]?.stringValue
                            let like_count = info["like_count"]?.intValue
                            temp_calendar_like_count.append(CalendarLikeCountModel( like_checked_date: like_checked_date!, like_count: like_count!))
                            
                            let date_form = self.make_date(expiration: like_checked_date!)
                            let same_idx = self.like_model.firstIndex(where: {$0.date == date_form})
                            self.like_model[same_idx!].like_num = like_count!
                            
                            //단일자 상세 페이지 모델에 저장하기 위해 저장할 index찾기
                            var schedule_model_idx : Int? = -1
                            schedule_model_idx = self.schedules_model.firstIndex(where: {
                                let string_date = self.date_to_string(date: $0.date)
                                return string_date == like_checked_date
                            }) ?? -1
                            if schedule_model_idx != -1{
                                self.schedules_model[schedule_model_idx!].like_num = like_count
                            }
                            print("단일자 데이터 모델 저장한 것 최종 확인: \(self.schedules_model)")
                        }
                    }
                    
                    //모든 데이터를 카드 좋아요 모델에 합쳐서 저장하기
                    self.calendar_like_model = CalendarLikeModel(like_checked_date: temp_like_user_checked, calendar_like_count: temp_calendar_like_count)
                    print("최종 저장한 캘린더 좋아요 데이터 : \(self.calendar_like_model)")
                    
                    self.small_schedules = self.currentCalendar.make_card_block(start: self.calendar_start_date, end: self.calendar_end_date, card_block_model: self.card_block_model, boring_model: self.boring_period_model, like_model: self.calendar_like_model, schedule_info: self.small_schedule_info_model)
                    
                    print("캘린더 일자 상세 페이지 데이터 저장한 것 확인: , \(self.schedules_model.count)")
                    
                    print("캘린더 카드 이벤트들 저장한 것 확인:  \(self.small_schedules.count)")
                    print("캘린더 한 칸 좋아요 데이터 확인: \(self.like_model)")
                }
                print("카드 공개 여부 확인: \(self.check_friend_result)")
                //카드만 공개인 경우 내 기간을 가져오지 않는다.
                if self.check_friend_result == "friend_allow"{
                    
                //내 일정 정보 가져오는 통신
                    self.get_personal_schedules(user_idx: self.calendar_owner.user_idx, date_start: self.date_to_string(date: self.calendar_start_date), date_end: self.date_to_string(date: self.calendar_end_date))
                }
            })
    }
    
    //심심기간 생성, 수정, 삭제 이벤트
    func send_boring_period_events(date_array: [EditBoringDatesModel]){
        cancellation = APIClient.send_boring_period_events(date_array: date_array)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 심심기간 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("캘린더 심심기간 설정 이벤트 후 response: \(response)")
                
                
            })
    }
    
    //캘린더에서 일자에 좋아요 클릭했을 때 통신
    func send_like_in_calendar(user_idx: Int, like_date: String){
        cancellation = APIClient.send_like_in_calendar(user_idx: user_idx, like_date: like_date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 일자에 대한 좋아요 클릭 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("캘린더 일자에 대한 좋아요 클릭 response: \(response)")
                if response["result"] == "ok"{
                    /*
                     1. 좋아요 클릭한 후 response로 온 idx값이
                     스케줄 모델에 저장된 idx값(like_idx)과 일치하는 모델의 배열의 idx값(found_idx)을 가져온다.(Schedules, SmallSchedules모델에 있는 데이터 업데이트 필요함.)
                     2.배열의 idx값을 이용해 기존에 저장된 모델의 좋아요 수, 내가 클릭한 여부를 변경한다.
                     */
                    
                    //서버로부터 받은 좋아요 idx
                    let like_idx = response["like_idx"].intValue
                    print("좋아요 클릭시 저장됐던 데이터 확인: \(self.schedules_model)")
                    print("좋아요 클릭해서 서버에 보낸 날짜: \(like_date)")

                    var like_click_idx : Int? = -1
                    //1. 상세페이지 뷰 데이터 변경하기
                    //좋아요 클릭한 날짜가 저장된 모델의 배열 idx값을 찾아와서 저장.
                    like_click_idx = self.schedules_model.firstIndex(where: {
                        let string_date = self.date_to_string(date: $0.date)
                        return string_date == like_date
                    }) ?? -1

                    if like_click_idx != -1{
                        self.schedules_model[like_click_idx!].like_num! += 1
                        self.schedules_model[like_click_idx!].like_idx = like_idx
                        self.schedules_model[like_click_idx!].liked_myself = true
                    }
                    print("좋아요 하고 상세페이지뷰 데이터 변경 확인: \(self.schedules_model[like_click_idx!])")

                    //아래에서 재사용할 것이기 때문에 -1로 다시 만들어줌.
                    like_click_idx = -1
                    //2.날짜 한 칸 뷰 데이터 변경하기
                    //좋아요 클릭한 날짜가 저장된 모델의 배열 idx값을 찾아와서 저장.
                    like_click_idx = self.small_schedules.firstIndex(where: {
                        let string_date = self.date_to_string(date: $0.arrivalDate)
                        print("날짜 한 칸 날짜 변환 후 확인: \(string_date)")
                        return string_date == like_date
                    }) ?? -1

                    if like_click_idx != -1{
                        print("날짜 한칸 좋아요 데이터 변경하기")
                        self.small_schedules[like_click_idx!].clicked_like_myself = true
                        self.small_schedules[like_click_idx!].like_num += 1
                        self.small_schedules[like_click_idx!].like_idx = like_idx
                    }
//
                    print("좋아요 하고 날짜 한칸 데이터 변경 확인: \(self.small_schedules[like_click_idx!])")
                    
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.calendar_like_click, object: nil, userInfo: ["calendar_like_click" : "ok", "like_idx": String(like_idx), "like_date" : like_date])
                    
                }else{
                    print("캘린더 좋아요 통신 response ok 아님")
                }
            })
    }
    
    //캘린더 - 좋아요 취소
    func send_cancel_like_calendar(user_idx: Int, calendar_like_idx: Int){
        cancellation = APIClient.send_cancel_like_calendar(user_idx: user_idx, calendar_like_idx:  calendar_like_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:{result in
                    switch result{
                    case .failure(let error):
                        print("캘린더 일자에 대한 좋아요 취소 통신 에러 발생 : \(error)")
                    case .finished:
                        break
                    }},receiveValue: {response in
                        print("좋아요 취소 response:\(response)")
                        
                        if response["result"].stringValue == "ok"{
                            print("좋아요 취소 완료")
                            print("좋아요 취소시 저장됐던 데이터 확인: \(self.schedules_model)")
                            /*
                             서버에 보낸 calendar_like_idx를 이용해 해당 idx값이 저장된 모델의 배열중 일치하는 배열의 idx값을 가져온다.
                             - Schedules, SmallSchedules 모델 변경 필요함.
                             위에서 가져온 배열의 idx값의 좋아요 갯수, 내가 좋아요한 여부를 변경해준다.
                             */
                            print("좋아요 취소하려는 idx: \(calendar_like_idx)")
                            let like_idx = calendar_like_idx
                            
                            //1.Schedules모델 : 상세 페이지 뷰의 데이터 모델
                            var like_cancel_idx : Int? = -1
                            like_cancel_idx = self.schedules_model.firstIndex(where: {

                                return $0.like_idx == like_idx
                            }) ?? -1

                            if like_cancel_idx != -1{

                                print("상세페이지 좋아요 취소 하기")
                                self.schedules_model[like_cancel_idx!].like_idx = -1
                                self.schedules_model[like_cancel_idx!].liked_myself = false
                                self.schedules_model[like_cancel_idx!].like_num! += -1
                            }
                            print("상세페이지 뷰 좋아요 취소하고 데이터 변경 확인: \(self.schedules_model[like_cancel_idx!])")
                            //아래에서 재사용할 것이기 때문에 -1로 다시 만들어줌.
                            like_cancel_idx = -1
//
                            //2.날짜 한 칸 뷰 데이터 변경하기
                            //좋아요 클릭한 like idx가 저장된 모델의 배열 idx값을 찾아와서 저장.
                            like_cancel_idx = self.small_schedules.firstIndex(where: {
                                print("날짜 한 칸 like cancel idx 확인: \(like_cancel_idx)")
                                return $0.like_idx == like_idx
                            }) ?? -1

                            if like_cancel_idx != -1{
                                print("날짜 한칸 좋아요 취소 데이터 변경하기: \(like_cancel_idx)")
                                self.small_schedules[like_cancel_idx!].clicked_like_myself = false
                                self.small_schedules[like_cancel_idx!].like_num -= 1
                                self.small_schedules[like_cancel_idx!].like_idx = -1
                            }
                            print("날짜 한 칸 뷰 좋아요 취소하고 데이터 변경 확인: \(self.small_schedules[like_cancel_idx!])")
                            
                            //뷰 업데이트 위해 보내기
                            NotificationCenter.default.post(name: Notification.calendar_like_click, object: nil, userInfo: ["calendar_like_click" : "canceled", "like_idx": String(calendar_like_idx)])
                        }else{
                            print("좋아요 취소 통신 result ok아님")
                        }
                    })
    }
    
    //좋아요한 사람들 목록 가져오는 통신
    func get_like_user_list(user_idx: Int, calendar_date: String){
        cancellation = APIClient.get_like_user_list(user_idx: user_idx, calendar_date: calendar_date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("좋아요한 사람들 목록 가져오는 통신 에러 발생 : \(error)")
                case .finished:
                    
                    break
                }
            }, receiveValue: {response in
                
                print("캘린더 좋아요 목록 가져오기 response: \(response)")
                let user_list = response.array
                
                if user_list?.count ?? 0 > 0{
                for user in user_list!{
                    
                    let idx = user["idx"].intValue
                    let nickname = user["nickname"].stringValue
                    let profile_photo_path = user["profile_photo_path"].string
                    
                    self.calendar_like_user_model.append(LikeUserListModel(idx: idx, nickname: nickname, profile_photo_path: profile_photo_path ?? ""))
                    }
                }
                print("캘린더 좋아요한 사람들 저장한 모델 확인: \(self.calendar_like_user_model)")
            })
    }
    
    //관심있어요 클릭 이벤트
    func send_interest_calendar(user_idx: Int, bored_date: String){
        cancellation = APIClient.send_interest_calendar(user_idx: user_idx, bored_date: bored_date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("심심기간 관심있어요 클릭 이벤트 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("관심있어요 클릭 response: \(response)")
                //result가 오류가 날 경우 없을 수도 있으므로 stringValue로 하지 않음.
                let result = response["result"].string
                
                if result == result{
                    
                    let interest_idx = response["interest_idx"].stringValue
                    print("결과가 있을 경우 : \(interest_idx)")
                    //response로 받은 idx저장 위해서 bored date가 저장된 모델의 idx값을 가져와서 그 안에 저장한다.
                    print("저장 전 interest model: \(self.interest_model)")
                    print("관심있어요 클릭한 날짜: \(bored_date)")
                    
                    //1.상세페이지에서 사용하는 관심있어요 모델
                    var append_idx: Int = -1
                    append_idx = self.interest_model.firstIndex(where: {
                        
                        let stored_bored_date = self.date_to_string(date: $0.date!)
                        print("string으로 변환한 날짜: \(stored_bored_date)")
                        return   stored_bored_date == bored_date
                    })!
                    print("idx저장하려는 배열 append idx: \(append_idx)")
                    
                    if append_idx != -1{
                        self.interest_model[append_idx].interest_date_idx = Int(interest_idx)
                        self.interest_model[append_idx].interest_num! += 1
                        self.interest_model[append_idx].clicked_interest_myself = true
                    }
                    print("상세페이지 관심있어요 모델 저장완료 후 확인: \(self.interest_model[append_idx])")
                    
                    //아래에서 재사용하기 위해 -1로 초기화.
                    append_idx = -1
                    
                    //2.날짜 한 칸에서 사용하는 관심있어요 모델
                    append_idx = self.small_interest_model.firstIndex(where: {
                        let stored_bored_date = self.date_to_string(date: $0.date!)
                        print("string으로 변환한 날짜: \(stored_bored_date)")
                        return   stored_bored_date == bored_date
                    })!
                    print("날짜 한 칸 - idx저장하려는 배열 append idx: \(append_idx)")
                    
                    if append_idx != -1{
                        self.small_interest_model[append_idx].interest_date_idx = Int(interest_idx)
                        self.small_interest_model[append_idx].interest_num! += 1
                        self.small_interest_model[append_idx].clicked_interest_myself = true
                        
                    }
                    print("날짜 한 칸 관심있어요 모델 저장 완료 후 확인: \(self.small_interest_model[append_idx])")
                    //뷰 업데이트 위해 보내기
                    NotificationCenter.default.post(name: Notification.calendar_interest_click, object: nil, userInfo: ["calendar_interest_click" : "ok", "interest_idx": String(interest_idx), "bored_date" : bored_date])
                }
            })
    }
    
    //관심있어요 취소 이벤트
    func cancel_interest_calendar(user_idx: Int, interest_idx: Int){
        cancellation = APIClient.cancel_interest_calendar(user_idx: user_idx, interest_idx: interest_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("심심기간 관심있어요 취소 이벤트 에러 발생 : \(error)")
                case .finished:
                    
                    break
                }
            }, receiveValue: {response in
                print("관심있어요 취소 이벤트 response: \(response)")
                
                let result = response["result"].string
                if result == result{
                    //1.저장됐던 관심있어요 모델 중에서 취소한 관심있어요 idx가 저장된 모델의 idx값을 가져온다.(모델 2개임.) -> 2.관심있어요 갯수, idx, 내가 관심있어요 체크한 여부를 변경한다.
                    var found_cancel_idx : Int? = -1
                    //1)상세페이지 관심있어요 모델
                    found_cancel_idx = self.interest_model.firstIndex(where: {
                                                                        $0.interest_date_idx == interest_idx}) ?? -1
                    
                    if found_cancel_idx != -1{
                        self.interest_model[found_cancel_idx!].clicked_interest_myself = false
                        self.interest_model[found_cancel_idx!].interest_num! -= 1
                        self.interest_model[found_cancel_idx!].interest_date_idx = -1
                    }
                    
                    //아래에서 재사용 위해서 -1로 초기화.
                    found_cancel_idx = -1
                    //2)날짜별 관심있어요 모델
                    found_cancel_idx = self.small_interest_model.firstIndex(where: {
                                                                                $0.interest_date_idx == interest_idx}) ?? -1
                    
                    if found_cancel_idx != -1{
                        self.small_interest_model[found_cancel_idx!].clicked_interest_myself = false
                        self.small_interest_model[found_cancel_idx!].interest_num! -= 1
                        self.small_interest_model[found_cancel_idx!].interest_date_idx = -1
                    }
                }
                print("관심있어요 취소 후 날짜별 - 최종 저장한 모델: \(self.small_interest_model)")
                //뷰 업데이트 위해 보내기
                NotificationCenter.default.post(name: Notification.calendar_interest_click, object: nil, userInfo: ["calendar_interest_click" : "canceled", "interest_idx": String(interest_idx)])
            })
    }
    
    //관심있어요 표시한 유저 리스트 가져오기
    func get_interest_users(user_idx: Int, bored_date: String){
        cancellation = APIClient.get_interest_users(user_idx: user_idx, bored_date: bored_date)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("심심기간 관심있어요 표시한 유저들 가져오는 데 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("관심있어요 유저 목록 response: \(response)")
                //result가 no valid request같이 딕셔너리 형태로 오는 경우도 있음.
                let response_array = response.array
                
                if response_array == response_array{
                    if response_array?.count ?? 0 > 0{
                    for user in response_array!{
                        
                        let user = user.dictionaryObject
                        let nickname = user!["nickname"]
                        var profile_photo_path = user!["profile_photo_path"]
                        let idx = user!["idx"]
                        //프로필 정보가 현재 null로만 들어오고 있어서 처리한 것.
                        if profile_photo_path == nil{
                            profile_photo_path = ""
                        }
                       
                        self.calendar_interest_user_model.append(InterestUsersModel(idx: idx! as! Int, nickname: nickname as! String, profile_photo_path: profile_photo_path as? String))
                    }
                    }
                    print("관심있어요 유저 목록 저장한 것 확인: \(self.calendar_interest_user_model)")
                }else{
                    print("관심있어요 유저 목록 가져오는데 response 에러: \(response)")
                }
            })
    }
    
    //캘린더 내 일정 추가하기
    func add_personal_schedule(title: String, content: String, schedule_date: String, schedule_start_time: String){
        cancellation = APIClient.add_personal_schedule(title: title, content: content, schedule_date: schedule_date, schedule_start_time: schedule_start_time)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 내 일정 추가하기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("내 일정 추가하기 response: \(response)")
                
                let result = response["result"].string
                if result == result{
                    if result == "ok"{
                        
                        let schedule_idx = response["schedule_idx"].intValue
                        
                        //스케줄 모델에 저장해야함.(Schedule)
                        /*
                         1.이미 일정이 저장된 날짜가 있는 경우
                         - schedule_date와 같은 날짜로 비교
                         
                         2.새롭게 저장하는 경우
                         - 새로 저장.
                         
                         3.publish변수에 저장된 제목, 날짜, 시간 초기화
                         - 그래야 뷰 재사용시 이전 데이터가 안남아있음.
                         */
                        
                        var find_idx: Int? = -1
                        find_idx = self.schedules_model.firstIndex(where: {
                            let date = self.date_to_string(date: $0.date)
                            return date == schedule_date
                        }) ?? -1
                        print("find idx 확인: \(String(describing: find_idx))")
                        print("선택한 시간 확인: \(schedule_start_time)")
                        //모델에 저장하기 위해 date형태로 만들기.
                        let schedule_date_form = self.make_date(expiration: schedule_date)
                        let schedule_time_form = self.string_to_time(time: schedule_start_time)
                        
                        //모델에 기존에 일정이 등록돼서 해당 날짜에 등록된 데이터가 있었을 경우
                        if find_idx != -1{
                            print("기존에 저장한 정보가 있었을 경우")
//                            self.schedules_model[find_idx!].schedule.append(ScheduleInfo(card_idx: schedule_idx, type: "personal", schedule_date: schedule_date_form, schedule_name: title, tag_color: Color.yellow, start_time: schedule_time_form, end_time: schedule_time_form, category: "", current_people: "", location_name: "", is_private: false, memo: content))
//                            print("내 일정 추가한 후 저장한 정보 확인: \(self.schedules_model[find_idx!])")
                            
                            let model_idx = String(find_idx!)
                            var schedule_info : [ScheduleInfo] = []
                            schedule_info.append(ScheduleInfo(card_idx: schedule_idx, type: "personal", schedule_date: schedule_date_form, schedule_name: title, tag_color: Color.yellow, start_time: schedule_date_form, end_time: schedule_date_form, category: "personal", current_people: "-1", location_name: "", is_private: false, memo: content))
                            
                            NotificationCenter.default.post(name: Notification.calendar_personal_schedule, object: nil, userInfo: ["add_calendar_schedule" : "already_exist_ok", "data" : schedule_info, "model_idx" : model_idx])
                            
                        //기존에 일정이 등록되지 않아서 모델에 저장된 데이터가 없었을 경우
                        }else{
                            print("기존에 저장한 정보가 없었을 경우")
                            
                            var schedule_info : [ScheduleInfo] = []
                            schedule_info.append(ScheduleInfo(card_idx: schedule_idx, type: "personal", schedule_date: schedule_date_form, schedule_name: title, tag_color: Color.yellow, start_time: schedule_date_form, end_time: schedule_date_form, category: "personal", current_people: "-1", location_name: "", is_private: false, memo: content))
                            
//                            let schedule_date = self.make_date(expiration: schedule_date)
//                            self.schedules_model.append(Schedule(date: schedule_date, like_num: -1, liked_myself: false, like_idx: -1, schedule: schedule_info))
                            
                            NotificationCenter.default.post(name: Notification.calendar_personal_schedule, object: nil, userInfo: ["add_calendar_schedule" : "new_ok", "data" : schedule_info, "schedule_date" : schedule_date])
                        }
                        
//                        self.schedule_start_date = Date()
//                        self.schedule_start_time = Date()
                    }
                }
            })
    }
    //내 일정 시간만 서버에서 받을 때 다시 date형식으로 변환하기 위해 사용.
    func string_to_time(time: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let date = formatter.date(from: time)
        return date!
    }
    
    //캘린더 - 내 일정 리스트 가져오기
    func get_personal_schedules(user_idx: Int, date_start: String, date_end: String){
        cancellation = APIClient.get_personal_schedules(user_idx: user_idx, date_start: date_start, date_end: date_end)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("내 일정 리스트 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("내 일정 리스트 가져오기 response: \(response)")
                
                let result = response["result"].string
                if result != "no result"{
                
                let response = response.array

                if response == response{
                    
                for schedule in response!{
                    
                    let schedule_idx = schedule["idx"].intValue
                    let title = schedule["title"].stringValue
                    
                    let content = schedule["content"].stringValue
                    let schedule_date = schedule["schedule_date"].stringValue
                    let schedule_start_time = schedule["schedule_start_time"].stringValue
                    //print("스케줄 시간 딕셔너리 확인: \(schedule_start_time)")
                    
                    var find_idx: Int? = -1
                    find_idx = self.schedules_model.firstIndex(where: {
                        let date = self.date_to_string(date: $0.date).split(separator: " ")[0]
                        return date == schedule_date
                    }) ?? -1
                   // print("기존 모델 배열 index 찾았는지 확인: \(find_idx)")
                    
                    //저장에 맞는 형식으로 날짜, 시간 변환
                    let schedule_date_form = self.make_date(expiration: schedule_date)
                    let schedule_time_form = self.make_time_date(time: schedule_start_time)
                    
                    //기존에 저장된 데이터가 있을 경우
                    if find_idx != -1{
                        print("기존 저장된 카드 이벤트 있어서 일정 정보 추가로 저장.")
                        self.schedules_model[find_idx!].schedule.append(ScheduleInfo(card_idx: schedule_idx, type: "personal", schedule_date: schedule_date_form, schedule_name: title, tag_color: Color.yellow, start_time: schedule_time_form, end_time: schedule_time_form, category: "", current_people: "", location_name: "", is_private: false, memo: content))
                        
                    //새롭게 데이터를 저장해야할 경우
                    }else{
                        print("새롭게 일정 정보 저장.")
                        var schedule_info: [ScheduleInfo] = []
                        schedule_info.append(ScheduleInfo(card_idx: schedule_idx, type: "personal", schedule_date: schedule_date_form, schedule_name: title, tag_color: Color.yellow, start_time: schedule_time_form, end_time: schedule_time_form, category: "", current_people: "", location_name: "", is_private: false, memo: content))
                        
                        self.schedules_model.append(Schedule(date: schedule_date_form, like_num: 0, liked_myself: false, like_idx: -1, schedule: schedule_info))
                    }
                }
                    print("내 일정 정보까지 저장 완료")
                }
                }else{
                    print("결과가 없을 때")
                }
            })
    }
    
    //캘린더 - 내 일정 편집하기
    func edit_personal_schedule(previous_date: String
                                ,schedule_idx: Int, title: String, content: String, schedule_date: String, schedule_start_time: String){
        cancellation = APIClient.edit_personal_schedule(schedule_idx: schedule_idx, title: title,content: content, schedule_date: schedule_date, schedule_start_time: schedule_start_time)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 내 일정편집하기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("내 일정 편집하기 response: \(response)")
                
                let result = response["result"].string
                if result == "ok"{
                    print("내 일정 편집하기 ok")
                    
                    //저장 전 시간, 날짜를 date형식으로 모두 바꾸기
                    //make_date: 시간이 없는 날짜만 있는 string을 date형태로 변환메소드.
                    let date_form = self.make_date(expiration: schedule_date)
                    let time_form = self.string_to_time(time: schedule_start_time)
                    /*
                     1.이전 데이터 삭제
                      1)previous_date를 이용해 schedule모델 배열의 index를 찾고
                      2)위에서 찾은 index이용해 schedule_info배열에서 schedule_idx가 같은 index를 가져온다.
                      3)날짜가 변동됐을 수 있으므로 기존 데이터 삭제
                     2.schedule_date와 일치하는 곳에 다시 저장한다.
                      1)schedule_date이용해 schedule모델 배열에서 일치하는 idx값 찾기
                      2)저장.
                     */
                    print("이전 날짜: \(previous_date), 새로운 날짜: \(schedule_date)")
                    let schedule_model_idx = self.schedules_model.firstIndex(where: {
                        let string_date =  self.date_to_string(date: $0.date)
                        return string_date == previous_date
                    })
                   //1-2)위에서 찾은 idx로 수정한 schedule_info idx를 가져온다.
                    let schedule_info_idx = self.schedules_model[schedule_model_idx!].schedule.firstIndex(where: {
                        //schedule_info모델에 개인일정의 schedule idx는 card idx에 저장돼 있음.
                        $0.card_idx == schedule_idx
                    })
                    //1-3).기존 데이터 삭제
                    self.schedules_model[schedule_model_idx!].schedule.remove(at: schedule_info_idx!)
                    
                    //2-1)
                    var new_model_idx : Int? = -1
                    new_model_idx = self.schedules_model.firstIndex(where: {
                        let string_date =  self.date_to_string(date: $0.date)
                        return string_date == schedule_date
                    }) ?? -1
                    
                    //2-2)schedule_info에 저장.
                    //기존에 저장된 데이터가 있었을 경우
                    if new_model_idx != -1{
                        
                    self.schedules_model[new_model_idx!].schedule.append(ScheduleInfo(card_idx: schedule_idx, type: "personal", schedule_date: date_form, schedule_name: title, tag_color: Color.yellow, start_time: time_form, end_time: time_form, category: "", tags: [], current_people: "", location_name: "", is_private: false, memo: content))
                        
                    //새롭게 데이터 저장하는 경우
                    }else{
                        var schedule_info : [ScheduleInfo] = []
                        schedule_info.append(ScheduleInfo(card_idx: schedule_idx, type: "personal", schedule_date: date_form, schedule_name: title, tag_color: Color.yellow, start_time: time_form, end_time: time_form, category: "", tags: [], current_people: "", location_name: "", is_private: false, memo: content))
                        
                        self.schedules_model.append(Schedule(date: date_form, like_num: 0, liked_myself: false, like_idx: -1, schedule: schedule_info))
                        
                    }
                    
                }else{
                    print("내 일정 편집하기 response ok 아님")
                }
            })
    }
    
    //캘린더 - 내 일정 삭제하기(schedule_date는 삭제시 schedule모델에서 날짜 찾기 위함.)
    func delete_personal_schedule(schedule_date: String
                                  ,schedule_idx: Int){
        cancellation = APIClient.delete_personal_schedule(schedule_idx: schedule_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 내 일정 삭제 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("내 일정 삭제 response: \(response)")
                
                let result = response["result"].string
                if result == "ok"{
                    print("내 일정 삭제 ok")
                    
                //모델에 저장돼 있던 데이터 삭제
                    let delete_idx = self.schedules_model.firstIndex(where: {
                        let string_date =  self.date_to_string(date: $0.date)
                        return string_date == schedule_date
                    })
                    
                    let delete_info_idx = self.schedules_model[delete_idx!].schedule.firstIndex(where: {
                        $0.card_idx == schedule_idx
                    })
                    
                    //모델에서 schedule info삭제하기
                    self.schedules_model[delete_idx!].schedule.remove(at: delete_info_idx!)
                    
                    print("모델에서 데이터까지 삭제 완료: \(self.schedules_model[delete_idx!].schedule.count)")
                    
                }else{
                    print("내 일정 삭제 ok 아님")
                }
            })
    }
        
    //캘린더 - 좋아요,관심있어요 유저 목록에서 친구인지 체크하는 통신
    func check_is_friend(friend_idx: Int) -> String{
        cancellation = APIClient.check_is_friend(friend_idx: friend_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 친구 체크 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("캘린더 친구 체크 통신 response: \(response)")
                
                let result = response["result"].intValue
                print("결과 꺼내옴: \(result)")
                //주인 정보는 다이얼로그 또는 bottom tabview, 카드 상세 페이지에서 미리 저장함.
                print("캘린더 저장된 주인 정보 확인: \(self.calendar_owner)")
                
                ///친구가 아닐 경우 피드 페이지 : 달력 보여주지 않고 친구 신청 버튼 놓기.
                if result == -1{
                    print("캘린더 친구 체크 결과 친구 아님")
                    self.check_friend_result = "not_friend"

                ///비공개
                }else if result == 0{
                    self.check_friend_result = "friend_disallow"
                    
                //공개, 자기자신인 경우
                }else if result == 1 || result == -2{
                    print("캘린더 친구 체크 통신 결과 친구")
                    
                    //피드 정보 가져오는 통신 진행.
                    //시작 날짜, 끝날짜 지정.
                    self.calendar_start_date = Calendar.current.date(byAdding: .day, value: -180, to: self.calendar_start_date)!
                    self.calendar_end_date = Calendar.current.date(byAdding: .day, value: 180, to: self.calendar_end_date)!
                    
                    print("카드 정보 가져오는 시작날짜: \(self.calendar_start_date), 끝날짜: \(self.calendar_end_date)")
                    
                    self.get_card_for_calendar(user_idx: self.calendar_owner.user_idx, date_start:  self.date_to_string(date: self.calendar_start_date), date_end:  self.date_to_string(date: self.calendar_end_date
                    ))
                    self.check_friend_result = "friend_allow"
                    
              //이미 친구 신청한 유저
                }else if result == -3{
                    self.check_friend_result = "already_friend_requested"
                }
                
                //카드만 공개
                else{
                    self.check_friend_result = "friend_allow_card"
                    //피드 정보 가져오는 통신 진행.
                    self.get_card_for_calendar(user_idx: self.calendar_owner.user_idx, date_start:  self.date_to_string(date: self.calendar_start_date), date_end:  self.date_to_string(date: self.calendar_end_date
                    ))
                }
            })
        print("친구 체크 통신 결과 후 저장한 값: \(self.check_friend_result)")
        return self.check_friend_result
    }
    
    //캘린더 - 친구 아닌 사람이 친구 신청 버튼 클릭시 요청 통신
    func add_friend_request(f_idx: Int){
        cancellation = APIClient.add_friend_request(f_idx: f_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 친구 요청 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
               print("캘린더에서 친구 요청 통신 response: \(response)")
                  
                if response["result"] == "ok"{
                    
                    self.friend_request_result_alert = .success
                    print("친구추가하기 성공")
                    self.check_friend_result = "already_friend_requested"
                    
                } else if response["result"]  == "no signed friends"{
                    
                    print("친구추가하기 없는 사용자")
                    self.friend_request_result_alert = .no_friends
                    
                }else if response["result"]  == "친구요청대기"{
                    
                    self.friend_request_result_alert = .request_wait
                    print("친구 요청 대기중 : \( self.friend_request_result_alert)")
                    
                }else if response["result"]  == "친구요청뱓음"{
                    
                    print("친구 요청 대기중")
                    self.friend_request_result_alert = .requested
                    
                }else if response["result"]  == "친구상태"{
                    
                    print("이미 친구입니다")
                    self.friend_request_result_alert = .already_friend
                    
                }else if response["result"]  == "자기자신"{
                    
                    print("나자신")
                    self.friend_request_result_alert = .myself
                    
                }else{
                    
                    print("실패")
                    self.friend_request_result_alert = .fail
                }                    
                })
    }
    
    //설정창에서 필요한 데이터 모두 가져오는 통신
    @Published var user_info_model : MyPageModel = MyPageModel(){
        didSet{
            objectWillChange.send()
        }
    }
    
    
    //마이페이지에서 유저 모든 정보를 가져와야 해서 통신.
    func get_detail_user_info(user_idx: Int){
        cancellation = APIClient.get_detail_user_info(user_idx: user_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("유저 모든 정보 가져오기 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("유저 모든 정보 가져오기 response: \(response)")
                
                let result = response.dictionaryValue
                
                if result["result"] == "no result"{
                    print("결과 없을 때")
                }else{
                
                
                let nickname = result["nickname"]?.stringValue
                let password_modify_at = result["password_modify_at"]?.stringValue
                let card_notify_state = result["card_notify_state"]?.intValue
                let chat_notify_state = result["chat_notify_state"]?.intValue
                let password = result["password"]?.stringValue
                let calendar_public_state = result["calendar_public_state"]?.intValue
                let feed_notify_state = result["feed_notify_state"]?.intValue
                let idx = result["idx"]?.intValue
                let phone_number = result["phone_number"]?.stringValue
                let profile_photo_path = result["profile_photo_path"]?.stringValue
               
                self.user_info_model = MyPageModel(nickname: nickname!, password_modify_at: password_modify_at!, card_notify_state: card_notify_state!, chat_notify_state: chat_notify_state!, password: password!, calendar_public_state: calendar_public_state!, feed_notify_state: feed_notify_state!, idx: idx!, phone_number: phone_number!, profile_photo_path: profile_photo_path ?? "")
                print("최종 저장한 유저 정보 모델: \(self.user_info_model)")
                
                NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["got_calendar_alarm_info" : "ok"])
                }
            })
    }
    
    //설정 - 캘린더 공개범위 설정
    func edit_calendar_disclosure_setting(calendar_public_state: Int){
        cancellation = APIClient.edit_calendar_disclosure_setting(calendar_public_state: calendar_public_state)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("캘린더 공개범위 설정 에러 발생 : \(error)")
                case .finished:
                    break
                }
                
            }, receiveValue: {response in
                print("피드에서 캘린더 공개범위 설정 response: \(response)")
                
                let result = response["result"].stringValue
                if result == "ok"{
                    print("ok")
                //result ok 아닐 때 처리 필요한지 생각해보기.
                }else{
                    
                }
            })
    }
    
    //친구 신청 취소
    func cancel_request_friend(f_idx: Int){
        cancellation = APIClient.cancel_request_friend(f_idx: f_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("회원가입 친구 요청 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구 신청 취소 응답: \(response)")
                
                let result : String?
                result = response["result"].string
                let friend_idx = String(f_idx)
                
                if result == "ok"{
                    print("친구 신청 취소 완료")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_feed": "canceled_ok", "friend": friend_idx])
                    
                }else{
                    print("친구 신청 취소 실패")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend_feed": "canceled_fail", "friend": friend_idx])
                    
                }
            })
    }
}


 extension Calendar{
    
    /*
     날짜 한 칸 일정 + 좋아요 뷰
     캘린더 탭 클릭시 카드 이벤트+좋아요 데이터 날짜별로 저장 메소드.
     
     - 기존 라이브러리 코드에서 generateVisits와 같음.
     */
    func make_card_block(start: Date, end: Date, card_block_model: CalendarCardBlockModel, boring_model: BoredDaysModel, like_model: CalendarLikeModel, schedule_info : [SmallScheduleInfo]) -> [SmallSchedule] {
        print("********make card block메소드 들어옴. SmallSchedule만들기 위한 메소드. 데이터 확인 schedule_info: \(schedule_info)")
        print("좋아요 데이터: \(like_model)")
        var schedules = [SmallSchedule]()
        
        enumerateDates(
            startingAfter: start,
            matching: .everyDay,
            matchingPolicy: .nextTime){ date, _, stop in
            
            if let date = date {
                if date < end {
                    /*
                     서버 통신해서 저장된 모델 데이터 중 date와 같은 index가져온 후
                     그 index안에서 title데이터를 smallschedule에 넣어주기
                     - 문제: 서버 통신해서 저장한 데이터 모델을 못 가져옴.-> 뷰모델 안에 메소드 만듬.
                     - index : 친구 카드 또는 그룹 카드 둘 중 한개에서 일치하는 index가 나오므로 optional값으로 만듬.
                     */
                    //print("현재 date 확인: \(date), 마지막 날짜 확인: \(end)")
                    //비교하려는 날짜가 서버에서 받아 저장한 데이터 모델에 있는지 확인. ->있다면 index 가져오는 것.
                    //한 날짜에 일정이 여러개일 수 있으므로 first index를 쓰지 않고 filter,map을 이용해 같은 날짜의 일정이 저장된 index를 가져온다.
                    var friend_idx_array: [String] = []
                    friend_idx_array = card_block_model.friend.public_type.filter({
                        $0.expiration_at?.split(separator: " ")[0] ==
                            date_to_string(date: date).split(separator: " ")[0]
                    }).map({String($0.expiration_at!.split(separator: " ")[0])})
                    
                    var meeting_idx_array: [String] = []
                    meeting_idx_array = card_block_model.meeting.filter({
                        
                        return  $0.expiration_at?.split(separator: " ")[0] ==
                            date_to_string(date: date).split(separator: " ")[0]
                    }).map({String($0.expiration_at!.split(separator: " ")[0])})
                   // print("모임 idx array: \(meeting_idx_array)")
                    //여기까지는 카드 이벤트 관련 인덱스 찾은 것.
                    /*
                     이제는 관심있어요, 좋아요 관련 정보 찾기
                     1.좋아요
                     - 1)그 날짜에 대한 총 좋아요 갯수 찾기
                     - 2)내가 클릭한 좋아요 날짜 정보 찾기
                     2.관심있어요
                     - 1)그 날짜에 대한 총 관심있어요 갯수 찾기
                     - 2)내가 클릭한 관심있어요 날짜 정보 찾기
                     */
                    //---------좋아요 총 갯수에 대한 정보 가져오기 시작
                    var total_like_idx : Int = -1
                    var like_num: Int = -1
                    //모델에 저장됐던 좋아요 갯수가 있으면
                    if !like_model.calendar_like_count.isEmpty{
                        total_like_idx = like_model.calendar_like_count.firstIndex(where:{
                            $0.like_checked_date == date_to_string(date: date).split(separator: " ")[0]
                        }) ?? -1
                        
                        //좋아요 정보가 있을 경우에만 처리
                        if total_like_idx != -1{
                            like_num = like_model.calendar_like_count[total_like_idx].like_count
                        }
                        //print("이 날짜에 대한 좋아요 갯수: 날짜: \(date), \(String(describing: like_num))")
                    }
                    
                    //----------내가 클릭한 좋아요 정보 가져오기 시작
                    var clicked_like_myself_idx: Int = -1
                    var like_myself : Bool = false
                    //내가 클릭한 정보가 있는 경우
                    if !like_model.like_checked_date.isEmpty{
                        let index  = like_model.like_checked_date.firstIndex(where: {
                            $0.like_checked_date == date_to_string(date: date).split(separator: " ")[0]
                        }) ?? -1
                        
                        if index != -1{
                            clicked_like_myself_idx = like_model.like_checked_date[index].idx
                            
                            like_myself = true
                        }
                        print("이 날짜에 내가 좋아요 눌렀는지: \(like_myself)")
                        print("이 날짜에 내가 좋아요 id: \(clicked_like_myself_idx)")
                    }
                    
                    if friend_idx_array.count > 0{
                        
                        for day in friend_idx_array{
                            print("친구 카드 idx 어레이 for문 안: \(day)")
                            let index = card_block_model.friend.public_type.firstIndex(where: {       let compare_date = $0.expiration_at?.split(separator: " ")[0]
                                                                                        return compare_date! == day})
                            
                            let creator_name = card_block_model.friend.public_type[index!].creator?.nickname
                            
                            //schedule model info중의 날짜와 같은 데이터 집어넣기.
                            var input_schedules : [SmallScheduleInfo] = []
                            //현재 date와 일치하는 id저장하는 배열.
                            let schedule_idx_array = schedule_info.filter({
                                
                                let schedule_date = self.date_to_string(date: $0.date)
                                print("string으로 변환한 날짜: \(schedule_date), 지금 비교하고 있는 날: \(date)")
                                return schedule_date == day
                            }).map({$0.date})
                            
                            for one_schedule in schedule_idx_array{
                                //위에서 찾은 id리스트에서 하나의 id가 저장된 index가져오는 것.
                                let s_index = schedule_info.firstIndex(where: {
                                    $0.date == one_schedule
                                })
                                input_schedules.append(SmallScheduleInfo(date: schedule_info[s_index!].date, locationName: schedule_info[s_index!].locationName, tagColor: Color.orange, type: "friend"))
                            }
                            print("인풋 스케줄스 만든 것 확인: \(input_schedules)")
                            
                            //************************************
                            schedules.append(.mock(withDate: date, like_num: like_num, clicked_like_myself: like_myself, like_idx: clicked_like_myself_idx, schedule_info: input_schedules))
                            
                        }
                        
                    }
                    else  if meeting_idx_array.count > 0{
                        //일정이 있는 card idx 배열
                        for day in meeting_idx_array{
                            print("모임 idx 어레이 포문 안: \(day)")
                            //schedule model info중의 날짜와 같은 데이터 집어넣기.
                            var input_schedules : [SmallScheduleInfo] = []
                            
                            let index = card_block_model.meeting.firstIndex(where: {
                                                                                let compare_date = $0.expiration_at?.split(separator: " ")[0]
                                                                                return compare_date! == day})
                            let meeting_name = card_block_model.meeting[index!].expiration_at
                            
                            
                            //현재 date와 일치하는 id저장하는 배열.
                            let schedule_idx_array = schedule_info.filter({
                                
                                let date = self.date_to_string(date: $0.date)
                                return date == day
                            }).map({$0.date})
                            if schedule_idx_array.count > 0{
                                for one_schedule in schedule_idx_array{
                                    //위에서 찾은 id리스트에서 하나의 id가 저장된 index가져오는 것.
                                    let s_index = schedule_info.firstIndex(where: {
                                        $0.date == one_schedule
                                    })
                                    input_schedules.append(SmallScheduleInfo(date: schedule_info[s_index!].date, locationName: schedule_info[s_index!].locationName, tagColor: Color.green, type: "group"))
                                }
                            }
                            //print("1차로 저장한 input schedule: \(input_schedules)")
                            
                            schedules.append(.mock(withDate: date, like_num: like_num, clicked_like_myself: like_myself, like_idx: clicked_like_myself_idx, schedule_info: input_schedules))
                        }
                    }
                    else{
                        //print("일치하는 index 아무것도 없음")
                    }
                }
                else {
                    stop = true
                }
            }
            //print("최종으로 스케줄 데이터 만듬")
        }
        return schedules
    }
    
    func date_to_string(date: Date) -> String{
        let day = DateFormatter.dateformatter.string(from: date)
       // print("date형식: \(date), 변환된 형식: \(day)")
        return day
    }
    
}

fileprivate extension DateComponents {
    
    static var everyDay: DateComponents {
        DateComponents(hour: 0, minute: 0, second: 0)
    }
    
}
