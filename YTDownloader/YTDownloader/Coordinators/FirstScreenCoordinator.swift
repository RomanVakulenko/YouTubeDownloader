//
//  FirstScreenCoordinator.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit

protocol FirstScreenCoordinatorProtocol: AnyObject {
    func pushSecondVC(deleteDetegate: DeleteDelegate)
    func popToRootVC()
}


final class FirstScreenCoordinator {

    // MARK: - Private properties
    private var navigationController: UINavigationController

    // MARK: - Init
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Private methods
    private func createFirstVC() -> UIViewController {


        let viewModel = FirstViewModel(coordinator: self)
        let firstVC = FirstVC(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: firstVC)
        navigationController = navController
        return navigationController
    }

    private func createSecondVC(deleteDetegate: DeleteDelegate) -> UIViewController {
        let viewModel = SecondViewModel(coordinator: self, delDelegate: deleteDetegate)
        let vc = SecondVC(viewModel: viewModel)
        return vc
    }

}

// MARK: - CoordinatorProtocol
extension FirstScreenCoordinator: CoordinatorProtocol {
    func start() -> UIViewController {
        let vc = createFirstVC()
        return vc
    }
}

extension FirstScreenCoordinator: FirstScreenCoordinatorProtocol {
    func pushSecondVC(deleteDetegate: DeleteDelegate) {
        let secondVC = createSecondVC(deleteDetegate: deleteDetegate)
        navigationController.pushViewController(secondVC, animated: true)
        
    }

    func popToRootVC() {
        navigationController.popToRootViewController(animated: true)
    }
}
