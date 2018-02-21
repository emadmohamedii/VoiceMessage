//
//  DynamoDB.swift
//  VoiceMessage
//
//  Created by SIN on 2018/02/18.
//  Copyright © 2018年 SAPPOROWORKS. All rights reserved.
//

import Foundation
import AWSDynamoDB

protocol DynamoDBDelegate {
    func finishPutItem(model: AWSDynamoDBObjectModel & AWSDynamoDBModeling, error: Error?)
    func finishGetItem(model: AWSDynamoDBObjectModel & AWSDynamoDBModeling, error: Error?)
}

class DynamoDB {
    
    var delegate: DynamoDBDelegate?
    
    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:PoolId)
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }

    func putItem(model: AWSDynamoDBObjectModel & AWSDynamoDBModeling) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.save(model, completionHandler: { (error: Error?) -> Void in
            self.delegate?.finishPutItem(model: model, error: error)
        })
    }

    func getItem(resultClass: AnyClass, hashKey: Any) {
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDBObjectMapper.load(VoiceItem.self, hashKey: hashKey, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? VoiceItem {
                print(resultBook)
            }
            return nil
        })
        
        
//        dynamoDBObjectMapper.load(VoiceItem.self, hashKey: hashKey, rangeKey: nil).continueWith { (task:AWSTask<AnyObject>) -> Any? in
//            self.delegate?.finishGetItem(model: task.result as! AWSDynamoDBObjectModel & AWSDynamoDBModeling, error: task.error)
//        }
    }
}


