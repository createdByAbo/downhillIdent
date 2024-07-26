import SwiftUI
import AVFoundation
import Vision

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    @Published var recognizedText = ""
    @Published var recognizedList: [String] = []
    private var lastRecognizedCodes: [String] = []

    override init() {
        super.init()
        checkCameraAuthorization()
    }

    private func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCamera()
                }
            }
        default:
            print("Camera access denied or restricted.")
        }
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(videoOutput)

        session.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }

            DispatchQueue.main.async {
                self.processRecognizedText(recognizedStrings.joined(separator: "\n"))
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false

        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing text recognition request: \(error)")
        }
    }

    private func processRecognizedText(_ text: String) {
        // Only process if the recognized text is a six-digit number
        let regex = try! NSRegularExpression(pattern: "^[0-9]{6}$")
        let range = NSRange(location: 0, length: text.utf16.count)
        if regex.firstMatch(in: text, options: [], range: range) != nil {
            lastRecognizedCodes.append(text)
            
            if lastRecognizedCodes.count > 5 {
                lastRecognizedCodes.removeFirst()
            }
            
            let codeCounts = lastRecognizedCodes.reduce([String: Int]()) { counts, code in
                var counts = counts
                counts[code, default: 0] += 1
                return counts
            }
            
            if let mostCommonCode = codeCounts.max(by: { $0.value < $1.value })?.key {
                recognizedText = (mostCommonCode)
                recognizedList.append(mostCommonCode)
            } else {
                recognizedText = (text)
            }
        }
    }
}
