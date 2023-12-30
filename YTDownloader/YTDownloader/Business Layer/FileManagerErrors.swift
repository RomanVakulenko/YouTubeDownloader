//
//  FileManagerErrors.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 06.12.2023.
//
import Foundation

enum FileManagerErrors: Error, CustomStringConvertible {
    case unableToDownload
    case unableToSaveToPHLibrary
    case unableToDelete
    case cannotGetURLOfFile

    var description: String {
        switch self {
        case .unableToDownload:
            return "unable To Download"
        case .unableToSaveToPHLibrary:
            return "unable To Save"
        case .unableToDelete:
            return "unable To Delete"
        case .cannotGetURLOfFile:
            return "cannot Get File's URL"
        }
    }
}
