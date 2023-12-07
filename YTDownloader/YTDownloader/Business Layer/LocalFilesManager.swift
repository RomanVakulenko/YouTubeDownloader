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
    func downloadFileAndSaveToPhotoGallery(file: File, from link: URL, filename: String, extension ext: String) throws
}

enum File {
    case video, photo
}

final class LocalFilesManager {
    
    // MARK: - Public properties
    let fileManager = FileManager.default

    // MARK: - Private properties

    //добавить метод на проверку наличия файлов в photo library

    // придумать как передавать обновлять стейт  - должен ли этот файл знать о вью модели?


    // MARK: - Public methods
    func getLocalFileURL(withNameAndExtension fileName_ext: String) -> URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName_ext)
    }

}

// MARK: - Extensions LocalFilesManagerProtocol

extension LocalFilesManager: LocalFilesManagerProtocol {

    func downloadFileAndSaveToPhotoGallery(file: File, from link: URL, filename: String, extension ext: String) throws {

        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NetworkManagerErrors.fileManagerErrors(error: .cannotGetFilesURL)
        }

        let fileURLwithNameAndExt = documentsURL.appendingPathComponent(filename + "." + ext)
        print("fileURLwithNameAndExt == \(fileURLwithNameAndExt)")

//добавить проверку на наличие файлов в photo library, потому что даже когда удалили на 52 строке, а потом заново запустили, то в fileManager его якобы нет, а в photo на симуляторе файлы отображаюся


        if fileManager.fileExists(atPath: fileURLwithNameAndExt.path) {
            print("File already exists") //??подумать как прокинуть инфу до viewModel, чтобы поменять state и отобразить уведомление
            do {
                try self.fileManager.removeItem(at: fileURLwithNameAndExt)
                print("File \(fileURLwithNameAndExt) was removed")
            } catch let error {
                print("Ошибка удаления файла из fileManager - \(error)")
            }
        } else {
           // self.fileManager.createFile(atPath: url.appendingPathComponent(fileName).path, contents: data)// в YouOn он зачем-то записывает файл сначала в fileManager...

            let downloadTask = URLSession.shared.downloadTask(with: link) { (location, response, error) in
                guard let location = location, error == nil else {
                    switch file {
                    case .video:
                        print("Error downloading video: \(error?.localizedDescription ?? "Unknown error")")
                    case .photo:
                        print("Error downloading photo: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    return
                }

                print("location = \(location)")

                do {

                    do {
                        try self.fileManager.moveItem(at: location, to: fileURLwithNameAndExt)
                        switch file {
                        case .video:
                            print("Video successfully moved to: \(fileURLwithNameAndExt.path)")
                        case .photo:
                            print("Photo successfully moved to: \(fileURLwithNameAndExt.path)")
                        }
                    } catch {
                        switch file {
                        case .video:
                            print("Error moving video to documents directory: \(error.localizedDescription)")
                        case .photo:
                            print("Error moving photo to documents directory: \(error.localizedDescription)")
                        }
                        return
                    }

                    switch file {
                    case .video:
                        try PHPhotoLibrary.shared().performChangesAndWait {
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .video, fileURL: fileURLwithNameAndExt, options: nil) //оппробовать использовать with data, поскольку дата нам приходила ранее
                        }
                        print("Video saved to Photo Library")
                    case .photo:
                        try PHPhotoLibrary.shared().performChangesAndWait {
                            let request = PHAssetCreationRequest.forAsset()
                            request.addResource(with: .photo, fileURL: fileURLwithNameAndExt, options: nil)
                        }
                        print("Photo saved to Photo Library")
                    }
                } catch {
                    switch file {
                    case .video:
                        print("Error saving video to Photo Library: \(error.localizedDescription)")
                    case .photo:
                        print("Error saving photo to Photo Library: \(error.localizedDescription)")
                    }
                    return
                }

            }
            downloadTask.resume()
        }
    }
}


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
