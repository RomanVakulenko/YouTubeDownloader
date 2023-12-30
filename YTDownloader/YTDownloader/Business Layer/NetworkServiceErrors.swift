//
//  NetworkManagerErrors.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation
import UIKit

enum NetworkServiceErrors: Error, CustomStringConvertible {
    case show
    case networkRouterErrors(error: RouterErrors)
    case mapperErrors(error: MapperError)
    case fileManagerErrors(error: FileManagerErrors)

    var description: String {
        switch self {
        case .show:
            return "some error"
        case .networkRouterErrors(error: let error):
            return error.description
        case .mapperErrors(error: let error):
            return error.description
        case .fileManagerErrors(error: let error):
            return error.description
        }
    }

    var descriptionForUser: String {
        "Ошибка соединения с сервером"
    }
}
