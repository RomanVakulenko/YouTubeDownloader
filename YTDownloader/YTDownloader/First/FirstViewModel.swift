//
//  FirstViewModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit

protocol NetworkAPIProtocol: AnyObject {
    func downloadVideo() async throws -> VideoForUI
}


protocol FirstVCViewModelProtocol: AnyObject {
    var closureChangingState: ((FirstViewModel.State) -> Void)? { get set }
}


final class FirstViewModel {

    // MARK: - Enum
    enum State { //дописать
        case none
        case processing
        case loading
        case loadedAndSaved //??надо ли делать еще 1 для запроа доступа к ФОТО на 1ый раз - или это в самом методе проверим
        case badURL(alertText: String)
        case deleted
        case pasted
    }

    // MARK: - Public properties
    var closureChangingState: ((State) -> Void)?

    // MARK: - Private properties
    private weak var coordinator: FirstScreenCoordinator?

    private var state: State = .none {
        didSet {
            closureChangingState?(state)
        }
    }

    // MARK: - Init
    init(coordinator: FirstScreenCoordinator?) {
        self.coordinator = coordinator
    }

}

// MARK: - FirstVCViewModelProtocol
extension FirstViewModel: NetworkAPIProtocol {
    @MainActor
    func downloadVideo() async throws -> videoForUI { //??возможно надо разъединить загрузку и сохранение
        state = .loading //после того как нажали на downloadButton

        Task {
            do {



            } catch {
//                switch error {
//
//                }

            }
        }
    }


}
