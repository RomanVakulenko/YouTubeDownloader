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
    var assetID: String?

    // MARK: - Private properties
    private var observation: NSKeyValueObservation?
    private let mapper: MapperProtocol

    // MARK: - Init
    init(mapper: MapperProtocol) {
        self.mapper = mapper
    }

    // MARK: - Public methods
    func deleteFilefromPhotoLibraryBy(_ nameAndExt: String) { //потом сделать deleteVideoByName(_ name: String) //будет удалять и из коллекции, и из fileManager и из PhotoLibrary
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
    private func saveVideoInPhotoLibraryWith(urlWithoutPath: URL) throws {
        ///сохраняем в Photo Library (была  задача или из-за уведомления от системы так решил)
        try PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: urlWithoutPath, options: nil) // бывает вариант с data
            self.assetID = request.placeholderForCreatedAsset?.localIdentifier
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
//        if fileManager.fileExists(atPath: urlOfMp4SavedInFM.path) {
//            print("File already exists")
//            if file  == .video {
//                self.statusClosure?(State.fileExists)
//            }
//            self.deleteFilefromPhotoLibraryBy(nameAndExt)
//            do {
//                try self.fileManager.removeItem(at: urlOfMp4SavedInFM)
//                print("File \(nameAndExt) was removed from FileManager")
//            } catch {
//                throw NetworkManagerErrors.fileManagerErrors(error: .unableToDelete)
//            }
//        } else {
            self.observation?.invalidate()
            if file  == .video {
                self.statusClosure?(State.loading)
            }
            let urlRequest = URLRequest(url: wwwlink)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
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

                do {
                    switch file {
                    case .video:
                        try self.saveVideoInPhotoLibraryWith(urlWithoutPath: urlOfMp4SavedInFM)
                        self.statusClosure?(State.loadedAndSaved)
                    case .photo:
                        print("Заставку не сохраняем в ФОТО, иначе, в момент сохранения при первом запуске, онлайн изменение полоски progress'a не показывается - его сбивает системный запрос на работу с PhotoLibrary")
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
//        } //от if else проверяющий есть ли такое видео
    }
}

// MARK: - Extensions



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
