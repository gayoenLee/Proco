//
//  EditProfilePhotoView.swift
//  proco
//
//  Created by 이은호 on 2021/05/31.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {
    let configuration: PHPickerConfiguration
    @Binding var pickerResult: UIImage?
    @Binding var isPresented: Bool
    //프로필 이미지 변경시, 모임 카드 이미지 추가시 같이 사용해서 구분하기 위해 추가
    var is_profile_img : Bool
    @ObservedObject var main_vm : SettingViewModel
    @ObservedObject var group_vm : GroupVollehMainViewmodel
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// PHPickerViewControllerDelegate => Coordinator
    class Coordinator: PHPickerViewControllerDelegate {
        
        private let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            for image in results {
                if image.itemProvider.canLoadObject(ofClass: UIImage.self)  {
                    
                    print("이미지 뭔지 확인: \(image)")
                    image.itemProvider.loadObject(ofClass: UIImage.self) { (newImage, error) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            print("리절트를 어펜드함: \(String(describing: newImage))")
                            //뷰에 보여주기 위해 넣는 것.
                            self.parent.pickerResult = newImage as! UIImage
                            
                            //이미지 데이터를 UIImage로 변환해서 jpeg로 만듬.
                            let ui_image : UIImage = newImage as! UIImage
                            print("ui image 확인: \(ui_image)")
                          let image_data = ui_image.jpegData(compressionQuality: 0.2) ?? Data()
                     print("이미지 데이터 확인: \(image_data)")
                            if self.parent.is_profile_img{
                            //프로필 이미지 변경 통신
                            self.parent.main_vm.send_profile_image(image_data: image_data)
                                
                            }else{
                                //모임 이미지 추가시
                                self.parent.group_vm.group_card_img_data = image_data
                            }
                        }
                    }
                } else {
                    print("Loaded Assest is not a Image")
                }
            }
            // dissmiss the picker
            parent.isPresented = false
        }
    }
}
