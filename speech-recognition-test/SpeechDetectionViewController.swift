//
//  SpeechDetectionViewController.swift
//  speech-recognition-test
//
//  Created by jam3 on 2019-06-11.
//  Copyright © 2019 jam3. All rights reserved.
//

import UIKit
import Speech

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {
    //@IBOutlet weak var detectedTextLabel: UILabel!
    //@IBOutlet weak var colorView: UIView!
    //@IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var transcriptionStatusLabel: UILabel!
    
    // Declaring speech recognition variables
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var recording = false
    var node: AVAudioInputNode
    
    required init?(coder aDecoder: NSCoder) {
        self.node = audioEngine.inputNode
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if recording == false {
            self.recordAndRecognizeSpeech()
            recording = true
            transcriptionStatusLabel.text = "Speech Recognition ON"
        } else {
            audioEngine.stop()
            recognitionTask?.cancel()
            self.node.removeTap(onBus: 0)
            recording = false
            transcriptionStatusLabel.text = "Speech Recognition OFF"
        }
    }
    
    @IBAction func clearText(_ sender: Any) {
        self.detectedTextLabel.text = ""
    }
    
    func recordAndRecognizeSpeech() {
//        guard let node = audioEngine.inputNode else { return }
//        node = audioEngine.inputNode
        let recordingFormat = self.node.outputFormat(forBus: 0)
        self.node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable {
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: {result, error in
            if let result = result {
                let isFinal = result.isFinal
                if isFinal {
                    print("60 second limit probably reached")
                }
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func checkForColorsSaid(resultString: String) {
        switch resultString {
        case "red":
            self.detectedTextLabel.backgroundColor = UIColor.red
            self.detectedTextLabel.textColor = UIColor.black
        case "orange":
            self.detectedTextLabel.backgroundColor = UIColor.orange
            self.detectedTextLabel.textColor = UIColor.black
        case "yellow":
            self.detectedTextLabel.backgroundColor = UIColor.yellow
            self.detectedTextLabel.textColor = UIColor.black
        case "green":
            self.detectedTextLabel.backgroundColor = UIColor.green
            self.detectedTextLabel.textColor = UIColor.black
        case "blue":
            self.detectedTextLabel.backgroundColor = UIColor.blue
            self.detectedTextLabel.textColor = UIColor.black
        case "purple":
            self.detectedTextLabel.backgroundColor = UIColor.purple
            self.detectedTextLabel.textColor = UIColor.black
        case "white":
            self.detectedTextLabel.backgroundColor = UIColor.white
            self.detectedTextLabel.textColor = UIColor.black
        case "gray":
            self.detectedTextLabel.backgroundColor = UIColor.gray
            self.detectedTextLabel.textColor = UIColor.black
        case "black":
            self.detectedTextLabel.backgroundColor = UIColor.black
            self.detectedTextLabel.textColor = UIColor.white
        default: break
        }
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "You didn't give me access to listen to everything you say :'("
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                @unknown default:
                    print("Error requesting authorization to initiate speech recognition")
                }
            }
        }
    }
}
