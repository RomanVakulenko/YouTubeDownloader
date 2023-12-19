//
//  MediaModel.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 04.12.2023.
//

import Foundation

protocol MediaItemProtocol: Any {
    var name: String { get set }
    var mp4URLWithPathInFMForPlayer: URL { get set }
    var jpgURLWithPathInFMForPlayer: URL? { get set }
    var dateOfDownload: Date { get set }
}


// MARK: - Into this struct we save Video info
struct VideoItemData: Codable, MediaItemProtocol {
    var name: String
    var mp4URLWithPathInFMForPlayer: URL
    var jpgURLWithPathInFMForPlayer: URL?
    var dateOfDownload: Date
}


// MARK: - From this struct we take Video info for UICollectionView cell
struct UIMediaItem: Decodable, Equatable, MediaItemProtocol {
    var name: String
    var mp4URLWithPathInFMForPlayer: URL
    var jpgURLWithPathInFMForPlayer: URL?
    var dateOfDownload: Date

    init(model: MediaItemProtocol) {
        self.name = model.name
        self.mp4URLWithPathInFMForPlayer = model.mp4URLWithPathInFMForPlayer
        self.jpgURLWithPathInFMForPlayer = model.jpgURLWithPathInFMForPlayer
        self.dateOfDownload = model.dateOfDownload
    }
}
