//
//  Linkable.swift
//  Rutgers
//
//  Created by Matt Robinson on 2/27/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation

protocol Linkable {
    func sharingUrl() -> URL?
    func sharingTitle() -> String?
}

extension UIViewController: Linkable {
    internal func sharingUrl() -> URL? {
        return nil
    }

    func sharingTitle() -> String? {
        return self.title
    }

    func setupShareButton() {
        if let _ = self.sharingUrl() {
            let newButtonItem = UIBarButtonItem(
                barButtonSystemItem: .action,
                target: self,
                action: #selector(actionButtonTapped)
            )

            if let rightBarButtonItem = self.navigationItem.rightBarButtonItem {
                self.navigationItem.rightBarButtonItems =
                    [newButtonItem, rightBarButtonItem]
            } else if let rightBarButtonItems =
                self.navigationItem.rightBarButtonItems
            {
                self.navigationItem.rightBarButtonItems =
                    [newButtonItem] + rightBarButtonItems
            } else {
                self.navigationItem.rightBarButtonItem = newButtonItem
            }
        }
    }

    func actionButtonTapped() {
        if let url = self.sharingUrl() {
            let favoriteActivity = RUFavoriteActivity(
                title: self.sharingTitle() ?? ""
            )

            let activityVC = UIActivityViewController(
                activityItems: [url],
                applicationActivities: [favoriteActivity!]
            )

            activityVC.excludedActivityTypes = [ .print, .addToReadingList ]

            switch (UI_USER_INTERFACE_IDIOM()) {
            case .pad:
                self.modalPresentationStyle = .popover
                if let ppc = activityVC.popoverPresentationController {
                    ppc.barButtonItem = self.navigationItem.rightBarButtonItem!
                }
            default: break
            }

            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
