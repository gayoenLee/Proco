//
//  NotificationService.swift
//  NotiServiceExtension
//
//  Created by 이은호 on 2021/03/25.
// fcm 노티 관련 클래스

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    //받은 데이터를 수정할 수 있는 부분.
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // 여기에서 노티 컨텐츠 변경
            
            //이미지인 경우
            guard let kinds = request.content.userInfo["kinds"] as? String else{
                contentHandler(bestAttemptContent)
                return
            }
            
            if kinds != nil || kinds != ""{
                
                //사진을 보낸 경우 메세지 컨텐츠 변경
                if kinds == "P"{
                    bestAttemptContent.body = "사진을 보냈습니다"
                }
            }
            
            guard let imageData = request.content.userInfo["fcm_options"] as? [String : Any]else{
                contentHandler(bestAttemptContent)
                return
            }
            
            if let urlImageString = imageData["image"] as? String {
                let attachmenturl = URL(string: urlImageString)
                
                download(url: attachmenturl!, completionHandler: {attach in
                    if let attach = attach{
                        bestAttemptContent.attachments = [attach]
                        contentHandler(bestAttemptContent)
                    }
                })
            }
        }
    }
    
    func download(url: URL, completionHandler : @escaping(UNNotificationAttachment?) -> Void){
        let task = URLSession.shared.downloadTask(with: url){(downloadedurl, response, error) in
            
            guard let downloadedurl = downloadedurl else{
                completionHandler(nil)
                return
            }
            
            var urlpath = URL(fileURLWithPath: NSTemporaryDirectory())
            
            let uniqueurlending = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
            urlpath = urlpath.appendingPathComponent(uniqueurlending)
            
            try? FileManager.default.moveItem(at: downloadedurl, to: urlpath)
            
            do{
                let attachment = try UNNotificationAttachment(identifier: "picture", url: urlpath, options: nil)
                completionHandler(attachment)
            }
            catch{
                completionHandler(nil)
            }
        }
        task.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            
            contentHandler(bestAttemptContent)
        }
    }
}
