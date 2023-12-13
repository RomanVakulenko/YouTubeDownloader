//
//  MediaModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 04.12.2023.
//

import Foundation

protocol MediaItemProtocol: Any {
    var uiId: UUID? { get set }
    var name: String { get set }
    var fileURL: URL { get set }
    var assetID: String? { get set }
    var dateOfDownload: Date { get set }
}


// MARK: - Into this struct we save Video info
struct VideoItemData: Codable, MediaItemProtocol {
    var uiId: UUID?
    var name: String
    var fileURL: URL
    var assetID: String?
    var dateOfDownload: Date
}


// MARK: - From this struct we take Video info for UICollectionView cell
struct UIMediaItem: Equatable, MediaItemProtocol {
    var uiId: UUID?
    var name: String
    var fileURL: URL
    var assetID: String?
    var dateOfDownload: Date

    init(model: MediaItemProtocol) {
        self.name = model.name
        self.fileURL = model.fileURL
        self.assetID = model.assetID
        self.dateOfDownload = model.dateOfDownload
    }
}
