//
//  FirstScreenCoordinator.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit

protocol FirstScreenCoordinatorProtocol: AnyObject {
    func pushSecondVC()
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

    private func createSecondVC() -> UIViewController {
        let viewModel = SecondViewModel(coordinator: self, delDelegate: DeleteDelegate)
        let vc = Seco
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
    func pushSecondVC() {
        let secondVC = createSecondVC()
        
    }

    func popToRootVC() {
        navigationController.popToRootViewController(animated: true)
    }
}
