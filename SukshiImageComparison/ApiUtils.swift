//
//  ApiUtils.swift
//  SukshiImageComparison
//
//  Created by Pavan Kalyan Jonnadula on 13/05/20.
//  Copyright © 2020 Pavan Kalyan Jonnadula. All rights reserved.
//

import Foundation
open class ApiUtils : NSObject,URLSessionDelegate{
    public typealias HttpRequestCompletionBlock = (Any?, URLResponse?, Error?) -> Void

    private var completionHandler: HttpRequestCompletionBlock?
    public static let shared = ApiUtils()
    var sharedSession : URLSession!
    public override init() {
        super.init()
        self.sharedSession = URLSession(configuration: URLSessionConfiguration.default,delegate: self,delegateQueue: OperationQueue.main) as URLSession
//        self.completionHandler = HttpRequestCompletionBlock
    }
  
    public func commentsuploadFileRequest(params: [String : String],mediaData1 : Data,mediaUploadKey1 : String,mediaData2 : Data, mediaUploadKey2 : String,requestCompletion: HttpRequestCompletionBlock?) {
        guard let _url = URL(string: "https://staging.vishwamcorp.com/v2/me/reference_ios") else {
            print("the url failure")
            return
        }
        var req = URLRequest(url: _url)
        req.httpMethod = "post"
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)",forHTTPHeaderField: "Content-Type")
        req.addValue("aab74e8bcbfc8506215c20eb59270e49", forHTTPHeaderField: "X-CallId")
        
        req.httpBody = commentsCreateBodyForUploadFile(parameters: params, boundary: boundary, data1: mediaData1, filename1: "image.jpg", mediaUploadKey1: "image", data2: mediaData2, filename2: "image2.jpg", mediaUploadKey2: "image2")
        
        let task = sharedSession.uploadTask(with: req,from: nil) { data, resp, er in
            OperationQueue.main.addOperation {
                if let d = data, let jsonObj = try? JSONSerialization.jsonObject(with: d,options: JSONSerialization.ReadingOptions.allowFragments) {
                    requestCompletion!(jsonObj, resp, er)
                }
            }
        }
        task.resume()
    }
    public func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential,URLCredential(trust: challenge.protectionSpace.serverTrust!)
        )
    }
    
    private func commentsCreateBodyForUploadFile(parameters: [String: String], boundary: String, data1 : Data, filename1 : String, mediaUploadKey1 :String ,data2 : Data, filename2 : String, mediaUploadKey2 :String) -> Data {
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(mediaUploadKey1)\"; filename=\"\(filename1)\"\r\n")
        body.appendString("Content-Type: image/*\r\n\r\n")
        body.append(data1)
        body.appendString("\r\n")
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(mediaUploadKey2)\"; filename=\"\(filename2)\"\r\n")
        body.appendString("Content-Type: image/*\r\n\r\n")
        body.append(data2)
        body.appendString("\r\n")
        
        body.appendString("--".appending(boundary.appending("--")))
        
        return body as Data
    }
}

fileprivate extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: false
        )
        append(data!)
    }
}
