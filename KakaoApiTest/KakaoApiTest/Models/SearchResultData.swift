//
//  SearchResultData.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import Foundation

struct SearchResultData: Codable {
    let documents: [Documents]
    let meta: Meta
}

struct Documents: Codable {
    let cafename: String?
    let blogname: String?
    let contents: String
    let datetime: String
    let thumbnail: String
    let title: String
    let url: String
    
    let isRead: Bool?
    
    var name: String {
        get {
            return cafename ?? blogname ?? "이름없음"
        }
    }
}

struct Meta: Codable {
    let is_end: Bool
}
