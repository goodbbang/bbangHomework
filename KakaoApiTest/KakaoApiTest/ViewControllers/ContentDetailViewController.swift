//
//  ContentDetailViewController.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/22.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import SafariServices

import UIKit
import RxSwift
import RxCocoa

class ContentDetailViewController: UIViewController {
    
    @IBOutlet weak var ivThumbnail: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbContent: UILabel!
    
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbLink: UILabel!
    @IBOutlet weak var btnLink: UIButton!
    
    let disposeBag = DisposeBag()
    var viewModel: ContentDetailViewModel?
    var isRead = BehaviorRelay<Bool>(value: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        isRead.accept(viewModel?.document.isRead ?? false)
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else { return }
        self.title = viewModel.document.name
        ivThumbnail.setImage(with: viewModel.document.thumbnail)
        lbName.text = viewModel.document.name
        lbTitle.text = viewModel.document.title.withoutHtml
        lbContent.text = viewModel.document.contents.withoutHtml
        lbDate.text = viewModel.document.date?.string()
        lbLink.text = viewModel.document.url
        
        btnLink.rx.tap.subscribe() { event in
            guard let url = URL(string: viewModel.document.url) else { return }
            
            viewModel.setRead()
            
            let viewController = SFSafariViewController(url: url)
            self.present(viewController, animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    @objc func backTouched() {
        self.navigationController?.popViewController(animated: true)
        isRead.accept(viewModel?.document.isRead ?? false)
    }
}
