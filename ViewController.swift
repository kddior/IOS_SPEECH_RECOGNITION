//
//  ViewController.swift
//  SPEECH_RECOGNITION
//
//  Created by itie.kone.dossongui on 10/16/19.
//  Copyright © 2019 itie.kone.dossongui. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {

@IBOutlet weak var textview: UITextView!
@IBOutlet weak var recordButton: UIButton!
@IBOutlet weak var buttonStatus: UILabel!
@IBOutlet weak var turnONButton: UIButton!
    
    var buttonState:Bool = false
    //property observer
    var turnON:Bool!  {
        willSet{
            
            if newValue == true  {
                self.turnONButton.sendActions(for: .touchUpInside)
            }else{
               // buttonState = !buttonState
             //   self.turnONButton.sendActions(for: .touchUpInside)
            }
            
        }
        didSet{
        
        }
        
    }
   
    
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textview.text = "Search desactivated"
    }
    
    
    @IBAction func startButtonTapped(_ sender: Any) {
    if audioEngine.isRunning {
               audioEngine.stop()
               recognitionRequest?.endAudio()
               recordButton.isEnabled = false
               recordButton.setTitle("Stopping", for: .disabled)
           } else {
               do {
                   try startSpeechTranscription()
                   recordButton.setTitle("START", for: [])
               } catch {
                   recordButton.setTitle("Recording Not Available", for: [])
               }
           }
    }
    
    
        // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
            
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }

    @IBAction func turnOnButtonTapped(_ sender: Any) {
        buttonStatus.text  = "\(!buttonState)" as! String
        buttonState = !buttonState
        
    }
    
    private func startSpeechTranscription() throws {
        
        
        //A-  Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        //B
     
        
       // Create and configure the speech recognition request.
       recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
       guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = false
     //   recognitionRequest.accessibilityRespondsToUserInteraction
       // Keep speech recognition data on device
       if #available(iOS 13, *) {
           recognitionRequest.requiresOnDeviceRecognition = false
       }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
          
            if let result = result {
                // Update the text view with the results.
                self.textview.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
                print("\(result.bestTranscription.formattedString.contains("turn on"))")
                self.turnON = result.bestTranscription.formattedString.lowercased().contains("turn on")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start speech", for: [])
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        

        // Let the user know to start talking.
        textview.text = "(Go ahead, I'm listening)"
        
    }

}

