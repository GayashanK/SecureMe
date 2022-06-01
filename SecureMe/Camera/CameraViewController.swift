//
//  CameraViewController.swift
//  SecureMe
//
//  Created by Kasun Gayashan on 28/05/2022.
//

import Cocoa
import AVFoundation

// MARK: CameraViewController
class CameraViewController: NSViewController {
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkAuthorizations()
    }
    
    // MARK: Private Methods
    /// Check Authorization Status for Audio and Video Device Access
    private func checkAuthorizations() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            break
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    // The user has previously granted access.
                }
            }
            
        case .denied: // The user has previously denied access.
            return
            
        case .restricted: // The user can't grant access due to restrictions.
            return
        @unknown default:
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession()
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
            
        case .denied: // The user has previously denied access.
            return
            
        case .restricted: // The user can't grant access due to restrictions.
            return
        @unknown default:
            return
        }
    }
    
    /// Capture Session Audio and Video Inputs
    private func setupCaptureSession() {
        // Create the capture session.
        let captureSession = AVCaptureSession()
        
        // Find the default video device.
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        // Find the default audio device.
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        
        do {
            // Wrap the video device in a capture device input.
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            // Wrap the audio device in a capture device input.
            let audioInput = try AVCaptureDeviceInput(device: audioDevice)
            // If the input can be added, add it to the session.
            if captureSession.canAddInput(videoInput), captureSession.canAddInput(audioInput) {
                captureSession.addInput(videoInput)
                captureSession.addInput(audioInput)
                
                self.captureMovieOutput(session: captureSession)
            }
        } catch {
            // Configuration failed. Handle error.
        }
    }
    
    /// Capture Session Movie File Output
    /// - Parameters session: AVCaptureSession
    private func captureMovieOutput(session: AVCaptureSession) {
        let movieOutput = AVCaptureMovieFileOutput()
        
        session.canAddOutput(movieOutput)
        session.sessionPreset = .vga640x480
        session.addOutput(movieOutput)
        session.commitConfiguration()
        session.startRunning()
        
        self.saveMovieFile(output: movieOutput, session: session)
    }
    
    /// Save Output Movie File to URL
    /// - Parameters output: AVCaptureMovieFileOutput, session: AVCaptureSession
    private func saveMovieFile(output: AVCaptureMovieFileOutput, session: AVCaptureSession) {
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        let fileName = Date().ISO8601Format() + "-rec.mov"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileUrl)
        
        output.startRecording(to: fileUrl, recordingDelegate: self)
        
        let delayTime = DispatchTime.now() + 300
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            print("stopping")
            output.stopRecording()
            session.stopRunning()
            timer.invalidate()
            self.progressBar.doubleValue = 0.0
        }
    }
    
    @objc func fireTimer() {
        self.progressBar.increment(by: 1)
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("FINISHED \(String(describing: error))")
        self.setupCaptureSession()
    }
}
