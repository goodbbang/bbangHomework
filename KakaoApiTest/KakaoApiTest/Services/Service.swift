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

struct URLs {
    static let baseURL = "https://dapi.kakao.com/v2/search/%@"
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
    func getSearchForKakao(type: SearchType, searchText: String, page: Int) -> SearchResponse
}

class Service: SearchResponseProtocol {

    func getSearchForKakao(type: SearchType, searchText: String, page: Int) -> SearchResponse {
        return SearchResponse.create { observer -> Disposable in
            let request = Alamofire.request(String(format: URLs.baseURL, type.searchType),
                                            method: .get,
                                            parameters: [URLs.query: searchText, URLs.page: page, URLs.size: 25],
                                            headers: URLs.headers)
                .validate()
                .responseData { responseData in
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
            return Disposables.create(with: {
                request.cancel()
            })
        }
    }
}
