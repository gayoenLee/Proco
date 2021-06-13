//
//  ImagePicker.swift
//  proco
//
//  Created by 이은호 on 2020/12/06.
//

import Foundation
import SwiftUI
import Combine
 
extension View {
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
         
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
         
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
         
        // here is the call to the function that converts UIView to UIImage: `.asImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}
 
extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
 
struct ImagePicker: UIViewControllerRepresentable {
 
    @Environment(\.presentationMode)
    var presentationMode
 
    @Binding var image: Image?
    @Binding var image_url : String?
    @Binding var ui_image : UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
 
        @Binding var presentationMode: PresentationMode
        @Binding var image: Image?
        @Binding var image_url : String?
        @Binding var ui_image : UIImage?

        init(presentationMode: Binding<PresentationMode>, image: Binding<Image?>, image_url : Binding<String?>, ui_image: Binding<UIImage?>) {
            _presentationMode = presentationMode
            _image = image
            _image_url = image_url
            _ui_image = ui_image
        }
 
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
          
            image = Image(uiImage: uiImage)
            try! image_url = String(describing: info[UIImagePickerController.InfoKey.imageURL])
            print("이미지 경로: \(String(describing: image_url))")
            ui_image = uiImage
            presentationMode.dismiss()
 
        }
 
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
 
    }
 
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, image: $image, image_url: $image_url, ui_image: $ui_image)
    }
 
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
 
}
