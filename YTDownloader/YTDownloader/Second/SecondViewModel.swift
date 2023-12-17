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


    // MARK: - Init
    init(emptyVideoAlertDelegate: EmptyVideoDelegateProtocol?, mapper: MapperProtocol) {
        self.emptyVideoDelegate = emptyVideoAlertDelegate
        self.mapper = mapper
    }

    // MARK: - Public methods
    func makeVideosArrForUI() {
        do {
            ///достаем из FileManager [VideoItemData] как data  и  декодруем в [UIMediaItem]
            let data = try Data(contentsOf: JsonModelsURL.inFM)
            videos = try mapper.decode(from: data, toArrStruct: [UIMediaItem].self)
            print(videos)
        } catch {
            print(NetworkManagerErrors.mapperErrors(error: .failAtMapping(reason: "1st launch or Ошибка конвертации из ФC в data или декодирования в [UIMediaItem]")))
        }
    }

    //    func deleteVideoAt(_ indexPath: IndexPath) {
    //        //обратиться к хранилищу и удалить оттуда
    //
    //        coordinator?.popToRootVC()
    //    }

    //запускать, когда 2 контроллер уходит с экрана
    func informIfNoVideo() {

//        if videos.isEmpty {
//            emptyVideoDelegate?.organizeAlertOfNoVideo()
//        }
    }
}
