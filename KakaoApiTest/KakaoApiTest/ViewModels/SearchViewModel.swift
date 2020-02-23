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
    private var searchText: String
    var resultArray = BehaviorRelay<[Document]>(value: [])
    var historyArray = BehaviorRelay<[String]>(value: [])
    
    init() {
        searchText = ""
    }
    
    func performFetchSearch(searchText: String) {
        
        guard self.validateSearchText(searchText: searchText) else { return }
        
        self.saveSearchText()
        
        Service().getSearchForKakao(type: .blog, searchText: searchText, page: 1)
        .subscribe(
            onNext: { [weak self] data in
                guard var searchData = self?.resultArray.value else { return }
                searchData.removeAll()
                self?.resultArray.accept(searchData + data.documents)
            },
            onError: { error in
            }
        )
        .disposed(by: disposeBag)
    }
    
    func validateSearchText(searchText: String?) -> Bool {
        
        guard let text = searchText, text.count > 1, text.count < 11 else {
//            return "검색어를 2자 이상 10자 이하 입력해주세요."
            return false
        }
        return true
    
//        guard let text = searchText, text.count > 1, historyArray.value.firstIndex(of: text) == nil else { return false }
        
//        self.searchText = text
//        return true
    }
    
    func saveSearchText() {
        historyArray.accept(historyArray.value + [searchText])
    }
}


