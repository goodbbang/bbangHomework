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
import PKHUD

class SearchViewContrller: UIViewController {
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    
    @IBOutlet weak var tableViewHeaderView: UIView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnSort: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var vwDim: UIControl!
    @IBOutlet weak var consDim: NSLayoutConstraint!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var searchTypeTableView: UITableView!
    
    var viewModel: SearchViewModel?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        tableView.tableHeaderView = tableViewHeaderView
        self.bindViewModel()
    }
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any?) {
        if segue.identifier == "contentDetail", let dest = segue.destination as? ContentDetailViewController {
            guard let indexPath = tableView.indexPathForSelectedRow, let document = viewModel?.resultArray.value[indexPath.row] else { return }
            tableView.deselectRow(at: indexPath, animated: false)
            
            let viewModel = ContentDetailViewModel(document: document)
            dest.viewModel = viewModel
            dest.isRead
                .subscribe(onNext: { [weak self] isRead in
                    guard let self = self else { return }
                    if (isRead) {
                        self.viewModel?.setItemRead(index: indexPath.row)
                    }
                }).disposed(by: dest.disposeBag)
        }
    }
    
    func bindViewModel() {
        viewModel = SearchViewModel()
        
        guard let viewModel = viewModel else { return }
        
        tfSearch.rx.controlEvent([.editingDidBegin])
            .subscribe(onNext: { [weak self] () in
                self?.searchTypeTableView.isHidden = true
                if (viewModel.historyArray.value.count > 0) {
                    self?.historyTableView.isHidden = false
                    self?.vwDim.isHidden = false
                }
            }).disposed(by: disposeBag)
        
        tfSearch.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [weak self] () in
                viewModel.updateQuery(searchText: self?.tfSearch.text ?? "")
            }).disposed(by: disposeBag)
        
        btnSearch.rx.tap
            .subscribe(onNext: { [weak self] () in
                viewModel.updateQuery(searchText: self?.tfSearch.text ?? "")
            }).disposed(by: disposeBag)
        
        btnFilter.rx.tap
            .subscribe(onNext: { [weak self] () in
                self?.consDim.constant = 40
                self?.searchTypeTableView.isHidden = false
                self?.vwDim.isHidden = false
            }).disposed(by: disposeBag)
        
        btnSort.rx.tap
            .subscribe() { _ in
                if (self.searchTypeTableView.isHidden == false) {
                    return
                }
                let actions: [UIAlertController.AlertAction] = [
                    .action(title: "TITLE"),
                    .action(title: "DATE"),
                    .action(title: "CANCEL", style: .destructive)
                ]
                UIAlertController
                    .present(in: self, title: nil, message: nil, style: .actionSheet, actions: actions)
                    .subscribe(onNext: { buttonIndex in
                        
                        switch buttonIndex {
                        case 1:
                            viewModel.setSort(sortType: SortType.date)
                            break
                        case 0:
                            viewModel.setSort(sortType: SortType.title)
                            break
                        default:
                            break
                        }
                        self.btnSort.setTitle(title: String(describing: viewModel.sortType.value).uppercased())
                    }).disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        vwDim.rx.controlEvent(.touchUpInside)
            .subscribe() { _ in
                self.clearOptionView()
        }.disposed(by: disposeBag)
        
        // search tableview setting
        viewModel.resultArray
            .bind(to: tableView.rx.items(cellIdentifier: "ContentCell")) { (index, document, cell) in
                if let cell = cell as? ContentCell {
                    cell.lbType.text = document.type
                    cell.lbName.text = document.name
                    cell.lbTitle.text = document.title.withoutHtml
                    cell.lbDate.text = document.date?.dateAgo()
                    cell.ivThumbnail.setImage(with: document.thumbnail)
                    cell.vwDimd.isHidden = !(document.isRead ?? false)
                }
        }.disposed(by: disposeBag)
        
        tableView.rx
            .willDisplayCell
            .subscribe(onNext: { cell, indexPath in
                let lastElement = viewModel.resultArray.value.count - 1
                if indexPath.row == lastElement {
                    viewModel.loadNextPage()
                }
            }).disposed(by: disposeBag)
        
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
        
        // searchType tableview setting
        let searchItems = [SearchType.all, SearchType.blog, SearchType.cafe]
        let searchTypeOb: Observable<[SearchType]> = Observable.of(searchItems)
        searchTypeOb.bind(to: searchTypeTableView.rx.items(cellIdentifier: "searchType")) { (index: Int, element: SearchType, cell: UITableViewCell) in
            cell.textLabel?.text = String(describing: element).uppercased()
            var textColor: UIColor
            if (viewModel.searchType.value == element) {
                textColor = UIColor.red
            } else {
                textColor = UIColor.black
            }
            cell.textLabel?.textColor = textColor
        }.disposed(by: disposeBag)
        
        searchTypeTableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.searchTypeTableView.deselectRow(at: indexPath, animated: false)
                self.clearOptionView()
                guard let text = self.tfSearch.text, text.count > 1 else {
                    viewModel.onShowError.onNext("검색어를 2~10자 입력해주세요.")
                    return
                }
                let searchType = searchItems[indexPath.row]
                self.btnFilter.setTitle(title: String(describing: searchType).uppercased())
                self.searchTypeTableView.reloadData()
                viewModel.setSearchType(searchType: searchType, searchText: text)
            }).disposed(by: disposeBag)
        
        viewModel
            .onShowLoadingHud
            .map { [weak self] in
                self?.clearOptionView()
                self?.setLoadingHud(visible: $0)
        }
        .subscribe()
        .disposed(by: disposeBag)
        
        viewModel
            .onShowError
            .map { alertMsg in
                self.alert(alertMsg: alertMsg)
        }
        .subscribe()
        .disposed(by: disposeBag)
        
        viewModel
            .moveTop
            .map { _ in
                let indexPath = NSIndexPath(row: NSNotFound, section: 0)
                self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
                self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
        .subscribe()
        .disposed(by: disposeBag)
        
        tfSearch.becomeFirstResponder()
    }
    
    private func clearOptionView() {
        self.historyTableView.isHidden = true
        self.searchTypeTableView.isHidden = true
        self.vwDim.isHidden = true
        self.consDim.constant = 0
        self.tfSearch.resignFirstResponder()
    }
    
    private func setLoadingHud(visible: Bool) {
        PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        visible ? PKHUD.sharedHUD.show(onView: view) : PKHUD.sharedHUD.hide()
    }
    
    private func alert(alertMsg: String) {
        let actions: [UIAlertController.AlertAction] = [.action(title: "확인")]
        UIAlertController
            .present(in: self, title: nil, message: alertMsg, style: .alert, actions:   actions)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}

