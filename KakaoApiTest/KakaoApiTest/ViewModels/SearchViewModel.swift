//
//  SearchViewModel.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import RxSwift
import RxCocoa

class SearchViewModel {
    private let disposeBag = DisposeBag()
    
    var resultArray = PublishRelay<[Documents]>()
    
    init() {
        performFetchSearchResult()
    }
    
    func performFetchSearchResult() {
        
        Service().getSearchForKakao(searchType: .all, searchText: "캠핑칸", page: 1)
        .subscribe(
            onNext: { [weak self] data in
                self?.resultArray.accept((data as SearchResultData).documents)
            },
            onError: { error in
            }
        )
        .disposed(by: disposeBag)
    }
}
