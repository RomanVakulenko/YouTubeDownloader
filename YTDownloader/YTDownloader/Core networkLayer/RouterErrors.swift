//
//  RouterErrors.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation

enum RouterErrors: Error, CustomStringConvertible {
    case badURL
    case noInternetConnection
    case serverErrorWith(_ statusCode: Int)

    var description: String {
        switch self {

        case .badURL:
            return "Invalid URL"
        case .noInternetConnection:
            return "Нет соединения с интернетом"
        case .serverErrorWith(let statusCode):
            print(statusCode)
            return "Bad status code - \(statusCode)"
        }
    }
}
