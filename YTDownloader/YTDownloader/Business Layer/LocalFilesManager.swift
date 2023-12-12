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

    // MARK: - Private properties
    private var observation: NSKeyValueObservation?


    // MARK: - Public methods
    func getLocalFileURL(withNameAndExtension fileName_ext: String) -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName_ext)
    }


    // MARK: - Private methods
    func isVideoExistIn(photoLibrary: [String: URL]) {

    }

    func deleteVideoBy(_ nameAndExt: String) { //потом сделать deleteVideoByName(_ name: String) //будет удалять и из коллекции, и из fileManager и из PhotoLibrary
        var assetsLocalIDs = [String]()
        let oneID = userDefaults.object(forKey: "\(nameAndExt)") as! String
        assetsLocalIDs.append(oneID)
        //                PhotoASSET_ID is = 4661BAA8-F374-4D16-9E19-3BCAA2321293/L0/001
        //                VideoASSET_ID is = 6F80236D-8087-4450-A45F-40607D28BD0F/L0/001
        let allAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsLocalIDs, options: nil)
        //почему-то удаляет только видео а фото не удаляет - возможно дело в последовaтельности вызовов ??....
        if let assetToDelete = allAssets.firstObject {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([assetToDelete] as NSArray)
            }) { success, error in
                if success {
                    print("Файл удален успешно")
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
            self.statusClosure?(State.fileExists)
            do {
                try self.fileManager.removeItem(at: fileURLwithNameAndExt)
                print("File \(nameAndExt) was removed from FileManager")
            } catch {
                throw NetworkManagerErrors.fileManagerErrors(error: .unableToDelete)
            }
        } else {
            self.statusClosure?(State.loading)
            let urlRequest = URLRequest(url: wwwlink)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                self.observation?.invalidate()
                guard let data,
                      let response = response as? HTTPURLResponse else {
                    print("Не смог скачать data")
                    return
                }
                print("data = \(data)")
                //записываем data в FileManager, чтобы потом сохранить через путь в PhotoLibrary
                self.fileManager.createFile(atPath: documentsURL.appendingPathComponent(nameAndExt).path, contents: data)// в YouOn он зачем-то записывает файл сначала в FileManager...

                let statusCode = response.statusCode
                if statusCode < 200 && statusCode > 299 {//прокидывать ошибку не дает dataTask
                    self.statusClosure?(State.badURL(alertText: "Сервер не отвечает"))
                }
                
                do {
                    switch file {
                    case .video:
                        try PHPhotoLibrary.shared().performChangesAndWait {
                            let request = PHAssetCreationRequest.forAsset()
                            //                            request.addResource(with: .video, data: data, options: nil)
                            request.addResource(with: .video, fileURL: fileURLwithNameAndExt, options: nil) // бывает вариант с data
                            if let assetID = request.placeholderForCreatedAsset?.localIdentifier {
                                self.userDefaults.set(assetID, forKey: "\(nameAndExt)")//ID файла для удаления (видео не удается удалять из PhotoLibrary, а фото удаляет)
                                print("VideoASSET_ID is = \(assetID)")
                            }
                        }
                        print("Video saved to Photo Library")
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
                        print("Photo saved to Photo Library")
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
                    self.statusClosure?(State.badURL(alertText: "Попробуйте позже"))
                    return
                }

            }
            ///следим за прогрессом загрузки
            switch file {
            case .video:
                self.observation = dataTask.progress.observe(\.fractionCompleted) { observingProgress, _ in
                    ///передаем значение прогресса в гл. потоке
                    DispatchQueue.main.async {
                        self.progressClosure?(Float(observingProgress.fractionCompleted))
                    }
                }
            case .photo:
                print("Photo saved to Photo Library")
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
