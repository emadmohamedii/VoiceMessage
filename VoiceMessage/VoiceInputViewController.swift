//
//  VoiceInputViewController.swift
//  VoiceMessage
//
//  Created by SIN on 2018/02/17.
//  Copyright © 2018年 SAPPOROWORKS. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceInputViewController: UIViewController {

    @IBOutlet weak var micButton: UIButton!
    
    let audio = Audio.shared
    var voice:Voice!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func startRecording(_ sender: Any) {
        audio.recordStart(url: voice.url!)
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        audio.recordStop()
        performSegue(withIdentifier: "finishRecordingSeque", sender: self)
    }

    @IBAction func touchUpOutsideMicButton(_ sender: Any) {
        audio.recordStop()
    }
}
