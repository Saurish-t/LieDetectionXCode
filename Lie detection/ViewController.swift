//
//  ViewController.swift
//  Lie detection
//
//  Created by rnv buja on 5/18/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private func addButtonBorder() {
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.5
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
    }
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Get started", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemCyan
        view.addSubview(button)
        button.frame = CGRect(
            x: 30,
            y: view.frame.size.height-150-view.safeAreaInsets.bottom,
            width: view.frame.size.width-60,
            height: 70
        )
        addButtonBorder()
        
        // Add target to the button
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc private func buttonTapped() {
        print("Button Tapped!")
        // Create an instance of the new view controller
        let newViewController = NewViewController()
        
        // Push the new view controller onto the navigation stack
        //navigationController?.pushViewController(newViewController, animated: true)
        present(newViewController, animated: true, completion: nil)
    }
}

// New view controller to navigate to
class NewViewController: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var movieOutput: AVCaptureMovieFileOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
        /*super.viewDidLoad()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Welcome to the new page!"
        label.textColor = .black
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)*/
    }
    private func setupUI() {
        
        
        let recordButton = UIButton(type: .custom)
        recordButton.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
        recordButton.layer.cornerRadius = 0.5 * recordButton.bounds.size.width
        recordButton.clipsToBounds = true
        recordButton.setTitle("Record", for: .normal)
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)

        recordButton.layer.borderWidth = 2.0
        recordButton.layer.borderColor = UIColor.black.cgColor

        view.addSubview(recordButton)

            // Layout constraints for the record button
            recordButton.translatesAutoresizingMaskIntoConstraints = false
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
    
    private func setupCamera(){
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
                print("Failed to get capture device")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)

                movieOutput = AVCaptureMovieFileOutput()
                captureSession.addOutput(movieOutput!)

                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                view.layer.addSublayer(videoPreviewLayer!)

                captureSession.startRunning()
            } catch {
                print("Error setting up capture session: \(error.localizedDescription)")
            }
    }
    
    @objc private func recordButtonTapped() {
            if movieOutput?.isRecording ?? false {
                stopRecording()
            } else {
                startRecording()
            }
        }

    private func startRecording() {
        guard let outputUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("video.mp4") else {
            print("Error: Invalid output URL")
            return
        }

        // Debug print the output URL
        print("Output URL:", outputUrl)

        // Check file writing permission
        let fileManager = FileManager.default
        if !fileManager.isWritableFile(atPath: outputUrl.path) {
            print("Error: Cannot write to file at \(outputUrl)")
            return
        }

        movieOutput?.startRecording(to: outputUrl, recordingDelegate: self)
    }

    private func stopRecording() {
        movieOutput?.stopRecording()
    }
}

extension NewViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording to \(fileURL)")
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            print("Recording finished: \(outputFileURL)")
        }
    }
}
