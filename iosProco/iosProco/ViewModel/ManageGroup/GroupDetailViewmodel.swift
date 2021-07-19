//
//  GroupDetailViewmodel.swift
//  proco
//
//  Created by 이은호 on 2020/12/16.
//

import Foundation
import Combine
import Alamofire
import SwiftyJSON


class GroupDetailViewmodel: ObservableObject{
    
    let objectWillChange = ObservableObjectPublisher()
    
    //전체 친구 struct
    @Published var friend_list_struct : [GetFriendListStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    //그룹 리스트에서 상세 페이지로 이동
    @Published var exit_to_detail_page : Bool = false{
        didSet{
            objectWillChange.send()
        }
    }
    
    //그룹 상세 페이지에 사용되는 친구 멤버
    @Published var group_details : [GroupDetailStruct] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    var cancellation: AnyCancellable?
    
    //그룹 이름 편집시 이곳에 데이터 저장.그리고 그룹 리스트 중 상세 그룹페이지로이동시 선택한 그룹 이름도 이곳에 저장.
    @Published var edit_group_name : String = ""{
        didSet{
            print("그룹 이름 편집 didset들어옴 : \(edit_group_name)")
            objectWillChange.send()
        }
    }
    
    //편집하려는 그룹 idx를 저장해놓음.
    @Published var edit_group_idx: Int = -1{
        didSet{
            objectWillChange.send()
            print("그룹 idx 편집 didset들어옴 : \(edit_group_idx)")
        }
    }
    
    //그룹 멤버 편집 완료시 사용하는 구분값
    @Published var edit_group_member_ok : Bool = false{
        didSet{
            objectWillChange.send()
            
        }
    }
    
    //그룹 멤버 편집에서 선택하는 친구들 리스트
    @Published var selected_friend_set = Set<Int>(){
        didSet{
            objectWillChange.send()
            
        }
    }
    
    //그룹 멤버 편집시 우선 여기에 담아놓은 후 확인 버튼 클릭했을 대 selected_friend_set에 넣기. 그래야 index out of range에러 안뜸
    @Published var temp_selected_friend_set = Set<Int>(){
        didSet{
            objectWillChange.send()
            
        }
    }
    
    //그룹 멤버 편집 후 업데이트된 친구 리스트.. 서버에 보낼 데이터 형식
    @Published var updated_friend_list : [Int] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var go_to_edit_friend: Bool = false{
        didSet{
            objectWillChange.send()
            
        }
    }
    
    //그룹 멤버 편집에서 선택한 친구들만 보여줄 때 foreach에서 갯수와 리스트를 알기 위해 사용함.
    func show_selected_member() ->  [GroupDetailStruct]{
        var filtered_array :  [GroupDetailStruct] = []
        filtered_array = self.group_details.filter{(selected_friend_set.contains($0.idx!)
        )}
        print("필터된 편집하는 친구 목록 확인: \(filtered_array)")
        return filtered_array
    }
    
    //그룹관리 - 그룹 이름 편집통신
    func edit_group_name_and_fetch(group_idx: Int, group_name: String){
        cancellation = APIClient.edit_group_name_api(group_idx: group_idx, group_name: group_name)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("그룹 이름 편집 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue:{ (response)in
                print("그룹 이름 편집 통신 확인 : \(response)")
                if response["result"].string == "ok"{
                    
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["edited_group_name" : "ok"])
                }else{
                    //그룹 이름 편집 안됐다는 예외처리하기*************************alert창
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["edited_group_name" : "fail"])
                }
            })
    }
    
    //그룹 상세 페이지 친구 목록 가져오는 데이터 통신 코드
    func get_group_detail_and_fetch(group_idx: Int){
        cancellation = APIClient.get_group_detail_api(group_idx: group_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:
                    {result in
                        switch result{
                        case .failure(let error):
                            print("그룹 상세 데이터 가져오는 데 에러 발생 : \(error)")
                        case .finished:
                            break
                        }
                    }
                  , receiveValue: {[weak self](response) in
                    print("그룹 상세 데이터 가져오는 데 받은 value값 : \(response)")
                    //이부분 안 넣어서 계속 오류 났었음. 기존의 친구들은 삭제하고 다시 넣는 식으로 로직 구성.
                    self!.selected_friend_set.removeAll()
                    self?.temp_selected_friend_set.removeAll()
                    self!.group_details.removeAll()
                    
                    for item in response{
                        if item.nickname != nil{
                            self?.group_details.append(GroupDetailStruct(result: item.result, idx: item.idx!, nickname: item.nickname!, profile_photo_path: item.profile_photo_path))
                            
                            //그룹내 속한 친구 목록이 친구 편집시 필요하므로 이때 저장.
                            self!.selected_friend_set.insert(item.idx!)
                            self!.temp_selected_friend_set.insert(item.idx!)
                            
                            print("그룹 상세 데이터 추가 되는 것 확인 : \(String(describing: item.nickname!))")
                        }
                    }
                    print("그룹 상세 데이터 추가됐는지 다시 확인하기 : \(String(describing: self?.group_details))")
                    print("그룹 관리 상세 페이지에서 temp_selected_friend_set: \(self?.temp_selected_friend_set)")
                    
                    print("그룹 관리 상세 페이지에서 selected_friend_set: \(self?.selected_friend_set)")
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["get_group_friend" : "ok"])
                  })
        
    }
    
    //그룹에 친구 편집 클릭시 "모든" 친구 리스트 가져오기 위해 하는 통신
    func get_friend_list_and_fetch(){
        cancellation = APIClient.get_friend_list_api(friend_type: "친구상태")
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                print("sink 결과 : \(result)")
                switch result {
                case .failure(let error):
                    print("sink후 친구 리스트 가져올 때 에러 발생: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {(response) in
                print("친구 편집 뷰모델의 receive value값 : \(String(describing: response))")
                //모두 제거하고 다시 가져오기
                self.friend_list_struct.removeAll()
                
                for friend in response{
                    if friend.nickname != nil{
                        self.friend_list_struct.append(GetFriendListStruct(idx: friend.idx, nickname: friend.nickname!, profile_photo: friend.profile_photo ?? "", state: friend.state, kinds: friend.kinds))
                        
                        self.group_details.append(GroupDetailStruct(idx: friend.idx, nickname: friend.nickname!, profile_photo_path: friend.profile_photo ?? ""))
                    }
                    print("통신 후 set에 데이터 추가 확인 : \(self.selected_friend_set)")
                }
                
                //친구 수를 노티를 이용하는 이유는 친구 수락 또는 거절시 친구 수를 state로 동적으로 변화시키기 위함.
                NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["got_all_friend_detail" : "ok"])
                
            })
    }
    
    //그룹 멤버 편집 후 업데이트 위한 통신
    func edit_group_member(group_idx: Int, friends_idx: Array<Any>){
        cancellation = APIClient.edit_group_member_api(group_idx: group_idx, friends_idx: friends_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("그룹 멤버 편집 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue:{ (response)in
                print("그룹 멤버 편집 통신 확인 : \(response)")
                if response["result"].string == "ok"{
                    //temp_selected_friend_set에 넣었던 것 다시 selected_friend_set에 넣기
                    print("temp_selected_friend_set 확인: \(self.temp_selected_friend_set)")
                    
                    self.selected_friend_set.removeAll()
                    self.selected_friend_set = self.temp_selected_friend_set
                    print("그룹 멤버 편집 뷰에서 업데이트한 친구 리스트 확인 : \(self.selected_friend_set)")
                    
                    self.edit_group_member_ok.toggle()
                    print("그룹 멤버 편집 통신 완료, 토글 값 : \( self.edit_group_member_ok)")
                    
                }else{
                    //그룹 이름 편집 안됐다는 예외처리하기*************************alert창
                    self.edit_group_member_ok = false
                    
                }
            })
    }
    
    //친구관리-그룹삭제 통신
    func delete_group(group_idx: Int){
        cancellation = APIClient.delete_group_api(group_idx: group_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("그룹 멤버 삭제 통신 에러 발생 : \(error)")
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["delete_group" : "fail"])
                case .finished:
                    break
                }
            }, receiveValue:{ (response)in
                print("그룹 삭제 통신 확인 : \(response)")
                if response["result"].string == "ok"{
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["delete_group" : "ok"])
                }else{
                    print("그룹 삭제 통신 실패")
                    //그룹 이름 편집 안됐다는 예외처리하기*************************alert창
                    NotificationCenter.default.post(name: Notification.get_data_finish, object: nil, userInfo: ["delete_group" : "fail"])
                }
            })
    }
    
    
    
    
}
