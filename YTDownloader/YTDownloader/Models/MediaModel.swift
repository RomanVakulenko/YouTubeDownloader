//
//  MediaModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 04.12.2023.
//

import Foundation

protocol MediaItemProtocol: Any {
    var name: String { get set }
    var mp4URLInFileManager: URL { get set }
    var thumbnailURL: URL? { get set }
    var assetID: String? { get set }
    var dateOfDownload: Date { get set }
}


// MARK: - Into this struct we save Video info
struct VideoItemData: Codable, MediaItemProtocol {
    var name: String
    var mp4URLInFileManager: URL
    var thumbnailURL: URL?
    var assetID: String?
    var dateOfDownload: Date
}


// MARK: - From this struct we take Video info for UICollectionView cell
struct UIMediaItem: Decodable, Equatable, MediaItemProtocol {
    var name: String
    var mp4URLInFileManager: URL
    var thumbnailURL: URL?
    var assetID: String?
    var dateOfDownload: Date

    init(model: MediaItemProtocol) {
        self.name = model.name
        self.mp4URLInFileManager = model.mp4URLInFileManager
        self.thumbnailURL = model.thumbnailURL
        self.assetID = model.assetID
        self.dateOfDownload = model.dateOfDownload
    }
}
