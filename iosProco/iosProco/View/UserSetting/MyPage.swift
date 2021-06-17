//
//  MyPage.swift
//  proco
//
//  Created by 이은호 on 2020/11/24.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct MyPage: View {
    
    @ObservedObject var main_vm : SettingViewModel
    
    @State private var user_nickname = ""

    //프로필 이미지값
    @State private var profile_photo_path: String = ""
    
    //이미지 원처럼 보이게 하기 위해 scale값을 곱함.
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 150, height: 150)) |> RoundCornerImageProcessor(cornerRadius: 40)
    
    //관심 친구 리스트 보러가기 이동값
    @State private var go_interest_friends : Bool = false
    //관심카드 보러가기 이동값
    @State private var go_like_cards: Bool = false
    //이미지 선택 sheet 보여줄지 구분하는 변수
    @State private var show_image_picker = false
        
    @State var pickerResult: [UIImage] = []
       var config: PHPickerConfiguration  {
          var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        //videos, livePhotos...등도 넣을 수 있음.
           config.filter = .images
        //0은 제한 없음을 의미, 갯수 제한 두는 것.
           config.selectionLimit = 1 //0 => any, set 1-2-3 for har limit
           return config
       }
    //닉네임 편집 뷰로 이동값
    @State private var go_to_edit_name : Bool = false
    
    var body: some View {
        VStack {
            NavigationLink("",destination: MyInterestFriendsListView(main_vm: self.main_vm), isActive: self.$go_interest_friends)
            
            NavigationLink("",destination: MyLikeCardsListView(main_vm: self.main_vm), isActive: self.$go_like_cards)
            
            //내 프로필
            profile_photo_view
            Group{
                HStack{
                        Text("\(self.user_nickname)")
                            .padding(.trailing, UIScreen.main.bounds.width/20)
                            
                    Spacer()
                    
                    Image("right_light")
                        .resizable()
                        .frame(width: 5.62, height: 11.74)
                    
                }.padding()
                .onTapGesture {
                    print("닉네임 변경 클릭")
                    self.go_to_edit_name = true
                }
            }
            
            List{
                watch_interest_friends
                watch_my_interest_cards
            }
            Spacer()
        }
        .navigationBarTitle(Text("마이페이지"))
        .navigationBarHidden(false)
        //갤러리 나타나는 것.
        .sheet(isPresented: $show_image_picker) {
            PhotoPicker(configuration: self.config,
                        pickerResult: $pickerResult,
                        isPresented: $show_image_picker,is_profile_img: true, main_vm: self.main_vm, group_vm : GroupVollehMainViewmodel())
        }
        .popover(isPresented: self.$go_to_edit_name, content: {
            EditNicknameView(open_view: self.$go_to_edit_name, nickname: self.$user_nickname, main_vm: self.main_vm)
        })
        .onAppear{
            self.main_vm.get_detail_user_info(user_idx: Int(self.main_vm.my_idx!)!)
            
            self.user_nickname = main_vm.nickname!
            print("마이페이지에서 프로필 이미지 확인: \(String(describing: self.main_vm.user_info_model.profile_photo_path))")
        }
        .onDisappear{
        }
    }
}

private extension MyPage {
    
    var profile_photo_view : some View{
        
        HStack(alignment: .center){
            //프로필 이미지 + 작은 변경 아이콘함
            Spacer()
            VStack{
                
                if self.main_vm.user_info_model.profile_photo_path == "" && pickerResult.count  == 0{
                    
                    Image("main_profile_img")
                        .resizable()
                        .frame(width: 154.26, height: 154.26)
                    
                }else if pickerResult.count > 0{
                    
                    ForEach(pickerResult, id: \.self) { image in
                        Image.init(uiImage: image)
                            .resizable()
                            //이미지 채우기
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                            .clipShape(Circle())
                    }
                }else{
                    
                    KFImage(URL(string: self.main_vm.user_info_model.profile_photo_path!))
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
                }
                
                Button(action: {
                    //이 버튼으로 이미지 선택 sheet값 변경함.
                    self.show_image_picker.toggle()
                    //self.show_select_img_view = true
                }){
                    Text("프로필 사진 바꾸기")
                        .font(.custom(Font.n_bold, size: 14))
                        .foregroundColor(Color.proco_blue)
                }
            }
            //가운데 정렬시키기 위한 공간
            Spacer()
        }
    }
    
    var watch_interest_friends : some View{
        
        HStack{
            Text("내 관심친구들")
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
            Spacer()
            Image("right_light")
                .resizable()
                .frame(width: 5.62, height: 11.24)
        }
        .onTapGesture {
            print("내 관심친구 리스트 보기 클릭")
            self.go_interest_friends = true
        }
    }
    
    var watch_my_interest_cards: some View{
        HStack{
            Text("내가 좋아요한 카드")
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
            Spacer()
            
            Image("right_light")
                .resizable()
                .frame(width: 5.62, height: 11.24)
            
        }
        .onTapGesture {
            print("내가 좋아요한 카드 보기 클릭")
            self.go_like_cards = true
        }
    }
}

