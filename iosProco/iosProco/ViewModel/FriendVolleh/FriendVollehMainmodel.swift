//
//  FriendVollehMainViewmodel.swift
//  proco
//
//  Created by 이은호 on 2020/12/21.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON
import SwiftUI

extension DateFormatter {
    static var dateformatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    static var time_formatter: DateFormatter {
        let time_format = DateFormatter()
        time_format.dateFormat = "hh:mm"
        return time_format
    }
}


class FriendVollehMainmodel.swift: ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    ///---------------------------------Mark : 데이터 모델들---------------------------
    //카테고리 태그
    @Published var volleh_category_tag_struct = [VollehTagCategoryStruct(category_name: "게임/오락"),VollehTagCategoryStruct(category_name: "사교/인맥"), VollehTagCategoryStruct(category_name: "문화/공연/축제"), VollehTagCategoryStruct(category_name: "운동/스포츠"), VollehTagCategoryStruct(category_name: "취미/여가"), VollehTagCategoryStruct(category_name: "스터디")]
    
    //친구랑 볼래 카드 데이터모델
    @Published var friend_volleh_card_struct : [FriendVollehCardStruct] = []{
        willSet {
            objectWillChange.send()
        }
    }
    //내 카드 데이터 모델
    @Published var my_friend_volleh_card_struct :[FriendVollehCardStruct] = []{
        willSet {
            objectWillChange.send()
        }
    }
    
    //친구 리스트 가져온 후 저장하는 모델
    @Published var friend_list_struct : [GetFriendListStruct] = []
    {
        willSet {
            objectWillChange.send()
        }
        
    }
    
    //그룹 리스트 하나당 데이터 갖고 있는 모델
    @Published var manage_groups = [ManageGroupStruct](){
        willSet {
            objectWillChange.send()
        }
        didSet{
            objectWillChange.send()
            
        }
    }
    
    //친구랑 볼래 카드 태그 데이터 모델
    @Published var friend_volleh_tag_struct: [FriendVollehTags] = []{
        willSet {
            objectWillChange.send()
        }
    }
    
    //카드 추가 request할때 사용
    @Published var add_card_struct = AddCardFriendVollehStruct(){
        willSet {
            objectWillChange.send()
        }
    }
    //카드 상세 페이지 데이터 모델
    @Published var friend_volleh_card_detail = FriendVollehCardDeatil(){
        willSet {
            objectWillChange.send()
        }
    }
    ///---------------------------------데이터 모델 끝------------------------------------------
    
    //카드 편집시 사용
    @Published var string_to_date : Date = Date(){
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var string_to_time : Date = Date(){
        willSet {
            objectWillChange.send()
        }
    }
    
    
    ///태그
    //친구랑 볼래 태그 "입력" 텍스트필드 임시 저장값
    @Published var user_input_tag_value : String = ""{
        willSet {
            objectWillChange.send()
        }
    }
    //친구랑 볼래에서 사용자가 "최종 선택한" 태그 리스트를 set으로 저장해놓는 곳.
    @Published var user_selected_tag_set = Set<String>(){
        willSet {
            objectWillChange.send()
        }
    }
    
    //친구랑 볼래에서 사용자가 "최종 선택한" 태그 리스트 set을 배열로 바꿔서 저장.
    @Published var user_selected_tag_list : [String] = []{
        willSet {
            objectWillChange.send()
        }
    }
    
    //*****************************카드 만들기에 사용하는 변수들시작****************************
    //1.시간, 2.태그들 배열 : user_selected_tag_list
    // 3.알릴 친구들 : 1)그룹 = show_card_group_array를 dictionary로 만들기
    //카드 만들기에서 선택한 알릴 친구 모음 Set
    
    ///알릴 친구들
    @Published var show_card_friend_set = Set<Int>(){
        willSet {
            objectWillChange.send()
        }
    }
    //카드 만들기에서 선택한 알릴 그룹 모음 Set
    @Published var show_card_group_set = Set<Int>(){
        willSet {
            objectWillChange.send()
        }
    }
    //카드 만들기에서 선택한 알릴 친구 모음 Set > 배열로 변환 값
    @Published var show_card_friend_array : [Int] = []{
        willSet {
            objectWillChange.send()
        }
    }
    
    //카드 만들기에서 선택한 알릴 그룹 모음 Set > 배열로 변환 값
    @Published var show_card_group_array : [Int] = []{
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var show_card_friend_name : Dictionary<Int , String> = [:]{
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var show_card_group_name : Dictionary<Int , String> = [:]{
        willSet {
            objectWillChange.send()
        }
    }
    
    
    ///카드 설정 날짜 및 시간
    @Published var card_date : Date = Date(){
        willSet {
            objectWillChange.send()
        }
    }
    
    ///카드 만료 시간
    @Published var card_time : Date = Date(){
        willSet {
            objectWillChange.send()
        }
    }
    //카드 만료일 + 시간
    @Published var card_expire_time : String = ""{
        
        willSet {
            objectWillChange.send()
        }
    }
    
    ///타입 : 친구, 그룹.....unique_idx: 친구,그룹의 idx
    @Published var pra : [Dictionary<String , Any>] = []{
        willSet {
            objectWillChange.send()
        }
    }
    
    //친구 리스트 가져오는 통신 성공했을 때 true로 바뀌고 화면 전환됨.
    @Published var got_friend_list_all : Bool = false{
        
        willSet {
            objectWillChange.send()
        }
    }
    //내 닉네임 가져와서 메인 페이지에서 내 카드만 보여줄 때 사용.
    @Published var my_nickname = ""{
        willSet {
            objectWillChange.send()
        }
    }
    //카드 리스트중 선택한 카드 idx값 저장.
    @Published var selected_card_idx : Int = 99 {
        willSet {
            objectWillChange.send()
        }
    }
    
    
    
    //내 아이디 갖고옴.
    func get_my_nickname(){
        self.my_nickname = UserDefaults.standard.string(forKey: "user_nickname")!
    }
    
    //카드 만들기에서 파라미터로 share_list보낼 때 데이터 형식 맞추기 위해 실행하는 메소드
    func make_dictionary(){
        
        for group_idx in self.show_card_group_array{
            let object = ["type" : "group", "unique_idx" : group_idx] as [String : Any]
            self.pra.append(object as [String : Any])
        }
        
        for friend_idx in self.show_card_friend_array{
            let object2 = ["type" : "friend", "unique_idx" : friend_idx]as [String : Any]
            self.pra.append(object2 as [String : Any])
        }
    }
    
    //카드 만들기에서 날짜 형식 맞춰서 보내기 위해 실행하는 메소드
    func make_card_date() -> String{
        let day = DateFormatter.dateformatter.string(from: self.card_date)
        let time = DateFormatter.time_formatter.string(from: self.card_time)
        self.card_expire_time = day + " "+time
        return self.card_expire_time
    }
    
    func change_date(my_day : String) -> Date{
       
        return DateFormatter.dateformatter.date(from: my_day) ?? Date()
         
    }
    
    
    func change_time(my_time: String) -> Date{
        return DateFormatter.time_formatter.date(from: my_time) ?? Date()
         
    }
    
    func string_to_date(expiration: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        var date = formatter.date(from: expiration)
        return date!
    }
    
    func string_to_time(expiration: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
       // formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        var date = formatter.date(from: expiration)
        return date!
    }
    //**********************************************************************************
    //카드 만들기
    func make_card_friend_volleh(){
        cancellation = APIClient.make_card_friend_volleh(type: "지금볼래", time: self.card_expire_time, tags: self.user_selected_tag_list, share_list: self.pra)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구랑 볼래 카드 만들기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구랑 볼래 카드 만들기 결과값 : \(response)")
            })
    }
    
    //친구랑 볼래 카드 리스트 가져오기 이때 내가 만든 카드, 친구가 만든 카드로 나눠서 저장.
    func get_friend_volleh_cards(){
        cancellation = APIClient.get_friend_volleh_card_list_api()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구랑 볼래 카드 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구랑 볼래 카드 리스트 가져오기 결과값 : \(response.count)")
                
                var my_count = 0
                for card in response{
                    
                    if my_count < response.count {
                        my_count = my_count + 1
                        
                        print("포문 안 횟수 : \(my_count)")
                        
                        if card.creator.nickname == self.my_nickname{
                            
                            self.my_friend_volleh_card_struct.append(FriendVollehCardStruct(card_idx: card.card_idx, kinds: card.kinds, expiration_at: card.expiration_at, tags: card.tags, creator: card.creator, offset: 0.0))
                            
                        }else{
                            self.friend_volleh_card_struct.append(FriendVollehCardStruct(card_idx: card.card_idx, kinds: card.kinds, expiration_at: card.expiration_at, tags: card.tags, creator: card.creator, offset: 0.0))
                            
                            print("친구랑 볼래 카드 데이터로 들어옴")
                        }
                    }
                    print("포문 마지막 줄")
                }
                print("포문 나감")
            })
    }
    
    //카드 설정시 알릴 친구 선택하기에 사용할 친구리스트 가져오기
    func get_all_people(){
        //친구 리스트 먼저 가져옴.
        cancellation = APIClient.get_friend_list_api(friend_type: "친구상태")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("메인에서 sink후 친구 리스트 가져올 때 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                
                print("메인에서 친구 리스트 가져오는 뷰모델의 receive value값 : \(String(describing: response))")
                //있는 데이터 제거 후 추가
                self.friend_list_struct.removeAll()
                
                for friend in response{
                    
                    if friend.nickname != nil{
                        
                        self.friend_list_struct.append(GetFriendListStruct(result: friend.result, idx: friend.idx!, nickname: friend.nickname!, profile_photo: friend.profile_photo, state: friend.state))
                    }
                }
                self.got_friend_list_all.toggle()
            })
    }
    
    //카드 설정시 사용할 그룹 리스트 가져오기
    func get_all_groups(){
        cancellation = APIClient.get_all_manage_group()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:
                    {result in
                        switch result{
                        case .failure(let error):
                            print("그룹 리스트만 가져오는 데 에러 발생 : \(error)")
                        case .finished:
                            break
                        }
                    }
                  , receiveValue: {(response) in
                    //그룹 리스트 업데이트 된 경우 다시 가져와야하므로 기존의 모델에 있던 데이터삭제 후 다시 append
                    self.manage_groups.removeAll()
                    print("그룹 리스트만 가져오는 데 받은 value값 : \(response)")
                    
                    for group in response{
                        
                        if group.name != nil{
                            self.manage_groups.append(ManageGroupStruct(result: group.result, idx: group.idx!, name: group.name!))
                            //print("그룹 데이터만 가져와서 추가 확인 : \(String(describing: group.name!))")
                        }
                    }
                  })
    }
    
    func edit_my_card(){
        cancellation = APIClient.edit_friend_volleh_card(card_idx: self.selected_card_idx, type: "지금볼래", time: self.card_expire_time, tags: self.user_selected_tag_list, share_list: self.pra)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("친구랑 볼래 카드 편집에서 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("친구랑 볼래 카드 편집 결과값 : \(response)")
            })
    }
    //카드 클릭시 상세 페이지 이동 위한 카드 정보 가져오기
    func get_card_detail(){
        cancellation = APIClient.get_card_info_friend_volleh(card_idx: self.selected_card_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("카드 상세 데이터 가져오는 데 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }
            , receiveValue: {response in
                print("카드 상세 데이터 가져온 것 확인 : \(response)")
                
                self.friend_volleh_card_detail.card_idx = response.card_idx
                self.friend_volleh_card_detail.expiration_at = response.expiration_at
                print("만료날짜 원래 데이터 확인 : \(response.expiration_at)")
                
                let first_filtered_day = self.string_to_date(expiration: response.expiration_at)
                print("날짜 변환했는지 확인 : \(first_filtered_day)")
                self.card_date = first_filtered_day
                
                print("시간 변환 전에 스플릿 확인 : \(response.expiration_at.split(separator: " ")[1]))")
                let time_filtered = self.string_to_time(expiration: String(response.expiration_at.split(separator: " ")[1]))
                self.card_time = time_filtered
                print("시간 변환 확인 : \(self.card_time)")
                
                self.friend_volleh_card_detail.kinds = response.kinds
                self.friend_volleh_card_detail.share_list = response.share_list
                self.friend_volleh_card_detail.tags = response.tags
                
                //태그 set, array에 이름 저장
                if response.tags != nil{
                    for tag in response.tags!{
                        self.user_selected_tag_set.insert(tag.tag_name)
                        self.user_selected_tag_list.append(tag.tag_name)
                    }}
                
                //알릴 사람들 set, array, dictionary에 저장
                if response.share_list != nil{
                    print("카드 상세 데이터 share_list 널 아닐 때")
                    for person in response.share_list!{
                        if person.idx_kinds == "friend"{
                            self.show_card_friend_set.insert(person.unique_idx)
                            self.show_card_friend_array.append(person.unique_idx)
                            self.show_card_friend_name.updateValue(person.name, forKey: person.unique_idx)
                            
                        }
                        print("알릴 그룹 set 저장됐는지 확인 : \( self.show_card_friend_set)")
                        if person.idx_kinds == "group"{
                            self.show_card_group_set.insert(person.unique_idx)
                            self.show_card_group_array.append(person.unique_idx)
                            self.show_card_group_name.updateValue(person.name, forKey: person.unique_idx)
                        }
                    }
                    print("알릴 친구들 저장됐는지 확인 : \(self.show_card_group_name)")
                }
                
                
            })
    }

    
}
