//
//  UIImageView.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/23.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import UIKit

extension UIImageView {
    func load(strUrl: String) {
        DispatchQueue.global().async { [weak self] in
            if let url = URL(string: strUrl){
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.image = UIImage(named: "noimage")!
                }
            }
        }
    }
}
