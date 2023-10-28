//
//  EntityMapperProtocol.swift
//  DailyFootball
//
//  Created by walkerhilla on 2023/10/28.
//

import Foundation

protocol EntityMapperProtocol {
  associatedtype TableType
  associatedtype EntityType
  
  static func mapTable(from entity: EntityType) throws -> TableType
  static func mapEntity(from table: TableType) throws -> EntityType
}

extension EntityMapperProtocol {
  static func mapTable(from entity: EntityType) throws -> TableType {
    throw MappingError.methodNotImplemented
  }
}

enum MappingError: Error {
  case missingData
  case methodNotImplemented
}
