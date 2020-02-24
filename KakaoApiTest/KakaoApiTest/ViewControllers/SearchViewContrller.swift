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
    @IBOutlet weak var tableViewHeaderView: UIView!
    
    @IBOutlet weak var btnSort: UIButton!

    var viewModel: SearchViewModel?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = tableViewHeaderView
        self.bindViewModel()
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "contentDetail", let dest = segue.destination as? ContentDetailViewController {
            guard let indexPath = tableView.indexPathForSelectedRow, let document = viewModel?.resultArray.value[indexPath.row] else { return }
            let viewModel = ContentDetailViewModel(document: document)
            dest.viewModel = viewModel
            dest.isRead.asObservable()
                .subscribe(onNext: { [weak self] isRead in
                    guard let `self` = self else { return }
                    if (isRead) {
                        self.viewModel?.setItemRead(index: indexPath.row)
                    }
                }).disposed(by: disposeBag)
        }
    }

    func bindViewModel() {
        viewModel = SearchViewModel()
        
        guard let viewModel = viewModel else { return }
        
        tfSearch.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe() { _ in
                if (viewModel.historyArray.value.count > 0) {
                    self.historyTableView.isHidden = false
                }
            }.disposed(by: disposeBag)
        
        tfSearch.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe() { _ in
                viewModel.updateQuery(searchText: self.tfSearch.text ?? "")
            }.disposed(by: disposeBag)
            
        btnSearch.rx.tap
            .subscribe() { _ in
                viewModel.updateQuery(searchText: self.tfSearch.text ?? "")
            }.disposed(by: disposeBag)
        
        btnSort.rx.tap
            .subscribe() { event in
                let actions: [UIAlertController.AlertAction] = [
                    .action(title: "제목순"),
                    .action(title: "최신순"),
                    .action(title: "취소", style: .destructive)
                ]
                UIAlertController
                    .present(in: self, title: "정렬", message: nil, style: .actionSheet, actions: actions)
                    .subscribe(onNext: { buttonIndex in
                        
                        switch buttonIndex {
                        case 1:
                            viewModel.sortArray(sortType: .dateTime)
                            break
                        case 0:
                            viewModel.sortArray(sortType: .title)
                            break
                        default:
                            break
                        }
                    }).disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
        
        // search tableview setting
        viewModel.resultArray
            .bind(to: tableView.rx.items(cellIdentifier: "CustomCell")) { (index, document, cell) in
                if let cell = cell as? ContentCell {
                                cell.lbType.text = document.type
                                cell.lbName.text = document.name
                                cell.lbContent.text = document.contents.withoutHtml
                                cell.lbDate.text = document.date?.dateAgo()
//                                cell.lbDate.text = document.date?.string()
                                cell.ivThumbnail.load(strUrl: document.thumbnail)
                                cell.vwDimd.isHidden = !(document.isRead ?? false)
                            }
            }.disposed(by: disposeBag)

        // history tableview setting
        viewModel.historyArray
            .bind(to: historyTableView.rx.items(cellIdentifier: "HistoryCell")) { (index, searchText, cell) in
                cell.textLabel?.text = searchText
            }.disposed(by: disposeBag)
        
        historyTableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let searchText = viewModel.historyArray.value[indexPath.row]
                viewModel.updateQuery(searchText: searchText)
                self.tfSearch.text = searchText
            }).disposed(by: disposeBag)
        
        viewModel.isLoading.asObservable()
            .subscribe(){ [weak self] _ in
                guard let `self` = self else { return }
                self.historyTableView.isHidden = true
                self.tfSearch.resignFirstResponder()
            }.disposed(by:self.disposeBag)
        
        viewModel.currentPage.asObservable()
            .subscribe(onNext: { [weak self] page in
                guard let `self` = self else { return }
                if (page == 1) {
                    let indexPath = NSIndexPath(row: NSNotFound, section: 0)
                    self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
                }
            }).disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
            .filter { [weak self] offset in
                guard let `self` = self else { return false }
                self.historyTableView.isHidden = true
                guard self.tableView.frame.height > 0 else { return false }
                return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 300
            }
            .subscribe() { _ in
                viewModel.loadNextPage()
            }.disposed(by: disposeBag)
    }
}
