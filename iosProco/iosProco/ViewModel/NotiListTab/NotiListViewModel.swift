//
//  NotiListViewModel.swift
//  proco
//
//  Created by 이은호 on 2021/06/01.
// 알림탭에서 사용되는 뷰모델

import Foundation
import Alamofire
import Combine
import SwiftyJSON

class NotiListViewModel : ObservableObject {
    public let objectWillChange = ObservableObjectPublisher()
    var cancellation: AnyCancellable?
    
    @Published var noti_list_model : [NotiListModel] = []{
        didSet{
            objectWillChange.send()
        }
    }
    
    func get_again(page_idx: Int, page_size: Int){
        cancellation = APIClient.get_notis(page_idx: page_idx, page_size: page_size)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:    {result in
                switch result{
                case .failure(let error):
                    print("알림 데이터 추가 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                    }
                }, receiveValue: {response in
                    print("알림 데이터 추가 가져오기 response: \(response)")
                    
                    let result: String?
                    result = response["result"].string
                    
                    if result == "no result"{
                        print("추가 알림 없음")
                        
                    }else{
                   
                        let data = response.arrayValue
                        
                        let json_string = """
                                \(data)
                                """
                        print("추가 알림 데이터 string변환")
                        
                        let json_data = json_string.data(using: .utf8)
                        
                        let notis = try? JSONDecoder().decode([NotiListModel].self, from: json_data!)
                        
                        print("추가 알림 데이터  디코딩한 값: \(String(describing: notis))")
                        for noti in notis!{
                        self.noti_list_model.append(noti)
                        }
                    }
                })
    }
    
    func get_noti_list(page_idx: Int, page_size: Int){
        cancellation = APIClient.get_notis(page_idx: page_idx, page_size: page_size)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion:    {result in
                switch result{
                case .failure(let error):
                    print("알림탭 데이터 가져오기 에러 발생 : \(error)")
                case .finished:
                    break
                    }
                }, receiveValue: {response in
                    print("알림탭 데이터 가져오기 response: \(response)")
                    
                    let result: String?
                    result = response["result"].string
                    
                    if result == "no result"{
                        print("알림 없음")
                        
                    }else{
                        
                        let data = response.arrayValue
                        let json_string = """
                                \(data)
                                """
                        print("알림탭 데이터 string변환")
                        
                        let json_data = json_string.data(using: .utf8)
                        
                        let notis = try? JSONDecoder().decode([NotiListModel].self, from: json_data!)
                        
                        print("알림탭 데이터  디코딩한 값: \(String(describing: notis))")
                       
                        self.noti_list_model = notis!
                    }
                })
    }
    
}
