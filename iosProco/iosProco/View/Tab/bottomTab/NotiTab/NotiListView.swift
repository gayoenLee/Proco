//
//  NotiListView.swift
//  proco
//
//  Created by 이은호 on 2021/06/01.
//

import SwiftUI
import Kingfisher

struct NotiListView: View {
    
    @StateObject var main_vm = NotiListViewModel()
    //친구관리 페이지로 이동
    @State private var go_friend_manage : Bool = false
    //친구 카드 상세 페이지 이동
    @State private var go_friend_card_detail: Bool = false
    //모임카드 상세 페이지 이동
    @State private var go_group_card_detail : Bool = false
    //피드 페이지로 이동
    @State private var go_feed : Bool = false
    
    //친구 카드 페이지로 이동 전 selected card idx를 저장하기 위해 필요.
    @ObservedObject var friend_card_vm = FriendVollehMainViewmodel()
    //모임 카드 페이지로 이동 전 selected card idx를 저장하기 위해 필요.
    @ObservedObject var group_card_vm = GroupVollehMainViewmodel()
    @ObservedObject var calendar_vm = CalendarViewModel()
    
    var body: some View {
        
        VStack{
            TopNavBar(page_name: "알림")
            
            //스크롤뷰의 경우 리사이클러뷰처럼 뷰를 보이는 것만 그리는 것이 아님. -> 그래서 lazyvstack을 함께 써줘야 무한스크롤링 구현 가능
            
            if self.main_vm.noti_list_model.count <= 0{
                HStack{
                   Text("알림이 없습니다.")
                    .font(.custom(Font.n_extra_bold, size: 15))
                    .foregroundColor(.gray)
                    
                }
            }else{
            ScrollView{
                LazyVStack{
                    ForEach(0..<self.main_vm.noti_list_model.count, id: \.self){index in
                        
                        //한번에 갖고 와서 모델에 저장된 데이터의 마지막인 경우 is_last값 true
                        if index == self.main_vm.noti_list_model.count-1{
                            
                            NotiRow(noti: self.main_vm.noti_list_model[index], main_vm: self.main_vm, calendar_vm: self.calendar_vm, go_friend_manage: self.$go_friend_manage, go_friend_card_detail: self.$go_friend_card_detail, go_group_card_detail: self.$go_group_card_detail, go_feed: self.$go_feed, friend_card_vm: self.friend_card_vm, group_card_vm: self.group_card_vm, is_last: true)
                                .padding([.leading, .trailing, .bottom])
                            
                        }else{
                            
                            NotiRow(noti: self.main_vm.noti_list_model[index], main_vm: self.main_vm, calendar_vm: self.calendar_vm, go_friend_manage: self.$go_friend_manage, go_friend_card_detail: self.$go_friend_card_detail, go_group_card_detail: self.$go_group_card_detail, go_feed: self.$go_feed, friend_card_vm: self.friend_card_vm, group_card_vm: self.group_card_vm, is_last: false)
                                .padding([.leading, .trailing, .bottom])
                        }
                    }
                }
            }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear{
            self.main_vm.get_noti_list(page_idx: 0, page_size: 20)
        }
    }
}

struct NotiRow: View{
    
    @State var noti : NotiListModel
    @ObservedObject var main_vm : NotiListViewModel
    //심심기간 관련 노티 화면 이동시 유저 정보 저장할 때 사용.
    @ObservedObject var calendar_vm : CalendarViewModel
    
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 40, height: 40)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    //친구관리 페이지로 이동
    @Binding var go_friend_manage : Bool
    //친구 카드 상세 페이지 이동
    @Binding var go_friend_card_detail: Bool
    //모임카드 상세 페이지 이동
    @Binding var go_group_card_detail : Bool
    //피드 페이지로 이동
    @Binding var go_feed : Bool
    //친구, 모임 카드 상세 페이지 이동 전 selected card idx 저장시켜서 뷰에 전달
    @ObservedObject var friend_card_vm : FriendVollehMainViewmodel
    @ObservedObject var group_card_vm : GroupVollehMainViewmodel
    
    //마지막 데이터인지 구분하는 값
    var is_last : Bool
    
    @ViewBuilder
    private func content() -> some View{
        var complete_sentence : Text = Text(verbatim: "")
        //인디케이터가 없는 경우 nil로 저장 안되는 경우가 있어서 추가
        if noti.content_indicator == nil{
            noti.content_indicator = nil
        }
        
        //인디케이터가 없는 경우도 있음
        if noti.content_indicator != "" || noti.content_indicator != nil{
            //인디케이터가 2개인 경우
            if noti.content_indicator!.contains(","){
                let indicator_array = noti.content_indicator?.split(separator: ",")
                if indicator_array!.count > 1{
                    
                    let sentence = noti.content!
                    //1.첫번째 인디케이터 기준으로 문장 두조각 내기
                    let seperated_txt = sentence.components(separatedBy: indicator_array![0])
                    
                    //2. 1번에서 조각낸 조각중 첫번째 조각에 두번째 인디케이터가 포함돼 있는지 체크
                    if seperated_txt[0].contains(indicator_array![1]){
                        //3.포함돼 있는 경우 이 조각에서 두번째 인디케이터 기준으로 다시 두조각 내기
                        let second_seperated_txt = seperated_txt[0].components(separatedBy: indicator_array![1])
                        
                        complete_sentence = Text(second_seperated_txt[0]).font(.custom(Font.n_regular, size: 15))+Text(indicator_array![1])
                            .font(.custom(Font.n_bold, size: 17))
                            .foregroundColor(Color.proco_black)+Text(second_seperated_txt[1])
                            .font(.custom(Font.n_regular, size: 15))
                            .foregroundColor(Color.proco_black)+Text(indicator_array![0])
                            .font(.custom(Font.n_bold, size: 17)).foregroundColor(Color.proco_black)+Text(seperated_txt[1])
                            .font(.custom(Font.n_regular, size: 15))
                            .foregroundColor(Color.proco_black)
                        
                    }else{
                        /*2-2. 1번에서 조각낸 조각중 두번째 조각에 두번째 인디케이터가 포함돼 있는 경우
                         - 두번째 인디케이터 기준으로 두번째 조각을 다시 두조각 내서 텍스트뷰 리턴
                         */
                        let second_seperated_txt = seperated_txt[1].components(separatedBy: indicator_array![1])
                        
                        complete_sentence = Text(seperated_txt[0])
                            .font(.custom(Font.n_regular, size: 15))
                            .foregroundColor(Color.proco_black)+Text(indicator_array![0])
                            .font(.custom(Font.n_bold, size: 17))
                            .foregroundColor(Color.proco_black)+Text(second_seperated_txt[0])
                            .font(.custom(Font.n_regular, size: 15))
                            .foregroundColor(Color.proco_black)+Text(indicator_array![1])
                            .font(.custom(Font.n_bold, size: 17))
                            .foregroundColor(Color.proco_black)+Text(second_seperated_txt[1])
                            .font(.custom(Font.n_regular, size: 15))
                            .foregroundColor(Color.proco_black)
                    }
                }
                //인디케이터가 한개인 경우 - 인디케이터 기준으로 두조각을 무조건 내서 중간에 인디케이터 끼워넣어 텍스트뷰 리턴
            }else{
                
                let seperated_txt = noti.content?.components(separatedBy: noti.content_indicator!)
                print("분리한 텍스트 확인: \(String(describing: seperated_txt))")
                
                complete_sentence = Text(seperated_txt![0]).font(.custom(Font.n_regular, size: 15))
                    .foregroundColor(Color.proco_black)+Text(noti.content_indicator!).font(.custom(Font.n_bold, size: 15))+Text(seperated_txt![1])
                    .font(.custom(Font.n_regular, size: 15))
                    .foregroundColor(Color.proco_black)
                
            }
            //인디케이터가 없는 경우
        }else{
            complete_sentence = Text(noti.content!)
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(Color.proco_black)
        }
        return complete_sentence
    }
    
    var body: some View{
            HStack{
                
                //프로필 이미지
                    if self.noti.image_path == "" || self.noti.image_path == nil{
                        
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                    }else{
                        
                        KFImage(URL(string: self.noti.image_path!))
                            .placeholder{Image("main_profile_img")
                                .resizable()
                                .frame(width: 40, height: 40)
                            }
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .fade(duration: 0.25)
                            .setProcessor(img_processor)
                            .onProgress{receivedSize, totalSize in
                                print("on progress: \(receivedSize), \(totalSize)")
                            }
                            .onSuccess{result in
                                print("성공 : \(result)")
                            }
                            .onFailure{error in
                                print("실패 이유: \(error)")
                                
                                Image("main_profile_img")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                            }
                    }
                //노티 클릭시 화면 이동시키는 링크들
                NavigationLink("",destination: ManageFriendListView(), isActive: self.$go_friend_manage)
                
                NavigationLink("",destination: FriendVollehCardDetail(main_vm: self.friend_card_vm, group_main_vm: self.group_card_vm, socket: SockMgr.socket_manager, calendar_vm: CalendarViewModel()), isActive: self.$go_friend_card_detail)
                
                NavigationLink("",destination: GroupVollehCardDetail(main_vm: self.group_card_vm, socket: SockMgr.socket_manager, calendar_vm: CalendarViewModel()), isActive: self.$go_group_card_detail)
                
                NavigationLink("",destination: SimSimFeedPage(main_vm: self.calendar_vm, view_router: ViewRouter()).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true), isActive: self.$go_feed)
                    VStack{
                        //인디케이터 볼드 처리 위해 뷰빌더 메소드로 리턴
                        content()
                    }
                   
                    //페이징 처리
                    .onAppear{
                        if self.is_last{
                            print("마지막이여서 데이터 추가 가져오기")
                            //noti.idx는 현재 갖고 있는 데이터중 작은 idx값
                            self.main_vm.get_again(page_idx: noti.idx!, page_size: 20)
                        }
                    }
                    Spacer()
            }
        .onTapGesture {
            print("노티 한 개 클릭: \(noti)")
            
            //화면 이동
            //1. 친구관리 페이지 이동 - 친구요청, 친구수락
            //2. 친구 카드 세부 화면 - 친구카드좋아요, 친구카드수정, 관심친구친구카드
            //3. 모임카드 세부 화면 - 모임카드수정,모임유저참가신청, 모임수락, 관심친구모임카드
            //4. 심심피드 - 관심친구심심기간
            switch noti.kinds{
            case "친구요청", "친구수락":
                return self.go_friend_manage = true
                
            case "친구카드좋아요", "친구카드수정", "관심친구친구카드":
                print("친구 카드 idx 저장")
                self.friend_card_vm.selected_card_idx = noti.unique_idx!
                return self.go_friend_card_detail = true
                
            case "모임카드수정", "모임유저참가신청", "모임수락", "관심친구모임카드":
                self.group_card_vm.selected_card_idx = noti.unique_idx!
                return self.go_group_card_detail = true
                
            case "관심친구심심기간":
        
                calendar_vm.calendar_owner.profile_photo_path = noti.image_path ?? ""
                calendar_vm.calendar_owner.user_idx = noti.idx!
                calendar_vm.calendar_owner.user_nickname = noti.content_indicator!
                calendar_vm.calendar_owner.watch_user_idx = Int(UserDefaults.standard.string(forKey: "user_id")!)!
                SimSimFeedPage.calendar_owner_idx = noti.unique_idx!
                print("관심친구 심심기간 노티 클릭 후 데이터 확인: \(calendar_vm.calendar_owner)")
                return self.go_feed = true
                
            default:
                return
            }
        }
    }
}


struct NotiListView_Previews: PreviewProvider {
    static var previews: some View {
        NotiListView()
    }
}
