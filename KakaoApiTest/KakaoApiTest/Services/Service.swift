//
//  Service.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import RxSwift
import Alamofire

class Service {

    enum GetSearchFailurReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
    }
    
    static let headers = [
        "Authorization": "KakaoAK 460cbc395a12b28d87d19c413670876d",
        "Accept": "application/json"
    ]

    func getSearch(type: SearchType, searchText: String, page: Int) -> Observable<SearchResultData> {
        let param = ["query": searchText,
                     "page": String(page),
                     "size": "25"]
        return Observable.create { (observer) -> Disposable in
            Alamofire.request(String(format: "https://dapi.kakao.com/v2/search/\(type)"),
                                        method: .get,
                                        parameters: param,
                                        headers: Service.headers)
            .validate()
            .responseJSON { response in
                    switch response.result {
                    case .success:
                        guard let data = response.data else {
                            observer.onError(response.error ?? GetSearchFailurReason.notFound)
                            return
                        }
                        do {
                            let searchResultData = try JSONDecoder().decode(SearchResultData.self, from: data)
                            observer.onNext(searchResultData)
                        } catch {
                            observer.onError(error)
                        }
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode,
                            let reason = GetSearchFailurReason(rawValue: statusCode)
                        {
                            observer.onError(reason)
                        }
                        observer.onError(error)
                    }
            }
            return Disposables.create()
        }
    }
}
