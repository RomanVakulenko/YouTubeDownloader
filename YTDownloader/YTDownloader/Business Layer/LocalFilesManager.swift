//
//  LocalFilesManager.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 01.12.2023.
//

import UIKit
import AVFoundation
import Photos

protocol someProtocol {

}

protocol LocalFilesManagerProtocol: AnyObject {
    var statusClosure: ((State) -> Void)? {get set}
    var progressClosure: ((Float) ->Void)? {get set}
    func downloadFileAndSaveToPhotoGallery(_ file: File,
                                           wwwlink: URL,
                                           filename: String,
                                           extension ext: String) throws
}

enum File {
    case video, photo
}

final class LocalFilesManager {

    // MARK: - Public properties
    let fileManager = FileManager.default
    let userDefaults = UserDefaults.standard
    var statusClosure: ((State) -> Void)?
    var progressClosure: ((Float) ->Void)?
    var videoItemWithData: VideoItemData?
    var encodedVideoItemData: Data?
    var assetID: String?

    // MARK: - Private properties
    private var observation: NSKeyValueObservation?
    private let mapper: MapperProtocol

    init(mapper: MapperProtocol) {
        self.mapper = mapper
    }

    // MARK: - Public methods
    func getLocalFileURL(withNameAndExtension fileName_ext: String) -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName_ext)
    }


    // MARK: - Private methods
    func deleteFileBy(_ nameAndExt: String) { //потом сделать deleteVideoByName(_ name: String) //будет удалять и из коллекции, и из fileManager и из PhotoLibrary
        var assetsLocalIDs = [String]()
        let oneID = userDefaults.object(forKey: "\(nameAndExt)") as? String
        guard let oneID = oneID else {
            print("Не смог достать объект \(nameAndExt) по этому же ключу из userDefaults, странно, но иногда выкидывает системный запрос на удаление видео, удаляю/Allow, но в приложении Фото видео висит))) пытался часа 4 это сделать и оставил так")
            return
        }
        assetsLocalIDs.append(oneID)
        let allAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsLocalIDs, options: nil)
        if let assetToDelete = allAssets.firstObject {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([assetToDelete] as NSArray)
            }) { success, error in
                if success {
                    print("Файл \(nameAndExt) удален успешно")
                } else {
                    print("Ошибка удаления файла: \(error!.localizedDescription)")
                }
            }
        }
    }
    deinit {
        observation?.invalidate()
    }

}

// MARK: - Extensions
extension LocalFilesManager: someProtocol {
 //что-то хотел сделать...
}

// MARK: - Extensions LocalFilesManagerProtocol

extension LocalFilesManager: LocalFilesManagerProtocol {

    func downloadFileAndSaveToPhotoGallery(_ file: File,
                                           wwwlink: URL,
                                           filename: String,
                                           extension ext: String) throws {

        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NetworkManagerErrors.fileManagerErrors(error: .cannotGetURLOfFile)
        }
        let nameAndExt = filename + "." + ext
        let fileURLwithNameAndExt = documentsURL.appendingPathComponent(nameAndExt)
        
        if fileManager.fileExists(atPath: fileURLwithNameAndExt.path) {
            print("File already exists")
            if file  == .video {
                self.statusClosure?(State.fileExists)
            }
            self.deleteFileBy(nameAndExt)
            do {
                try self.fileManager.removeItem(at: fileURLwithNameAndExt)
                print("File \(nameAndExt) was removed from FileManager")
            } catch {
                throw NetworkManagerErrors.fileManagerErrors(error: .unableToDelete)
            }
        } else {
            if file  == .video {
                self.statusClosure?(State.loading)
            }
            let urlRequest = URLRequest(url: wwwlink)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                self.observation?.invalidate()
                guard let data,
                      let response = response as? HTTPURLResponse else {
                    print("Не смог скачать data")
                    return
                }

                let statusCode = response.statusCode
                if statusCode < 200 && statusCode > 299 {//прокидывать ошибку не дает dataTask
                    if file  == .video {
                        self.statusClosure?(State.badURL(alertText: "Сервер не отвечает"))
                    }
                }
                
                do {
                    switch file {
                    case .video:
                        self.userDefaults.set(Date(), forKey: "\(nameAndExt)")

                        try PHPhotoLibrary.shared().performChangesAndWait {
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: fileURLwithNameAndExt, options: nil) // бывает вариант с data
                            self.assetID = request.placeholderForCreatedAsset?.localIdentifier
                            print("VideoASSET_ID is = \(String(describing: self.assetID))")
                        }
                        ///нужную инфо о видео упорядочили в структуру
                        self.videoItemWithData = VideoItemData(name: nameAndExt,
                                                               fileURL: fileURLwithNameAndExt,
                                                               assetID:  self.assetID,
                                                               dateOfDownload: Date())
                        ///энкодируем модель данных в Data, чтобы потом записать в FileManager
                        do {
                            self.encodedVideoItemData = try self.mapper.encode(from: self.videoItemWithData)
                        } catch {
                            print("\(MapperError.failAtParsing(reason: "Не смог энкодировать в Data"))")
                        }

                        ///сохраняем encodedVideoItemData в FileManager
                        if let data = self.encodedVideoItemData {
                            do {
                                try data.write(to: fileURLwithNameAndExt)
                            } catch {
                                print("Error saving data to FileManager: \(error.localizedDescription)")
                            }
                            self.statusClosure?(State.loadedAndSaved)
                        }
#error("сохранил encodedVideoItemData в FileManager, далее где будем применять данные - достаем из FileManager, декодируем в secondViewModel в UIMediaItem или в массив их, и потом во VC подставляем в ячейку по indexPathl; также надо создать ячейку")
                    case .photo:
                        try PHPhotoLibrary.shared().performChangesAndWait {
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .photo, data: data, options: nil)
                            if let assetID = request.placeholderForCreatedAsset?.localIdentifier {
                                self.userDefaults.set(assetID, forKey: "\(nameAndExt)")//ID файла для удаления
                                print("PhotoASSET_ID is = \(assetID)")

                            }
                        }
                    }
                } catch {
                    switch error {
                    case NetworkManagerErrors.fileManagerErrors(error: .unableToMove):
                        print(error.localizedDescription)
                    case NetworkManagerErrors.fileManagerErrors(error: .unableToSaveToPHLibrary):
                        print(error.localizedDescription)
                    default:
                        print("Error saving \(file) to Photo Library: \(error.localizedDescription)")
                    }
                    if file  == .video {
                        self.statusClosure?(State.badURL(alertText: "Попробуйте позже"))
                    }
                    return
                }

            }
            ///следим за прогрессом загрузки
            if file  == .video {
                self.observation = dataTask.progress.observe(\.fractionCompleted) { observingProgress, _ in
                    ///передаем значение прогресса в гл. потоке
                    DispatchQueue.main.async {
                        self.progressClosure?(Float(observingProgress.fractionCompleted))
                    }
                }
            }
            dataTask.resume()
        }
    }
}

// MARK: - Extensions
//extension LocalFilesManager: URLSessionDownloadDelegate {

//заходит в urlData.write и приложении висит, не нашел решения
//________
//        let urlData = try Data(contentsOf: link)
//        DispatchQueue.main.async {
//            do {
//                try urlData.write(to: fileURL, options: .atomic)
//                PHPhotoLibrary.requestAuthorization { status in
//                    if status == .authorized {
//                        PHPhotoLibrary.shared().performChanges({
//                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
//                        }) { completed, error in
//                            if completed {
//                                print("Video is saved!")
//                            }
//                            if let error = error {
//                                print("Error saving video: \(error)")
//                            }
//                        }
//                    }
//                }
//            } catch {
//                print("Error writing video to disk: \(error)")
//            }
//        }
//________








//были внутри класса:
//
//static func saveImage(_ image: UIImage?, withName filename: String) {
//    guard let img = image else {
//        return
//    }
//    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//    let documentsDirectory = paths[0]
//    let dataPathStr = documentsDirectory + "/" + filename + ".jpg"
//
//    let dataPath = URL(fileURLWithPath: dataPathStr)
//    do {
//        try img.jpegData(compressionQuality: 1.0)?.write(to: dataPath, options: .atomic)
//    } catch {
//        print("file cant not be save at path \(dataPath), with error : \(error)");
//    }
//}
//
//static func deleteFile(withNameAndExtension filename_ext: String) -> Bool {
//    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//    let documentsDirectory = paths[0]
//    let dataPathStr = documentsDirectory + "/" + filename_ext
//    if FileManager.default.fileExists(atPath: dataPathStr) {
//        do {
//            try FileManager.default.removeItem(atPath: dataPathStr)
//            print("Removed file: \(dataPathStr)")
//        } catch let removeError {
//            print("couldn't remove file at path", removeError.localizedDescription)
//            return false
//        }
//    }
//    return true
//}
//
//static func checkFileExist (_ filename_ext: String) -> Bool {
//    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//    let documentsDirectory = paths[0]
//    let dataPathStr = documentsDirectory + "/" + filename_ext
//    return FileManager.default.fileExists(atPath: dataPathStr)
//}
//
//static func clearTmpDirectory() {
//    do {
//        let tmpDirURL = FileManager.default.temporaryDirectory
//        let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
//        try tmpDirectory.forEach { file in
//            let fileUrl = tmpDirURL.appendingPathComponent(file)
//            try FileManager.default.removeItem(atPath: fileUrl.path)
//        }
//    } catch {
//        print("Cleaning Tmp Directory Failed: " + error.localizedDescription)
//    }
//}
//
