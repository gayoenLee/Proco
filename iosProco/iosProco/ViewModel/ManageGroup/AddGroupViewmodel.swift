//
//  AddGroupViewmodel.swift
//  proco
//
//  Created by 이은호 on 2020/12/14.
// 친구관리 - 그룹추가시 사용하는 뷰모델

import Foundation
import Combine
import Alamofire
import SwiftyJSON

//set을 array로 바꾸는 extension
extension Array where Element: Hashable {
    func convert() -> [Element]{
        let set = Set(self)
        return Array(set)
    }
}

class AddGroupViewmodel: ObservableObject{
    
    let objectWillChange = ObservableObjectPublisher()
    //친구 리스트 가져온 후 저장하는 모델
    @Published var friend_list_struct : [GetFriendListStruct] = []{
        didSet {
            objectWillChange.send()
        }
    }
    //만들려는 그룹 이름 저장하는 변수
    @Published var input_group_name : String = ""{
        didSet {
            objectWillChange.send()
        }
    }
    //그룹에 넣으려는 친구 리스트 최종 배열값.
    @Published var added_friend_list  : [Int] = []{
        didSet {
            objectWillChange.send()
        }
    }
    
    //그룹 추가페이지 - 친구 추가시 추가한 친구 리스트들 set으로 임시로 넣어놓는 곳.
    //set으로 넣으면 중복값은 자동으로 삭제해줘서 좋다.
    @Published var selected_friend_set = Set<Int>(){
        didSet {
            objectWillChange.send()
        }
    }

    //1.그룹 관리 메인 - 그룹 추가 버튼 클릭시 그룹 추가 페이지로 이동할 때 사용
    @Published var go_to_add_group : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
    
    //2.그룹 추가 페이지 - 친구 추가 페이지로 이동할 때 사용
    @Published var go_to_add_friend : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
   
    //3.그룹 추가 완료시 다시 메인으로 이동시키기 위해 사용하는 변수
    @Published var add_group_ok : Bool = false{
        didSet {
            objectWillChange.send()
        }
    }
    var cancellation : AnyCancellable?
    
    //그룹 추가하기
    func add_group(){
        APIClient.add_group_api(group_name: self.input_group_name, friends_idx: self.added_friend_list, completion: {result in
            switch result{
            case .success(let result):
                print("그룹 추가 결과 : \(result)")
                if result.result == "ok"{
                    
                    self.add_group_ok = true
                    self.input_group_name = ""
                    self.selected_friend_set.removeAll()
                    
                    NotificationCenter.default.post(name: Notification.event_finished, object: nil, userInfo: ["add_group": "ok"])
                    
                    //그룹 추가에 실패했을 경우 예외처리
                }else if result.result == "group_name duplicated"{
                    NotificationCenter.default.post(name: Notification.event_finished, object: nil, userInfo: ["add_group": "group_name duplicated"])
                    
                }else{
                    self.add_group_ok = false
                    NotificationCenter.default.post(name: Notification.event_finished, object: nil, userInfo: ["add_group": "error"])
                }
            case .failure(let error):
                print("그룹 추가 에러 : \(error)")
                self.add_group_ok = false
                NotificationCenter.default.post(name: Notification.event_finished, object: nil, userInfo: ["add_group": "error"])

            }
        })
    }
    
    //그룹 추가에서 선택한 친구들만 보여줄 때 foreach에서 갯수와 리스트를 알기 위해 사용함.
    func show_selected_member() -> [GetFriendListStruct] {
        var filtered_array :  [GetFriendListStruct] = []
         filtered_array = friend_list_struct.filter{(selected_friend_set.contains($0.idx!)
        )}
        print("필터된 친구 리스트: \(filtered_array)")
        return filtered_array
    }
    
    //전체 친구 목록 가져오기
    func fetch_friend_list(){
        cancellation = APIClient.get_friend_list_api(friend_type: "친구상태")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("add group viewmodel에서 가져올 때 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("add group viewmodel에서 친구 목록 가져온 response : \(String(describing: response))")
                
                //있는 데이터 제거 후 추가
                self.friend_list_struct.removeAll()
                
                for friend in response{
                    if friend.nickname != nil{
                        self.friend_list_struct.append(GetFriendListStruct(result: friend.result, idx: friend.idx, nickname: friend.nickname!, profile_photo_path: friend.profile_photo_path, state: friend.state))
                        print("add group viewmodel에서 데이터 추가 확인 : \(friend.nickname!)")
                    }
                }
            })
    }
}

