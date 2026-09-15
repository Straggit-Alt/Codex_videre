import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    
    @Binding var scannedCode: String
    @Binding var codeType: String
    @Binding var torchOn: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ),
        let input = try? AVCaptureDeviceInput(device: camera) else {
            return view
        }
        
        view.camera = camera
        view.session = session
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(
                context.coordinator,
                queue: DispatchQueue.main
            )
            
            metadataOutput.metadataObjectTypes = [
                .qr,
                .dataMatrix,
                .ean8,
                .ean13,
                .code128,
                .code39,
                .code93,
                .pdf417,
                .aztec,
                .upce,
                .itf14
            ]
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.previewLayer = previewLayer
        view.layer.addSublayer(previewLayer)
        
        session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.setTorch(on: torchOn)
    }
}

extension CameraView {
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let value = metadataObject.stringValue else {
                return
            }
            
            parent.scannedCode = value
            parent.codeType = metadataObject.type.rawValue
        }
    }
}

class CameraPreviewView: UIView {
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var camera: AVCaptureDevice?
    var session: AVCaptureSession?
    
    func setTorch(on: Bool) {
        guard let camera = camera, camera.hasTorch else {
            return
        }
        
        do {
            try camera.lockForConfiguration()
            
            camera.torchMode = on ? .on : .off
            
            camera.unlockForConfiguration()
        } catch {
            print("Could not set torch: \(error)")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewLayer?.frame = bounds
    }
}
