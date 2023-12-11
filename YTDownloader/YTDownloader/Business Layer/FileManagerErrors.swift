//
//  FileManagerErrors.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 06.12.2023.
//
import Foundation

enum FileManagerErrors: Error, CustomStringConvertible {
    case fileAlreadyExist
    case unableToDownload
    case unableToMove
    case unableToSaveToPHLibrary
    case unableToDelete
    case cannotGetURLOfFile
    case serverErrorWith(_ statusCode: Int)

    var description: String {
        switch self {

        case .fileAlreadyExist:
            return "file already exist"
        case .unableToDownload:
            return "unable To Download"
        case .unableToMove:
            return "unable To Move to dstURL"
        case .unableToSaveToPHLibrary:
            return "unable To Save"
        case .unableToDelete:
            return "unable To Delete"
        case .cannotGetURLOfFile:
            return "cannot Get File's URL"
        case .serverErrorWith(let statusCode):
            print(statusCode)
            return "Bad status code - \(statusCode)"
        }
    }
}
