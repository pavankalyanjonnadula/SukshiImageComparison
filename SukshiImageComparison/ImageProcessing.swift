//
//  ImageProcessing.swift
//  SukshiImageComparison
//
//  Created by Pavan Kalyan Jonnadula on 12/05/20.
//  Copyright © 2020 Pavan Kalyan Jonnadula. All rights reserved.
//

import Foundation
import UIKit

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage , imageData : Data)
    func errorWhileSelectingPhoto(error : String)
}

open class ImageProcessing : NSObject{

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    public func present(from sourceView: UIView) {
        self.pickerController.sourceType = .camera
        self.presentationController?.present(self.pickerController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage , imageData : Data) {
        controller.dismiss(animated: true, completion: nil)
        self.delegate?.didSelect(image: image, imageData: imageData)
    }
}

extension ImageProcessing: UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage{
            self.pickerController(picker, didSelect: image,imageData: image.jpegData(compressionQuality: 0.3)!)
        }else{
            self.delegate?.errorWhileSelectingPhoto(error: "Image not picked")
        }
        
    }
}
