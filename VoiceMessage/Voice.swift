//
//  Voice.swift
//  VoiceMessage
//
//  Created by SIN on 2018/02/17.
//  Copyright © 2018年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import AWSDynamoDB

class Voice {
    
    private var date: Date
    var url: URL? = nil
    var isRead: Bool = false

    init() {
        self.date = Date()
    }

    init(date:Date, url: URL) {
        self.date = date
        self.url = url
    }
    
    var dateUnix: Double {
        get{
            return date.timeIntervalSince1970
        }
    }
    
    var title: String {
        get{
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd(E) HH:mm:ss"
            return formatter.string(from: date)
        }
    }
    
    var item: VoiceItem {
        get {
            let item = VoiceItem()
            item?.dateUnix = String(dateUnix)
            item?.isRead = isRead
            return item!
        }
    }
}


class VoiceItem : AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    @objc var dateUnix:String?
    @objc var isRead:Bool = false
    
    static func dynamoDBTableName() -> String {
        return "ios-voice-message-skill"
    }
    
    class func hashKeyAttribute() -> String {
        return "dateUnix"
    }
}

