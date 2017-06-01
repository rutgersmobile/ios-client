//
//  RxUIActionSheetDelegateProxy.swift
//  Rutgers
//
//  Created by Matt Robinson on 3/23/17.
//  Copyright © 2017 Rutgers. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RxUIActionSheetDelegateProxy
    : DelegateProxy
    , UIActionSheetDelegate
    , DelegateProxyType
{
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let actionSheet = object as! UIActionSheet
        return actionSheet.delegate
    }

    static func setCurrentDelegate(
        _ delegate: AnyObject?,
        toObject object: AnyObject
    ) {
        let actionSheet = object as! UIActionSheet
        actionSheet.delegate = delegate as? UIActionSheetDelegate
    }
}

extension Reactive where Base: UIActionSheet {
    public var delegate: DelegateProxy {
        return RxUIActionSheetDelegateProxy.proxyForObject(base)
    }

    public var buttonClickedIndex: ControlEvent<Int> {
        let source: Observable<Int> = self.delegate.methodInvoked(
            #selector(UIActionSheetDelegate.actionSheet(_:clickedButtonAt:))
        ).map { params in
            return params[1] as! Int
        }
        return ControlEvent(events: source)
    }
}
