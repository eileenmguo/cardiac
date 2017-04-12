//
//  VideoViewController.swift
//  Cardiac
//
//  Created by Patrick Leopard on 4/7/17.
//  Copyright © 2017 Eileen Guo. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    let WHITE_BALANCE_TEMP: Float = 4000.0
    let WHITE_BALANCE_TINT: Float = 0.0
    
    var recordingTimer = Timer()
    var recordingCounter = 0
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        return s
    }()
    
    lazy var fileOutput: AVCaptureMovieFileOutput = {
        
        let fileOutput = AVCaptureMovieFileOutput()
        return fileOutput
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width/1.5, height: self.view.bounds.height/1.5)
        preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateButtons(isRecording: false)
        
        setupCameraSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateButtons(isRecording: false)
        
        view.layer.addSublayer(previewLayer)
        
        cameraSession.startRunning()
    }
    
    // MARK: - Camera Setup
    
    func setupCameraSession() {
        // Default camera and microphone devices
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        let audioCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) as AVCaptureDevice
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
            
            cameraSession.beginConfiguration()
            
            // Add camera to session
            if cameraSession.canAddInput(videoDeviceInput) {
                cameraSession.addInput(videoDeviceInput)
            } else {
                print("Error: could not add videoDeviceInput.")
            }
            
            // Add microphone to session
            if cameraSession.canAddInput(audioDeviceInput) {
                cameraSession.addInput(audioDeviceInput)
            } else {
                print("Error: could not add audioDeviceInput.")
            }
            
            // Add file output to session
            if cameraSession.canAddOutput(fileOutput) {
                cameraSession.addOutput(fileOutput)
            } else {
                print("Error: could not add device output.")
            }
            
            configureCameraWhiteBalance(device: videoCaptureDevice)
            
            // Set camera to highest available framerate
            configureCameraForHighestFrameRate(device: videoCaptureDevice)
            
            cameraSession.commitConfiguration()
        }
        catch let error as NSError {
            print("\(error): \(error.localizedDescription)")
        }
    }
    
    func configureCameraForHighestFrameRate(device: AVCaptureDevice) {
        // Load formats that camera is capable of
        let deviceFormats = device.formats as! [AVCaptureDeviceFormat]
        var bestFormat = deviceFormats[0]
        
        if var bestFrameRateRange: AVFrameRateRange = bestFormat.videoSupportedFrameRateRanges[0] as? AVFrameRateRange {
            
            // Loop through device formats and find highest framerate and format available
            for format in deviceFormats {
                for range in format.videoSupportedFrameRateRanges as! [AVFrameRateRange] {
                    
                    // Check if new highest
                    if range.maxFrameRate > bestFrameRateRange.maxFrameRate {
                        bestFormat = format
                        bestFrameRateRange = range
                    }
                }
            }
            
            // Configure device
            do{
                try device.lockForConfiguration()
                
                // Set camera properties
                device.activeFormat = bestFormat
                device.activeVideoMinFrameDuration = bestFrameRateRange.minFrameDuration
                device.activeVideoMaxFrameDuration = bestFrameRateRange.minFrameDuration
                
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device to configure camera frame rate.")
            }
            
        } else {
            print("Error: Could not cast \"var bestFrameRateRange\" as \"AVFrameRateRange\".")
        }
    }
    
    func configureCameraWhiteBalance(device: AVCaptureDevice) {
        // Configure device
        do{
            try device.lockForConfiguration()
            
            // Set white balance to 4000 K and 0 tint
            let temperatureAndTintValues = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: WHITE_BALANCE_TEMP, tint: WHITE_BALANCE_TINT)
            var deviceGains = device.deviceWhiteBalanceGains(for: temperatureAndTintValues)
            deviceGains = setGainsRange(gains: deviceGains, device: device)
            device.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(deviceGains, completionHandler: nil)
            
            device.unlockForConfiguration()
        } catch {
            print("Could not lock device to configure camera white balance.")
        }
    }
    
    func setGainsRange(gains: AVCaptureWhiteBalanceGains, device: AVCaptureDevice) -> AVCaptureWhiteBalanceGains {
        var ng = gains
        
        ng.redGain = max(1.0, ng.redGain)
        ng.greenGain = max(1.0, ng.greenGain)
        ng.blueGain = max(1.0, ng.blueGain)
        
        ng.redGain = min(device.maxWhiteBalanceGain, ng.redGain)
        ng.greenGain = min(device.maxWhiteBalanceGain, ng.greenGain)
        ng.blueGain = min(device.maxWhiteBalanceGain, ng.blueGain)
        
        return ng
    }
    
    func beginRecording() {
        // Save file in Documents directory
        let fileManager = FileManager.default
        let documentsDirectory = try! fileManager.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileName = Date().timeIntervalSince1970.description
        let fileURL = documentsDirectory.appendingPathComponent(fileName + ".mov")
        
        fileOutput.startRecording(toOutputFileURL: fileURL, recordingDelegate: self)
    }
    
    func endRecording() {
        fileOutput.stopRecording()
    }
    
    // MARK: - Actions
    
    @IBAction func pushRecord(_ sender: Any) {
        beginRecording()
        
        startTimer()
        updateButtons(isRecording: true)
    }
    
    @IBAction func pushStop(_ sender: Any) {
        endRecording()
        
        stopTimer()
        updateButtons(isRecording: false)
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    // Informs the delegate when the output has started writing to a file
    func capture(_: AVCaptureFileOutput!, didStartRecordingToOutputFileAt: URL!, fromConnections: [Any]!) {
        print("didStartRecordingToOutputFileAt: \(didStartRecordingToOutputFileAt!)")
    }
    
    // Informs the delegate when the output will stop writing new samples to a file
    func capture(_: AVCaptureFileOutput!, willFinishRecordingToOutputFileAt: URL!, fromConnections: [Any]!, error: Error!) {
        print("willFinishRecordingToOutputFileAt: \(willFinishRecordingToOutputFileAt!)")
    }
    
    // Required. Informs the delegate when all pending data has been written to an output file
    func capture(_: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt: URL!, fromConnections: [Any]!, error: Error!) {
        print("didFinishRecordingToOutputFileAt: \(didFinishRecordingToOutputFileAt!)")
    }
    
    // Called whenever the output is recording to a file and successfully pauses the recording at the request of a client
    func capture(_: AVCaptureFileOutput!, didPauseRecordingToOutputFileAt: URL!, fromConnections: [Any]!) {
        print("didPauseRecordingToOutputFileAt: \(didPauseRecordingToOutputFileAt!)")
    }
    
    // Called whenever the output, at the request of the client, successfully resumes a file recording that was paused
    func capture(_: AVCaptureFileOutput!, didResumeRecordingToOutputFileAt: URL!, fromConnections: [Any]!) {
        print("didResumeRecordingToOutputFileAt: \(didResumeRecordingToOutputFileAt!)")
    }
    
    // MARK: - Timer
    
    func startTimer() {
        recordingTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(VideoViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        recordingTimer.invalidate()
        recordingCounter = 0
        timerLabel.text = "00:00"
    }
    
    func updateTimer() {
        recordingCounter += 1
        
        let minutes = Int(recordingCounter) / 60 % 60
        let seconds = Int(recordingCounter) % 60
        
        // Format as "00:00"
        timerLabel.text = String(format:"%02i:%02i", minutes, seconds)
    }
    
    // MARK: - Miscellaneous
    
    func updateButtons(isRecording: Bool) {
        // Update button appearances
        self.recordButton.isEnabled = !isRecording
        self.stopButton.isEnabled = isRecording
    }

}
