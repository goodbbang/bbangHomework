//
//  UIButtonExtension.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/25.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import UIKit
extension UIButton {
    func setTitle(title: String) {
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .highlighted)
    }
}
