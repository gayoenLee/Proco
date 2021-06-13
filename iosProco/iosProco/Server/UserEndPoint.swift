////
////  UserEndPoint.swift
////  proco
////
////  Created by 이은호 on 2020/12/03.
////
//
//import Alamofire
//import Foundation
//
//
////AF.request안에 들어갈 메소드들 정리한 것.
//public protocol APIConfiguration: URLRequestConvertible {
//    var method: HTTPMethod { get }
//    var path: String { get }
//    var parameters: Parameters? { get }
//}
//
////라우터별로 enum만든 것.
//enum UserEndpoint: APIConfiguration {
//
//    case phone_auth(phone_num: String, type: String)
//    case check_phone_auth(phone_num: String, auth_num: String, type: String)
//    //회원가입 마지막 정보 보낼 때
//    case send_profile_image(profile_image: Data)
//    case send_signup_info(phone: String, email: String, password: String, gender: Int, birthday: String, nickname: String, marketing_yn: Int, auth_num: String, sign_device: String, update_version: String)
//
//
//    // MARK: - HTTPMethod
//    var method: HTTPMethod {
//        switch self {
//        case .phone_auth:
//            return .post
//        case .check_phone_auth:
//            return .post
//        case .send_profile_image:
//            return .post
//        case .send_signup_info:
//            return .post
//        }
//    }
//
//    // MARK: - Path
//    var path: String {
//        switch self {
//        case .phone_auth:
//            return "/auth/phone-number"
//        case .check_phone_auth:
//            return "/auth/phone-number"
//        case .send_profile_image:
//            return "/users"
//        case .send_signup_info:
//            return "/users"
//        }
//    }
//
//    // MARK: - Parameters
//    var parameters: Parameters? {
//        switch self {
//        case .phone_auth(let phone_num, let type):
//            return [Keys.PhoneAuthKey.phone_num: phone_num, Keys.PhoneAuthKey.type: type]
//        case .check_phone_auth(let phone_num, let auth_num, let type):
//            return [Keys.CheckPhoneAuthKey.phone_num: phone_num, Keys.CheckPhoneAuthKey.auth_num: auth_num, Keys.CheckPhoneAuthKey.type: type]
//        case .send_profile_image(let profile_image):
//            return  [Keys.SendProfileImageKey.profile_image: profile_image]
//        case .send_signup_info(let phone, let email, let password, let gender, let birthday, let nickname, let marketing_yn, let auth_num, let sign_device, let update_version):
//        return [Keys.SendSignupInfoKey.phone: phone, Keys.SendSignupInfoKey.email: email, Keys.SendSignupInfoKey.password: password, Keys.SendSignupInfoKey.gender: gender, Keys.SendSignupInfoKey.birthday: birthday, Keys.SendSignupInfoKey.nickname: nickname, Keys.SendSignupInfoKey.marketing_yn: marketing_yn, Keys.SendSignupInfoKey.auth_num: auth_num, Keys.SendSignupInfoKey.sign_device: sign_device, Keys.SendSignupInfoKey.update_version: update_version]
//        }
//    }
//
//    // MARK: - URLRequestConvertible
//    func asURLRequest() throws -> URLRequest {
//        let url = try Keys.ProductionServer.base_url.asURL()
//        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
//                // HTTP Method
//        urlRequest.httpMethod = method.rawValue
//
//
//        switch self{
//        case .check_phone_auth, .phone_auth, .send_signup_info:
//        // Common Headers
//        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
//        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
//
//        case .send_profile_image:
//            urlRequest.setValue(ContentType.image.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
//            urlRequest.setValue(ContentType.image.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
//
//        }
//        // Parameters
//        if let parameters = parameters {
//            switch self{
//            case .check_phone_auth, .phone_auth, .send_signup_info:
//                do {
//                    print("라우터에서 파라미터")
//                    let checker = JSONSerialization.isValidJSONObject(parameters)
//                    print("라우터에서 체크 \(checker)")
//                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
//                }
//                catch {
//                    throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
//                }
//
//            case .send_profile_image(profile_image: let _):
//                urlRequest.httpBody = nil
//            }
//            }
//
//        return urlRequest
//    }
//
//    // MARK: MultipartFormData
//       var multipartFormData: MultipartFormData {
//           let multipartFormData = MultipartFormData()
//           switch self {
//           case .send_profile_image(let profile_image):
//               multipartFormData.append(profile_image, withName: "file", fileName: "file.png", mimeType: "image/png")
//           default: ()
//           }
//
//           return multipartFormData
//       }
//}
