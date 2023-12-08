//
//  YTNetworkService.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 04.12.2023.
//

import Foundation
import YouTubeKit
import XCDYouTubeKit


typealias NetworkServiceCompletion = (Result<(() -> Void)?, NetworkManagerErrors>) -> Void


protocol YTNetworkServiceProtocol: AnyObject {
    func downloadVideo(videoIdentifier: String,
                       videoURL: URL,
                       _ completion: @escaping NetworkServiceCompletion) throws
//                       onCompleted: (() -> Void)?, //во viewModel покажем уведомление saved
//                       errorHandler: ((Error) -> Void)?)
}


final class YTNetworkService {

    // MARK: - Public properties
    var fileName: String?
    var photoURL: URL?
    var successCompletion: (() -> Void)?

    // MARK: - Private properties
    private let manager: LocalFilesManagerProtocol

    init(manager: LocalFilesManagerProtocol) {
        self.manager = manager
    }

    // MARK: - Private methods
    private func fetchVideoInfo(youTubeID: String,
                                onCompleted: @escaping (_ video: XCDYouTubeVideo) -> Void) {

        XCDYouTubeClient.default().getVideoWithIdentifier(youTubeID) { video, error in //убрал [weak self]
            guard let video = video else {
                if error != nil {
                    print("Error at fetching XCD Video")
                }
                return
            }
            onCompleted(video)
        }
    }


}

// MARK: - Extensions YTNetworkServiceProtocol
extension YTNetworkService: YTNetworkServiceProtocol {

    func downloadVideo(videoIdentifier: String,
                       videoURL: URL,
                       _ completion: @escaping NetworkServiceCompletion) throws {


        fetchVideoInfo(youTubeID: videoIdentifier) { [weak self] video in
            guard let self else {return}

            self.fileName = "\(video.identifier)"
            let videoThumbnail = video.thumbnailURLs?.first
            self.photoURL = videoThumbnail

            Task {
                do {
                    let streamURL = try await YouTube(videoID: videoIdentifier).streams
                        .filter { $0.isProgressive && $0.subtype == "mp4" }
                        .lowestResolutionStream()?
                        .url
                    print("streamURL == \(String(describing: streamURL))")

                    guard let streamURL else {
                        print("streamURL error")
                        return
                    }

                    self.successCompletion?() //идея или забрать контекст для следующего кода - для manager.downloadFile

                    try self.manager.downloadFileAndSaveToPhotoGallery(file: File.video, from: streamURL, filename: self.fileName!, extension: "mp4")
                    try self.manager.downloadFileAndSaveToPhotoGallery(file: File.photo, from: self.photoURL!, filename: self.fileName!, extension: "jpg")
                    //
                } catch {
                    switch error {

                    default:
                        ()
                    }
                }
            }

        }

    }
}
