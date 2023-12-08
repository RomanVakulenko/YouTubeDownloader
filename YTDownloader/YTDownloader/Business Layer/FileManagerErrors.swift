//
//  FileManagerErrors.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 06.12.2023.
//

import Foundation

enum FileManagerErrors: Error, CustomStringConvertible {
    case fileAlreadyExist
    case cannotGetFilesURL
    case serverErrorWith(_ statusCode: Int)

    var description: String {
        switch self {

        case .fileAlreadyExist:
            return "file already exist"
        case .cannotGetFilesURL:
            return "cannot Get File's URL"
        case .serverErrorWith(let statusCode):
            print(statusCode)
            return "Bad status code - \(statusCode)"
        }
    }
}
