//
//  SecondViewModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 27.11.2023.
//

import Foundation
import UIKit
import Photos


protocol DeleteDelegate: AnyObject {
    func organizeAlertAfterDeletion()
}

final class SecondViewModel {

//    private(set) var ytModel: [VideoForUI] = []
    var videos: [PHAsset] = []

    // MARK: - Private properties
    private var coordinator: FirstScreenCoordinator?
    private weak var delDelegate: DeleteDelegate?

    // MARK: - Init
    init(coordinator: FirstScreenCoordinator, delDelegate: DeleteDelegate) {
        self.coordinator = coordinator
        self.delDelegate = delDelegate
    }

    // MARK: - Public methods
    func deleteVideoAt(_ indexPath: IndexPath) { //?? как узнать в какой ячейке нажали на корзину?
        //обратиться к хранилищу и удалить оттуда


        coordinator?.popToRootVC()
    }

}
