//
//  Common.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import Foundation

enum SearchType {
    case all
    case blog
    case cafe
    
    var searchType: String {
        switch self {
        case .blog:
            return "blog"
        case .cafe:
            return "cafe"
        default:
            return ""
        }
    }
    
    var typeTitle: String {
        switch self {
        case .all:
            return "All"
        case .blog:
            return "블로그"
        case .cafe:
            return "카페"
        }
    }
}
