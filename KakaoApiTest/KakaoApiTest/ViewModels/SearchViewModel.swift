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
    private var sortType: SortType
    private var isEnd: Bool = true

    var resultArray = BehaviorRelay<[Document]>(value: [])
    var historyArray = BehaviorRelay<[String]>(value: [])
    var searchType = PublishSubject<SearchType>()
    var isLoading = BehaviorRelay<Bool>(value: false)
    var currentPage = BehaviorRelay<Int>(value: 1)
    init() {
        searchText = ""
        sortType = SortType.title
    }
    
    func updateQuery(searchText: String, page: Int = 1) {
        
        guard self.validateSearchText(searchText: searchText) else { return }
        
        self.isLoading.accept(true)
        self.searchText = searchText
        self.saveSearchText()
        
        Service().getSearchForKakao(type: .blog, searchText: searchText, page: page)
        .subscribe(
            onNext: { [weak self] data in
                self?.isEnd = data.meta.is_end
                self?.sortArray(data: data.documents, sortType: self?.sortType ?? .title)
            },
            onError: { error in
                self.isLoading.accept(false)
                print("검색결과가 없거나 일시적인 장애가 발생했습니다.")
            }
        )
        .disposed(by: disposeBag)
    }
    
    func loadNextPage() {
        if (isEnd == false && isLoading.value == false) {
            self.currentPage.accept(self.currentPage.value + 1)
            self.updateQuery(searchText: self.searchText, page: self.currentPage.value)
        }
    }
    
    func validateSearchText(searchText: String?) -> Bool {
            
        guard let text = searchText, text.count > 1, text.count < 10 else {
            print("검색어 길이제한 ")
            return false
        }
        if (self.searchText != text) {
            self.currentPage.accept(1)
        }
        self.searchText = text
        return true
    }
    
    func saveSearchText() {
        if (historyArray.value.firstIndex(of: self.searchText) == nil) {
            historyArray.accept(historyArray.value + [self.searchText])
        }
    }
    
    func sortArray(data: [Document], sortType: SortType) {
        var sorted: [Document]
        
        let targetData = data
        switch sortType {
        case .dateTime:
            sorted = targetData.sorted {
                $0.datetime > $1.datetime
            }
        default:
            sorted = targetData.sorted {
                $0.title < $1.title
            }
        }
        self.sortType = sortType
        
        sorted = sorted.map {
            var copy = $0
            if (copy.blogname == nil) {
                copy.type = "cafe"
            } else {
                copy.type = "bolg"
            }
            return copy
        }
        
        if (self.currentPage.value > 1) {
            self.resultArray.accept(self.resultArray.value + sorted)
        } else {
            self.resultArray.accept(sorted)
        }
        self.isLoading.accept(false)
    }
    
    func sortArray(sortType: SortType) {
        self.sortArray(data: self.resultArray.value, sortType: sortType)
    }
    
    func setItemRead(index: Int) {
        var allItem = self.resultArray.value
        var readItem = allItem[index]
        readItem.isRead = true
        allItem[index] = readItem
        self.resultArray.accept(allItem)
    }
}


