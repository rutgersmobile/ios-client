//
//  ActionSheetDataSource.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/24/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ActionSheetDataSource<T> {
    typealias D = ActionSheetModel<T>
    let data: [D]
    let actionSheet: UIActionSheet

    static func from(titles: [String]) -> ActionSheetDataSource<String> {
        let data: [ActionSheetModel<String>] = titles.map {
            ActionSheetModel(title: $0, datum: $0)
        }
        return ActionSheetDataSource<String>(data: data)
    }

    init(data: [D]) {
        let actionSheet = UIActionSheet()
        for datum in data {
            actionSheet.addButton(withTitle: datum.title)
        }
        actionSheet.cancelButtonIndex =
            actionSheet.addButton(withTitle: "Cancel")
        self.actionSheet = actionSheet
        self.data = data
    }

    public func modelSelected() -> Observable<T> {
        return actionSheet.rx.buttonClickedIndex.map { idx in
            if idx >= 0 && idx < self.data.count {
                return self.data[idx].datum
            } else {
                return nil
            }
        }.filterMap { $0 }
    }
}

struct ActionSheetModel<T> {
    let title: String
    let datum: T
}
