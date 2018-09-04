//
//  UILabel+RUAdditions.swift
//  Rutgers
//
//  Created by Matt Robinson on 6/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

extension UILabel {
    func setHTMLFromString(text: String) {
        if
            let fontName = self.font?.fontName,
            let pointSize = self.font?.pointSize
        {
            let modifiedFont = String(
                format: "<span style=\""
                    + "font-family: \(fontName); "
                    + "font-size: \(pointSize)\">%@</span>",
                text
            )

            do {
                let modifiedFontData = modifiedFont.data(using: .utf8)
                let attrStr = try NSAttributedString(
                    data: modifiedFontData!,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html
                    ],
                    documentAttributes: nil
                )

                self.attributedText = attrStr
            } catch {
                print(error)
            }
        }
    }
}
