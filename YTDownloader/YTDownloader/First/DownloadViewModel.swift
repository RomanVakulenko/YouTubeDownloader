//
//  FirstViewModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit
import XCDYouTubeKit

protocol DownloadProtocol: AnyObject {
    func downloadAndSaveVideo(at videoID: String, and url: URL)
}

// MARK: - Enum
enum State { 
    case none
    case processing
    case fileExists
    case loading
    case loadedAndSaved
    case badURL(alertText: String)
    case thereIsNoAnyVideo
}

final class DownloadViewModel {
    
    // MARK: - Public properties
    var closureChangingState: ((State) -> Void)?
    let fManager: LocalFilesManagerProtocol

    var state: State = .none {
        didSet {
            closureChangingState?(state)
        }
    }
    
    var fileName: String?
    var photoURL: URL?
    
    // MARK: - Private properties
    private weak var coordinator: FlowCoordinatorProtocol?
    private let networkService: YTNetworkServiceProtocol
    
    
    // MARK: - Init
    init(coordinator: FlowCoordinatorProtocol, networkService: YTNetworkServiceProtocol, fManager: LocalFilesManagerProtocol) {
        self.coordinator = coordinator
        self.networkService = networkService
        self.fManager = fManager
    }
    
    // MARK: - Public methods
    func showSecondVC() {
        coordinator?.pushSecondVC(emptyVideoDelegate: self)
    }
}


// MARK: - DownloadProtocol
extension DownloadViewModel: DownloadProtocol {
    
    func downloadAndSaveVideo(at videoID: String, and url: URL) {
        state = .processing //сразу после того как нажали на download

        do {
            try self.networkService.downloadAndSaveVideo(videoIdentifier: videoID, videoURL: url)

            fManager.statusClosure = { [weak self] status in
                switch status {
                case .fileExists:
                    self?.state = .fileExists

                case .loading:
                    self?.state = .loading

                case .loadedAndSaved:
                    self?.state = .loadedAndSaved

                case .badURL(alertText: let alertTextForUser):
                    self?.state = .badURL(alertText: alertTextForUser)

                default: print("зашел в дефолтный кейс fManagerА")
                }
            }
        } catch let error as URLError {
            if error.networkUnavailableReason == .cellular {
                self.state = .badURL(alertText: "Сотовая сеть отключена")
            } else if let reason = error.networkUnavailableReason {
                self.state = .badURL(alertText: "Сеть недоступна: \(reason)")
            }
            switch error.code {
            case .badURL:
                self.state = .badURL(alertText: "Некорректный URL")
            case .notConnectedToInternet:
                self.state = .badURL(alertText: "Нет подключения к интернету")
            default:
                print("Неизвестная ошибка типа URLError")
                self.state = .badURL(alertText: "Некорректный URL")
            }
        } catch {
            switch error {
            case NetworkServiceErrors.networkRouterErrors(error: .fetchingXCDVideoError):
                print("XCDYouTubeVideo не смог сделать URL для загрузки с инета")
            default: print(error.localizedDescription)
            }
        }
    }
}

// MARK: - EmptyVideoDelegateProtocol
extension DownloadViewModel: EmptyVideoDelegateProtocol {

    func organizeAlertOfNoVideo() {
        self.state = .thereIsNoAnyVideo
    }

}
