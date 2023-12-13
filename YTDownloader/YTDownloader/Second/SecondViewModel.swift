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
    var videos: [MediaItemProtocol] = []
    let fManager: LocalFilesManagerProtocol

    // MARK: - Private properties
    private var coordinator: VideoFlowCoordinator?
    private weak var emptyVideoDelegate: EmptyVideoDelegateProtocol?


    // MARK: - Init
    init(fManager: LocalFilesManagerProtocol, coordinator: VideoFlowCoordinator?, emptyVideoAlertDelegate: EmptyVideoDelegateProtocol?) {
        self.fManager = fManager
        self.coordinator = coordinator
        self.emptyVideoDelegate = emptyVideoAlertDelegate
    }

    // MARK: - Public methods
    func createVideosCollection() {

    }

    func deleteVideoAt(_ indexPath: IndexPath) {
        //обратиться к хранилищу и удалить оттуда

        coordinator?.popToRootVC()
    }

    //запускать, когда 2 контроллер уходит с экрана
    func informIfNoVideo() {
        if videos.isEmpty {
            emptyVideoDelegate?.organizeAlertOfNoVideo()
        }
    }
}
