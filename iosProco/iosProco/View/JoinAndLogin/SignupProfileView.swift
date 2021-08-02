//
//  signup_profile_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/11.
//

import SwiftUI
import Combine
import Alamofire
import SwiftyJSON
import SDWebImage

struct SignupProfileView: View {
    @Environment(\.presentationMode) var presentation

    //회원가입 정보들 저장할 곳
    @StateObject var info_viewmodel :  SignupViewModel
    //이미지 선택 sheet 보여줄지 구분하는 변수
    @State private var show_image_picker = false
    
    //선택한 이미지 보여주기
    @State private var selected_image: Image? = nil
    @State private var image_data : Data = Data()
    
    //회원가입 성공시 alert창 나타내기 위해 변수값으로 구분
    @State private var login_success : Bool = false
    //회원가입시 오류 발생했을 때 처음으로 돌려보내기 위함.
    @State private var login_fail : Bool = false
    @State private var image_url : String? = ""
    @State private var ui_image : UIImage? = nil
    
    //닉네임 값 - 뷰모델값 쓰면 publish돼서 화면 전환 문제 일어나서 state값 씀.
    @State private var nickname: String = ""
    
    var body: some View {
     
        VStack(alignment: .center){
            HStack{
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()

                    }){
                    Image("left")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                    }
                Spacer()
            Text("프로필 정보 입력")
                .font(.custom(Font.n_extra_bold, size: 20))
                .foregroundColor(Color.proco_black)
                Spacer()
            }
            .padding()
            
            //프로필 이미지, 프로필 변경 아이콘 스택
            HStack(alignment: .center){
                //프로필 이미지 옆 작은 변경 아이콘 겹쳐서 보여주기 위함
                Spacer()
                Group{
                    
                    if selected_image != nil{
                        Button(action: {
                            //이 버튼으로 이미지 선택 sheet값 변경함.
                            self.show_image_picker.toggle()
                        }){
                            self.selected_image!
                                .resizable()
                                //이미지 채우기
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                                .clipShape(Circle())
                        }
                    }
                    
                    else{
                        
                        Button(action: {
                            //이 버튼으로 이미지 선택 sheet값 변경함.
                            self.show_image_picker.toggle()
                        }){
                            Image("profile_img")
                                .resizable()
                                //이미지 채우기
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                        }
                    }
                }
                Spacer()
            }
            TextField("닉네임 최대 15글자", text: self.$nickname)
                .font(.custom(Font.n_regular, size: 15))
                //IOS14부터 onchange사용 가능
                .onChange(of: self.nickname) { value in
                    print("닉네임 onchangee 들어옴")
                   if value.count > 15 {
                    print("닉네임 15글자 넘음")
                    self.nickname = String(value.prefix(15))
                    print("닉네임 확인: \(self.nickname)")
                  }
              }
                .padding()
                .background(Color.proco_white)
                .cornerRadius(25.0)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding([.top,.leading, .trailing], UIScreen.main.bounds.width/20)
            Spacer()
            //클릭시 회원가입 정보 모두 서버에 보내는 통신
            Button(action:{
                //이메일값 뷰모델에 저장
                //self.info_viewmodel.nickname = self.nickname
                
                //이미지 데이터를 UIImage로 변환해서 jpeg로 만듬.
                if selected_image != nil{
                let ui_image : UIImage = self.selected_image.asUIImage()
                image_data = ui_image.jpegData(compressionQuality: 0.2) ?? Data()
                }
                
                let fcm_token = UserDefaults.standard.string(forKey: "fcm_token") ?? ""
                print("핸드폰 : \(info_viewmodel.phone_number), password: \(info_viewmodel.password), nickname: \(info_viewmodel.nickname), marketing_yn: \(info_viewmodel.marketing_term_ok), auth_num: \(info_viewmodel.auth_num)")
                //회원가입 정보 보내는 통신 진행.
                send_user_info(fcm_token: fcm_token)
            }){
                Text("가입 완료")
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.proco_white)
                    .background(Color.proco_black)
                    .cornerRadius(25)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
            }
            
            HStack{
            //회원가입에 성공했을 경우 메인화면으로 보내기, 네비게이션 뷰에서 버튼 없이 화면 이동 가능한 방법.
            NavigationLink("", destination: EnrolledFriendListView(), isActive: self.$login_success)
            //07 29  베타 출시 전 소셜로그인 제거 -> 일반로그인페이지로 변경
            NavigationLink("", destination: NormalLoginView(), isActive: self.$login_fail)
            
            //프로필 이미지 선택시 갤러리
            NavigationLink("", destination:  ImagePicker(image: self.$selected_image, image_url: self.$image_url, ui_image: self.$ui_image), isActive: self.$show_image_picker)
            }.frame(width: 0, height: 0)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background( Image("signup_fifth")
                         .resizable()
                         .scaledToFill())
        .alert(isPresented: $login_fail){
            Alert(title: Text(""), message: Text("회원가입 중 오류가 발생했습니다. 다시 시도해주세요"), dismissButton: .default(Text("확인")))
        }
    }
    
    //이미지 파일로 저장하기
    func send_profile_image(){
        APIClient.upload(image: image_data, to: APIRouter.send_profile_image(profile_image: image_data), completion: { result in
            if result.exists(){
                //프로필 이미지는 회원가입시 필수가 아님
                print("이미지 결과 확인 : \(result)")
                let result_string = result["result"].string
                if (result_string == "ok"){
                    //self.login_success = true
                    let profile_photo_path = result["profile_photo_path"].string
                    UserDefaults.standard.set(profile_photo_path, forKey: "profile_photo_path")
                    
                    ViewRouter.get_view_router().init_root_view = "enrolled_friend"
                    
                }else{
                    self.login_fail = true
                }
            }
        })
    }
    
    //회원가입 정보 전송
    func send_user_info(fcm_token: String){
        
        APIClient.send_user_info_api(phone: info_viewmodel.phone_number, email: "", password: info_viewmodel.password, gender: 0, birthday: "", nickname: self.nickname, marketing_yn: info_viewmodel.marketing_term_ok, auth_num: info_viewmodel.auth_num, sign_device: "ios", update_version: "test_version", fcm_token: fcm_token,completion: {result in
            switch result{
            case .success(let result):
                print("회원가입 성공, 다음 화면 이동 boolean : \(login_success)")
                print(result)
                
                if result.result == "signup_done"{
                    print("받은 토큰 확인 : \(result.refresh_token)")
                    
                    //회원가입 완료 후 토큰 저장
                    let user_id = result.idx
                    let user_nickname = result.nickname
                    let user_access = result.access_token
                    let user_refresh = result.refresh_token
                    print("서버한테 받은 리절트값 : \(result)")
                    
                    print("회원가입 토큰 저장하는 값 확인 : \(user_refresh)")
                    UserDefaults.standard.set(user_refresh, forKey: "refresh_token")
                    UserDefaults.standard.set(user_access, forKey: "access_token")
                    UserDefaults.standard.set(user_id, forKey: "user_id")
                    UserDefaults.standard.set(self.nickname, forKey: "nickname")
                
                    UserDefaults.standard.set(info_viewmodel.phone_number, forKey: "phone_number")
                    
                    print("스토리지에 저장한 값 확인: \(String(describing: UserDefaults.standard.string(forKey: "access_token")))")
                    
                    //서버 통신은 성공했으나 회원가입이 안된 경우 회원가입 다시 하라고 alert/서비스 첫 화면으로 돌려 보내기
                    if image_data.count > 0{
                        
                    send_profile_image()
                        
                    }else{
                        
                        ViewRouter.get_view_router().init_root_view = "enrolled_friend"
                    }
                }else{
                    self.login_success = false
                    self.login_fail.toggle()
                    print("회원가입 정보 전송에서 result를 signupdone이 아닌 다른 것 받음 : \(result)")
                }
            case .failure(let error):
                print("회원가입 실패 : \(error)")
                login_fail.toggle()
            }
            
        })
    }
}

