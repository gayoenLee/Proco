//
//  SignupInviteListViewModel.swift
//  proco
//
//  Created by 이은호 on 2021/07/21.
//

import Foundation
import Combine
import Alamofire
import Contacts

class SignupInviteListViewModel: ObservableObject{
    let objectWillChange = ObservableObjectPublisher()
    var cancellation : AnyCancellable?
    
    
    @Published var contacts_model : [FetchedContactModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //전체 연락처 가져오기
        func getContacts(){
            // 1.
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { (granted, error) in
                if let error = error {
                    print("주소록 권한 요청에 실패", error)
                    return
                }
                if granted {
                    // 2.
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    do {
                        // 3.
                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                            print("핸드폰 번호: \(contact.phoneNumbers.first?.value.stringValue ?? "")")
                            print("이름: \(contact.familyName)\(contact.givenName)")
                            
                            let my_friend_phone = contact.phoneNumbers.first?.value.stringValue.replacingOccurrences(of: "-", with: "")
                            print("형식 통일한 전화번호: \(String(describing: my_friend_phone))")
                            
                            let my_idx = UserDefaults.standard.string(forKey: "user_id")!
                            
                            //이미 초대 문자 보낸 친구 저장된 값 꺼내오기
                            let sent_invite_friends = UserDefaults.standard.array(forKey: "\(my_idx)_invited_friends") as? [String] ?? []
                            
                            //주소록에 등록된 정보중 전화번호가 없는 경우도 있음.
                            if my_friend_phone != nil{
                                //이미 초대 문자 보낸 친구 : sent invite msg값 true
                                if sent_invite_friends.contains(where: {
                                                                    print("값 확이니ㅣㅣ: \($0)")
                                                                  return  $0 == my_friend_phone!}){
                                    
                                    print("전화번호 포함하고 있음: \(my_friend_phone!)")

                                    self.contacts_model.append(FetchedContactModel(firstName: contact.givenName, lastName: contact.familyName, telephone: my_friend_phone ?? "", profile_photo_path: "", sent_invite_msg: true))
                                    print("데이터 바꼈는지: \(self.contacts_model)")
                                    
                                }else{
                                self.contacts_model.append(FetchedContactModel(firstName: contact.givenName, lastName: contact.familyName, telephone: my_friend_phone ?? "", profile_photo_path: "", sent_invite_msg: false))
                                }
                            }
                            
                        })

                    } catch let error {
                        print("전화번호 가져오는데 실패", error)
                    }
                } else {
                    print("접근 거부됨.")
                }
            }
        }
    //연락처가져오기
    func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("주소록 권한 요청에 실패", error)
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        print("핸드폰 번호: \(contact.phoneNumbers.first?.value.stringValue ?? "")")
                        print("이름: \(contact.familyName)\(contact.givenName)")
                        
                        let my_friend_phone = contact.phoneNumbers.first?.value.stringValue.replacingOccurrences(of: "-", with: "")
                        print("형식 통일한 전화번호: \(String(describing: my_friend_phone))")
                        
                        let my_idx = UserDefaults.standard.string(forKey: "user_id")!
                        
                        //이미 초대 문자 보낸 친구 저장된 값 꺼내오기
                        let sent_invite_friends = UserDefaults.standard.array(forKey: "\(my_idx)_invited_friends") as? [String] ?? []
                        
                        //주소록에 등록된 정보중 전화번호가 없는 경우도 있음.
                        if my_friend_phone != nil{
                            //이미 초대 문자 보낸 친구 : sent invite msg값 true
                            if sent_invite_friends.contains(where: {
                                                                print("값 확이니ㅣㅣ: \($0)")
                                                              return  $0 == my_friend_phone!}){
                                
                                print("전화번호 포함하고 있음: \(my_friend_phone!)")

                                self.contacts_model.append(FetchedContactModel(firstName: contact.givenName, lastName: contact.familyName, telephone: my_friend_phone ?? "", profile_photo_path: "", sent_invite_msg: true))
                                print("데이터 바꼈는지: \(self.contacts_model)")
                                
                            }else{
                            
                            self.contacts_model.append(FetchedContactModel(firstName: contact.givenName, lastName: contact.familyName, telephone: my_friend_phone ?? "", profile_photo_path: "", sent_invite_msg: false))
                            }
                        }
                        
                        for enrolled_friend in self.enrolled_friends_model{
                            print("비교하는 친구 한 명: \(enrolled_friend.phone_number)")
                            
                            if my_friend_phone ?? "" == enrolled_friend.phone_number{
                                print("같은 전화번호")
                                self.contacts_model.removeAll(where: {$0.telephone == enrolled_friend.phone_number})
                            }
                        }
                    })
                    
                    //서버에서 가져온 친구 리스트, 내 주소록 기반 연락처 리스트 비교해서 서버에서 가져온 리스트에 포함이 안된 경우 -> contacts_model에 넣기.
                    
                } catch let error {
                    print("전화번호 가져오는데 실패", error)
                }
            } else {
                print("접근 거부됨.")
            }
        }
    }
    
    @Published var enrolled_friends_model : [EnrolledFriendsModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    //내 친구들 중 이미 앱에 가입한 친구리스트 가져오기
    func get_enrolled_friends(contacts: Array<Any>){
        cancellation = APIClient.get_enrolled_friends(contacts: contacts)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("이미 앱에 가입한 친구리스트 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("이미 앱에 가입한 친구리스트 가져오기 response: \(response)")
                let result = response["result"].string
                if result == "ok"{
                    print("가입된 친구 없음")
                }
                
                let list = response.array
                print("체크: \(String(describing: list))")
                if list?.count ?? 0 > 0{
                    print("가입된 친구가 있는 경우")
                    self.enrolled_friends_model.removeAll()
                    let friends = response.arrayValue
                    
                    for friend in friends{
                        
                        let idx = friend["idx"].intValue
                        let nickname = friend["nickname"].stringValue
                        let profile_img = friend["profile_photo_path"].stringValue
                        let phone_number = friend["phone_number"].stringValue
                        
                        self.enrolled_friends_model.append(EnrolledFriendsModel(idx: idx, nickname: nickname, profile_photo_path: profile_img, phone_number: phone_number))
                    }
                    print("최종 저장한 등록된 친구들 모델: \(self.enrolled_friends_model)")
                }
                //내 주소록에 등록된 연락처 친구 리스트 가져오기
                //self.fetchContacts()
            })
    }
    
    //회원가입시 친구들에게 초대 문자 보내기
    func send_invite_message(contacts: Array<Any>){
        cancellation = APIClient.send_invite_message(contacts: contacts)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("회원가입시 친구들에게 초대 문자 보내기 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue:{response in
                print("친구들에게 초대 문자 보내기 response: \(response)")
                
                let result = response["result"].string
                if result == "message sended"{
                    print("메세지 보내짐")
                    
                    //전화번호도 노티에 보내야 받아서 비교해서 뷰 변경 가능.
                    let contact = contacts[0] as! String
                    NotificationCenter.default.post(name: Notification.sent_invite_msg, object: nil, userInfo: ["sent_invite_msg": "ok", "contact": contact])
                    
                }else if result == "message send error"{
                    print("메세지 보내는데 에러 발생")
                    //전화번호도 노티에 보내야 받아서 비교해서 뷰 변경 가능.
                    let contact = contacts[0] as! String
                    
                    NotificationCenter.default.post(name: Notification.sent_invite_msg, object: nil, userInfo: ["sent_invite_msg": "fail", "contact": contact])
                    
                }else{
                    //전화번호도 노티에 보내야 받아서 비교해서 뷰 변경 가능.
                    let contact = contacts[0] as! String
                    
                    NotificationCenter.default.post(name: Notification.sent_invite_msg, object: nil, userInfo: ["sent_invite_msg": "fail", "contact": contact])
                    
                }
            })
    }
    
    //친구 신청하기
    func add_friend_request(f_idx: Int){
        cancellation = APIClient.add_friend_request(f_idx: f_idx)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {result in
                switch result{
                case .failure(let error):
                    print("회원가입 친구 요청 통신 에러 발생 : \(error)")
                case .finished:
                    break
                }
            }, receiveValue: {response in
                print("회원가입 친구 요청 통신 response: \(response)")
                let friend_idx = String(f_idx)
                if response["result"] == "ok"{
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "ok", "friend": friend_idx])
                    
                } else if response["result"]  == "no signed friends"{
                    print("회원가입 친구추가하기 없는 사용자")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "no signed friends", "friend": friend_idx])
                    
                }else if response["result"]  == "친구요청대기"{
                    print("회원가입 친구 요청 대기중")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "친구요청대기", "friend": friend_idx])
                    
                }else if response["result"]  == "친구요청뱓음"{
                    print("회원가입 친구 요청 대기중")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "친구요청뱓음", "friend": friend_idx])
                    
                }else if response["result"]  == "친구상태"{
                    print("회원가입 이미 친구입니다")
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "친구상태", "friend": friend_idx])
                    
                }else if response["result"]  == "자기자신"{
                    print("회원가입 나자신")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "자기자신", "friend": friend_idx])
                    
                    
                }else{
                    print("회원가입 친구 요청 실패")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "fail"])
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
                    
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "canceled_ok", "friend": friend_idx])
                    
                }else{
                    print("친구 신청 취소 실패")
                    NotificationCenter.default.post(name: Notification.request_friend, object: nil, userInfo: ["request_friend": "canceled_fail", "friend": friend_idx])
                    
                }
            })
    }
    
}
