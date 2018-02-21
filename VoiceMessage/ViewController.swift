//
//  ViewController.swift
//  VoiceMessage
//
//  Created by SIN on 2018/02/17.
//  Copyright © 2018年 SAPPOROWORKS. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    var voiceRepository = VoiceRepository()

    @IBOutlet weak var tableView: UITableView!
    let audio = Audio.shared
    var newVoice: Voice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        voiceRepository.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    @IBAction func finishRecording(segue: UIStoryboardSegue) {
        voiceRepository.append(voice: newVoice!)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dist = segue.destination as? VoiceInputViewController {
            newVoice = Voice()
            let dateUnix = String(newVoice!.dateUnix)
            newVoice!.url = voiceRepository.createUrl(fileName: dateUnix + ".caf")
            dist.voice = newVoice
        }
    }
    
    func documentFilePath()-> URL {
        let fileManager = FileManager()
        let fileName = "sample.caf"
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) as [NSURL]
        let dirURL = urls[0]
        return dirURL.appendingPathComponent(fileName)!
    }
}

extension ViewController: VoiceRepositoryDelegate {
    func changed() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, indexPath) -> Void in
            self.voiceRepository.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        deleteButton.backgroundColor = UIColor.red
        return [deleteButton]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voice = voiceRepository.getVoice(index: indexPath.row)
        audio.play(url: voice.url!)
    }
}

extension ViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voiceRepository.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let voice = voiceRepository.getVoice(index: indexPath.row)
        cell.textLabel?.text = voice.title
        return cell
        
    }
}

