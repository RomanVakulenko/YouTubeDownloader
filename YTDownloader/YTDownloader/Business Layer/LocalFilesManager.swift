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
    var statusClosure: ((State) -> Void)? { get set }
    var progressClosure: ((Float) ->Void)? { get set }
    func downloadFileAndSaveToPhotoGallery(_ file: File,
                                           wwwlink: URL,
                                           filename: String,
                                           extension ext: String) throws
    func deleteFileFromPhotoLibraryBy(nameAndExt: String, mp4URL: URL, jpgURL: URL?) throws
    func checkIfVideoExist(path: String) -> Bool
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
    func deleteFileFromPhotoLibraryBy(nameAndExt: String, mp4URL: URL, jpgURL: URL?) throws {
        ///удаляем из FM mp4 и jpg
        if fileManager.fileExists(atPath: mp4URL.path) {
            do {
                guard let jpgURL else { return }
                try self.fileManager.removeItem(at: mp4URL)
                try self.fileManager.removeItem(at: jpgURL)
                print("File at \(mp4URL) was removed from FileManager")
                print("File at \(jpgURL) was removed from FileManager")
            } catch {
                throw NetworkServiceErrors.fileManagerErrors(error: .unableToDelete)
            }
        }
        ///удаляем из PhotoLibrary
        var assetsLocalIDs = [String]()
        let oneID = userDefaults.object(forKey: "\(nameAndExt)") as? String
        guard let oneID else { return }
        assetsLocalIDs.append(oneID)

        let allAssets = PHAsset.fetchAssets(withLocalIdentifiers: assetsLocalIDs, options: nil)
        if let assetToDelete = allAssets.firstObject {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([assetToDelete] as NSArray)
            }) { success, error in
                if success {
                    print("Файл \(nameAndExt) удален успешно из PhotoLibrary")
                } else {
                    print("Ошибка удаления файла: \(error!.localizedDescription)")
                }
            }
        }
    }

    func checkIfVideoExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }


    // MARK: - Private methods
    private func saveVideoToPHAndAssetToUD(urlWithoutPath: URL, nameAndExt: String) throws {
        try PHPhotoLibrary.shared().performChangesAndWait {
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .video, fileURL: urlWithoutPath, options: nil) // бывает вариант с data
            if let assetID = request.placeholderForCreatedAsset?.localIdentifier {
                self.assetID = assetID
                ///сохраним в UD ID для удаления - так удобнее, чем выбрасывать assetID в YTNetworkService (для модели)
                self.userDefaults.set(assetID, forKey: "\(nameAndExt)")
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
            throw NetworkServiceErrors.fileManagerErrors(error: .cannotGetURLOfFile)
        }

        let nameAndExt = filename + "." + ext
        let urlOfMp4SavedInFM = documentsURL.appendingPathComponent(nameAndExt)

        if self.checkIfVideoExist(path: urlOfMp4SavedInFM.path) {
            if file  == .video {
                self.statusClosure?(State.fileExists)
            }
        } else {
            self.observation?.invalidate()
            if file  == .video {
                self.statusClosure?(State.loading)
            }
            let urlRequest = URLRequest(url: wwwlink)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard let data,
                      let response = response as? HTTPURLResponse else {
                    print("Не смог скачать data")
                    return
                }
                let statusCode = response.statusCode
                if statusCode < 200 && statusCode > 299 {
                    if file  == .video {
                        self.statusClosure?(State.badURL(alertText: "Сервер не отвечает"))
                        print("serverErrorWith \(statusCode)") //прокидывать ошибку не дает dataTask
                    }
                }
                ///Сохраняем file (mp4/jpg) в FileManager
                self.fileManager.createFile(atPath: urlOfMp4SavedInFM.path, contents: data)

                do {
                    switch file {
                    case .video:
                        ///Сохраняем video в PhotoLibrary
                        try self.saveVideoToPHAndAssetToUD(urlWithoutPath: urlOfMp4SavedInFM, nameAndExt: nameAndExt)
                        self.statusClosure?(State.loadedAndSaved)
                    case .photo:
                        print("Заставку не сохраняем в PhotoLibrary(PH), иначе, в момент сохранения при первом запуске, системный запрос на работу с PH сбивает изменение progress'a, да и из PH photo не удалить кодом")
                    }
                } catch let error as URLError {
                    if error.networkUnavailableReason == .cellular {
                        print("Сотовая сеть отключена")
                    } else if let reason = error.networkUnavailableReason {
                        print("Сеть недоступна: \(reason)")
                    }
                    switch error.code {
                    case .badURL:
                        print("Некорректный URL")
                    case .networkConnectionLost:
                        print("Соединение было разорвано")
                    case .notConnectedToInternet:
                        self.statusClosure?(State.badURL(alertText: RouterErrors.noInternetConnection.description))
                        print("Нет подключения к интернету")
                    default:
                        print("Неизвестная типа URLError")
                    }
                } catch {
                    switch error {
                    case NetworkServiceErrors.fileManagerErrors(error: .unableToSaveToPHLibrary):
                        print(error.localizedDescription)
                    default:
                        self.statusClosure?(State.badURL(alertText: NetworkServiceErrors.show.descriptionForUser))
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

