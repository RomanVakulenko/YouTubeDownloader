//
//  NetworkManagerErrors.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation
import UIKit

enum NetworkManagerErrors: Error, CustomStringConvertible {
    case show
    case networkRouterErrors(error: RouterErrors)
    case mapperErrors(error: MapperError)

    var description: String {
        switch self {
        case .show:
            return "some error"
        case .networkRouterErrors(error: let error):
            return error.description
        case .mapperErrors(error: let error):
            return error.description
        }
    }

    var descriptionForUser: String {
        switch self {
        case .networkRouterErrors(let error):
            switch error {
            case .noInternetConnection:
                return error.description //должен увидеть реальную ошибку
            default:
                return "Ошибка соединения с сервером"
            }
        default:
            return "Ошибка соединения с сервером"
        }
    }
}
