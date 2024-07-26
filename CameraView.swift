//
//  CameraView.swift
//  downhillIdent
//
//  Created by Daniel Krupa on 26/07/2024.
//

import SwiftUI
import Vision
import AVFoundation

struct CameraView: UIViewRepresentable {
    @ObservedObject var viewModel: CameraViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        let previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.frame

        view.layer.addSublayer(previewLayer)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraView(viewModel: CameraViewModel())
}

