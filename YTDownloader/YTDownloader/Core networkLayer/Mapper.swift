//
//  Mapper.swift
//  YTDownloader
//
//  Created by Roman Vakulenko on 28.11.2023.
//

import Foundation

protocol MapperProtocol {
    func encode<T: Encodable>(from someStruct: T) throws -> Data
    func decode<T: Decodable>(from data: Data, toStruct: T.Type) throws -> T
    
}

final class DataMapper {

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        return encoder
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

}


// MARK: - Extensions
extension DataMapper: MapperProtocol {
    func encode<T: Encodable>(from someStruct: T) throws -> Data {
        do {
            let modelEncodedToData = try self.encoder.encode(someStruct)
            return modelEncodedToData
        } catch {
            throw error
        }
    }

    func decode<T: Decodable>(from data: Data, toStruct: T.Type) throws -> T {
        do {
            let decodedModel = try self.decoder.decode(toStruct, from: data)
            return decodedModel
        } catch let error as DecodingError {
            // Чтобы узнать место появления ошибки так делают??
            let errorLocation = "in File: \(#file), at Line: \(#line), Column: \(#column)"
            throw MapperError.failAtParsing(reason: "\(error), \(errorLocation)")
        } catch {
            print("Unknown error have been caught in File: \(#file), at Line: \(#line), Column: \(#column)")
            throw error
        }
    }

}
