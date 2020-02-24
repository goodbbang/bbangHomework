//
//  ContentDetailViewModel.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import RxSwift
import RxCocoa

class ContentDetailViewModel {
    private let disposeBag = DisposeBag()
    var document: Document
    
    init(document: Document) {
        self.document = document
    }
    
    func setRead() {
        document.isRead = true
    }
}

