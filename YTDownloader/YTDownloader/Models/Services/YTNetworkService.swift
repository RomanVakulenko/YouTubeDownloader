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
    var dataModelsStoredInFM: [VideoItemData]  { get set }
    func downloadVideo(videoIdentifier: String, videoURL: URL) throws
}


final class YTNetworkService {


    // MARK: - Public properties
    var fileName: String?

    var mp4URLInFileManager: URL?
    var thimbnailURLOfVideo: URL?

    var dataModelsStoredInFM: [VideoItemData] = [] {
        didSet {
            encodeAndSaveToFM(videoItemData: dataModelsStoredInFM)
            print("dataModelsStoredInFM - \(dataModelsStoredInFM)")
        }
    }

    // MARK: - Private properties
    private let manager: LocalFilesManagerProtocol
    private let mapper: MapperProtocol


    // MARK: - Init
    init(manager: LocalFilesManagerProtocol, mapper: MapperProtocol) {
        self.mapper = mapper
        self.manager = manager
        do {
            let data = try Data(contentsOf: JsonModelsURL.inFM)
            dataModelsStoredInFM = try mapper.decode(from: data, toArrStruct: [VideoItemData].self)
        }
        catch {
            print("1st launch or Error decoding data from FileManager into dataModels", error)
        }
    }

    // MARK: - Private methods
    private func encodeAndSaveToFM(videoItemData: [VideoItemData]) {
        do {
            ///делаем data из [VideoItemData]
            let data = try mapper.encode(from: videoItemData)
            ///сохраняем в FM по уникальному url
            try data.write(to: JsonModelsURL.inFM)
            print("dataWrittenInto JsonModelsURL.inFM - \(data)")
        } catch {
            print("Error saving data to FileManager: \(error.localizedDescription)")
        }
    }

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
            print("XCDYouTubeClient ------ \(video)")
        }
    }
}

// MARK: - Extensions YTNetworkServiceProtocol
extension YTNetworkService: YTNetworkServiceProtocol {
//    @MainActor
    func downloadVideo(videoIdentifier: String, videoURL: URL) throws {

        let fileName = videoIdentifier
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        //        self.mp4URLInFileManager = URL(filePath: documentsURL.appendingPathComponent(fileName + ".mp4").path())
        //        self.thimbnailURLOfVideo = URL(filePath: documentsURL.appendingPathComponent(fileName + ".jpg").path())

        let urlVideoWithPathInFM = URL(filePath: documentsURL.appendingPathComponent(fileName + ".mp4").path())
        let urlPhotoWithPathInFM = URL(filePath: documentsURL.appendingPathComponent(fileName + ".jpg").path())
        ///нужную инфо о видео упорядочиваем в новую dataModel
        let dataModel11 = VideoItemData(
            name: fileName,
            mp4URLInFileManager: urlVideoWithPathInFM,
            thumbnailURL: urlPhotoWithPathInFM,
            //                          assetID:  self.assetID,
            dateOfDownload: Date()
        )
            ///dataModel добавляем в массив, массив кодируем в data и сохраняем в FM
            self.dataModelsStoredInFM.append(dataModel11)
//            print(dataModelsStoredInFM)

//        #error("1. переименовать классы этот и LocalFilesManager соосно функционалу, реализовать удаление и обновление коллекции тут же, 2. если не первый запуск и если все видео удалены, то выкидывать алерт")
//        let fmVideoURLWithoutPath = documentsURL.appendingPathComponent(fileName + ".mp4")


        fetchVideoInfo(youTubeID: videoIdentifier) { [weak self] video in
            guard let self else {return}

            self.fileName = "\(video.identifier)"
            guard let videoThumbnail = video.thumbnailURLs?.first else {
                print("There was no thumbnail or can not get it")
                return
            }

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
                    try self.manager.downloadFileAndSaveToPhotoGallery(File.photo, wwwlink: videoThumbnail, filename: self.fileName!, extension: "jpg")

                    try self.manager.downloadFileAndSaveToPhotoGallery(File.video, wwwlink: streamURL, filename: self.fileName!, extension: "mp4")

                } catch let error as RouterErrors {
                    throw NetworkManagerErrors.networkRouterErrors(error: error)
                }
            }
        }

    }
}
