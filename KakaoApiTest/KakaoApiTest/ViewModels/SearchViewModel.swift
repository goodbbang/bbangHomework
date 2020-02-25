//
//  SearchViewModel.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import RxSwift
import RxCocoa

enum SearchType: String, CaseIterable {
    case all
    case blog
    case cafe
}

enum SortType {
    case title
    case date
}

class SearchViewModel {
    let service: Service
    private let disposeBag = DisposeBag()
    
    private var searchText: String
    
    private var blogPage = 0
    private var isBlogEnd: Bool = false
    private var cafePage = 0
    private var isCafeEnd: Bool = false
    
    var resultArray = BehaviorRelay<[Document]>(value: [])
    var historyArray = BehaviorRelay<[String]>(value: [])
    
    var searchType = BehaviorRelay<SearchType>(value: .all)
    var sortType = BehaviorRelay<SortType>(value: .title)
    var onShowLoadingHud: Observable<Bool> {
        return loadInProgress
            .asObservable()
            .distinctUntilChanged()
    }
    let onShowError = PublishSubject<String>()
    let moveTop = PublishSubject<Bool>()
    private let loadInProgress = BehaviorRelay<Bool>(value: false)
    
    init(service: Service = Service()) {
        self.service = service
        self.searchText = ""
    }
    
    // MARK: - API Call
    func updateQuery(searchText: String, isNextPage: Bool = false) {
        
        guard self.validateSearchText(searchText: searchText) else { return }
        
        if (isNextPage == false) {
            blogPage = 0
            isBlogEnd = false
            cafePage = 0
            isCafeEnd = false
        }
        loadInProgress.accept(true)
        
        Observable
            .zip(self.getSearch())
            .subscribe(
                onNext: { [weak self] data in
                    guard let self = self else { return }
                    self.loadInProgress.accept(false)
                    var result: [Document] = []
                    data.forEach { (item) in
                        result.append(contentsOf: item.documents)
                    }
                    self.sortArray(data: result, isNextPage: isNextPage)
                },
                onError: { error in
                    self.loadInProgress.accept(false)
                    self.onShowError.onNext("검색결과가 없거나 일시적인 장애가 발생했습니다.")
            },
                onCompleted: {
                    self.loadInProgress.accept(false)
            }
        ).disposed(by: disposeBag)
    }
    
    func getBlogSearch() -> Observable<SearchResultData>? {
        if (isBlogEnd) {
            return nil
        } else {
            blogPage += 1
            return service.getSearch(type: .blog, searchText: searchText, page: blogPage)
        }
    }
    
    func getCafeSearch() -> Observable<SearchResultData>? {
        if (isCafeEnd) {
            return nil
        } else {
            cafePage += 1
            return service.getSearch(type: .cafe, searchText: searchText, page: cafePage)
        }
    }
    
    func getSearch() -> [Observable<SearchResultData>] {
        var array: [Observable<SearchResultData>] = []
        switch searchType.value {
        case .all:
            if let blog = getBlogSearch() {
                array.append(blog)
            }
            if let cafe = getCafeSearch() {
                array.append(cafe)
            }
            break
        case .blog:
            if let blog = getBlogSearch() {
                array.append(blog)
            }
            break
        case .cafe:
            if let cafe = getCafeSearch() {
                array.append(cafe)
            }
            break
        }
        return array
    }
    
    // MARK: - Search Text
    
    func validateSearchText(searchText: String?) -> Bool {
        
        guard let text = searchText, text.count > 1, text.count < 10 else {
            self.onShowError.onNext("검색어를 2~10자 입력해주세요.")
            return false
        }
        self.saveSearchText(searchText: text)
        return true
    }
    
    func saveSearchText(searchText: String) {
        var history = historyArray.value
        if let index = history.firstIndex(of: searchText) {
            history.remove(at: index)
        }
        history.insert(searchText, at: 0)
        historyArray.accept(history)
        self.searchText = searchText
    }
    
    // MARK: - Data set
    func sortArray(data: [Document], isNextPage: Bool = false) {
        guard data.count != 0 else { return }
        var sorted: [Document]
        
        switch self.sortType.value {
        case .date:
            sorted = data.sorted {
                $0.datetime > $1.datetime
            }
        default:
            sorted = data.sorted {
                $0.title < $1.title
            }
        }
        if (isNextPage) {
            self.resultArray.accept(self.resultArray.value + sorted)
        } else {
            self.resultArray.accept(sorted)
            moveTop.onNext(true)
        }
    }
    
    func setSort(sortType: SortType) {
        self.sortType.accept(sortType)
        self.sortArray(data: self.resultArray.value)
    }
    
    func setSearchType(searchType: SearchType, searchText: String) {
        
        if (self.searchType.value == searchType) {
            return
        }
        self.searchType.accept(searchType)
        self.updateQuery(searchText: searchText)
    }
    
    func loadNextPage() {
        if (self.loadInProgress.value == false) {
            self.updateQuery(searchText: self.searchText, isNextPage: true)
        }
    }
    
    func setItemRead(index: Int) {
        var allItem = self.resultArray.value
        var readItem = allItem[index]
        readItem.isRead = true
        allItem[index] = readItem
        self.resultArray.accept(allItem)
    }
}
