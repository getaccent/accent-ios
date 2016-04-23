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
        
        dispatch_async(dispatch_get_main_queue()) { 
            self.synthesizer = AVSpeechSynthesizer()
            self.synthesizer.delegate = self
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if closeButton == nil {
            closeButton = UIButton()
            closeButton.addTarget(self, action: #selector(closeButtonPressed(_:)), forControlEvents: .TouchUpInside)
            closeButton.setImage(UIImage(named: "Close"), forState: .Normal)
            addSubview(closeButton)
        }
        let closeSize = CGSizeMake(28, 28)
        closeButton.frame = CGRectMake(0, (bounds.height - (closeSize.height + 32)) / 2, closeSize.width + 32, closeSize.height + 32)
        
        if toggleButton == nil {
            toggleButton = UIButton()
            toggleButton.addTarget(self, action: #selector(toggleButtonPressed(_:)), forControlEvents: .TouchUpInside)
            toggleButton.setImage(UIImage(named: "Play"), forState: .Normal)
            addSubview(toggleButton)
        }
        let toggleSize = CGSizeMake(28, 28)
        toggleButton.frame = CGRectMake((bounds.width - toggleSize.width) / 2, (bounds.height - toggleSize.height) / 2, toggleSize.width, toggleSize.height)
        
        if speedButton == nil {
            speedButton = UIButton()
            speedButton.addTarget(self, action: #selector(speedButtonPressed(_:)), forControlEvents: .TouchUpInside)
            speedButton.contentHorizontalAlignment = .Right
            speedButton.setTitle("1.0x", forState: .Normal)
            speedButton.setTitleColor(UIColor.accentDarkColor(), forState: .Normal)
            speedButton.titleLabel?.font = UIFont.systemFontOfSize(18)
            addSubview(speedButton)
        }
        let speedSize = CGSizeMake(40, 36)
        speedButton.frame = CGRectMake(bounds.width - speedSize.width - 20, (bounds.height - speedSize.height) / 2, speedSize.width, speedSize.height)
    }
    
    internal func closeButtonPressed(sender: UIButton) {
        synthesizer.stopSpeakingAtBoundary(.Immediate)
        delegate?.hiding()
    }
    
    internal func toggleButtonPressed(sender: UIButton) {
        paused = !paused
        
        if paused {
            synthesizer.pauseSpeakingAtBoundary(.Immediate)
        } else {
            if synthesizer.paused {
                synthesizer.continueSpeaking()
            } else {
                let utterance = self.utteranceWithRate(self.currentRate())
                self.synthesizer.speakUtterance(utterance)
            }
        }
    }
    
    internal func speedButtonPressed(sender: UIButton) {
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
        
        speedButton.setTitle(title, forState: .Normal)
        
        guard !synthesizer.paused else {
            return
        }
        
        synthesizer.stopSpeakingAtBoundary(.Immediate)
        
        speedPressNum += 1
        let num = speedPressNum
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            guard self.speedPressNum == num else {
                return
            }
            
            let utterance = self.utteranceWithRate(self.currentRate())
            self.synthesizer.speakUtterance(utterance)
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
    
    private func utteranceWithRate(rate: Float) -> AVSpeechUtterance {
        offsetLocation += currentLocation
        
        var string = article.text
        string = (string as NSString).substringWithRange(NSMakeRange(offsetLocation, string.characters.count - offsetLocation))
        
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = rate
        utterance.voice = AVSpeechSynthesisVoice(language: Language.savedLanguage()?.getCode())
        
        return utterance
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didContinueSpeechUtterance utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Pause"), forState: .Normal)
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Play"), forState: .Normal)
        currentLocation = 0
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didPauseSpeechUtterance utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Play"), forState: .Normal)
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
        toggleButton.setImage(UIImage(named: "Pause"), forState: .Normal)
    }
    
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        currentLocation = characterRange.location
        delegate?.updatedSpeechRange(NSMakeRange(offsetLocation + currentLocation, characterRange.length))
    }
}

protocol AudioBarDelegate {
    func hiding()
    func updatedSpeechRange(range: NSRange)
}
