//
//  CameraPrreviewInternal.swift
//  CameraController
//
//  Created by Itay Brenner on 7/21/20.
//  Copyright © 2020 Itaysoft. All rights reserved.
//
//  Modified by Jay T.

import Foundation
import Cocoa
import AVFoundation

class CameraPreviewInternal: NSView {
    var captureDevice: AVCaptureDevice?
    private var captureSession: AVCaptureSession
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var audioSession: AVCaptureAudioPreviewOutput!
    private var captureInput: AVCaptureInput?
    private var audioInput: AVCaptureInput?
    private var audioDevice = AVCaptureDevice.default(for: .audio)!

    init(frame frameRect: NSRect, device: AVCaptureDevice?) {
        captureDevice = device
        captureSession = AVCaptureSession()

        super.init(frame: frameRect)

        configureDevice(device)
        setupPreviewLayer(captureSession)
        //setupAudioPreview()
        captureSession.startRunning()
    }
    
    /*/ Add audio input
    private func setupAudioPreview() {
        if let audioDevice = self.audioDevice {
            self.audioInput = try AVCaptureDeviceInput(device: audioDevice)
            if captureSession.canAddInput(self.audioInput!) {
                captureSession.addInput(self.audioInput!)
            } else {
                throw CameraControllerError.inputsAreInvalid
            }
        }
    }*/

    private func setupPreviewLayer(_ captureSession: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: 1280, height: 720)
        previewLayer.videoGravity = .resizeAspect
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        previewLayer.frame = bounds
        layer?.addSublayer(previewLayer)
    }

    func stopRunning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    func updateCamera(_ cam: AVCaptureDevice?) {
        if captureDevice != cam {
            captureSession.stopRunning()
            configureDevice(cam)
            captureSession.startRunning()
        }
    }

    private func configureDevice(_ aDevice: AVCaptureDevice?) {
        guard let device = aDevice else {
            captureDevice = aDevice
            return
        }

        if let input = captureInput {
            captureSession.removeInput(input)
        }

        do {
            captureInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }

        if let input = captureInput,
            captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            return
        }
        captureDevice = device
    }
}
