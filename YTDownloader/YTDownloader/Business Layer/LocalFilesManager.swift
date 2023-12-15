//
//  LocalFilesManager.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 01.12.2023.
//

import UIKit
import AVFoundation
import Photos

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
    var dataModel: VideoItemData?
    var dataModelsForSavingIntoFM: [VideoItemData] = [] {
        didSet {
            encodeAndSaveToFM(videoItemData: dataModelsForSavingIntoFM)
        }
    }
    var assetID: String?

    // MARK: - Private properties
    private var observation: NSKeyValueObservation?
    private let mapper: MapperProtocol

    // MARK: - Init
    init(mapper: MapperProtocol) {
        self.mapper = mapper
        do {
            let data = try Data(contentsOf: JsonModelsURL.inFM)
            dataModelsForSavingIntoFM = try mapper.decode(from: data, toArrStruct: [VideoItemData].self)
        }
        catch {
            print("1st launch or Error decoding data from FileManager into dataModels", error)
        }
    }

    // MARK: - Public methods
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

    // MARK: - Private methods
    private func encodeAndSaveToFM(videoItemData: [VideoItemData]) {
        do {
            ///делаем data из [VideoItemData]
            let data = try mapper.encode(from: videoItemData)
            ///сохраняем в FM по уникальному url
            try data.write(to: JsonModelsURL.inFM)
        } catch {
            print("Error saving data to FileManager: \(error.localizedDescription)")
        }
    }

    deinit {
        observation?.invalidate()
    }
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
        let urlOfMp4SavedInFM = documentsURL.appendingPathComponent(nameAndExt)
//        if fileManager.fileExists(atPath: fileURLwithNameAndExt.path) {
//            print("File already exists")
//            if file  == .video {
//                self.statusClosure?(State.fileExists)
//            }
//            self.deleteFileBy(nameAndExt)
//            do {
//                try self.fileManager.removeItem(at: fileURLwithNameAndExt)
//                print("File \(nameAndExt) was removed from FileManager")
//            } catch {
//                throw NetworkManagerErrors.fileManagerErrors(error: .unableToDelete)
//            }
//        } else {
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

                ///Сохраняем file (mp4/jpg) в FileManager
                self.fileManager.createFile(atPath: urlOfMp4SavedInFM.path, contents: data)
                ///Создаем urlWithPath до file (mp4/jpg) в FileManager (чтбы плеер потом его смог бы достать из FM)
                let urlWithPath = URL(filePath: urlOfMp4SavedInFM.path())

                do {
                    switch file {
                    case .video:
                        ///сохраняем в Photo Library (была  задача или из-за уведомления от системы так решил)
                        try PHPhotoLibrary.shared().performChangesAndWait {
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: urlOfMp4SavedInFM, options: nil) // бывает вариант с data
                            self.assetID = request.placeholderForCreatedAsset?.localIdentifier
                        }


                        self.statusClosure?(State.loadedAndSaved)


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


                    ///нужную инфо о видео упорядочиваем в dataModel
                    let dataModel = VideoItemData(
                        name: nameAndExt,
                        mp4URLInFileManager: urlWithPath,
                        thumbnailURL: urlWithPath,
//                          assetID:  self.assetID,
                        dateOfDownload: Date())

                    ///dataModel добавляем в массив, массив кодируем в data и сохраняем в FM
                    self.dataModelsForSavingIntoFM.append(dataModel)

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
//        } //от if else проверяющий есть ли такое видео 
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








// MARK: - Public methods
//    func getLocalFileURL(withNameAndExtension fileName_ext: String) -> URL {
//        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName_ext)
//    }

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
