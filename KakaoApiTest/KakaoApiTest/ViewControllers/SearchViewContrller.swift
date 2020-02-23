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
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!

    var viewModel: SearchViewModel?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func bindViewModel() {
        viewModel = SearchViewModel()
        
        guard let viewModel = viewModel else { return }
        
        tfSearch.rx.controlEvent([.editingDidBegin])
        .asObservable()
        .subscribe(onNext: { _ in
            self.historyTableView.isHidden = false
        }).disposed(by: disposeBag)
        
        tfSearch.rx.controlEvent([.editingDidEndOnExit])
        .asObservable()
        .subscribe(onNext: { _ in
            self.historyTableView.isHidden = false
        }).disposed(by: disposeBag)
            
        btnSearch.rx.tap.subscribe() { event in
            viewModel.performFetchSearch(searchText: self.tfSearch.text ?? "")
        }.disposed(by: disposeBag)
        
        // search tableview setting
        viewModel.resultArray.bind(to: tableView.rx.items(cellIdentifier: "CustomCell")) { (index, document, cell) in
            if let cell = cell as? ContentCell {
                cell.lbType.text = ""
                cell.lbName.text = document.name
                cell.lbContent.text = document.contents
                cell.lbDate.text = document.datetime
            }
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
        .subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            let item = viewModel.resultArray.value[indexPath.row]
            let viewController = ContentDetailViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        })
        .disposed(by: disposeBag)

        // history tableview setting
        viewModel.historyArray.bind(to: historyTableView.rx.items(cellIdentifier: "HistoryCell")) { (index, searchText, cell) in
            cell.textLabel?.text = searchText
        }.disposed(by: disposeBag)
        
        historyTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.performFetchSearch(searchText: viewModel.historyArray.value[indexPath.row])
            })
        .disposed(by: disposeBag)
    }
    
    func performFetchSearch(searchText: String) {
        self.historyTableView.isHidden = true
        self.tfSearch.endEditing(true)
    }
}
