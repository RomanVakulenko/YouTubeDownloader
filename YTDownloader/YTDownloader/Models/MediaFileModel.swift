////
////  MediaFileModel.swift
////  YTDownloader
////
////  Created by Roman Vakulenko on 04.12.2023.
////
//
//import Foundation
//
//
//enum FileType {
//    case mp4
//    case jpg
//}
//
//protocol MediaItemUIProtocol: Any {
//    var fileURL: URL { get set }
//    var
//}
////
//struct MediaItem: Codable, MediaItemUIProtocol {
//    let id = UUID()
//    var fileURL: URL
//    var dateLoaded: Date
////    var type: FileType
//    var assetID: String?
//    var isExistInCollection: Bool
//}
//
//struct UIMediaItem: Equatable, MediaItemUIProtocol {
//    let id = UUID()
//    var fileURL: URL
//    var dateLoaded: Date
//    var type: FileType
//    var assetID: String?
//    var isExistInCollection: Bool
//
//    init(fileURL: URL, dateLoaded: Date, type: FileType, assetID: String?, isExistInCollection: Bool) {
//        self.fileURL = fileURL
//        self.dateLoaded = dateLoaded
//        self.type = type
//        self.assetID = assetID
//        self.isExistInCollection = isExistInCollection
//    }
//}
//
//// MARK: - Extensions
//extension UIMediaItem: Codable {
//
//    func encodeToData() -> Data? {
//        let encoder = JSONEncoder()
//        let data = try? encoder.encode(self)
//        return data
//    }
//
//    init(from data: Data) throws {
//        let decoder = JSONDecoder()
//        let decodedData = try decoder.decode(UIMediaItem.self, from: data)
//        self = decodedData
//    }
//}
//
//
//protocol MediaFileUIProtocol: Any {
//    var id: String { get }
//    var title: String { get set }
//    var duration: TimeInterval { get set }
//    var author: String { get set }
//    var imageURL: URL? { get set }
//    var uiId: UUID? { get set }
//    var playerSpecID: UUID? { get set }
//}
//
//struct MediaFile: Codable, MediaFileUIProtocol {
//    var playerSpecID: UUID?
//
//    var url: String
//    var title: String
//    var id: String
//    var uiId: UUID?
//    var duration: TimeInterval
//    var author: String
//    var videoURL: URL
//    var supportsVideo: Bool = false
//    var videoDescription: String?
//    var imageURL: URL?
//}
//
//struct MediaFileUIModel: Equatable, MediaFileUIProtocol {
//    var playerSpecID: UUID?
//    var id: String
//    var title: String
//    var duration: TimeInterval
//    var author: String
//    var imageURL: URL?
//    var uiId: UUID?
//
//    var identity: String {
//        get {
//            return uiId?.uuidString ?? id
//        }
//    }
//
//    init(model: MediaFileUIProtocol) {
//        self.id = model.id
//        self.title = model.title
//        self.imageURL = model.imageURL
//        self.duration = model.duration
//        self.author = model.author
//        self.uiId = model.uiId
//        self.playerSpecID = model.playerSpecID
//    }
//}
