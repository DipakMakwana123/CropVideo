//
//  ViewController.swift
//  CropVideo
//
//  Created by Dipakbhai Valjibhai Makwana on 23/04/23.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Photos
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addTabView()
        //copyVideoFromURL()
    }

    private func addTabView() {
        // Create a UIHostingController with your SwiftUI view
               let swiftUIView = MyTabView()
               let hostingController = UIHostingController(rootView: swiftUIView)

               // Add the hosting controller's view as a subview
               addChild(hostingController)
               view.addSubview(hostingController.view)
               hostingController.view.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                   hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
               ])
               hostingController.didMove(toParent: self)
           
    }

    private func copyVideoFromURL(){
        let string1 = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        //let string1 = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
        //let string1 = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
       // let string1 = "https://file-examples.com/wp-content/uploads/2018/04/file_example_MOV_1920_2_2MB.mov"
        guard let url = URL(string: string1) else { return }
     //   cropVideo(sourceURL1: url, statTime: 1.00, endTime: 5.00)
        let startTime = CMTime(seconds: Double(3.0), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(5.0), preferredTimescale: 1000)
       // let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.mp4")
//        cropVideo1(sourceURL: url, startTime: startTime, endTime: endTime, outputURL: outputUrl, completion: {success in
//            debugPrint(success)
//        })
       // let sourceURL = URL(fileURLWithPath: "path/to/source/video.mp4")
        cropVideo3(sourceURL: url, startTime: 5.0, endTime: 20.0) { [weak self] (outputURL, error) in
            if let error = error {
                print("Error cropping video: \(error)")
                return
            }

            guard let outputURL = outputURL else {
                print("Error cropping video: output URL is nil")
                return
            }
            self?.saveVideoToLibrary(videoURL: outputURL) { success, error in
                if success {
                    print("Video saved to library")
                } else {
                    print("Error saving video to library: \(error?.localizedDescription ?? "Unknown error")")
                }
            }

            // Use the cropped video at outputURL
        }

    }
//    private func requestPermission(){
//        let fileManager = FileManager.default
//
//        fileManager.(for: .documentDirectory) { (result) in
//            switch result {
//            case .authorized:
//                print("User granted permission")
//                let string1 = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
//                guard let url = URL(string: string1) else {return}
//                cropVideo(sourceURL1: url, statTime: 3.00, endTime: 5.00)
//            case .denied:
//                print("User denied permission")
//            case .notDetermined:
//                print("Permission not determined")
//            case .restricted:
//                print("Permission restricted")
//            default:
//                break
//            }
//        }
//    }





    func cropVideo3(sourceURL: URL, startTime: Double, endTime: Double, completion: @escaping (URL?, Error?) -> Void) {
        let asset = AVAsset(url: sourceURL)
        let composition = AVMutableComposition()

        let videoTrack = asset.tracks(withMediaType: .video).first!
        let audioTrack = asset.tracks(withMediaType: .audio).first!

        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!

        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime(seconds: startTime, preferredTimescale: 1000), duration: CMTime(seconds: endTime - startTime, preferredTimescale: 1000)), of: videoTrack, at: .zero)
            try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(start: CMTime(seconds: startTime, preferredTimescale: 1000), duration: CMTime(seconds: endTime - startTime, preferredTimescale: 1000)), of: audioTrack, at: .zero)
        } catch {
            DispatchQueue.main.async {
                completion(nil, error)
            }
            return
        }

        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!

        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "croppedVideo.mp4")

        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4

        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                DispatchQueue.main.async {
                    completion(outputURL, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, exportSession.error)
                }
            }
        }
    }

    func saveVideoToLibrary(videoURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            completion(success, error)
        }
    }
/*
    func cropVideo1(sourceURL: URL, startTime: CMTime, endTime: CMTime, outputURL: URL, completion: @escaping (Bool) -> Void) {

        let asset = AVURLAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(false)
            return
        }

        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first,
            let assetAudioTrack = asset.tracks(withMediaType: .audio).first else {
                completion(false)
                return
        }

        let assetTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)

        do {
            try videoTrack?.insertTimeRange(assetTimeRange, of: assetVideoTrack, at: .zero)
            try audioTrack?.insertTimeRange(assetTimeRange, of: assetAudioTrack, at: .zero)
        } catch {
            completion(false)
            return
        }

        let croppedRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = croppedRange

        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack!)
        let videoSize = assetVideoTrack.naturalSize
        let transform = assetVideoTrack.preferredTransform.translatedBy(x: -croppedRange.start.seconds * videoSize.height, y: 0)
        transformer.setTransform(transform, at: .zero)

        instruction.layerInstructions = [transformer]

        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        videoComposition.renderSize = videoSize

        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                completion(true)
            } else {
                completion(false)
            }
        }
    }


    func cropVideo(from videoUrl: URL, startTime: CMTime, endTime: CMTime, completion: @escaping (URL?, Error?) -> Void) {
        let asset = AVAsset(url: videoUrl)

        // Create an export session with the desired output settings
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(nil, NSError(domain: "com.example.video", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"]))
            return
        }

        let outputUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("output.mp4")

        // Configure the export session with the desired time range and output URL
        exportSession.outputURL = outputUrl
        exportSession.outputFileType = AVFileType.mp4
        exportSession.timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)

        // Perform the export
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(exportSession.outputURL, nil)
            case .failed:
                completion(nil, exportSession.error)
            case .cancelled:
                completion(nil, NSError(domain: "com.example.video", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"]))
            default:
                break
            }
        }
    }

    func cropVideo(sourceURL1: URL, statTime:Float, endTime:Float)
    {
        let manager = FileManager.default

        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        let mediaType = "mp4"
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {
            let asset = AVAsset(url: sourceURL1 as URL)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")

            let start = statTime
            let end = endTime

            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).\(mediaType)")
            }catch let error {
                print(error)
            }

            //Remove existing file
            _ = try? manager.removeItem(at: outputURL)


//            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
//            exportSession.outputURL = outputURL
//            exportSession.outputFileType = .mov//.mp4

            guard
                    let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality),
                    exportSession.supportedFileTypes.contains(AVFileType.mp4) else {
                   // completion(nil)
                    return
                }
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            let startTime = CMTime(seconds: Double(start), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)

            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                PHPhotoLibrary.requestAuthorization { status in
                          if status == .authorized {
                              // Retrieve videos from the user's photo library

                              switch exportSession.status {
                                              case .completed:
                                                  print("exported at \(outputURL)")
                                              case .failed:
                                                  print("failed \(exportSession.error)")

                                              case .cancelled:
                                                  print("cancelled \(exportSession.error)")

                                              default: break
                                              }
                          } else {
                              print("Access to photo library denied")
                          }
                      }
                  }

//            exportSession.exportAsynchronously{
//                switch exportSession.status {
//                case .completed:
//                    print("exported at \(outputURL)")
//                case .failed:
//                    print("failed \(exportSession.error)")
//
//                case .cancelled:
//                    print("cancelled \(exportSession.error)")
//
//                default: break
//                }
//            }
        }
    }
*/
}

