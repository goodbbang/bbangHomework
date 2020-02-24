//
//  SearchResultData.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import Foundation

fileprivate let format = "yyyy-MM-dd'T'HH:mm:ss.SSSXXX"

struct SearchResultData: Codable {
    let documents: [Document]
    let meta: Meta
}

struct Document: Codable {
    var type: String?
    let cafename: String?
    let blogname: String?
    let contents: String
    let datetime: String
    let thumbnail: String
    let title: String
    let url: String
    
    var isRead: Bool? = false
    
    var name: String {
        get {
            return cafename ?? blogname ?? "-"
        }
    }
    var date: Date? {
        return datetime.date(with: format)
    }
}

struct Meta: Codable {
    let is_end: Bool
}
