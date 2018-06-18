//
//  CameraViewController.swift
//  Best Friend Match
//
//  Created by Alexander K. White on 6/18/18.
//  Copyright © 2018 Alexander K. White. All rights reserved.
//

import UIKit
import AWSCore
import AWSMobileClient
import AWSS3
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let mediaHelper = MediaHelper()
    
    @IBOutlet var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func uploadImageButtonTapped(_ sender: UIButton) {
        let imageData = UIImageJPEGRepresentation(imageView.image!, 0.6) as Data?
        mediaHelper.uploadMedia(mediaData: imageData!, mediaID: "mobileTest")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    // MARK: -UIImagePicker ControllerDelegate Methods
    
    func imagePickerController(_ picked: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

class MediaHelper {
    
    var transferManager: AWSS3TransferManager!
    
    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:AWSRegionType.USEast2,
                                                                identityPoolId:"us-east-2:a28a038b-8d56-4a9a-bf44-06b7daa67308")
        let configuration = AWSServiceConfiguration(region:AWSRegionType.USEast2, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        self.transferManager = AWSS3TransferManager.default()
    }
    
    func uploadMedia(mediaData: Data, mediaID: String) {
        
        let uploadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(mediaID)
        do {
            try mediaData.write(to: uploadingFileURL, options: Data.WritingOptions.atomic)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        
        uploadRequest.bucket = "bestfriendpets"
        uploadRequest.key = mediaID + ".jpg"
        uploadRequest.body = uploadingFileURL
        uploadRequest.contentType = "image/jpeg"
        transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as NSError? {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(uploadRequest.key!) Error: \(error)")
                    }
                } else {
                    print("Error uploading: \(uploadRequest.key!) Error: \(error)")
                }
                return nil
            }
            
            let uploadOutput = task.result
            print("Upload complete for: \(uploadRequest.key!)")
            return nil
        })
    }
    
}
