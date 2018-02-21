//
//  ViceList.swift
//  VoiceMessage
//
//  Created by SIN on 2018/02/17.
//  Copyright © 2018年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import AWSS3
import AWSDynamoDB

protocol VoiceRepositoryDelegate {
    func changed()
}

class VoiceRepository {
    
    var delegate: VoiceRepositoryDelegate?
    var voiceList: Array<Voice> = []
    

    let dynamoDB = DynamoDB()
    
    let s3 = S3()
    let backetName = "ios-voice-message-skill"
    let contentType = "audio/x-caf"
    
    init() {
        s3.delegate = self
        dynamoDB.delegate = self
        
        s3.list(bucketName: backetName)
    }
    
    var count: Int {
        get {
            return voiceList.count
        }
    }
    
    func append(voice: Voice) {
        voiceList.insert(voice, at: 0)
        let dateUnix = String(voice.dateUnix)
        let keyName = "\(dateUnix).caf"
        s3.upload(bucketName: backetName, keyName: keyName, url: voice.url!, contentType: contentType)
    }
    
    func remove(at index: Int) {
        let dateUnix = String(voiceList[index].dateUnix)
        s3.delete(bucketName: backetName, keyName: "\(dateUnix).caf")
        s3.delete(bucketName: backetName, keyName: "\(dateUnix).mp3")
        voiceList.remove(at: index)
    }
    
    func getVoice(index: Int) -> Voice {
        return voiceList[index]
    }
    
    func createUrl(fileName:String)-> URL {
        let fileManager = FileManager()
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) as [NSURL]
        let dirURL = urls[0]
        return dirURL.appendingPathComponent(fileName)!
    }
}
extension  VoiceRepository: DynamoDBDelegate {

    func finishPutItem(model: AWSDynamoDBObjectModel & AWSDynamoDBModeling, error: Error?) {
        if let error = error {
            print("DynamoDB put Error: \(error)")
            return
        }
    }
    
    func finishGetItem(model: AWSDynamoDBObjectModel & AWSDynamoDBModeling, error: Error?) {
        if let error = error {
            print("DynamoDB get Error: \(error)")
            return
        }
    }
}

extension  VoiceRepository: S3Delegate {
    
    func finishDownload(bucketName: String, keyName: String, error: Error?) {
        finish(title: "download", bucketName: backetName, keyName: keyName, error: error)
    }
    
    func finishUpload(bucketName: String, keyName: String, error: Error?) {
        finish(title: "upload", bucketName: backetName, keyName: keyName, error: error)
    }
    
    func finishDelete(bucketName: String, keyName: String, error: Error?) {
        finish(title: "delete", bucketName: backetName, keyName: keyName, error: error)
    }
    
    private func finish(title:String, bucketName: String, keyName: String, error: Error?) {
        if error != nil {
            print("\(title) error Bucket:\(bucketName) Key:\(keyName) \(error.debugDescription)")
        } else {
            print("\(title) success Bucket:\(bucketName) Key:\(keyName)")
            delegate?.changed()
        }
    }

    func finishList(objects: [AWSS3Object]) {
        for object in objects {
            if let fileName = object.key {
                if fileName.contains(".caf") {
                    let url = createUrl(fileName: fileName)
                    print(url.path)
                    s3.download(bucketName: backetName, keyName: fileName, url: url)
                    
                    let unixDateStr = fileName.replacingOccurrences(of:".caf", with:"")
                    let unixDate = NSString(string: unixDateStr).doubleValue
                    let date = Date(timeIntervalSince1970: unixDate)
                    let voice = Voice(date: date, url: url)
                    voiceList.insert(voice, at: 0)
                }
            }
        }
        delegate?.changed()
    }
}
