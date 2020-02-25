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
    var type: String {
        if (cafename == nil) {
            return "blog"
        } else {
            return "cafe"
        }
    }
    var name: String {
        return cafename ?? blogname ?? "-"
    }
    let cafename: String?
    let blogname: String?
    let contents: String
    let datetime: String
    let thumbnail: String
    let title: String
    let url: String
    var date: Date? {
        return datetime.date(with: format)
    }
    var isRead: Bool? = false
}

struct Meta: Codable {
    let is_end: Bool
}
