//
//  MainCoordinator.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 26.11.2023.
//

import Foundation
import UIKit

final class MainCoordinator {

    // MARK: - Private properties
    /// хранит ссылки на координаторы, иначе, при выходе за область видимости функции start, потеряем ссылки на координаторов (когда main создает дочерние или дочерние создают еще свои дочерние)
    private var childCoordinators = [CoordinatorProtocol]()

    // MARK: - Private methods
    /// т.к. координатор может состоять из кучи объектов, то лучше обернуть в метод
    private func makeFirstScreenCoordinator() -> CoordinatorProtocol {
        let coordinator = FirstScreenCoordinator(navigationController: UINavigationController())
        return coordinator
    }
    /// сравниваем адреса памяти, ссылается ли объект на тот же адрес памяти (т.е. до тех пор пока координаторов нет - добавляй их)
    private func addChildCoordinator(_ coordinator: CoordinatorProtocol) {
        guard !childCoordinators.contains(where: { $0 === coordinator }) else { return }
        childCoordinators.append(coordinator)
    }

}

// MARK: - Extension
extension MainCoordinator: CoordinatorProtocol {
    /// этот VC мы возвращаем в sceneDelegate
    func start() -> UIViewController {
        let firstScreenCoordinator = makeFirstScreenCoordinator()
        addChildCoordinator(firstScreenCoordinator)
        return firstScreenCoordinator.start()
    }
}
