//
//  ViewController.swift
//  DemoApp
//
//  Created by Pavan Kalyan Jonnadula on 14/05/20.
//  Copyright © 2020 Pavan Kalyan Jonnadula. All rights reserved.
//

import UIKit
import SukshiImageComparison

class ViewController: UIViewController , ImagePickerDelegate{
    //MARK : Outlets
    @IBOutlet weak var imageone: UIButton!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var imageTwo: UIButton!
    @IBOutlet weak var oneImageView: UIImageView!
    @IBOutlet weak var compareTwoImages: UIButton!
    @IBOutlet weak var activityIndicatorForLoading: UIActivityIndicatorView!
    var imagePicker: ImageProcessing!
    var oneIsEnable = false
    var imageOneData = Data()
    var imageTwoData = Data()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImageProcessing(presentationController: self, delegate: self)
        activityIndicatorForLoading.isHidden = true
    }
    
    @IBAction func imageOneAction(_ sender: UIButton) {
        oneIsEnable = true
        imagePicker.present(from: sender)
    }
    @IBAction func imageTwoAction(_ sender: UIButton) {
        oneIsEnable = false
        imagePicker.present(from: sender)

    }
    @IBAction func CompareImages(_ sender: Any) {
        if imageOneData.isEmpty || imageTwoData.isEmpty{
            showAlert(title: "Error", message: "First Select images and then compare")
            return
        }
        let params : [String : String] = ["type" : "1","app_id" : "vishwam" , "user_id" : "pavan" , "deviceOs" : "A" , "deviceId" : "c14e7fb1–4476–4b21-ba18–063-c35c0a3b" , "deviceIdType" : "IMEI" , "osVersion" : "7.1" , "deviceModel" : "samsung"]
        let requestApi = ApiUtils.init()
        activityIndicatorForLoading.isHidden = false
        requestApi.commentsuploadFileRequest(params: params, mediaData1: imageOneData, mediaUploadKey1: "image", mediaData2: imageTwoData, mediaUploadKey2: "image2") { (json, response, error) in
            print("the json data",json as Any)
            self.activityIndicatorForLoading.isHidden = true

            if let responseData = json as? NSDictionary{
                if let errorResponse = responseData.object(forKey: "error") as? String{
                    self.showAlert(title: "Error", message: errorResponse)
                    return
                }
                if let status = responseData.object(forKey: "status") as? String{
                    if status == "ok"{
                        let percent = responseData.object(forKey: "matchPercentage") as? String ?? ""
                        self.showAlert(title: "\(percent)%", message: "Match Percentage")
                    }else{
                        self.showAlert(title: "Error", message: "Something wentworng , Satus is not OK")
                        return
                    }
                }
            }
            else{
                self.showAlert(title: "Error", message: "Something went wrong , please try again")

            }
        }
    }
    func didSelect(image: UIImage, imageData: Data) {
        if oneIsEnable{
            imageOneData = imageData
            oneImageView.image = image
        }else{
            imageTwoData = imageData
            secondImageView.image = image
        }
    }
    
    func errorWhileSelectingPhoto(error: String) {
        showAlert(title: "Error", message: "Something went wrong , please try again")
    }
}

//MARK : Extensions
extension UIViewController {
    
    func showAlert(title: String?, message messageToShow: String?, buttonTitle: String = "Ok"){
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title ?? "",
                message: messageToShow ?? "",
                preferredStyle: UIAlertController.Style.alert
            )
            
            let defaultAction = UIAlertAction(
                title: buttonTitle,
                style: UIAlertAction.Style.cancel,
                handler: nil
            )
            
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
