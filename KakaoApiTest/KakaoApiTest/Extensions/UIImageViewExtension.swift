//
//  UIImageViewExtension.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/23.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    func setImage(with urlString: String?) {
        guard let urlString = urlString, urlString.count > 0 else {
            self.image = UIImage(named: "noimage")
            return
        }
        let cache = ImageCache.default
        cache.retrieveImage(forKey: urlString, options: nil) { (image, _) in
            if let image = image {
                self.image = image
            } else {
                let url = URL(string: urlString)
                let resource = ImageResource(downloadURL: url!, cacheKey: urlString)
                self.kf.setImage(with: resource)
            }
        }
    }
}
