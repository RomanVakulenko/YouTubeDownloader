//
//  SecondViewModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit
import Photos


protocol EmptyVideoDelegateProtocol: AnyObject {
    func organizeAlertOfNoVideo()
}


final class SecondViewModel {

    // MARK: - Public properties
    var videos: [UIMediaItem] = []

    // MARK: - Private properties
    private let coordinator: VideoFlowCoordinator
    private weak var emptyVideoDelegate: EmptyVideoDelegateProtocol?
    private let mapper: MapperProtocol
    private let ytNetworkService: YTNetworkServiceProtocol?


    // MARK: - Init
    init(coordinator: VideoFlowCoordinator, emptyVideoAlertDelegate: EmptyVideoDelegateProtocol, mapper: MapperProtocol, ytNetworkService: YTNetworkServiceProtocol) {
        self.coordinator = coordinator
        self.emptyVideoDelegate = emptyVideoAlertDelegate
        self.mapper = mapper
        self.ytNetworkService = ytNetworkService
    }

    // MARK: - Public methods
    func makeVideosArrForUI() {
        do {
            ///достаем из FileManager [VideoItemData] как data  и  декодруем в [UIMediaItem]
            let data = try Data(contentsOf: JsonModelsURL.inFM)
            /// videos создается пустым сначала и тут наполняется
            videos = try mapper.decode(from: data, toArrStruct: [UIMediaItem].self)
            print("videos.count = \(videos.count), viewModelvideos = \(videos)")
        } catch {
            print(NetworkServiceErrors.mapperErrors(error: .failAtMapping(reason: "1st launch или нечего декодировать or Ошибка конвертации из ФC в data или декодирования в [UIMediaItem]")))
        }
    }


    func didTapDeleteVideoAt(_ indexPath: IndexPath,
                             reloadCollectionWhenCompleted: @escaping (() -> Void)) {

        let videoToDelete = videos[indexPath.item]

        ///удаляем конкретную dataModel из Storage из массива dataModelsStoredInFM и перезаписываем содержание массива  в FM по адресу JsonModelsURL.inFM
        ///и перезаписываем содержание массива DataModelsStoredInFM в FM по адресу JsonModelsURL.inFM
        Storage.shared.dataModelsStoredInFM.removeAll(where: { $0.name == videoToDelete.name })

        ///удаляем из FileManager и из PhotoLibrary
        self.ytNetworkService?.deleteFilesFromFMAndPhotoLibraryBy(
            fileName: videoToDelete.name,
            mp4URL: videoToDelete.mp4URLWithPathInFMForPlayer,
            jpgURL: videoToDelete.jpgURLWithPathInFMForPlayer
        )

        ///удаляем видео из массива для коллекции
        self.videos.remove(at: indexPath.item)

        self.videos.count == 0 ? coordinator.popToRootVC() : ()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.informIfNoVideo()
        }
        reloadCollectionWhenCompleted()
    }

    // MARK: - Private methods
    private func informIfNoVideo() {
        if self.videos.count == 0 {
            emptyVideoDelegate?.organizeAlertOfNoVideo()
        }
    }
}

