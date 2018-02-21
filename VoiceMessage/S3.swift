//
//  S3.swift
//  VoiceMessage
//
//  Created by SIN on 2018/02/18.
//  Copyright © 2018年 SAPPOROWORKS. All rights reserved.
//

import Foundation
import AWSS3


protocol S3Delegate {
    func finishList(objects: [AWSS3Object])
    func finishUpload(bucketName: String, keyName:String, error: Error?)
    func finishDownload(bucketName: String, keyName:String, error: Error?)
    func finishDelete(bucketName: String, keyName:String, error: Error?)
}

class S3 {
    
    var delegate: S3Delegate?
    
    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:PoolId)
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func upload(bucketName: String, keyName: String, url: URL, contentType: String) {
        let transferManager = AWSS3TransferManager.default()
        if let uploadRequest = AWSS3TransferManagerUploadRequest() {
            uploadRequest.bucket = bucketName
            uploadRequest.key = keyName
            uploadRequest.body = url
            uploadRequest.contentType = contentType
            transferManager.upload(uploadRequest).continueWith { (task: AWSTask) -> AnyObject? in
                self.delegate?.finishUpload(bucketName: bucketName, keyName: keyName, error: task.error)
                return nil
            }
        }
    }
    
    func download(bucketName: String, keyName: String, url: URL) {
        let transferManager = AWSS3TransferManager.default()
        if let downloadRequest = AWSS3TransferManagerDownloadRequest() {
            downloadRequest.bucket = bucketName
            downloadRequest.key = keyName
            downloadRequest.downloadingFileURL = url
            transferManager.download(downloadRequest).continueWith(block: { (task: AWSTask) -> Any? in
                self.delegate?.finishDownload(bucketName: bucketName, keyName: keyName, error: task.error)
                return nil
            })
        }
    }

    func delete(bucketName: String, keyName: String) {
        
        let s3 = AWSS3.default()
        if let deleteRequest = AWSS3DeleteObjectRequest() {
            deleteRequest.bucket = bucketName
            deleteRequest.key = keyName
            s3.deleteObject(deleteRequest).continueWith(block: { (task: AWSTask) -> Any? in
                self.delegate?.finishDelete(bucketName: bucketName, keyName: keyName, error: task.error)
                return nil
            })
        }
    }

    func list(bucketName: String) {
        let s3 = AWSS3.default()
        let listObjectsRequest = AWSS3ListObjectsRequest()
        listObjectsRequest?.bucket = bucketName
        s3.listObjects(listObjectsRequest!).continueWith { (task) -> AnyObject! in
            if let error = task.error {
                print("listObjects failed: [\(error)]")
            }
            
            if let listObjectsOutput = task.result {
                if let contents = listObjectsOutput.contents {
                    self.delegate?.finishList(objects: contents)
                }
            }
            return nil
        }
    }
}
