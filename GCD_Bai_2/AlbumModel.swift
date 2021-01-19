//
//  AlbumModel.swift
//  GCD_Bai_2
//
//  Created by Apple on 1/18/21.
//  Copyright © 2021 NgocNB. All rights reserved.
//

import Foundation
import ObjectMapper

class AlbumModel: Decodable {
    var albumId: Int
    var id: Int
    var title: String
    var url: String
    var thumbnailUrl: String
    var imageData: Data?
}

class AlbumModels: Mappable {
    
    var albumId: Int?
        var id: Int?
        var title: String?
        var url: String?
        var thumbnailUrl: String?
        var imageData: Data?
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        url <- map["url"]
        thumbnailUrl <- map["thumbnailUrl"]
        imageData <- map["imageData"]
    }
    
    
}
