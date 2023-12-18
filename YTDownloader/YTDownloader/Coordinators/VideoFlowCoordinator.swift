//
//  VideoFlowCoordinator.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit

protocol FlowCoordinatorProtocol: AnyObject {
    func pushSecondVC(emptyVideoDelegate: EmptyVideoDelegateProtocol)
    func popToRootVC()
}


final class VideoFlowCoordinator {

    // MARK: - Private properties
    private var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Private methods
    private func createFirstVC() -> UIViewController {
        let mapper = DataMapper()
        let fileManager = LocalFilesManager(mapper: mapper)
        let networkService = YTNetworkService(manager: fileManager, mapper: mapper)
        let viewModel = FirstViewModel(coordinator: self,
                                       networkService: networkService,
                                       fManager: fileManager
        )
        let firstVC = FirstVC(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: firstVC)
        navigationController = navController
        return navigationController
    }

    private func createSecondVC(emptyVideoDelegate: EmptyVideoDelegateProtocol) -> UIViewController {

        let mapper = DataMapper()
        let fileManager = LocalFilesManager(mapper: mapper)
        let networkService = YTNetworkService(manager: fileManager, mapper: mapper)
        let viewModel = SecondViewModel(emptyVideoAlertDelegate: emptyVideoDelegate,
                                        mapper: mapper,
                                        ytNetworkService: networkService
        )
        let vc = SecondVC(viewModel: viewModel)
        return vc
    }

}

// MARK: - CoordinatorProtocol
extension VideoFlowCoordinator: CoordinatorProtocol {
    func start() -> UIViewController {
        let vc = createFirstVC()
        return vc
    }
}


// MARK: - FlowCoordinatorProtocol
extension VideoFlowCoordinator: FlowCoordinatorProtocol {

    func pushSecondVC(emptyVideoDelegate: EmptyVideoDelegateProtocol) {
        let secondVC = createSecondVC(emptyVideoDelegate: emptyVideoDelegate)
        navigationController.pushViewController(secondVC, animated: true)
    }

    func popToRootVC() {
        navigationController.popToRootViewController(animated: true)
    }
}
