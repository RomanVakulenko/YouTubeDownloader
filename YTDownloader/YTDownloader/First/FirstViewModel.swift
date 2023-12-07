//
//  FirstViewModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit
import XCDYouTubeKit
import YouTubeKit

protocol NetworkAPIProtocol: AnyObject {
    func downloadVideo(at videoID: String, and url: URL)
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
        case loadedAndSaved //??надо ли делать еще 1 для запроcа доступа к ФОТО на 1ый раз - или это в самом методе проверим
        case badURL(alertText: String)
        case errorAtXCDDownloading(alertText: String)
        case deleted
        case pasted
    }

    // MARK: - Public properties
    var closureChangingState: ((State) -> Void)?
    var state: State = .none {
        didSet {
            closureChangingState?(state)
        }
    }
    
    var fileName: String?
    var photoURL: URL?

    // MARK: - Private properties
    private weak var coordinator: FirstScreenCoordinator?
    private let networkService: YTNetworkServiceProtocol
    private let fManager: LocalFilesManagerProtocol


    // MARK: - Init
    init(coordinator: FirstScreenCoordinator, networkService:YTNetworkServiceProtocol, fManager: LocalFilesManagerProtocol) {
        self.coordinator = coordinator
        self.networkService = networkService
        self.fManager = fManager
    }

    // MARK: - Public methods
    func showSecondVC() {
        coordinator?.pushSecondVC(deleteDetegate: self)
    }

    // MARK: - Private methods

}


// MARK: - FirstVCViewModelProtocol
extension FirstViewModel: NetworkAPIProtocol {

    @MainActor
    func downloadVideo(at videoID: String, and url: URL) {
        state = .processing //сразу после того как нажали на download

        Task {
            do {
                try networkService.downloadVideo(videoIdentifier: videoID, videoURL: url) { result in

                    switch result {
                    case .success(_):
//                        <#code#> //переделал на MVVM + C, должно скачивать и сохранять видео 
                        self.state = .loadedAndSaved
                    case .failure(_):
//                        <#code#>
                        self.state = .badURL(alertText: "error in viewModel")
                    }
                }
            } catch {
                switch error {

                default:
                    print("smth")//????
                }

            }
        }

        
    }
}


extension FirstViewModel: DeleteDelegate {
    func organizeAlertAfterDeletion() {

    }


}
