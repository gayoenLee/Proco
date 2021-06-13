//
//  ImageResizer.swift
//  proco
//
//  Created by 이은호 on 2021/05/10.
//

import UIKit

struct ImageResizer {
    static func resize(image: UIImage, maxByte: Int, completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentImageSize = image.jpegData(compressionQuality: 1.0)?.count else { return completion(nil) }
            
            var imageSize = currentImageSize
            var percentage: CGFloat = 1.0
            var generatedImage: UIImage? = image
            let percantageDecrease: CGFloat = imageSize < 10000000 ? 0.1 : 0.3
            
            while imageSize > maxByte && percentage > 0.01 {
                let canvas = CGSize(width: image.size.width * percentage,
                                    height: image.size.height * percentage)
                let format = image.imageRendererFormat
                format.opaque = true
                generatedImage = UIGraphicsImageRenderer(size: canvas, format: format).image {
                    _ in image.draw(in: CGRect(origin: .zero, size: canvas))
                }
                guard let generatedImageSize = generatedImage?.jpegData(compressionQuality: 1.0)?.count else { return completion(nil) }
                imageSize = generatedImageSize
                percentage -= percantageDecrease
            }
            
            completion(generatedImage)
        }
    }
}
