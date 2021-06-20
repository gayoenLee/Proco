//
//  EditCardView.swift
//  proco
//
//  Created by 이은호 on 2020/12/24.
// 친구랑 볼래 카드 수정 페이지

import Foundation
import SwiftUI
import Combine

struct EditCardView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var main_viewmodel : FriendVollehMainViewmodel
    @State var tag_category_struct : VollehTagCategoryStruct
        
    //수정 완료 후 메인 뷰로 이동하기 위한 토글 값
    @State private var end_plus : Bool = false
    //카테고리 최소 1개 선택 안했을 경우 띄우는 알림창
    @State private var category_alert : Bool = false
    
    @State private var selected_category : String = ""
    //온.오프라인 모임 종류 - onappear에서 데이터 가져온 후 세팅
    @State private var is_offline_meeting : Bool = true
    @State private var go_to_select_friends : Bool = false
    
    var body: some View {
        
        VStack{
        HStack{
            //뒤로가기 버튼
            Button(action: {
                
                self.presentationMode.wrappedValue.dismiss()
                
            }, label: {
                Image("white_left")
                    .resizable()
                    .frame(width: 8.51, height: 17)
            })
            .padding(.leading, UIScreen.main.bounds.width/20)
            Spacer()
            
            //카드 수정 완료 후 메인 뷰로 이동
            NavigationLink("",
                           destination: FriendVollehMainView(main_vm: self.main_viewmodel, volleh_category_struct: self.tag_category_struct).navigationBarHidden(true)
                            .navigationBarTitle(""),
                           isActive: self.$end_plus
            )
            
            Text("카드 수정")
                .font(.custom(Font.t_extra_bold, size: 20))
                .foregroundColor(.proco_white)
                .padding(.trailing, UIScreen.main.bounds.width/20)
            Spacer()
        
        }
        .frame(width: UIScreen.main.bounds.width*1.1, height: UIScreen.main.bounds.width*0.5)

        ScrollView{
            VStack{
                //완료 버튼을 제외한 카드 편집 뷰
                FreindVollehMyCardEditView(viewmodel: self.main_viewmodel, tag_category_struct: self.tag_category_struct, card_detail_struct: main_viewmodel.friend_volleh_card_detail, go_to_select_friends: self.$go_to_select_friends, category_alert: self.$category_alert, selected_category: self.$selected_category)
            
            
            Button(action: {
                
                if self.main_viewmodel.category_is_selected(){
                    
                    self.main_viewmodel.make_card_date()
                    print("날짜 값 최종 확인 : \(main_viewmodel.card_expire_time)")
                    print("마지막에 share list값 확인 : \(Array(self.main_viewmodel.add_card_struct.share_list))")
                    
                    //카드 수정 통신시에 share_list파라미터 dictionary로 만드는 메소드 실행.
                    main_viewmodel.make_dictionary()
                  
                    //태그 데이터 보낼 때 카테고리, 태그 2개 순서대로 보내야 함.
                    let category_idx = self.main_viewmodel.user_selected_tag_list.firstIndex(where: {
                        $0 == self.selected_category
                    })
                    //카테고리를 유저가 선택한 태그 배열에서 삭제하고 맨 첫번재 순서로 다시 집어넣는다.
                    self.main_viewmodel.user_selected_tag_list.remove(at: category_idx!)
                    self.main_viewmodel.user_selected_tag_list.insert(self.selected_category, at: 0)
                    print("유저가 선택한 카테고리 재배열한 것 확인: \(self.main_viewmodel.user_selected_tag_list)")
                    
                    //카드 수정 통신
                    self.main_viewmodel.edit_my_card()
                    
                    //카드 수정 통신 결과에 따라 alert창 띄우기 위함.
                    main_viewmodel.result_alert(main_viewmodel.alert_type)
                    
                }else{
                    print("카드에 태그 포함 안돼 있음.")
                    //카테고리 최소 1개 선택 안함.
                    self.category_alert.toggle()
                    
                }
            }){
                Text("완료")
                    .font(.custom(Font.t_regular, size: 17))
                    .padding()
                    .foregroundColor(.proco_white)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color.main_orange)
            .cornerRadius(25)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            //수정 완료 후 서버 통신 결과에 따라 alert창 다르게 보여줌. 카드 수정 실패시 메인 뷰로 이동하지 않는다.
            .alert(isPresented: $main_viewmodel.show_alert){
                switch main_viewmodel.alert_type{
                case .success:
                    return Alert(title: Text("카드 수정"), message: Text("카드 수정이 완료됐습니다."),  dismissButton: Alert.Button.default(Text("확인"), action:{
                        self.presentationMode.wrappedValue.dismiss()
                        //self.end_plus.toggle()
                    }))
                case .fail:
                    return Alert(title: Text("카드 수정"), message: Text("카드 수정을 다시 시도해주세요."), dismissButton: Alert.Button.default(Text("확인"), action:{
                    }))
                }
            }
            }
        }
        }
        .onAppear{
            print("상세 페이지 나타남")
            self.main_viewmodel.get_card_detail(card_idx: self.main_viewmodel.selected_card_idx)
            
        }
    }
}

struct FreindVollehMyCardEditView : View {
    
    @ObservedObject var viewmodel: FriendVollehMainViewmodel
    @State var tag_category_struct : VollehTagCategoryStruct
    @State var card_detail_struct : FriendVollehCardDetailModel
    //알릴 친구들 선택하는 뷰로 이동할 때 이용하는 값.
    @Binding var go_to_select_friends : Bool
    //추가하려는 태그의 갯수가 3개를 넘으면 값이 true
    @State private var tag_num_over_three : Bool = false
    //카테고리 최소 1개 선택 안했을 경우 경고 문구를 띄우기 위함.
    @Binding var category_alert: Bool

    @Binding  var selected_category : String
    
    var body: some View{
        VStack{
        Group{
           // date_view
            time_view
        }
        //태그 3개 초과해서 추가하려고 할 경우 나타나는 경고 문구
        if tag_num_over_three{
            HStack{
            Text("태그는 최대 3개까지 추가 가능합니다.")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_red)
            }
        }
        if self.category_alert{
            HStack{
            Text("카테고리 1개 필수 선택입니다.")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_red)
            }
        }
        
        //태그 선택 부분 시작
        HStack{
            Text("심심태그")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_black)
            Text("최대 2개")
                .font(.custom(Font.n_regular, size: 10))
                .foregroundColor(.gray)
            Spacer()
            
        }
        .padding()
        
        category_select_view
        
        HStack{
         tag_textfield_view
        plus_tag_btn
        }
        
        //사용자가 선택한 태그값이 있을 때 이곳에 태그 리스트 보여줌.
        //이곳에서 다시 태그 클릭했을 때 삭제
        if viewmodel.user_selected_tag_list.count > 0{
            ScrollView(.horizontal, showsIndicators: false){
                HStack{
                selected_category_view
                selected_tag_view
                }
            }
            .padding([.leading, .trailing], UIScreen.main.bounds.width/40)
        }
        Spacer()
        Group{
        HStack{
            Text("알릴 친구들")
                .font(.custom(Font.t_extra_bold, size: 15))
                .foregroundColor(.proco_black)
            
            //뷰모델에서 친구 리스트 데이터를 모두 갖고 오면 다음 뷰로 이동한다.
            NavigationLink("", destination: SelectFriendMakeCard(main_viewmodel: self.viewmodel), isActive: self.$go_to_select_friends)
            
            Button(action: {
                print("알릴 친구들 보여주기 true로 바꿈")
                //친구 추가하기 위해 친구 목록, 그룹 목록 리스트있는 뷰로 이동.
                self.go_to_select_friends = true
            }){
                Image("pencil")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            Spacer()

            //알릴 사람을 아무도 선정하지 않았을 경우에만 보여줌
            if  viewmodel.show_card_friend_array.count + viewmodel.show_card_group_array.count == 0{
                Text("모든친구")
                    .font(.custom(Font.t_extra_bold, size: 13))
                    .foregroundColor(.proco_black)
                    .padding(UIScreen.main.bounds.width*0.01)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.proco_black, lineWidth: 1)
                )
            }
        }
        .padding()
        }
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                //알릴 친구들 리스트 프레임 최대 영역 벗어나면 아랫줄로 자동 이동하도록 구성.
                if viewmodel.show_card_group_array.count > 0{
                    
                    //그룹
                  show_selected_group
                }
                
                if viewmodel.show_card_friend_array.count > 0 {
                    //친구
                    show_selected_friend
                }
            }
        }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.send_selected_card_category)){value in
            print("내 카드 수정페이지에서 category태그 노티 받음: \(value)")
            if let user_info = value.userInfo, let tag_category = user_info["selected_category"]{
                print("내 카드 수정페이지에서category태그 받았음: \(tag_category)")
                
               // if tag_category as! String == "selected_category"{
                    self.selected_category = tag_category as! String
                    print("카테고리 태그 저장한 것 확인: \(self.selected_category)")
                //}
            }else{
                print("내 카드 수정페이지에서category태그 못받음.")
            }
        }
    }
}

private extension FreindVollehMyCardEditView {
    var date_view : some View{
        HStack{
            Text("날짜")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_black)

            Spacer()
            //in: 은 미래 날짜만 선택 가능하도록 하기 위함, displayedComponents는 시간을 제외한 날짜만 캘린더에 보여주기 위함.
            DatePicker("", selection: $viewmodel.card_date, in: Date()..., displayedComponents: .date)
                //다이얼로그식 캘린더 스타일
                .datePickerStyle(CompactDatePickerStyle())
            Spacer()
        }
        .padding()
    }
    
    var time_view: some View{
        HStack{
            Text("시간")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_black)
            Spacer()
            
            DatePicker("시간을 설정해주세요", selection: self.$viewmodel.card_time, displayedComponents:
                        .hourAndMinute)
                .labelsHidden()
                .datePickerStyle( GraphicalDatePickerStyle())
        }
        .padding()
    }
    
    var category_select_view : some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(0..<viewmodel.volleh_category_tag_struct.count, id: \.self){ category_index in
                    //태그 카테고리 뷰
                    //1개 클릭시 뷰모델에 user_selected_tag_set에 저장됨.
                    VollehTagCategoryView(viewmodel: self.viewmodel, category_model: self.viewmodel.volleh_category_tag_struct[category_index], selected_category: self.$selected_category, is_for_filter: false)
                    
                }.padding(.leading, UIScreen.main.bounds.width/60)
            }
        }.frame(height: UIScreen.main.bounds.width/5)
    }
    
    var tag_textfield_view : some View{
        HStack{
            
            //태그 입력 칸. 텍스트필드에서 엔터키 누를 때도 사용자 입력값 받고 또는 추가 버튼 클릭시에도 받음.
            //onCommit: 사용자가 엔터키 눌렀을 때 이벤트
            TextField("직접입력(필수x), 최대 10글자까지 입력 가능합니다", text: $viewmodel.user_input_tag_value, onCommit:{
                //뷰모델에서 선택한 태그 갯수 체크하는 메소드의 결과값
                self.tag_num_over_three = viewmodel.limit_tag_num(tag_list: self.viewmodel.user_selected_tag_list)
                
                //태그는 최대 3개까지 추가 가능. 3개가 넘었을 때는 set, array에 태그 추가 안함.> 상단에 경고문구 보여줌.
                if self.tag_num_over_three{
                    print("직접입력 추가 버튼에서 태그 선택 3개 넘음")
                }else{
                    print("직접입력 추가 버튼에서 태그 선택 3개 안넘음")
                    
                //뷰모델의 set에 중복 방지를 위해 우선 값 저장. 후에 배열로 다시 저장.
                self.viewmodel.user_selected_tag_set.insert(self.viewmodel.user_input_tag_value)
                self.viewmodel.user_selected_tag_list = Array(self.viewmodel.user_selected_tag_set)
                }
                
                //엔터키 친 이후에 텍스트 필드 창에 있던 값 reset하기
                self.viewmodel.user_input_tag_value = ""
            })
            //글자수 제한 적용. ios14부터만 사용 가능.
            .onChange(of: self.viewmodel.user_input_tag_value, perform: {value in
                
                if value.count > 10{
                    self.viewmodel.user_input_tag_value = String(value.prefix(10))
                }
            })
            .padding()
        }
        .background(Color.light_gray)
        .cornerRadius(25.0)
        .padding(UIScreen.main.bounds.width/25)
    }
    
    var plus_tag_btn : some View{
        HStack{
            //태그 추가하기 버튼
            Button(action: {
                //뷰모델에서 선택한 태그 갯수 체크하는 메소드의 결과값
                self.tag_num_over_three = viewmodel.limit_tag_num(tag_list: self.viewmodel.user_selected_tag_list)
                if self.tag_num_over_three{
                    print("직접입력 추가 버튼에서 태그 선택 3개 넘음")
                    
                }else{
                    print("직접입력 추가 버튼에서 태그 선택 3개 안넘음")
                viewmodel.user_selected_tag_set.insert(viewmodel.user_input_tag_value)
                self.viewmodel.user_selected_tag_list = Array(self.viewmodel.user_selected_tag_set)
                }
                //엔터키 친 이후에 텍스트 필드 창에 있던 값 reset하기
                self.viewmodel.user_input_tag_value = ""
            }){
                Capsule()
                    .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/8)
                    .foregroundColor(Color.proco_black)
                    .overlay(
                        Text("추가")
                            .font(.custom(Font.t_extra_bold, size: 15))
                            .foregroundColor(.proco_white))
                .padding(.trailing, UIScreen.main.bounds.width/20)
            }
        }
    }
    
    var selected_category_view: some View{
        HStack{
            
            ForEach(0..<viewmodel.user_selected_tag_list.count, id: \.self){ tag_index in
                if viewmodel.volleh_category_tag_struct.contains(where: {
                    $0.category_name == viewmodel.user_selected_tag_list[tag_index]
                }){
                    Image("small_x")
                        .resizable()
                        .frame(width: 7, height: 7)
                    
                    Capsule()
                                .foregroundColor(viewmodel.user_selected_tag_list[tag_index] == "사교/인맥" ? .proco_yellow : viewmodel.user_selected_tag_list[tag_index] == "게임/오락" ? .proco_pink : viewmodel.user_selected_tag_list[tag_index] == "문화/공연/축제" ? .proco_olive : viewmodel.user_selected_tag_list[tag_index] == "운동/스포츠" ? .proco_green : viewmodel.user_selected_tag_list[tag_index] == "취미/여가" ? .proco_mint : viewmodel.user_selected_tag_list[tag_index] == "스터디" ? .proco_blue : .proco_red )
                        .frame(width: 90, height: 22)
                        .overlay(
                    Button(action: {
                        print("선택한 태그 리스트들 확인\(viewmodel.user_selected_tag_list) ")
                        
                        print("선택한 태그 리스트들 중 현재 선택한 것 확인 : \(viewmodel.user_selected_tag_list[tag_index])")
                        if viewmodel.user_selected_tag_set.contains(viewmodel.user_selected_tag_list[tag_index]){
                            print("이미 선택한 태그")
                            viewmodel.user_selected_tag_set.remove(viewmodel.user_selected_tag_list[tag_index])
                            self.viewmodel.user_selected_tag_list = Array(self.viewmodel.user_selected_tag_set)
                            self.selected_category = ""
                        }else{
                            print("새로 선택한 태그")
                            viewmodel.user_selected_tag_set.insert(viewmodel.user_selected_tag_list[tag_index])
                            self.viewmodel.user_selected_tag_list =
                                Array(self.viewmodel.user_selected_tag_set)
                            self.selected_category = viewmodel.user_selected_tag_list[tag_index]
                        }
                    }){
                            Text(viewmodel.user_selected_tag_list[tag_index])
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.custom(Font.n_bold, size: 14))
                                .foregroundColor(.proco_white)

                    })
                }
            }
        }
    }
    var selected_tag_view: some View{
        HStack{
            
            ForEach(0..<viewmodel.user_selected_tag_list.count, id: \.self){ tag_index in
                if viewmodel.volleh_category_tag_struct.contains(where: {
                    $0.category_name == viewmodel.user_selected_tag_list[tag_index]
                }){
                }else{
                    
                    HStack{
                        Image("small_x")
                            .resizable()
                            .frame(width: 5, height: 5)
                    
                Button(action: {
                    print("선택한 태그 리스트들 확인\(viewmodel.user_selected_tag_list) ")
                    
                    print("선택한 태그 리스트들 중 현재 선택한 것 확인 : \(viewmodel.user_selected_tag_list[tag_index])")
                    if viewmodel.user_selected_tag_set.contains(viewmodel.user_selected_tag_list[tag_index]){
                        print("이미 선택한 태그")
                        viewmodel.user_selected_tag_set.remove(viewmodel.user_selected_tag_list[tag_index])
                        self.viewmodel.user_selected_tag_list = Array(self.viewmodel.user_selected_tag_set)
                        
                    }else{
                        print("새로 선택한 태그")
                        viewmodel.user_selected_tag_set.insert(viewmodel.user_selected_tag_list[tag_index])
                        self.viewmodel.user_selected_tag_list = Array(self.viewmodel.user_selected_tag_set)
                    }
                }){
                    HStack{
                        Image("tag_sharp")
                            .resizable()
                            .frame(width: 16, height: 16)

                        Text(viewmodel.user_selected_tag_list[tag_index])
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .font(.custom(Font.n_bold, size: 14))
                            .foregroundColor(.proco_black)
                    }
                }
                    }
                }
            }
        }
    }
    
    var show_selected_group : some View{
        //그룹
        ForEach(0..<viewmodel.show_card_group_array.count, id: \.self){ group in
            let selected_item = viewmodel.show_card_group_array[group]
            
            Button(action: {
                if viewmodel.show_card_group_set.contains(viewmodel.show_card_group_array[group]){
                    print("이미 선택했던 그룹을 다시 클릭했으므로 제거")
                    //선택한 그룹 set에서 제거
                    viewmodel.show_card_group_set.remove(viewmodel.show_card_group_array[group])
                    
                    
                    print("그룹 어레이 바뀌기 전 : \(viewmodel.show_card_group_array[group])")
                    //그룹 이름 저장한 dictionary
                    self.viewmodel.show_card_group_name.removeValue(forKey: self.viewmodel.show_card_group_array[group])
                    
                    //선택한 그룹 list에서 제거
                    viewmodel.show_card_group_array = Array(self.viewmodel.show_card_group_set)
                }else{
                    print("새로 그룹 선택")
                }
                
            }){
                Text(self.viewmodel.show_card_group_name[selected_item]!)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .font(.system(size: UIScreen.main.bounds.width/25))
                    .foregroundColor(.proco_black)

            }
            .overlay(RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.proco_black,lineWidth: 1))
            .scaledToFit()
        }
    }
    
    var show_selected_friend : some View{
        
        ForEach(0..<viewmodel.show_card_friend_array.count, id: \.self){
            person in
            
            let selected_friend = viewmodel.show_card_friend_array[person]
            
            Button(action: {
                if viewmodel.show_card_friend_set.contains(viewmodel.show_card_friend_array[person]){
                    //선택한 친구 set, list에서 제거
                    viewmodel.show_card_friend_set.remove(viewmodel.show_card_friend_array[person])
                    
                    //친구 이름 저장한 dictionary
                    self.viewmodel.show_card_friend_name.removeValue(forKey: self.viewmodel.show_card_friend_array[person])
                    
                    //선택한 그룹 리스트 업데이트
                    viewmodel.show_card_friend_array = Array(self.viewmodel.show_card_friend_set)
                }else{
                    
                }
            }){
                HStack{
                    Image("small_x")
                        .resizable()
                        .frame(width: 6, height: 6)
                    
                Text(self.viewmodel.show_card_friend_name[selected_friend]!)
                    .frame(minWidth: 0, maxWidth: 100, minHeight: 0, maxHeight: 30)       .font(.system(size: UIScreen.main.bounds.width/25))
                    .foregroundColor(.proco_black)
            }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.proco_black,lineWidth: 1))
            .scaledToFit()
            
        }
    }
    }


