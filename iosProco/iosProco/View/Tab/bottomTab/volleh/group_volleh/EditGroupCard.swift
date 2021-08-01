//
//  EditGroupCard.swift
//  proco
//
//  Created by 이은호 on 2020/12/27.
// 모여 볼래 카드 수정 페이지

import SwiftUI
import Combine
import PhotosUI
import Kingfisher

struct EditGroupCard: View {
    //편집 완료 클릭시 이용해서 창 닫고 메인으로 돌아감.
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var main_vm: GroupVollehMainViewmodel
    
    //편집 완료 후 메인 뷰로 이동하기 위한 토글 값
    @State private var go_to_edit : Bool = false
    //카테고리 최소 1개 선택 안했을 경우 띄우는 알림창
    @State private var category_alert : Bool = false
    //제목 필수 입력 안했을 때 경고 문구 띄우기 위해 사용.
    @State private var is_title_empty : Bool = false
    //온.오프라인 모임 종류 - onappear에서 데이터 가져온 후 세팅
    @State private var is_offline_meeting : Bool = true
    
    @State private var selected_category : String = ""
    //지도 웹뷰 열기
    @State private var open_map : Bool = false
    @State private var show_img_picker : Bool = false
    var image_url : String?{
        self.main_vm.card_detail_struct.card_photo_path ?? ""
    }
    @State private var ui_image : UIImage? = UIImage()
    //모임 카드 10분 이전 것 만든 경우 경고창
    @State private var make_card_time_disallow : Bool = false
    @State private var card_img_url : String? = ""
    
    @State private var pickerResult: UIImage? = UIImage()
    var config: PHPickerConfiguration  {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        //videos, livePhotos...등도 넣을 수 있음.
        config.filter = .images
        //0은 제한 없음을 의미, 갯수 제한 두는 것.
        config.selectionLimit = 1 //0 => any, set 1-2-3 for har limit
        return config
    }
    
    var body: some View{
  
            VStack{
                HStack(alignment: .center){
                    
                    Button(action: {
                        print("돌아가기 클릭")
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Image("left")
                            .resizable()
                            .frame(width: 8.51, height: 17)
                            .padding(.leading)

                    }
                    .frame(width: 45, height: 45, alignment: .leading)

                    Spacer()
                    
                    Text("모임 수정")
                        .font(.custom(Font.n_extra_bold, size: 22))
                        .foregroundColor(Color.proco_black)
                        .padding(.trailing)

                    
                    Spacer()
                }  .padding(.trailing)
                
                ScrollView{
                    
                    EditingView(main_vm: self.main_vm, category_alert: self.$category_alert, is_title_empty: self.$is_title_empty, is_offline_meeting: self.$is_offline_meeting, selected_category: self.$selected_category, open_map: self.$open_map, selected_img: self.image_url, show_img_picker: self.$show_img_picker, go_to_edit: self.$go_to_edit, make_card_time_disallow: self.$make_card_time_disallow, pickerResult: self.$pickerResult, card_img_url: self.$card_img_url)
                    
                    
                    //완료 버튼 클릭시 메인뷰로 이동.
                    Button(action: {
                        
                        if self.main_vm.category_is_selected(){
                            
                            category_alert = false
                            //날짜 형식에 맞춰서 서버에 보내기.
                            let card_time =  main_vm.make_card_date()
                            print("모임카드 수정시 태그 데이터 확인: \(self.main_vm.user_selected_tag_list)")
                            
                            let check_time_result = self.main_vm.make_card_time_check(make_time: card_time)
                            
                            if check_time_result{
                                
                                make_card_time_disallow = false
                                //태그 데이터 보낼 때 카테고리, 태그 2개 순서대로 보내야 함.
                                let category_idx = self.main_vm.user_selected_tag_list.firstIndex(where: {
                                    $0 == self.selected_category
                                })
                                //카테고리를 유저가 선택한 태그 배열에서 삭제하고 맨 첫번재 순서로 다시 집어넣는다.
                                self.main_vm.user_selected_tag_list.remove(at: category_idx!)
                                self.main_vm.user_selected_tag_list.insert(self.selected_category, at: 0)
                                print("유저가 선택한 카테고리 재배열한 것 확인: \(self.main_vm.user_selected_tag_list)")
                                
                                //카드 수정 완료 통신 - kinds: 온라인.오프라인 모임
                                //                        main_vm.edit_group_card(type: self.main_vm.my_card_detail_struct.kinds!)
                                
                                main_vm.edit_card_with_img(type: self.main_vm.my_card_detail_struct.kinds!, photo_file: self.main_vm.group_card_img_data ?? nil)
                                
                                //alert창 타입
                                main_vm.card_result_alert(main_vm.alert_type)
                                
                            }else{
                                print("모임 카드 만드는 시간 현재 시간 10분 후 아님 ")
                                self.make_card_time_disallow = true
                                
                            }
                            
                        }else if self.main_vm.title_check(title: self.main_vm.card_name){
                            print("카드 이름 작성 안함.")
                            is_title_empty.toggle()
                        }
                        else{
                            //카테고리 최소 1개 선택 안함.
                            category_alert = true
                        }
                    }){
                        Text("완료")
                            .font(.custom(Font.t_regular, size: 17))
                            .padding()
                            .foregroundColor(.proco_white)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.main_green)
                    .cornerRadius(25)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                    //카드 만들기 성공, 실패 결과에 따라 다르게 알림 창 띄움.
                    .alert(isPresented: $main_vm.show_alert){
                        switch main_vm.alert_type{
                        case .success:
                            return Alert(title: Text("약속 편집"), message: Text("약속 편집이 완료됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action:{
                                print("편집 알림 클릭 후 데이터 : \(self.main_vm.my_group_card_struct)")
                                
                                self.presentationMode.wrappedValue.dismiss()
                                //go_to_edit.toggle()
                            }))
                        case .fail:
                            return Alert(title: Text("약속 편집"), message: Text("약속 편집을 다시 시도해주세요."), dismissButton: Alert.Button.default(Text("확인"), action:{
                                
                            }))
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
                //갤러리 나타나는 것.
                .sheet(isPresented: $show_img_picker) {
                    PhotoPicker(configuration: self.config,
                                pickerResult: $pickerResult,
                                isPresented: $show_img_picker, is_profile_img: false, main_vm: SettingViewModel(), group_vm: self.main_vm)
                }
                //.navigationBarTitle("카드 수정", displayMode: .inline)
                .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
                    print("모임 카드 상세 데이터 통신 완료 노티 받음")
                    if let user_info = value.userInfo, let data = user_info["get_data_finish"]{
                        print("모임 상세 데이터 통신 완료 받았음: \(data)")
                        
                        if main_vm.my_card_detail_struct.kinds == "오프라인 모임" || main_vm.card_detail_struct.kinds == "오프라인 모임"{
                            
                            self.is_offline_meeting = true
                            print("카드 편집에서 오프라인 미팅임")
                        }else{
                            self.is_offline_meeting = false
                            print("카드 편집에서 온라인 미팅임;")
                        }
                        
                        self.card_img_url = main_vm.card_detail_struct.card_photo_path ?? ""
                        print("카드 수정 페이지 - 모임 카드 이미지 확인: \(self.card_img_url)")
                    }else{
                        print("모임 카드 상세 데이터 통신 노티 아님")
                    }
                }
            }
            .onAppear{
                print("모여볼래 카드 편집 뷰 넘어옴")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.main_vm.is_just_showing  = true
                    //카드 상세 정보 가져오는 통신.
                    self.main_vm.get_group_card_detail(card_idx: self.main_vm.selected_card_idx)
                }
            }
            .navigationBarHidden(true)
            //.navigationBarColor(background_img: "meeting_wave_bg")
           // .navigationBarTitle("카드 수정")
//            .navigationBarItems(leading:
//                                    Button(action: {
//                                        self.presentationMode.wrappedValue.dismiss()
//                                    }){
//                                        Image("left")
//                                    })
        
    }
}

struct EditingView: View{
    
    @ObservedObject var main_vm: GroupVollehMainViewmodel
    //추가하려는 태그의 갯수가 3개를 넘으면 값이 true
    @State private var tag_num_over_three : Bool = false
    //카테고리 최소 1개 선택 안했을 경우 경고 문구를 띄우기 위함.
    @Binding var category_alert: Bool
    //모임 제목 입력 안했을 경우 알림 문구 띄우기 위함.
    @Binding var is_title_empty : Bool
    
    @Binding var is_offline_meeting : Bool
    @Binding  var selected_category : String
    @Binding  var open_map : Bool
    
    //그룹 소개 글자 수
    @State private var introduce_txt_count = "0"
    var selected_img : String?
    @Binding  var show_img_picker : Bool
    
    @Binding var go_to_edit : Bool
    
    //약속 시간을 현재 시간 기준 10분 이후로 안만든 경우 안내 문구 띄우기
    @Binding var make_card_time_disallow : Bool
    @Binding var pickerResult : UIImage?
    //카드 이미지
    @Binding var card_img_url : String?
    
    let img_processor =  CroppingImageProcessor(size: CGSize(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.4)) |> DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width*0.9, height:  UIScreen.main.bounds.width*0.4)) |> RoundCornerImageProcessor(cornerRadius: 5) |> ResizingImageProcessor(referenceSize: CGSize(width: UIScreen.main.bounds.width*0.9, height:  UIScreen.main.bounds.width*0.4), mode: .aspectFit)
    
    var body: some View{
        VStack{
            
            Group{
                HStack{
                    VStack{
                        // meeting_kinds_selection
                        
                        //제목을 입력하지 않고 모임 만들기를 클릭할 경우 나타난다.
                        if self.is_title_empty{
                            HStack{
                                Text("모임이름은 필수입니다.")
                            }
                        }
                        HStack{
                            Text("모임 이름")
                                .font(.custom(Font.t_regular, size: 18))
                                .foregroundColor(Color.proco_black)
                            Spacer()
                        }
                        meeting_title_tfd
                    }
                }
                .padding()
                
            }
            Group{
                HStack{
                    Text("심심태그")
                        .font(.custom(Font.t_extra_bold, size: 16))
                        .foregroundColor(.proco_black)
                    Text("최대 3개")
                        .font(.custom(Font.n_regular, size: 10))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding()
                
                //태그 3개 초과해서 추가하려고 할 경우 나타나는 경고 문구
                if tag_num_over_three{
                    HStack{
                        Text("태그는 최대 3개까지 추가 가능합니다.")
                            .font(.custom(Font.t_extra_bold, size: 14))
                            .foregroundColor(.proco_red)
                    }
                }
                if self.category_alert{
                    HStack{
                        Text("카테고리는 최소 1개 필수 선택입니다.")
                            .font(.custom(Font.t_extra_bold, size: 14))
                            .foregroundColor(.proco_red)
                    }
                }
                
                //카테고리들 세로 리스트
                category_selections
                
                HStack{
                    
                    tag_textfield_view
                    plus_tag_btn
                    
                }
                //선택한 카테고리 리스트로 보여주기
                if main_vm.user_selected_tag_list.count > 0{
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            selected_category_btn
                            selected_tag_btn
                            
                        }
                        .padding([.leading, .trailing], UIScreen.main.bounds.width/40)
                        
                    }
                }
                Spacer()
                
            }
            //날짜, 시간 선택
            Group{
                date_view
                    .onTapGesture {
                        print("수정 클릭 날짜 확인: \(self.main_vm.card_date)")
                    }
                
                if make_card_time_disallow{
                    Text("현재 시간 기준 10분 이후 약속부터 가능합니다.")
                        .font(.custom(Font.t_extra_bold, size: 14))
                        .foregroundColor(.proco_red)
                }
                time_view
            }
            //위치
            Group{
                //오프라인 모임인 경우에만 지도 선택 뷰 보여주기
                if is_offline_meeting{
                    HStack{
                        Text("지역")
                            .font(.custom(Font.t_extra_bold, size: 16))
                            .foregroundColor(.proco_black)
                        Spacer()
                    }
                    .padding(.leading)
                    
                    NavigationLink("",destination: BigMapContainedView(vm: self.main_vm), isActive: self.$open_map)
                    
                    HStack{
                        Button(action: {
                            print("지역 입력 텍스트필드 클릭")
                            //이렇게 해줘야 초기화됨
                            // self.main_vm.is_editing_card = false
                            self.open_map.toggle()
                            self.main_vm.is_editing_card = true
                        }){
                            TextField("위치를 입력해주세요", text: $main_vm.input_location)
                                .padding()
                        }
                    }  .background(Color.light_gray)
                    .cornerRadius(25.0)
                    .padding(.leading,UIScreen.main.bounds.width/25)
                    
                    //지도 이미지
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.5, alignment: .center)
                        .foregroundColor(Color.gray)
                        .overlay( MyWebView(vm: self.main_vm, url: "https://withproco.com/map/map.html?device=ios"))
                }
            }
            //모임 소개
            Group{
                meeting_introduce_field
                
                select_meeting_img_view
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.event_finished), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["group_card_img_changed"]{
                
                if data as! String == "ok"{
                    self.card_img_url = ""
                    self.main_vm.my_card_detail_struct.card_photo_path = ""
                }
            }
        })
        .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
            print("모임카드 편집 - 상세 데이터 통신 완료 노티 받음")
            
            if let user_info = value.userInfo, let data = user_info["get_group_card_detail_finish"]{
                print("모임카드 편집 -  데이터 통신 완료 받았음: \(data)")
                
                if data as! String == "no result"{
                    
                }else{
                    print("수정하려는 카드 데이터 : \(self.main_vm.my_card_detail_struct)")
                    if self.main_vm.my_card_detail_struct.kinds! == "온라인 모임"{
                        self.is_offline_meeting = false
                    }else{
                        self.is_offline_meeting = true
                    }
                    
                    self.card_img_url = self.main_vm.my_card_detail_struct.card_photo_path ?? ""
                    print("카드 이미지 url: \(self.card_img_url)")
                }
            }else{
                print("친구 메인에서 오늘 심심기간 설정 서버 통신 후 노티 응답 실패: .")
            }
        }
    }
}

extension EditingView {
    
    var select_meeting_img_view : some View{
        VStack{
            HStack{
                Text("모임 이미지")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                Spacer()
            }
            .padding([.top, .leading])
            
            if  self.main_vm.my_card_detail_struct.card_photo_path != ""{

                KFImage(URL(string: self.main_vm.my_card_detail_struct.card_photo_path!))
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
                    }
                    .overlay(
                        Button(action: {
                            print("카드 이미지 선택 버튼 클릭")

                            self.show_img_picker.toggle()
                        }){
                            Image("plus_img_btn")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }, alignment: .center)
                
                
            }else if self.main_vm.my_card_detail_struct.card_photo_path == ""{
         
                Image.init(uiImage: pickerResult!)
                    .resizable()
                    //이미지 채우기
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.4)
                    .cornerRadius(5)
                    .overlay(
                        Button(action: {
                            print("카드 이미지 선택 버튼 클릭")
                            
                            self.show_img_picker.toggle()
                        }){
                            Image("plus_img_btn")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }, alignment: .center)
                
            }else if card_img_url == ""{
                
                Rectangle()
                    .overlay(
                        Button(action: {
                            print("카드 이미지 선택 버튼 클릭")
                            
                            self.show_img_picker.toggle()
                        }){
                            Image("plus_img_btn")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }, alignment: .center)
                    .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.4)
                    .cornerRadius(5)
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    //온오프라인 모임 선택 뷰
    var meeting_kinds_selection : some View{
        HStack{
            Rectangle()
                .cornerRadius(5)
                .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.1)
                .foregroundColor(self.is_offline_meeting == false ? .proco_mint : .proco_sky_blue)
                .overlay(
                    Button(action: {
                        self.is_offline_meeting = false
                        print("현재 모임 type: \(self.is_offline_meeting)")
                    }){
                        Text("채팅만")
                            .font(.custom(Font.t_extra_bold, size: UIScreen.main.bounds.width/15))
                            .foregroundColor(self.is_offline_meeting == false ? .proco_white : .inactive_blue)
                    })
            
            RoundedRectangle(cornerRadius: 5)
                .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width*0.1)
                .foregroundColor(self.is_offline_meeting == true ? .proco_mint : .proco_sky_blue)
                .overlay(
                    Button(action: {
                        self.is_offline_meeting = true
                    }){
                        Text("만나서")
                            .font(.custom(Font.t_extra_bold, size: UIScreen.main.bounds.width/15))
                            .foregroundColor(self.is_offline_meeting == true ? .proco_white : .inactive_blue)
                    })
        }
    }
    
    var meeting_title_tfd: some View{
        HStack{
            //모임 이름 글자 수 제한 확인할 것
            //10글자로 제한함.prefix : 최대 길이로 설정된 것까지만 리턴함.
            TextField("모임 이름을 입력해주세요", text: $main_vm.card_name)
                //IOS14부터 onchange사용 가능
                .onChange(of: self.main_vm.card_name) { value in
                    print("닉네임 onchangee 들어옴")
                    if value.count > 10 {
                        print("닉네임 10글자 넘음")
                        self.main_vm.card_name = String(value.prefix(10))
                    }
                }
                .padding()
        }
        .background(Color.light_gray)
        .cornerRadius(25.0)
    }
    
    var category_selections : some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                
                ForEach(0..<main_vm.category_tag_struct.count, id: \.self){ category_index in
                    //태그 카테고리 뷰(친구와 모임에서 사용하는 뷰모델이 달라서 한 뷰에서 예외처리 안하고 뷰를 그냥 나눔 )
                    //1개 클릭시 뷰모델에 user_selected_tag_set에 저장됨.
                    TagCategoryView(vm: self.main_vm, tag_struct: self.main_vm.category_tag_struct[category_index], selected_category: self.$selected_category, is_for_filter: false)
                    
                }.padding(.leading, UIScreen.main.bounds.width/60)
            }
        }.frame(height: UIScreen.main.bounds.width/5)
    }
    
    var tag_textfield_view : some View{
        
        HStack{
            TextField("직접입력 (선택사항)", text: $main_vm.user_input_tag_value, onCommit:{
                
                //뷰모델에서 선택한 태그 갯수 체크하는 메소드의 결과값
                self.tag_num_over_three = main_vm.limit_tag_num(tag_list: self.main_vm.user_selected_tag_list)
                
                //태그는 최대 3개까지 추가 가능. 3개가 넘었을 때는 set, array에 태그 추가 안함.> 상단에 경고문구 보여줌.
                if self.tag_num_over_three{
                    print("직접입력 추가 버튼에서 태그 선택 3개 넘음")
                }else{
                    print("직접입력 추가 버튼에서 태그 선택 3개 안넘음")
                    
                    //뷰모델의 set에 중복 방지를 위해 우선 값 저장. 후에 배열로 다시 저장.
                    self.main_vm.user_selected_tag_set.insert(self.main_vm.user_input_tag_value)
                    self.main_vm.user_selected_tag_list = Array(self.main_vm.user_selected_tag_set)
                }
                
                //엔터키 친 이후에 텍스트 필드 창에 있던 값 reset하기
                self.main_vm.user_input_tag_value = ""
            })
            //글자수 제한 적용 메소드. ios14부터만 사용 가능.
            .onChange(of: self.main_vm.user_input_tag_value, perform: {value in
                
                if value.count > 10{
                    self.main_vm.user_input_tag_value = String(value.prefix(10))
                }
            })
            .padding()
        }
        .background(Color.light_gray)
        .cornerRadius(25.0)
        .padding(.leading,UIScreen.main.bounds.width/25)
    }
    
    var plus_tag_btn : some View{
        Button(action: {
            //뷰모델에서 선택한 태그 갯수 체크하는 메소드의 결과값
            self.tag_num_over_three = main_vm.limit_tag_num(tag_list: self.main_vm.user_selected_tag_list)
            
            if self.tag_num_over_three{
                print("직접입력 추가 버튼에서 태그 선택 3개 넘음")
                
            }else{
                print("직접입력 추가 버튼에서 태그 선택 3개 안넘음")
                
                //선택한 태그 set에 저장하고 array에도 저장.
                main_vm.user_selected_tag_set.insert(main_vm.user_input_tag_value)
                self.main_vm.user_selected_tag_list = Array(self.main_vm.user_selected_tag_set)
            }
            //엔터키 친 이후에 텍스트 필드 창에 있던 값 reset하기
            self.main_vm.user_input_tag_value = ""
        }){
            Capsule()
                .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/8)
                .foregroundColor(Color.proco_black)
                .overlay(
                    Text("추가")
                        .font(.custom(Font.t_extra_bold, size: 15))
                        .foregroundColor(.proco_white))
                .padding(.trailing, UIScreen.main.bounds.width/40)
        }
    }
    
    var selected_category_btn : some View{
        ForEach(0..<main_vm.user_selected_tag_list.count, id: \.self){ tag_index in
            
            if main_vm.category_tag_struct.contains(where: {
                $0.category_name == main_vm.user_selected_tag_list[tag_index]
            }){
                Image("small_x")
                    .resizable()
                    .frame(width: 7, height: 7)
                
                Capsule()
                    .foregroundColor(main_vm.user_selected_tag_list[tag_index] == "사교/인맥" ? .proco_yellow : main_vm.user_selected_tag_list[tag_index] == "게임/오락" ? .proco_pink : main_vm.user_selected_tag_list[tag_index] == "문화/공연/축제" ? .proco_olive : main_vm.user_selected_tag_list[tag_index] == "운동/스포츠" ? .proco_green : main_vm.user_selected_tag_list[tag_index] == "취미/여가" ? .proco_mint : main_vm.user_selected_tag_list[tag_index] == "스터디" ? .proco_blue : .proco_red )
                    .frame(width: 90, height: 22)
                    .overlay(
                        
                        Button(action: {
                            print("선택한 태그 리스트들 확인\(main_vm.user_selected_tag_list) ")
                            
                            print("선택한 태그 리스트들 중 현재 선택한 것 확인 : \(main_vm.user_selected_tag_list[tag_index])")
                            if main_vm.user_selected_tag_set.contains(main_vm.user_selected_tag_list[tag_index]){
                                print("이미 선택한 태그")
                                main_vm.user_selected_tag_set.remove(main_vm.user_selected_tag_list[tag_index])
                                self.main_vm.user_selected_tag_list = Array(self.main_vm.user_selected_tag_set)
                                //카테고리 선택 초기화
                                self.selected_category = ""
                                
                            }else{
                                print("새로 선택한 태그")
                                main_vm.user_selected_tag_set.insert(main_vm.user_selected_tag_list[tag_index])
                                self.main_vm.user_selected_tag_list = Array(self.main_vm.user_selected_tag_set)
                                //선택한 카테고리 저장.
                                self.selected_category = main_vm.user_selected_tag_list[tag_index]
                            }
                        }){
                            
                            Text(main_vm.user_selected_tag_list[tag_index])
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .font(.custom(Font.n_bold, size: 14))
                                .foregroundColor(.proco_white)
                            
                        })
            }
        }
    }
    var selected_tag_btn: some View{
        HStack{
            ForEach(0..<main_vm.user_selected_tag_list.count, id: \.self){ tag_index in
                
                if main_vm.category_tag_struct.contains(where: {
                    $0.category_name == main_vm.user_selected_tag_list[tag_index]
                }){}
                else{
                    Image("small_x")
                        .resizable()
                        .frame(width: 5, height: 5)
                    
                    Button(action: {
                        print("선택한 태그 리스트들 확인\(main_vm.user_selected_tag_list) ")
                        
                        print("선택한 태그 리스트들 중 현재 선택한 것 확인 : \(main_vm.user_selected_tag_list[tag_index])")
                        if main_vm.user_selected_tag_set.contains(main_vm.user_selected_tag_list[tag_index]){
                            print("이미 선택한 태그")
                            main_vm.user_selected_tag_set.remove(main_vm.user_selected_tag_list[tag_index])
                            self.main_vm.user_selected_tag_list = Array(self.main_vm.user_selected_tag_set)
                            
                            
                        }else{
                            print("새로 선택한 태그")
                            main_vm.user_selected_tag_set.insert(main_vm.user_selected_tag_list[tag_index])
                            self.main_vm.user_selected_tag_list = Array(self.main_vm.user_selected_tag_set)
                            
                        }
                    }){
                        HStack{
                            Image("tag_sharp")
                                .resizable()
                                .frame(width: 16, height: 16)
                            
                            Text(main_vm.user_selected_tag_list[tag_index])
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)                                .font(.custom(Font.n_bold, size: 14))
                                .foregroundColor(.proco_black)
                        }
                    }
                }
            }
        }
    }
    
    var date_view : some View{
        HStack{
            Text("날짜")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_black).font(.callout)
            
            Spacer()
            //in: 은 미래 날짜만 선택 가능하도록 하기 위함, displayedComponents는 시간을 제외한 날짜만 캘린더에 보여주기 위함.
            DatePicker("", selection: $main_vm.card_date, in: Date()..., displayedComponents: .date)
                //다이얼로그식 캘린더 스타일
                .datePickerStyle(CompactDatePickerStyle())
                .environment(\.locale,Locale.init(identifier: "ko_KR"))
            
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
            
            DatePicker("시간을 설정해주세요", selection: $main_vm.card_time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle( GraphicalDatePickerStyle())
                .environment(\.locale,Locale.init(identifier: "ko_KR"))
        }
        .padding()
    }
    
    var meeting_introduce_field : some View{
        VStack{
            HStack{
                Text("모임 소개")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                
                Text("\(self.introduce_txt_count)/255")
                    .foregroundColor(Color.gray)
                    .font(.custom(Font.n_regular, size: 10))
                Spacer()
            }
            .padding([.top, .leading])
            //여러줄의 텍스트 입력을 위해서는 text editor 사용.
            //text에는 바인딩값만 넣을 수 있음
            TextEditor(text: self.$main_vm.input_introduce)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(self.main_vm.input_introduce == "내용을 입력해주세요" ? .gray : .primary)
                .colorMultiply(Color.light_gray)
                .cornerRadius(3)
                .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.4)
                .onChange(of: self.main_vm.input_introduce) { value in
                    print("그룹 소개 onchange 들어옴")
                    //현재 몇 글자 작성중인지 표시
                    self.introduce_txt_count = "\(value.count)"
                    if value.count > 1000 {
                        print("그룹 소개 1000글자 넘음")
                        self.main_vm.input_introduce = String(value.prefix(1000))
                    }
                }
                //텍스트 에디터의 placeholder값 넣기 위해
                .onAppear{
                    // 키보드가 나타나면 placeholder값 지움
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                        withAnimation {
                            if self.main_vm.input_introduce == "내용을 입력해주세요" {
                                self.main_vm.input_introduce = ""
                            }
                            
                        }
                        
                        // 사용자가 입력하지 않고 키보드를 다시 내렸을 경우 placeholder 다시 보여줌
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                            withAnimation {
                                if self.main_vm.input_introduce == "" {
                                    self.main_vm.input_introduce = "내용을 입력해주세요"
                                }
                            }
                        }
                    }
                }
        }
    }
}



