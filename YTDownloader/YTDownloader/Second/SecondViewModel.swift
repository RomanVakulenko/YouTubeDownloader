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

protocol SecondViewModelGetVideoProtocol: AnyObject {

}

final class SecondViewModel {

    // MARK: - Public properties
    var videos: [MediaItemProtocol]?

    // MARK: - Private properties
    private weak var emptyVideoDelegate: EmptyVideoDelegateProtocol?
    private let mapper: MapperProtocol
    private let ytNetworkService: YTNetworkServiceProtocol?


    // MARK: - Init
    init(emptyVideoAlertDelegate: EmptyVideoDelegateProtocol, mapper: MapperProtocol, ytNetworkService: YTNetworkServiceProtocol) {
        self.emptyVideoDelegate = emptyVideoAlertDelegate
        self.mapper = mapper
        self.ytNetworkService = ytNetworkService
    }

    // MARK: - Public methods
    func makeVideosArrForUI() {
        do {
            ///достаем из FileManager [VideoItemData] как data  и  декодруем в [UIMediaItem]
            let data = try Data(contentsOf: JsonModelsURL.inFM)
            videos = try mapper.decode(from: data, toArrStruct: [UIMediaItem].self)
            print(videos as Any)
        } catch {
            print(NetworkManagerErrors.mapperErrors(error: .failAtMapping(reason: "1st launch or Ошибка конвертации из ФC в data или декодирования в [UIMediaItem]")))
        }
    }


    func didTapDeleteVideoAt(_ indexPath: IndexPath,
                             reloadCollectionWhenCompleted: @escaping (() -> Void)) {
        //обратимся к хранилищу и удалить оттуда
        guard let videos else { return }
        let videoToDelete = videos[indexPath.item]

        ///удаляем видео из FM
        self.ytNetworkService?.dataModelsStoredInFM.removeAll(
            where: { $0.name == videoToDelete.name }
        )
        ///удаляем видео из [model]
        self.videos?.remove(at: indexPath.item)

#error("обязательно удалять сами файлы видео и фото из FM!")


#warning("тут также можно удалять видео из PhotoLibrary (вопрос нужен ли asset - скорее да)")

        reloadCollectionWhenCompleted()
        //            coordinator?.popToRootVC()
    }


    //запускать, когда 2 контроллер уходит с экрана
    func informIfNoVideo() {

        //        if videos.isEmpty {
        //            emptyVideoDelegate?.organizeAlertOfNoVideo()
        //        }
    }
}

