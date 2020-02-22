//
//  SearchViewContrller.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewContrller: UIViewController {
    @IBOutlet weak var lbReceiptAmount: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var viewModel: SearchViewModel?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindUi()
    }

    func bindUi() {
        viewModel = SearchViewModel()
        guard let viewModel = viewModel else { return }
        viewModel.resultArray.asObservable()
            .subscribe(onNext: { [weak self] array in
                self?.lbReceiptAmount.text = ""
                print("\(array)")
            })
            .disposed(by:self.disposeBag)
    }
}
