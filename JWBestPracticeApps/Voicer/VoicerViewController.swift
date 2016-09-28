//
//  VoicerViewController.swift
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 9/21/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

import UIKit
import Intents

class VoicerViewController: JWRemoteCastPlayerViewController {
    
    let userDefaults = UserDefaults.init(suiteName: "group.com.jwplayer.wormhole")
    let playerSynonyms = ["player", "play", "playing", "playback", "video", "movie"]
    let seekingSynonyms = ["seeking", "seek"]
    let castingSynonyms = ["casting", "chrome cast"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        INPreferences.requestSiriAuthorization { (authorizationStatus) in
        }
        
    }
    
    func prepareCustomVocabulary() {
        
    }
    
    public func handle(intent: INIntent) {
        if intent is INPauseWorkoutIntent {
            let pauseIntent = intent as! INPauseWorkoutIntent
            self.handlePause(command: pauseIntent.workoutName?.spokenPhrase)
        } else if intent is INResumeWorkoutIntent {
            let resumeIntent = intent as! INResumeWorkoutIntent
            self.handleResume(command: resumeIntent.workoutName?.spokenPhrase)
        } else if intent is INStartWorkoutIntent {
            let startIntent = intent as! INStartWorkoutIntent
            let startGoal = startIntent.goalValue != nil ? UInt(startIntent.goalValue!) : 0
            self.handleStart(command: (startIntent.workoutName?.spokenPhrase), quantity: startGoal)
        } else if intent is INEndWorkoutIntent {
            let endCastingIntent = intent as! INEndWorkoutIntent
            self.handleStart(command: (endCastingIntent.workoutName?.spokenPhrase), quantity: 0)
        }
    }
    
    func handleResume(command: String?) {
        if self.keywordFrom(synonym: command!) == "player" {
            self.player.play()
        }
    }
    
    func handlePause(command: String?) {
        if self.keywordFrom(synonym: command!) == "player" {
            self.player.pause()
        }
    }
    
    func handleStart(command: String?, quantity: UInt?) {
        if self.keywordFrom(synonym: command!) == "seeking" {
            self.player.seek(quantity!)
        } else if self.keywordFrom(synonym: command!) == "player" {
            self.player.play()
        } else {
            self.castTo(deviceName: command!)
        }
    }
    
    func handleEnd(command: String?) {
        if self.keywordFrom(synonym: command!) == "casting" {
            self.castController.disconnect()
        }
    }
    
    // MARK: Helper Methods
    
    func keywordFrom(synonym: String)-> String? {
        let playerSynonyms = ["player", "play", "playing", "playback", "video", "movie"]
        let seekingSynonyms = ["seeking", "seek"]
        let castingSynonyms = ["casting", "chrome cast"]
        if playerSynonyms.contains(synonym) {
            return "player"
        } else if seekingSynonyms.contains(synonym) {
            return "seeking"
        } else if castingSynonyms.contains(synonym) {
            return "casting"
        }
        return nil
    }
    
    func castTo(deviceName: String) {
        let castingDevice = self.obtainCastingDevice(name: deviceName)
        if castingDevice != nil {
            self.castController.connect(to: castingDevice)
        }
    }
    
    func obtainCastingDevice(name: String) -> JWCastingDevice? {
        for device in self.castController.availableDevices {
            let castDevice = device as! JWCastingDevice
            if castDevice.name == name {
                return castDevice
            }
        }
        return nil
    }
    
    // MARK: Cast Delegate Methods
    
    override func onCastingDevicesAvailable(_ devices: [JWCastingDevice]!) {
        super.onCastingDevicesAvailable(devices)
        self.prepareCastingDevices()
    }
    
    func prepareCastingDevices() {
        var castingDevices = [String]()
        for device in self.castController.availableDevices {
            castingDevices.append((device as! JWCastingDevice).name)
        }
        if castingDevices.count > 0 {
            self.userDefaults?.set(castingDevices, forKey: "castingDevices")
            self.userDefaults?.synchronize()
        }
    }
}
