//
//  Audio.swift
//  VoiceMessage
//
//  Created by SIN on 2018/02/17.
//  Copyright © 2018年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import AVFoundation

class Audio: NSObject {
    
    static let shared = Audio()
    var audioRecorder: AVAudioRecorder?
    var adioPlayer: AVAudioPlayer?
    let session = AVAudioSession.sharedInstance()

    func recordStart(url: URL) {
        try! session.setCategory(AVAudioSessionCategoryRecord)
        try! session.setActive(true)
        let recordSetting : [String : AnyObject] = [
            AVEncoderAudioQualityKey : AVAudioQuality.min.rawValue as AnyObject,
            AVEncoderBitRateKey : 16 as AnyObject,
            AVNumberOfChannelsKey: 1 as AnyObject,
            AVSampleRateKey: 44100.0 as AnyObject,
            AVLinearPCMIsBigEndianKey: false as AnyObject,
            AVLinearPCMIsFloatKey: false as AnyObject
        ]
        do {
            try audioRecorder = AVAudioRecorder(url: url, settings: recordSetting)
        } catch {
            print("AVAudioRecorder initialize faild")
        }
        audioRecorder?.record()
    }

    func recordStop() {
        audioRecorder?.stop()
    }
    
    func play(url: URL) {
        if audioRecorder != nil {
            if (audioRecorder?.isRecording)! {
                audioRecorder?.stop()
            }
        }
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        do {
            try adioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("AVAudioPlayer initialize faild")
        }
        adioPlayer?.play()
    }
}
