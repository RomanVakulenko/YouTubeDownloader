//
//  YTNetworkService.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 04.12.2023.
//

import Foundation
import YouTubeKit
import XCDYouTubeKit


//typealias NetworkServiceCompletion = (Result<(() -> Void)?, NetworkManagerErrors>) -> Void


protocol YTNetworkServiceProtocol: AnyObject {
    func downloadVideo(videoIdentifier: String, videoURL: URL) throws
}


final class YTNetworkService {

    // MARK: - Public properties
    var fileName: String?
    var photoURL: URL?

    // MARK: - Private properties
    private let manager: LocalFilesManagerProtocol

    init(manager: LocalFilesManagerProtocol) {
        self.manager = manager
    }

    // MARK: - Private methods
    private func fetchVideoInfo(youTubeID: String,
                                onCompleted: @escaping (_ video: XCDYouTubeVideo) -> Void) {

        XCDYouTubeClient.default().getVideoWithIdentifier(youTubeID) { video, error in
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

    func downloadVideo(videoIdentifier: String, videoURL: URL) throws {


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
                    guard let streamURL else {
                        print("streamURL error")
                        return
                    }
//вообще, вроде бы, плеер сам показывает первый кадр видео как превью/заставка (пока еще не делал плеер)
                    try self.manager.downloadFileAndSaveToPhotoGallery(File.video, wwwlink: streamURL, filename: self.fileName!, extension: "mp4")
//без загрузки фото запрос системы на разрешение работать с фото библиотекой не прерывает изменение прогерраса загрузки (если же метод загрузки фото включить, то он отрабатывает быстрее и системное уведомление выскакивает как раз на моменте загрузки видео  и это прерывает показ прогресса загрузки видео), даже group + Operation не помогли...возможно дело в коде метода downloadFileAndSaveToPhotoGallery...оставил - тоже часа 3 отняло...
//                    try self.manager.downloadFileAndSaveToPhotoGallery(File.photo, wwwlink: self.photoURL!, filename: self.fileName!, extension: "jpg")
                } catch let error as RouterErrors {
                    throw NetworkManagerErrors.networkRouterErrors(error: error)
                }
            }

        }

    }
}
