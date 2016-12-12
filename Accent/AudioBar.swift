//
//  AudioBar.swift
//  Accent
//
//  Created by Jack Cook on 4/13/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import AVFoundation
import UIKit

class AudioBar: UIView, AVSpeechSynthesizerDelegate {
    
    var article: Article!
    var delegate: AudioBarDelegate?
    
    private var closeButton: UIButton!
    private var toggleButton: UIButton!
    private var speedButton: UIButton!
    
    private var currentSpeed = 1
    private var paused = true
    
    private var synthesizer: AVSpeechSynthesizer!
    private var currentLocation = 0
    private var currentFullLocation = 0
    private var offsetLocation = 0
    
    private var speedPressNum = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        DispatchQueue.main.async { 
            self.synthesizer = AVSpeechSynthesizer()
            self.synthesizer.delegate = self
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if closeButton == nil {
            closeButton = UIButton()
            closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), for: .touchUpInside)
            closeButton.setImage(UIImage(named: "Close"), for: .normal)
            addSubview(closeButton)
        }
        let closeSize = CGSize(width: 28, height: 28)
        closeButton.frame = CGRect(x: 0, y: (bounds.height - (closeSize.height + 32)) / 2, width: closeSize.width + 32, height: closeSize.height + 32)
        
        if toggleButton == nil {
            toggleButton = UIButton()
            toggleButton.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .touchUpInside)
            toggleButton.setImage(UIImage(named: "Play"), for: .normal)
            addSubview(toggleButton)
        }
        let toggleSize = CGSize(width: 28, height: 28)
        toggleButton.frame = CGRect(x: (bounds.width - toggleSize.width) / 2, y: (bounds.height - toggleSize.height) / 2, width: toggleSize.width, height: toggleSize.height)
        
        if speedButton == nil {
            speedButton = UIButton()
            speedButton.addTarget(self, action: #selector(speedButtonPressed(_:)), for: .touchUpInside)
            speedButton.contentHorizontalAlignment = .right
            speedButton.setTitle("1.0x", for: .normal)
            speedButton.setTitleColor(UIColor.accentDarkColor(), for: .normal)
            speedButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            addSubview(speedButton)
        }
        let speedSize = CGSize(width: 40, height: 36)
        speedButton.frame = CGRect(x: bounds.width - speedSize.width - 20, y: (bounds.height - speedSize.height) / 2, width: speedSize.width, height: speedSize.height)
    }
    
    internal func closeButtonPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
        delegate?.hiding()
    }
    
    internal func toggleButtonPressed(_ sender: UIButton) {
        paused = !paused
        
        if paused {
            synthesizer.pauseSpeaking(at: .immediate)
        } else {
            if synthesizer.isPaused {
                synthesizer.continueSpeaking()
            } else {
                let utterance = self.utteranceWithRate(self.currentRate())
                self.synthesizer.speak(utterance)
            }
        }
    }
    
    internal func speedButtonPressed(_ sender: UIButton) {
        currentSpeed += currentSpeed == 3 ? -3 : 1
        
        var title = "1.0x"
        
        switch currentSpeed {
        case 1:
            title = "1.0x"
        case 2:
            title = "1.5x"
        case 3:
            title = "2.0x"
        default:
            title = ".5x"
        }
        
        speedButton.setTitle(title, for: .normal)
        
        guard !synthesizer.isPaused else {
            return
        }
        
        synthesizer.stopSpeaking(at: .immediate)
        
        speedPressNum += 1
        let num = speedPressNum
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.speedPressNum == num else {
                return
            }
            
            let utterance = self.utteranceWithRate(self.currentRate())
            self.synthesizer.speak(utterance)
        }
    }
    
    private func currentRate() -> Float {
        switch currentSpeed {
        case 0: return 0.29
        case 1: return 0.4
        case 2: return AVSpeechUtteranceDefaultSpeechRate
        case 3: return 0.525
        default: return 0.4
        }
    }
    
    private func utteranceWithRate(_ rate: Float) -> AVSpeechUtterance {
        offsetLocation += currentLocation
        
        var string = article.text
        string = (string as NSString).substring(with: NSMakeRange(offsetLocation, string.characters.count - offsetLocation))
        
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = rate
        utterance.voice = AVSpeechSynthesisVoice(language: Language.savedLanguage()?.getCode())
        
        return utterance
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Pause"), for: .normal)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Play"), for: .normal)
        currentLocation = 0
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Play"), for: .normal)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Pause"), for: .normal)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        currentLocation = characterRange.location
        delegate?.updatedSpeechRange(NSMakeRange(offsetLocation + currentLocation, characterRange.length))
    }
}

protocol AudioBarDelegate {
    func hiding()
    func updatedSpeechRange(_ range: NSRange)
}
