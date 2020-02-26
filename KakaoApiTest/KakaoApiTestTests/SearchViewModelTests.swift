//
//  SearchViewModelTests.swift
//  KakaoApiTestTests
//
//  Created by Roy Bang on 2020/02/25.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import XCTest
import RxSwift

class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func test_SearchType_All_잘가져오나요() {
        viewModel.searchType.accept(.all)
        let result = viewModel.getSearch()
        XCTAssertTrue(result.count == 2)
    }
    
    func test_SearchType_Blog_잘가져오나요() {

        viewModel.searchType.accept(.blog)
        let result = viewModel.getSearch()
        XCTAssertTrue(result.count == 1)
    }
    
    func test_SearchType_Cafe_잘가져오나요() {

        viewModel.searchType.accept(.cafe)
        let result = viewModel.getSearch()
        XCTAssertTrue(result.count == 1)
    }
    
    func test_길이가_1_인_검색어_걸러지나요() {
        XCTAssertFalse(viewModel.validateSearchText(searchText: "인"))
    }
    
    func test_길이가_11_인_검색어_걸러지나요() {
        XCTAssertFalse(viewModel.validateSearchText(searchText: "12345678901"))
    }
    
    func test_길이가_2_이상_10이하_인_검색어_통과하나요() {
        XCTAssertTrue(viewModel.validateSearchText(searchText: "78901"))
    }
    
    func test_검색어_저장_잘되나요() {
        viewModel.saveSearchText(searchText: "저장해주세요")
        XCTAssertTrue(viewModel.historyArray.value.count == 1)
    }
    
    func test_검색어_같은_검색어_저장_안되나요() {
        viewModel.saveSearchText(searchText: "저장해주세요")
        viewModel.saveSearchText(searchText: "저장해주세요")
        XCTAssertTrue(viewModel.historyArray.value.count == 1)
    }
    
    func test_검색어_다른_검색어_저장_되나요() {
        viewModel.saveSearchText(searchText: "저장해주세요1")
        viewModel.saveSearchText(searchText: "저장해주세요2")
        XCTAssertTrue(viewModel.historyArray.value.count == 2)
    }
    
    func test_검색어_마지막_검색어가_0번째에_저장_되나요() {
        viewModel.saveSearchText(searchText: "저장해주세요1")
        viewModel.saveSearchText(searchText: "저장해주세요2")
        viewModel.saveSearchText(searchText: "저장해주세요3")
        viewModel.saveSearchText(searchText: "저장해주세요1")
        XCTAssertTrue(viewModel.historyArray.value[0] == "저장해주세요1")
    }
}
