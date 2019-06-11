//
//  ViewController.swift
//  speech-recognition-test
//
//  Created by jam3 on 2019-06-11.
//  Copyright © 2019 jam3. All rights reserved.
//

import UIKit
import Speech

//class ViewController: UIViewController {
//
//
//
//
//}

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {
    //@IBOutlet weak var detectedTextLabel: UILabel!
    //@IBOutlet weak var colorView: UIView!
    //@IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    // Declaring speech recognition variables
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    let running = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.recordAndRecognizeSpeech()
    }
    
    func recordAndRecognizeSpeech() {
        //guard let node = audioEngine.inputNode else { return }
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
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
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func terminateSpeechRecognition() {
        
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
