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
    @ObservedObject var info_viewmodel :  SignupViewModel
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
                                .shadow(radius: 10)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
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
            TextField("닉네임 최대 15글자", text: self.$info_viewmodel.nickname)
                .font(.custom(Font.n_regular, size: 15))
                //IOS14부터 onchange사용 가능
                .onChange(of: self.info_viewmodel.nickname) { value in
                    print("닉네임 onchangee 들어옴")
                   if value.count > 10 {
                    print("닉네임 10글자 넘음")
                    self.info_viewmodel.nickname = String(value.prefix(10))
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
                //이미지 데이터를 UIImage로 변환해서 jpeg로 만듬.
                if selected_image != nil{
                let ui_image : UIImage = self.selected_image.asUIImage()
                image_data = ui_image.jpegData(compressionQuality: 0.2) ?? Data()
                }
                print("핸드폰 : \(info_viewmodel.phone_number) email: \(info_viewmodel.email), password: \(info_viewmodel.password), gender: \(info_viewmodel.gender), birthday: \(info_viewmodel.birth_string), nickname: \(info_viewmodel.nickname), marketing_yn: \(info_viewmodel.marketing_term_ok), auth_num: \(info_viewmodel.auth_num)")
                //회원가입 정보 보내는 통신 진행.
                send_user_info()
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
            
//테스트 위해 주석처리함*************************
            //회원가입에 성공했을 경우 메인화면으로 보내기, 네비게이션 뷰에서 버튼 없이 화면 이동 가능한 방법.
            NavigationLink("", destination: TabbarView(view_router: ViewRouter()), isActive: self.$login_success)

            NavigationLink("", destination: LoginMenuView(), isActive: self.$login_fail)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background( Image("signup_fifth")
                         .resizable()
                         .scaledToFill())
        //갤러리 나타나는 것.
        .sheet(isPresented: $show_image_picker, content:{
            ImagePicker(image: self.$selected_image, image_url: self.$image_url, ui_image: self.$ui_image)
        })
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
                    self.login_success = true

                }else{
                    self.login_success = true
                }
            }
        })
    }
    
    //회원가입 정보 전송
    func send_user_info(){
        
        APIClient.send_user_info_api(phone: info_viewmodel.phone_number, email: info_viewmodel.email, password: info_viewmodel.password, gender: info_viewmodel.gender, birthday: "1988-08-18", nickname: info_viewmodel.nickname, marketing_yn: info_viewmodel.marketing_term_ok, auth_num: info_viewmodel.auth_num, sign_device: "ios", update_version: "test_version", completion: {result in
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
                    let user_photo = result.profile_photo_path
                    
                    print("회원가입 토큰 저장하는 값 확인 : \(user_refresh)")
                    UserDefaults.standard.set(user_refresh, forKey: "refresh_token")
                    UserDefaults.standard.set(user_access, forKey: "access_token")
                    UserDefaults.standard.set(user_id, forKey: "user_id")
                    UserDefaults.standard.set(user_nickname, forKey: "nickname")
                    UserDefaults.standard.set(user_photo, forKey: "\(user_id)_photo")
                    
                    print("스토리지에 저장한 값 확인: \(String(describing: UserDefaults.standard.string(forKey: "access_token")))")
                   // print("저장한 access토큰값 확인 : \(global_state.access_token)" )
                    
                    //서버 통신은 성공했으나 회원가입이 안된 경우 회원가입 다시 하라고 alert/서비스 첫 화면으로 돌려 보내기
                    send_profile_image()
                    
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

