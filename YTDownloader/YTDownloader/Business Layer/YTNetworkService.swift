//
//  YTNetworkService.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 04.12.2023.
//

import Foundation
import YouTubeKit
import XCDYouTubeKit

protocol YTNetworkServiceProtocol: AnyObject {
//    var dataModelsStoredInFM: [VideoItemData]  { get set }
    func downloadVideo(videoIdentifier: String, videoURL: URL) throws
    func deleteFilesFromFMAndPhotoLibraryBy(fileName: String, mp4URL: URL, jpgURL: URL?)
//    func encodeAndSaveModelsArrAsJsonFileToFM(videoItemData: [VideoItemData])
}


final class YTNetworkService {

    // MARK: - Public properties
    var fileName: String?
    var mp4URLInFileManager: URL?
    var thumbnailURLInFileManager: URL?

//    var dataModelsStoredInFM: [VideoItemData]?
//        didSet { encodeAndSaveToFM(videoItemData: dataModelsStoredInFM) }
//    }

    // MARK: - Private properties
    private let fileManager: LocalFilesManagerProtocol
    private let mapper: MapperProtocol


    // MARK: - Init
    init(manager: LocalFilesManagerProtocol, mapper: MapperProtocol) {
        self.mapper = mapper
        self.fileManager = manager
          ///нужно, чтобы при перезапуске отображались уже скачанные видео
//        do {
//            let data = try Data(contentsOf: JsonModelsURL.inFM)
//            dataModelsStoredInFM = try mapper.decode(from: data, toArrStruct: [VideoItemData].self)
//            print("dataModelsStoredInFM inited in YTNet = \(dataModelsStoredInFM.count)")
//        }
//        catch {
//            print("1st launch or Error decoding data from FileManager into [VideoItemData]", error)
//        }
    }


    // MARK: - Public methods
    func deleteFilesFromFMAndPhotoLibraryBy(fileName: String, mp4URL: URL, jpgURL: URL?) {
        let nameAndExt = fileName + ".mp4"
        do {
            try self.fileManager.deleteFileFromPhotoLibraryBy(nameAndExt: nameAndExt,
                                                              mp4URL: mp4URL,
                                                              jpgURL: jpgURL)
        } catch {
            print(error.localizedDescription)
        }
    }

//    func encodeAndSaveModelsArrAsJsonFileToFM(videoItemData: [VideoItemData]) {
//        do {
//            ///кодируем data из [VideoItemData] для сохранения videoItemData в FM
//            let data = try mapper.encode(from: videoItemData)
//            ///сохраняем в FM по уникальному url
//            try data.write(to: JsonModelsURL.inFM)
//            print("\(DataModelsStoredInFM), this ARRAY encoded to \(data) & saved to \(JsonModelsURL.inFM)")
//        } catch {
//            print("Error saving data to FileManager: \(error.localizedDescription)")
//        }
//    }

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
        self.mp4URLInFileManager = URL(filePath: documentsURL.appendingPathComponent(fileName + ".mp4").path())
        self.thumbnailURLInFileManager = URL(filePath: documentsURL.appendingPathComponent(fileName + ".jpg").path())

        guard let videoURL = self.mp4URLInFileManager,
              let photoURL = self.thumbnailURLInFileManager else { return }

        if fileManager.checkIfVideoExist(path: videoURL.path) {
            fileManager.statusClosure?(State.fileExists)
        } else {
            ///нужную инфо о видео упорядочиваем в новую dataModel
            let dataModel = VideoItemData(
                name: fileName,
                mp4URLWithPathInFMForPlayer: videoURL,
                jpgURLWithPathInFMForPlayer: photoURL,
                dateOfDownload: Date()
            )

            ///dataModel этого видео добавляем в [VideoItemData] в Storage и в didSet сохраняем [VideoItemData] в FileManager
            Storage.shared.dataModelsStoredInFM.append(dataModel)


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
                        try self.fileManager.downloadFileAndSaveToPhotoGallery(File.photo, wwwlink: videoThumbnail, filename: self.fileName!, extension: "jpg")
                        
                        try self.fileManager.downloadFileAndSaveToPhotoGallery(File.video, wwwlink: streamURL, filename: self.fileName!, extension: "mp4")
                        
                    } catch let error as RouterErrors {
                        throw NetworkServiceErrors.networkRouterErrors(error: error)
                    }
                }

            }

        }
    }
}
