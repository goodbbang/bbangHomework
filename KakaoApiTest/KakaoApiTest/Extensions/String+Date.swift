//
//  String+Date.swift
//  KakaoApiTest
//
//  Created by Roy Bang on 2020/02/23.
//  Copyright © 2020 Roy Bang. All rights reserved.
//

import Foundation

extension String {
    func date(with format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
}

extension String {
    public var withoutHtml: String {
        guard let data = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }

        return attributedString.string
    }
}
