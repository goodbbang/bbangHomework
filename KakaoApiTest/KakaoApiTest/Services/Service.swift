//
//  Service.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

enum SearchType: String {
    case all
    case blog
    case cafe
    
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

struct URLs {
    static let baseURL = "https://dapi.kakao.com/v2/search/%s"
    static let query = "query"
    static let page = "page"
    static let size = "size"
    static let headers = [
        "Authorization": "KakaoAK 460cbc395a12b28d87d19c413670876d",
        "Accept": "application/json"
    ]
}

typealias SearchResponse = Observable<SearchResultData>

protocol SearchResponseProtocol {
    func getSearchForKakao(searchType: SearchType, searchText: String, page: Int) -> SearchResponse
}

class Service: SearchResponseProtocol {

    func getSearchForKakao(searchType: SearchType, searchText: String, page: Int) -> SearchResponse {
        return SearchResponse.create { observer -> Disposable in
            let request = Alamofire.request(String(format: URLs.baseURL, searchType.typeTitle),
                                            method: .get,
                                            parameters: [URLs.query: searchText, URLs.page: page, URLs.size: 25],
                                            headers: URLs.headers)
                .validate()
                .responseData { responseData in
                    DispatchQueue.main.sync {
                        switch responseData.result {
                        case .success(let value):
                            do {
                                let jsonData = try JSONDecoder().decode(SearchResultData.self, from: value)
                                observer.onNext(jsonData)
                                observer.onCompleted()
                            } catch {
                                observer.onError(error)
                            }
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
            }
            return Disposables.create(with: {
                request.cancel()
            })
        }
    }
}
